#include "startkit_gpio.h"
#include <print.h>
#include <xs1.h>
#include "slider.h"
#include "capsens.h"
/*
 * the patterns for each bit are:
 *   0x80000 0x40000 0x20000
 *   0x01000 0x00800 0x00400
 *   0x00200 0x00100 0x00080
 *
 * As the leds go to 3V3, 0x00000 drives all 9 leds on, and 0xE1F80 drives
 * all nine leds off.
 */

static const unsigned int map[3][3] = {
  {0x80000, 0x40000, 0x20000},
  {0x01000, 0x00800, 0x00400},
  {0x00200, 0x00100, 0x00080}
};


// This function is distributable i.e. can be spread amongst other cores
[[distributable]]
void startkit_led_driver(server startkit_led_if c_led[n], unsigned n, port p32)
{
  // This variable stores the current output value to the leds
  unsigned data = 0xffffffff;
  p32 <: data;
  while (1) {
    select {
    case c_led[int i].set(unsigned row, unsigned col, unsigned val):
      // We are setting the leds in a discrete (on/off) way.
      // Just look at the top bit to determine if the value is > LED_ON/2
      val >>= 31;
      // Clear the bit for this led
      data &= ~map[row][col];
      // Set the bit for this led (depending on the value)
      data |= val ? 0 : map[row][col];
      // Output the new data value onto the port for all leds
      p32 <: data;
      break;
    case c_led[int i].set_multiple(unsigned mask, unsigned val):
      val >>= 31;
      // Iterate through all leds from right to left, bottom to top
      // shifting through thee mask from right to left
      for (int row = 2; row >= 0; row--) {
        for (int col = 2; col >= 0; col--) {
          // Depending on the mask and the value set the bit for this led
          data &= ~map[row][col];
          data |= (val & (mask & 1))  ? 0 : map[row][col];
          mask >>= 1;
        }
      }
      // Output the new data value onto the port for all leds
      p32 <: data;
      break;
    }
  }
}

// This function is combinable - it can share a core with other combinable
// tasks.
[[combinable]]
 void startkit_gpio_driver_aux(server startkit_led_if ?i_led,
                               server startkit_button_if ?i_button,
                               server slider_if ?i_slider_x,
                               server slider_if ?i_slider_y,
                               port p32,
                               client slider_query_if sx,
                               client slider_query_if sy)
 {
  unsigned button_val = BUTTON_DOWN;
  const int pwm_cycle = 100000;   // The period in 100Mhz timer ticks of the
                                  // pwm
  const int pwm_res = 100;        // The resolution of the pwm
  const int delay = pwm_cycle / pwm_res; // The period between updates
                                         // to the port output
  int count = 0; // The count that tracks where we are in the pwm cycle

  // This array stores the pwm levels for the leds
  int level[3][3] = {{0,0,0},{0,0,0},{0,0,0}};

  sliderstate xstate = IDLE, ystate = IDLE;
  int capsense_period = 500000;
  int capsense_time;
  timer tmr;
  int poll_x_or_y = 0;
  int time;   // This variable always stores the time of the next pwm event
  tmr :> time;
  capsense_time = time + capsense_period;
  int button_debounce_max_count = 50;
  int button_debounce_count = button_debounce_max_count;
  while (1) {
    select {
    // A periodic event that occurs event 'delay' ticks.
    case tmr when timerafter(time) :> void:
      count++;
      if (count == pwm_res) {
        unsigned data;
        unsigned pt;
        p32 :> data;
        tmr :> pt;
        tmr when timerafter(pt + 10) :> void;
        p32 :> data;
        if (!isnull(i_button)) {
          if (button_debounce_count >= button_debounce_max_count) {
            // At the end of each pwm cycle, sample the button
            // by turning the output port into an input port
            // Look at the bottom bit of the port
            button_val_t new_val = (data & 1) ? BUTTON_UP : BUTTON_DOWN;
            // If the value has changed, call the changed() notification
            // to tell the client
            if (new_val != button_val) {
              i_button.changed();
              button_val = new_val;
              button_debounce_count = 0;
            }
          }
          else {
            button_debounce_count++;
          }
        }
        if (poll_x_or_y) {
          if (!isnull(i_slider_x)) {
            sliderstate new_state = sx.filter();
            if (new_state != xstate) {
              xstate = new_state;
              i_slider_x.changed_state();
            }
          }
        } else {
          if (!isnull(i_slider_y)) {
            sliderstate new_state = sy.filter();
            if (new_state != ystate) {
              ystate = new_state;
              i_slider_y.changed_state();
            }
          }
        }
        poll_x_or_y = ~poll_x_or_y;
        capsense_time += capsense_period;
        count = 0;
      }
      // Create the output for this phase in the pwm
      unsigned data = 0xffffffff;
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          // If the led level is higher than the current
          // phase of the pwm then clear that bit (i.e. drive the led)
          if (pwm_res - count < level[row][col]) {
            data &= ~map[row][col];
          }
        }
      }
      // Output the combined led data
      p32 <: data;
      // Set up the next event
      tmr :> time;
      time += delay;
      break;

    // Case handling a request for the button value
    case !isnull(i_button) => i_button.get_value() -> button_val_t res:
      res = button_val;
      break;

    // Case handling a client request to set an output level
    case !isnull(i_led) => i_led.set(unsigned row, unsigned col,
                                     unsigned val):
      // Scale the level to the output resolution of the pwm
      level[row][col] = val / (LED_ON / pwm_res);
      break;

    // Case handling a client request to set multiple output levels
    case !isnull(i_led) => i_led.set_multiple(unsigned mask,
                                              unsigned val):
      // Scale the level to the output resolution of the pwm
      val = val / (LED_ON / pwm_res);

      // Iterate though the led array setting the level depending on the mask
      for (int row = 2; row >= 0; row--) {
        for (int col = 2; col >= 0; col--) {
          level[row][col] = (mask & 1) ? val : 0;
          mask >>= 1;
        }
      }
      break;
    case !isnull(i_slider_x) => i_slider_x.get_coord() -> int coord:
      coord = sx.get_coord();
      break;
    case !isnull(i_slider_x) => i_slider_x.get_slider_state() -> sliderstate ret:
      ret = xstate;
      break;
    case !isnull(i_slider_y) => i_slider_y.get_coord() -> int coord:
      coord = sy.get_coord();
      break;
    case !isnull(i_slider_y) => i_slider_y.get_slider_state() -> sliderstate ret:
      ret = ystate;
      break;

    }
  }
}


[[combinable]]
void startkit_gpio_driver(server startkit_led_if ?i_led,
                          server startkit_button_if ?i_button,
                          server slider_if ?i_slider_x,
                          server slider_if ?i_slider_y,
                          startkit_gpio_ports &ps)
{
  slider_query_if sx;
  slider_query_if sy;
  absolute_slider_if ax, ay;
  capsenseInitClock(ps.clk);
  [[combine]]
  par {
    startkit_gpio_driver_aux(i_led, i_button, i_slider_x, i_slider_y,
                             ps.p32, sx, sy);
    slider(sx, ax);
    slider(sy, ay);
    absolute_slider(ax, ps.capx, ps.clk, 4, 80, 100, 50);
    absolute_slider(ay, ps.capy, ps.clk, 4, 80, 100, 50);
  }
}


