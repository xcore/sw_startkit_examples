// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 * acelloslice.xc
 *
 *  Created on: 1 Oct 2013
 *      Author: edward
 */

#include "i2c.h"
#include "ball.h"
#include <xs1.h>
#include <print.h>
#include <xscope.h>
#include "debug_print.h"

/** Function that reads out an acceleration; out of two registers and makes
 * it two's complements.
 */
int read_acceleration(client i2c_master_if i2c, int reg) {
  int r;
  r = i2c.read_reg(0x1D, reg) << 2;
  r |= i2c.read_reg(0x1D, reg + 1) >> 6;
  if(r & 0x200) {
    r -= 1023;
  }
  return r;
}

/** Function that reads acceleration in 3 dimensions and outputs them onto a channel end
 */
void accelerometer(client ball_if ball, client i2c_master_if i2c) {
  // Set up dividers
  i2c.write_reg(0x1D, 0x0E, 0x01);
  i2c.write_reg(0x1D, 0x2A, 0x01);
  while(1) {
    unsigned char data;
    do {
      data = i2c.read_reg(0x1D, 0x00);
    } while (!data & 0x08);
    int x, y, z;
    x = read_acceleration(i2c, 1);
    y = read_acceleration(i2c, 3);
    z = read_acceleration(i2c, 5);

    // Once the position is read use it to set the ball position
    ball.new_position(x, y, z);
  }
}
