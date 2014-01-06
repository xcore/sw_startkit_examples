/*
 * lfo.xc
 *
 * Generates a 5 - 40 Hz Triangle waveform and sends it over a channel
 * Amplitude and frequency are controlled via the sliders on startKIT
 *
 * Every millisecond, it sends a new sample across
 *
 *  Created on: Oct 17, 2013
 *      Author: Ed
 */

#include "lfo.h"
#include <print.h>

#define MILLISECOND 100000
#define SECOND 100000000
#define FSD 0x7fffffff

#define SLIDER_MIN 1000
#define SLIDER_MAX 2000

#define LFO_MIN 5
#define LFO_MAX 40

void lfo(chanend c_lfo, client slider_if i_slider_x, client slider_if i_slider_y)
{
	int gain = FSD, dir = 1, time;
	int hertz = 30;
	int depth = 0; //0 = no effect, FSD = max depth
	int slider_pos_x, slider_pos_y;
	int step = (FSD/((SECOND/MILLISECOND) / (2 * hertz)));
	timer tmr;
	tmr :> time;

	while(1){

		time += MILLISECOND;
		select{
			case tmr when timerafter(time) :> time: //Time for a new sample to be generated
				if(dir==1) gain += step;            //Rising phase of triangle
				else gain -= step;                  //Falling phase of triangle
				if (gain >= (FSD-step)) dir = -1;
				if (gain <= step) dir = 1;
				//c_lfo <: gain;
				c_lfo <: FSD - (int) (((long long)depth * (long long)gain) >> 31);
				break;

			case i_slider_y.changed_state():            //CHange frequency (ie. step size)
				slider_pos_y = i_slider_y.get_coord();
				i_slider_y.get_slider_state(); 			//necessary to clear notification
				if ((slider_pos_y > SLIDER_MIN) && (slider_pos_y < SLIDER_MAX)){
					hertz = LFO_MIN + (((LFO_MAX-LFO_MIN) * (slider_pos_y-SLIDER_MIN)) / (SLIDER_MAX-SLIDER_MIN));
					printint(hertz);
					printstrln(" hertz");
					step = (FSD/((SECOND/MILLISECOND) / (2 * hertz)));
				}
				break;

			case i_slider_x.changed_state():            //CHange modulation depth (ie. amplitude)
				slider_pos_x = i_slider_x.get_coord();
				i_slider_x.get_slider_state(); 			//necessary to clear notification
				if ((slider_pos_x > SLIDER_MIN) && (slider_pos_x < SLIDER_MAX)){
					depth = ((FSD / (SLIDER_MAX-SLIDER_MIN)) * (slider_pos_x-SLIDER_MIN));
				}
				if ((slider_pos_x < SLIDER_MIN) && (slider_pos_x != 0)) depth = FSD;
				if (slider_pos_x > SLIDER_MAX) depth = 0;
				printhex(depth);
				printstrln(" depth");
				break;
		}
	}
}
