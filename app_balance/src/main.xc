// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <stdio.h>

extern void accelerometer(chanend c);

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

/* This section of code filters and averages values */

#define H 32

struct history {
    int values[H];     // A filter that holds 32 old values
    int w;             // index of the oldest value in the array
    int av;            // Running average of all values
};

/** This function initialises the running average. It sets all old values
 * to zero, the running average to 0 (the sum of all values), and it sets
 * the 2 index to some legal value (0).
 */
void filter_init(struct history &h) {
    h.w = 0;
    h.av = 0;
    for(int i = 0; i < H; i++) {
        h.values[i] = 0;
    }
}

/** This function adds a sample to the history, and computes a new average.
 * The running average is adapted by subtracting the oldest value, and
 * adding in the new value. The new value is then stored, and the sum is
 * returned
 */
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

#define FULL_SCALE  1024

/** This function takes a number and splits it into a sign (-1, 1) and a
 * value between 0 and FULL_SCALE to identify the fraction. The input value
 * is in the range -10..10, is then filtered (which produces a sum of H
 * values, hence a factor H higher), the filtered value is hence divided by
 * 10 * H after being divided by the full scale.
 */
void split(int value, struct history &h, int &sign, int &partial) {
    int scale = 10 * H;
    int filtered = filter(h, value);
    if (filtered < 0) {
        sign = -1;
        partial = (-filtered)*FULL_SCALE/scale;
    } else {
        sign = 1;
        partial = (filtered)*FULL_SCALE/scale;
    }
    if (partial > FULL_SCALE) {
        partial = FULL_SCALE;
    }
}

void ball(chanend c) {
    struct history zvalues, xvalues;
    filter_init(xvalues);
    filter_init(zvalues);
    int x, y, z;
    timer tmr;           // Create a timer to time transistions
    int now;             // A variable to hold the current time
    int delay = 100000;  // 1 ms 
    int sx = 1, sy = 1;  // sign: -1 or 1, ball is either left or right of centre
    int px = 0, py = 0;  // partial: 0..FULL_SCALE: 0 means centre, FULL_SCALE means edge
    tmr :> now;          // Initialise current time
    while(1) {
        select {
        case c :> x:     // If the accelerometer has a new X/Y/Z value
            c :> y;
            c :> z;
            split(z, zvalues, sy, py);  // split them into a sign and partial value
            split(x, xvalues, sx, px);  // for both X and Y
            break;
        default:                        // otherwise continue to modulate the LEDs
            break;
        }
        p32 <: leds[1][1];              // Drive center led for 1-px * 1-py fraction of time
        now += delay * (FULL_SCALE-px)/FULL_SCALE * (FULL_SCALE-py)/FULL_SCALE;
        tmr when timerafter(now) :> void;
        p32 <: leds[1][1+sy];           // Drive led 1 down/up for 1-px * py fraction
        now += delay * (FULL_SCALE-px)/FULL_SCALE * py/FULL_SCALE;
        tmr when timerafter(now) :> void;
        p32 <: leds[1+sx][1];           // Drive led 1 right/keft for px * 1-py fraction
        now += delay * px/FULL_SCALE * (FULL_SCALE-py)/FULL_SCALE;
        tmr when timerafter(now) :> void;
        p32 <: leds[1+sx][1+sy];        // Drive led on diagoanl for px * py fraction
        now += delay * px/FULL_SCALE * py/FULL_SCALE;
        tmr when timerafter(now) :> void;
    }
}

int main(void) {
    chan c;
    par {
        ball(c);
        accelerometer(c);
    }
}
