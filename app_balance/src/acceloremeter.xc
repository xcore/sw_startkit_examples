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

void accelerometer(chanend c) {
    unsigned char data[1];
    i2c_master_init(i2c);

    data[0] = 0x01;
    i2c_master_write_reg(0x1D, 0x0E, data, 1, i2c);
    data[0] = 0x01;
    i2c_master_write_reg(0x1D, 0x2A, data, 1, i2c);
    while(1) {
        int x, y, z;
        do {
            i2c_master_read_reg(0x1D, 0x00, data, 1, i2c);
        } while(!(data[0] & 0x08));
        i2c_master_read_reg(0x1D, 0x01, data, 1, i2c);
        x = data[0] << 2;
        i2c_master_read_reg(0x1D, 0x02, data, 1, i2c);
        x |= (data[0] >> 6);
        if(x & 0x200) {
            x -= 1023;
        }
        i2c_master_read_reg(0x1D, 0x03, data, 1, i2c);
        y = data[0] << 2;
        i2c_master_read_reg(0x1D, 0x04, data, 1, i2c);
        y |= (data[0] >> 6);
        if(y & 0x200) {
            y -= 1023;
        }
        i2c_master_read_reg(0x1D, 0x05, data, 1, i2c);
        z = data[0] << 2;
        i2c_master_read_reg(0x1D, 0x06, data, 1, i2c);
        z |= (data[0] >> 6);
        if(z & 0x200) {
            z -= 1023;
        }
        c <: x;
        c <: y;
        c <: z;
    }
}
