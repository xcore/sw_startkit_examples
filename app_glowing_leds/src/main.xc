#include <xs1.h>
#include <platform.h>
#include <print.h>
#include "startkit_gpio.h"

// This function is combinable - it can share a core with other tasks
[[combinable]]
static void glow(client startkit_led_if leds, client startkit_button_if button)
{
  timer tmr;
  int period = 1 * 1000 * 1000 * 100; // period from off to on = 1s;
  unsigned res = 30;                  // increment the brightness in this
                                      // number of steps
  int delay = period / res;           // how long to wait between updates
  int level = 0;                      // the level of led brightness
  unsigned pattern = 0b010101010;     // the pattern output to the leds,
                                      // alternates between an X and its
                                      // inverse
  int timestamp;
  int dir = 1;

  // Take the initial timestamp of the 100Mhz timer
  tmr :> timestamp;
  while (1) {
    select {
    // After 'delay' ticks do this
    case tmr when timerafter(timestamp + delay) :> void:
      // increase the output level of the led
      level += dir * (LED_ON / res);
      if (level > LED_ON) {
        level = LED_ON;
        dir = -1;
      }
      if (level < 0) {
        level = 0;
        dir = 1;
      }
      // set the leds
      leds.set_multiple(pattern, level);
      // update the timestamp for the next timeout
      timestamp += delay;
      break;

    case button.changed():
      if (button.get_value() == BUTTON_DOWN) {
        // If the button has been pressed down then
        // invert the pattern
        pattern = ~pattern;
      }
      break;
    }
  }
}


startkit_gpio_ports gpio_ports =
  {XS1_PORT_32A, XS1_PORT_4A, XS1_PORT_4B, XS1_CLKBLK_1};

// 'main' sets up the system, consisting of two tasks - one to drive
// the i/o and one to run the application that communicates with that
// driver.
int main()
{
  // These interface connections link the application to the
  // gpio driver.
  startkit_led_if i_led;
  startkit_button_if i_button;
  par {
    on tile[0].core[0]: startkit_gpio_driver(i_led, i_button,
                                             null, null,
                                             gpio_ports);
    on tile[0].core[1]: glow(i_led, i_button);
  }
  return 0;
}
