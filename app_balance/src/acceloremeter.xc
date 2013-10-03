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

#include <xs1.h>
#include <print.h>
#include <xscope.h>

r_i2c i2c = { XS1_PORT_1K, XS1_PORT_1I, 250 };

/** Function that reads out an acceleration; out of two registers and makes
 * it two's complements.
 */
int read_acceleration(int reg) {
    int r;
    unsigned char data[1];
    i2c_master_read_reg(0x1D, reg, data, 1, i2c);
    r = data[0] << 2;
    i2c_master_read_reg(0x1D, reg+1, data, 1, i2c);
    r |= (data[0] >> 6);
    if(r & 0x200) {
        r -= 1023;
    }
    return r;
}

/** Function that reads acceleration in 3 dimensions and outputs them onto a channel end
 */
void accelerometer(chanend c) {
    unsigned char data[1];
    int x, y, z;
    i2c_master_init(i2c);

    data[0] = 0x01;                                 // Set up dividers
    i2c_master_write_reg(0x1D, 0x0E, data, 1, i2c);
    data[0] = 0x01;
    i2c_master_write_reg(0x1D, 0x2A, data, 1, i2c);
    while(1) {
        do {
            i2c_master_read_reg(0x1D, 0x00, data, 1, i2c);
        } while(!(data[0] & 0x08));
        x = read_acceleration(1);
        y = read_acceleration(3);
        z = read_acceleration(5);
        c <: x;
        c <: y;
        c <: z;
    }
}
