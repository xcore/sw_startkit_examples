#include <xs1.h>
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

#define MODES 4

int leds[MODES] = {
    0xE0380,
    0x61700,
    0xA1680,
    0xC1580
};

/* This the port where the leds reside */
port p32 = XS1_PORT_32A;

int main(void) {
    timer tmr;           // Create a timer to time transistions
    int now;             // A variable to hold the current time
    int delay = 5000000; // initial delay 50 ms (in 100 MHz ticks)
    int led_counter = 0; // A counter to count through the leds array
    tmr :> now;          // Get the current time, used for delaying the spinning bar
    while(1) {
        now += delay;                     // The time that we want to wait for
        delay += 1 * 1000 * 100;          // gradually increase the delay
        tmr when timerafter(now) :> void; // Wait
        p32 <: leds[led_counter];         // Drive the next led pattern
        led_counter++;                    // Pick the next pattern
        if (led_counter == MODES) {       // If we are at the last pattern
            led_counter = 0;              // then wrap around.
        }
    }
    return 0;
}
