#include <xs1.h>
#include <timer.h>

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
    int delay = 50;      // initial delay 50 ms
    int led_counter = 0; // A counter to count through the leds array
    while(1) {
        delay_milliseconds(delay);        // Wait
        delay += 1;                       // Gradually increase the delay
        p32 <: leds[led_counter];         // Drive the next led pattern
        led_counter++;                    // Pick the next pattern
        if (led_counter == MODES) {       // If we are at the last pattern
            led_counter = 0;              // then wrap around.
        }
    }
    return 0;
}
