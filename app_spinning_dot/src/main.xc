// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>

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

#define MIDDLE 0x00800

#define MODES    8

int leds[MODES] = {
    0xA1F80,
    0xC1F80,
    0xE1B80,
    0xE1F00,
    0xE1E80,
    0xE1D80,
    0xE0F80,
    0x71F80,
};

/* This the port where the leds reside */
port p32 = XS1_PORT_32A;

int main(void) {
    timer tmr;               // Create a timer to time transistions
    int now;                 // A variable to hold the current time
    int pwm_period = 100000; // 1 ms PWM period, 1 kHz clock
    int delay = 1000/MODES;  // One full circle in 1000 PWM periods = 1 sec
    int led_counter = 0;     // A counter to count through the leds array
    int middle = 0;          // state of the middle led. Off initially

    tmr :> now;              // Get the current time, this is maintained in now
    while(1) {
        int new_led_counter = led_counter+1;      // Next pattern
        int new_middle = middle;                  // and next middle LED status
        if (new_led_counter == MODES) {           // If we have gone around all patterns
            new_led_counter = 0;                  // Go back to the first pattern
            new_middle = new_middle ^ MIDDLE;     // and toggle the middle led.
        }                                         // To PWM we repeatedly push two LED
        for(int i = 0; i < delay; i ++) {         // patterns, for a total of 1 ms
            p32 <: leds[new_led_counter] ^ new_middle;           // new pattern
            tmr when timerafter(now+pwm_period*i/delay) :> void; // Wait for i/delay %
            p32 <: leds[led_counter] ^ middle;                   // old pattern
            now += pwm_period;                                   // Wait for rest
            tmr when timerafter(now) :> void;                    // increase i for gentle
        }                                                        // change to brightness
        led_counter = new_led_counter;            // Move on to the next pattern and
        middle = new_middle;                      // the next middle LED status
    }
    return 0;
}
