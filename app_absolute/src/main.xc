#include <xs1.h>
#include <stdio.h>
#include <xscope.h>

/*
 * the patterns for each bit are:
 *   0x80000 0x40000 0x20000 
 *   0x01000 0x00800 0x00400 
 *   0x00200 0x00100 0x00080 
 *
 * As the leds go to 3V3, 0x00000 drives all 9 leds on, and 0xE1F80 drives
 * all nine leds off.
 * The four patterns below drive a dash, backslash, pipe, and slash.
 */

int leds[3][3] = {
    { 0x71F80, 0xA1F80, 0xC1F80 },
    { 0xE0F80, 0xE1780, 0xE1B80 },
    { 0xE1D80, 0xE1E80, 0xE1F00 },
};

/* This the port where the leds reside */
port p32 = XS1_PORT_32A;

#define H 4

struct history {
    int values[H];
    int w;
    int av;
};

void filter_init(struct history &h) {
    h.w = 0;
    h.av = 0;
    for(int i = 0; i < H; i++) {
        h.values[i] = 0;
    }
}

int filter(struct history &h, int value) {
    h.av += value;
    h.av -= h.values[h.w];
    h.values[h.w] = value;
    h.w++;
    if (h.w == H) {
        h.w = 0;
    }
    return h.av;
}

void ball(chanend cx, chanend cy) {
    struct history zvalues, xvalues;
    filter_init(xvalues);
    filter_init(zvalues);
    int x, z;
    timer tmr;           // Create a timer to time transistions
    int now;             // A variable to hold the current time
    int delay = 100000;  // 1 ms 
    int sx = 1, sy = 1;
    int px = 1024, py = 0;
    tmr :> now;
    while(1) {
        int scale = 1000 * H;
        select {
        case cy :> z:
          //  printf("%d %d %d\n", x, y, z);
            int filteredz = filter(zvalues, z-1500);
            if (filteredz < 0) {
                sy = -1;
                py = (-filteredz)*1024/scale;
            } else {
                sy = 1;
                py = (filteredz)*1024/scale;
            }
            if (py > 1024) py = 1024;
            break;
        case cx :> x:
            int filteredx = filter(xvalues, x-1500);
            if (filteredx < 0) {
                sx = -1;
                px = (-filteredx)*1024/scale;
            } else {
                sx = 1;
                px = (filteredx)*1024/scale;
            }
            if (px > 1024) px = 1024;
            break;
        default:
            break;
        }
        p32 <: leds[1][1];
        tmr when timerafter(now+=delay*(1024-px)/1024*(1024-py)/1024) :> void;
        p32 <: leds[1][1+sy];
        tmr when timerafter(now+=delay*(1024-px)/1024*py/1024) :> void;
        p32 <: leds[1+sx][1];
        tmr when timerafter(now+=delay*px/1024*(1024-py)/1024) :> void;
        p32 <: leds[1+sx][1+sy];
        tmr when timerafter(now+=delay*px/1024*py/1024) :> void;
    }
}


#include <xs1.h>
#include <stdio.h>
#include "slider.h"

clock clkx = XS1_CLKBLK_1;
clock clky = XS1_CLKBLK_2;
port capx = XS1_PORT_4A;
port capy = XS1_PORT_4B;

void user_input(chanend c, port cap, clock clk) {
    absolute_pos x;
    absolute_slider_init(x, cap, clk, 4, 400, 200);
    while(1) {
        int rx = absolute_slider(x, cap);
        if (rx != 0) {
            c <: rx;
        }
    }
}

void user_input_seq(chanend cx, chanend cy) {
    absolute_pos x, y;
    absolute_slider_init(x, capx, clkx, 4, 1000, 150);
    absolute_slider_init(y, capy, clky, 4, 1000, 150);
    while(1) {
        int rx = absolute_slider(x, capx);
        int ry = absolute_slider(y, capy);
        if (rx != 0) {
            cx <: rx;
        }
        if (ry != 0) {
            cy <: ry;
        }
    }
}

void xscope_user_init(void) {
    xscope_config_io(XSCOPE_IO_BASIC);
}


int main(void) {
    chan x, y;
    par {
        ball(x, y);
        user_input_seq(x, y);
//        user_input(x, capx, clkx);
//        user_input(y, capy, clky);
    }
}
