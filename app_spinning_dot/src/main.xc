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

#define MODES    8

#define MIDDLE 0x00800

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
    
    tmr :> now;
    while(1) {
        int new_led_counter = led_counter+1;
        int new_middle = middle;
        if (new_led_counter == MODES) {
            new_led_counter = 0;
            new_middle = new_middle ^ MIDDLE;  // toggle middle led.
        }
        for(int i = 0; i < delay; i ++) {
            p32 <: leds[new_led_counter] ^ new_middle;
            tmr when timerafter(now+pwm_period*i/delay) :> void;
            p32 <: leds[led_counter] ^ middle;
            now += pwm_period;
            tmr when timerafter(now) :> void;
        }
        led_counter = new_led_counter;
        middle = new_middle;
    }
    return 0;
}
