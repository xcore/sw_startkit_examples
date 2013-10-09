// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "user_input.h"

#include <xs1.h>
#include <stdio.h>
#include "slider.h"

clock clkx = XS1_CLKBLK_1;
clock clky = XS1_CLKBLK_2;
port capx = XS1_PORT_4A;
port capy = XS1_PORT_4B;

void user_input(chanend to_output) {
    slider x, y;
    slider_init(x, capx, clkx, 4, 75, 40);
    slider_init(y, capy, clky, 4, 75, 40);
    while(1) {
        to_output :> int _;
        int rx = slider_filter(x, capx);
        int ry = slider_filter(y, capy);
        to_output <: rx == LEFTING ? 1 : rx == RIGHTING ? -1 : 0;
        to_output <: ry == LEFTING ? 1 : ry == RIGHTING ? -1 : 0;
    }
}
