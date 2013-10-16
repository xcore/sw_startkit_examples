#include <xs1.h>
#include <stdio.h>
#include <xscope.h>
#include "startkit_gpio.h"
#include <stdlib.h>
#include <platform.h>
#include <print.h>
#include <xscope.h>

typedef interface ball_if {
  void  new_position(int x, int y, int z);
} ball_if;


#define HISTORY_LEN 32

struct history {
  int values[HISTORY_LEN];     // A filter that holds 32 old values
  int w;             // index of the oldest value in the array
  int av;            // Running average of all struct
};

static int filter(struct history &h, int value) {
  h.av += value;
  h.av -= h.values[h.w];
  h.values[h.w] = value;
  h.w++;
  if (h.w == HISTORY_LEN) {
    h.w = 0;
  }
  return h.av/HISTORY_LEN;
}


// This is the range of the ball, i.e. the x,y,z coordinates will
// be between -BALL_RANGE and +BALL_RANGE
#define BALL_RANGE 700

[[combinable]]
void ball(server ball_if ball, client startkit_led_if leds) {
  struct history history_x, history_y, history_z;
  history_x.w = history_y.w = history_z.w = 0;
  history_x.av = history_y.av = history_z.av = 0;

  for(int i = 0; i < HISTORY_LEN; i++) {
    history_x.values[i] = history_y.values[i] = history_z.values[i] = 0;
  }

  while(1) {
    select {
    case ball.new_position(int new_x, int new_y, int new_z):
      int x, y, z;

      // Average the ball position over recent history
      x = filter(history_x, new_x);
      y = filter(history_y, new_y);
      z = filter(history_z, new_z);

      // Split the position into sign and magnitude
      // where the magnitude is between 0..LED_ON
      int sx = x < 0 ? -1 : 1;
      int sy = y < 0 ? -1 : 1;
      unsigned px, py;
      px = abs(x);
      px = px > BALL_RANGE ? BALL_RANGE : px;
      px = px * LED_ON/BALL_RANGE;

      py = abs(y);
      py = py > BALL_RANGE ? BALL_RANGE : py;
      py = py * LED_ON/BALL_RANGE;

      // Clear all led levels
      leds.set_multiple(0b111111111, 0);

      // Set the leds to show the ball position
      leds.set(1,      1,      (LED_ON - px) * (LED_ON - py) / LED_ON);
      leds.set(1,      1 + sy, (LED_ON - px) * py / LED_ON);
      leds.set(1 + sx, 1,      (px * (LED_ON - py)) / LED_ON);
      leds.set(1 + sx, 1 + sy, (px * py) / LED_ON);
      break;
    }
  }
}

[[combinable]]
void drive_ball(client slider_if i_slider_x,
                client slider_if i_slider_y,
                client ball_if   i_ball)
{
  timer tmr;
  int t;
  int poll_period = 100000;
  tmr :> t;
  while (1) {
    select {
    case tmr when timerafter(t + poll_period) :> t:
      int x = i_slider_x.get_coord();
      int y = i_slider_y.get_coord();
      // Capsense returns in range 0..3000, adjust so 0 is centre
      x -= 1500;
      y -= 1500;
      xscope_int(PROBEX, x);
      xscope_int(PROBEY, y);
      i_ball.new_position(x, y, 0);
      t += poll_period;
      break;
    }
  }
}

/* This the port where the leds reside */
startkit_gpio_ports gpio_ports =
  {XS1_PORT_32A, XS1_PORT_4A, XS1_PORT_4B, XS1_CLKBLK_1};

int main(void) {
  // These interfaces connect the tasks below together
  ball_if i_ball;
  startkit_led_if i_led;
  slider_if i_slider_x, i_slider_y;
  par {
    on tile[0].core[0]: drive_ball(i_slider_x, i_slider_y, i_ball);

    // This task reads the ball position from the accelerometer task
    // when there is a change and updates the LED values based on
    // that position
    on tile[0].core[1]: ball(i_ball, i_led);

    // The led driver task
    on tile[0].core[2]: startkit_gpio_driver(i_led, null,
                                             i_slider_x, i_slider_y,
                                             gpio_ports);
  }
  return 0;
}

