#include <xs1.h>
#include <servo.h>
#include <print.h>
#include <stdio.h>

void servo_task(server interface servo_if i_servo, out port p_servo,
        static const unsigned port_width, static const unsigned initial_position){

    unsigned transition_table[port_width];      //length of each servo channel in 10ns ticks
    unsigned transition_trigger[port_width];    //Variable used to trigger each channel's timer
    timer t_transition[port_width];             //Timers used for setting the falling edge transition

    unsigned cycle_end_trigger;                 //Variable for triggering end of PWM frame
    timer t_cycle_end;                          //Timer used for triggering end of PWM frame
    unsigned port_shadow = ~0;                  //Port shadow, initialised to all high for beginning of cycle

    t_cycle_end :> cycle_end_trigger;           //Grab time for start of frame
    cycle_end_trigger += SERVO_PERIOD;          //Set trigger for end of frame

    p_servo <: port_shadow;                     //Set the initial value

    for(int i=0; i<port_width; i++){            //Initialise periods, and time triggers
        transition_table[i] = initial_position;
        t_transition[i] :> transition_trigger[i];
        transition_trigger[i] += transition_table[i];
    }


    while(1){
        select{
            //Cases for individual transitions. This expands out to <port_width> individual cases - one for each channel
            //Note that edges that are close together may be delayed by ~750ns per channel for a 4b port, or 1100ns per channel for 8b port.
            //This is because each timer case has to be executed sequentially, so there may be queue
            //this translates to worst case error of about 0.14% error for 4 outputs on 4b port and
            //about 0.48% error for 8b port with 8 outputs
            case (int i=0; i<port_width; i++) t_transition[i] when timerafter(transition_trigger[i]) :> void:
            port_shadow &= ~(0x1 << i);         //Clear the relevant bit (set to 0)
            p_servo <: port_shadow;             //Put it on the port
            transition_trigger[i] += SERVO_PERIOD;//Set up tigger far out into next cycle
            break;

            //Case that handles end of frame. Resets all channels
            case t_cycle_end when timerafter(cycle_end_trigger) :> void:
            port_shadow = ~0;                   //Set all outputs to 1
            p_servo <: port_shadow;

            for(int i=0; i<port_width; i++){    //Set new tigger time for each channel
                t_transition[i] :> transition_trigger[i];
                transition_trigger[i] += transition_table[i];
            }
            cycle_end_trigger += SERVO_PERIOD;  //Set up next cycle end event
            break;

            //Upate case. Note that this buffers and so will noy apply until end of frame/next frame
            case i_servo.set_pos(unsigned channel, int position):
            if (position > (int)SERVO_MAX_POS) {//Clip to max
                position = SERVO_MAX_POS;
            }
            if (position < (int)SERVO_MIN_POS) {//Clip to min
                position = SERVO_MIN_POS;
            }
            transition_table[channel] = position;//Update new transition buffer
            break;

        }
    }
}
