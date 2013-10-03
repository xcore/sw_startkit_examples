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
    slider_init(x, capx, clkx, 4, 1000, 150);
    slider_init(y, capy, clky, 4, 1000, 150);
    while(1) {
        int rx = slider_filter(x, capx);
        int ry = slider_filter(y, capy);
        if (rx == LEFTING || rx == RIGHTING ||
            ry == LEFTING || ry == RIGHTING) {
            to_output <: rx == LEFTING ? 1 : rx == RIGHTING ? -1 : 0;
            to_output <: ry == LEFTING ? 1 : ry == RIGHTING ? -1 : 0;
        }
    }
}
