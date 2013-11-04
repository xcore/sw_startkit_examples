// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <stdio.h>
#include <print.h>
#include <stdlib.h>
#include <xclib.h>
#include <platform.h>
#include "ball.h"
#include "i2c.h"
#include "startkit_gpio.h"

extern void accelerometer(client ball_if, r_i2c &i2c);

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
#define BALL_RANGE 50

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
      int sz = z < 0 ? -1 : 1;
      unsigned px, pz;

      px = abs(x);                             // take absolute value
      px = px > BALL_RANGE ? BALL_RANGE : px;  // clip at BALL_RANGE
      px = px * LED_ON/BALL_RANGE;             // scale to LED_ON

      pz = abs(z);
      pz = pz > BALL_RANGE ? BALL_RANGE : pz;
      pz = pz * LED_ON/BALL_RANGE;

      // Clear all led levels
      leds.set_multiple(0b111111111, 0);

      // Set the leds to show the ball position
      leds.set(1,      1,      (LED_ON - px) * (LED_ON - pz) / LED_ON);
      leds.set(1,      1 + sz, (LED_ON - px) * pz / LED_ON);
      leds.set(1 + sx, 1,      (px * (LED_ON - pz)) / LED_ON);
      leds.set(1 + sx, 1 + sz, (px * pz) / LED_ON);
      break;
    }
  }
}

/* The ports for the I2C interface to the accelerometer */
r_i2c i2c = { XS1_PORT_1K, XS1_PORT_1I, 250 };

/* The ports for leds/button/capsense */
startkit_gpio_ports gpio_ports =
  {XS1_PORT_32A, XS1_PORT_4A, XS1_PORT_4B, XS1_CLKBLK_1};

int main(void) {
  // These interfaces connect the tasks below together
  ball_if i_ball;
  startkit_led_if i_led;

  //  This is what the task diagram of the application is like:
  //
  //  i2c_master <-- accelerometer
  //                      |
  //                      V
  //                     ball  --> startkit_gpio_driver

  //  The ball and startkit_gpio_driver tasks run on the same logical
  //  core (using co-operative multitasking).
  //
  //  The i2c_master tasks is "distributable" and connected to the
  //  accelerometer task on the same tile so does not take up a logical
  //  core of its own.
  //
  //  Altogether the application takes up 2 logical cores.

  par {
    // This task periodically reads the position from the
    // accelerometer slice and feeds it to the ball task
    on tile[0]: accelerometer(i_ball, i2c);

    // This task reads the ball position from the accelerometer task
    // when there is a change and updates the LED values based on
    // that position
    on tile[0].core[0]: ball(i_ball, i_led);

    // The led driver task
    on tile[0].core[0]: startkit_gpio_driver(i_led, null, null, null,
                                             gpio_ports);
  }
  return 0;
}
