/*
 *  Created on: Dec 21, 2013
 *  Author: ShannonS
 *  E-mail: strutz.shannon@gmail.com
 *  Website: www.shannonstrutz.com
 *
 *  This code is offered under the MIT 2013 License
 */

#include <xs1.h>
#include <timer.h>

//As listed in the startKIT hardware manual, A1 is at port P32A19, pin X0D70
//What alll that means is that it is controlled by bit 19 in the 32-bit register

//Unfortunatly the hardware manual also has another error
//At the bottom of page 10, it states the LED pins are active high.
//When you run this program, you can clearly see that is wrong.

port p32 = XS1_PORT_32A;                //PORT 32A
int leds[10] = {
        0b01111111111111111111,         //LED A1
        0b10111111111111111111,         //LED B1
        0b11011111111111111111,         //LED C1
        0b11111110111111111111,         //LED A2
        0b11111111011111111111,         //LED B2
        0b11111111101111111111,         //LED C2
        0b11111111110111111111,         //LED A3
        0b11111111111011111111,         //LED B3
        0b11111111111101111111,         //LED C3
        0b11111111111111111111          //ALL OFF
};

port p1 = XS1_PORT_1A;
port p2 = XS1_PORT_1D;


int main(void){
    int delay = 500;
    while(1){
        for(int i = 0; i < 10; i++) {
            p32 <: leds[i];
            delay_milliseconds(delay);
        }
        p2 <: 1;
        delay_milliseconds(delay);
        p2 <: 0;
        p1 <: 1;
        delay_milliseconds(delay);
        p1 <: 0;
    }
    return 0;
}
