#include <platform.h>
#include <xs1.h>
#include <print.h>
#include "servo.h"

//Test program - ramps up and down all 4 channels
//See servo.h for API
//See servo.xc for implementation notes

#define PORT_WIDTH  4

on tile[0] : out port p_servo = XS1_PORT_4C; //D14, D20, D15, D21 on startKIT

void demo_servo (client interface servo_if i_servo) {
	timer tmr;
	unsigned int time, delay = 5000 * MICROSECOND;
	unsigned int i, j;
	
	tmr :> time;
	while (1) {
	    printstrln("Going up!");
		for (i = SERVO_MIN_POS; i < SERVO_MAX_POS; i+= 100) {
			for (j = 0; j < PORT_WIDTH; j++) {
				i_servo.set_pos(j, i);
			}
			tmr when timerafter(time + delay) :> time;
		}
		printstrln("Going down!");
		for (i = SERVO_MAX_POS; i > SERVO_MIN_POS; i-= 100) {
			tmr when timerafter(time + delay) :> time;
			for (j = 0; j < PORT_WIDTH; j++) {
				i_servo.set_pos(j, i);
			}
			tmr when timerafter(time + delay) :> time;
		}
	}
	return;
}

int main() {
    interface servo_if i_servo;
	par {
		on tile[0] : demo_servo(i_servo);
		on tile[0] : servo_task(i_servo, p_servo, PORT_WIDTH, SERVO_CENTRE_POS);
	}
	return 0;
}
