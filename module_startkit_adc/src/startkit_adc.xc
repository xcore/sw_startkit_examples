#include <xs1.h>
#include <stdio.h>
#include <platform.h>
#include <xscope.h>
#include <print.h>
#include "startkit_adc.h"

out port adc_sample = ADC_TRIG_PORT;            //Trigger port for ADC - defined in STARTKIT.xn

#pragma select handler                          //Special function to allow select on inuint primative
void get_adc_data(chanend c_adc, unsigned &data){
    data = inuint(c_adc);                       //Get ADC packet one (2 x 16b samps)
}

static void init_adc_network(void) {
     unsigned data;
     read_node_config_reg(tile[0], 0x87, data);
     if (data == 0) {                                       //If link not setup already then...
         write_node_config_reg(tile[0], 0x85, 0xC0002004);  //open
         write_node_config_reg(tile[0], 0x85, 0xC1002004);  //and say hello
         write_sswitch_reg_no_ack(0x8000, 0x86, 0xC1002004);//say hello
         write_sswitch_reg_no_ack(0x8000, 0xC, 0x11111111); //Setup link directions
     }
}

static void init_adc_periph(chanend c) { //Configures the ADC peripheral for this application
     unsigned data[1], time;

     data[0] = 0x0;                               //Switch ADC off initially
     write_periph_32(adc_tile, 2, 0x20, 1, data);
     asm("add %0,%1,0":"=r"(data[0]):"r"(c));     //Get node/channel ID. Used for enable (below)
     data[0] &= 0xffffff00;                       //Mask off all but node/channel ID
     data[0] |= 0x1;                              //Set enable bit

     write_periph_32(adc_tile, 2, 0x0, 1, data);  //Enable Ch 0
     write_periph_32(adc_tile, 2, 0x4, 1, data);  //Enable Ch 1
     write_periph_32(adc_tile, 2, 0x8, 1, data);  //Enable Ch 2
     write_periph_32(adc_tile, 2, 0xc, 1, data);  //Enable Ch 3


     data[0] = 0x10401;                         //16 bits per sample, 4 samples per 32b packet, calibrate off, ADC on
     write_periph_32(adc_tile, 2, 0x20, 1, data);

     time = 0;
     adc_sample <: 0 @ time;       //Ensure trigger startes low. Grab timestamp into time

     for (int i = 0; i < 6; i++) { //Do initial triggers. Do 6 calibrate and initialise
       time += ADC_TRIG_DELAY;
       adc_sample @ time <: 1;     //Rising edge triggers ADC
       time += ADC_TRIG_DELAY;
       adc_sample @ time <: 0;     //Falling edge
     }
     time += ADC_TRIG_DELAY;
     adc_sample @ time <: 0;       //Final delay to ensure 0 is asserted for minimum period
}

[[combinable]]
void adc_task(server startkit_adc_if i_adc, chanend c_adc, int trigger_period){
  unsigned adc_state = 0;                 //State machine. 0 = idle, 1-8 = generating triggers, 9 = rx data
  unsigned adc_samps[2] = {0, 0};         //The samples (2 lots of 16 bits packed into to unsigned ints)
  int trig_pulse_time;                    //Used to time individual edges for trigger
  int trig_period_time;                   //Used to time periodic triggers
  timer t_trig_state;                     //Timer for ADC trigger I/O pulse gen
  timer t_trig_periodic;                  //Timer for periodic ADC trigger

  init_adc_network();                     //Ensure it works in flash as well as run/debug
  init_adc_periph(c_adc);                 //Setup the ADC

  trigger_period *= 100;                  //Comvert to microseconds

  if(trigger_period){
      t_trig_periodic :> trig_period_time;//Get current time. Will cause immediate trigger
  }

  while(1){
    select{
      case i_adc.trigger():               //Start ADC state machine via interface method call
        if (adc_state == 0){
          adc_sample <: 1;                //Send first rising edge to trigger ADC
          t_trig_state :> trig_pulse_time;//Grab current time
          trig_pulse_time += ADC_TRIG_DELAY;//Setup trigger time for next edge (falling)
          adc_state = 1;                  //Start trigger state machine
        }
        else ;                            //Do nothing - trig/aquisition already in progress
      break;

                                          //Start ADC state machine via timer, if enabled
      case trigger_period => t_trig_periodic when timerafter(trig_period_time) :> void:
        trig_period_time += trigger_period;//Setup next trigger event
        if (adc_state == 0){              //Start tigger state machine
          adc_sample <: 1;                //Send first rising edge to trigger ADC
          t_trig_state :> trig_pulse_time;//Grab current time
          trig_pulse_time += ADC_TRIG_DELAY;//Setup trigger time for next edge (falling)
          adc_state = 1;                  //Start trigger state machine
        }
        else ;                            //Do nothing - trig/aquisition already in progress
        break;

                                          //I/O edge generation phase of ADC state machine
      case (adc_state > 0 && adc_state < 9) => t_trig_state when timerafter(trig_pulse_time) :> void:
        adc_state++;
        if (adc_state == 9){              //Assert low when finished
          adc_sample <: 0;
          break;
        }
        if (adc_state & 0b0001) adc_sample <: 1;  //Do rising edge if even count
        else adc_sample <: 0;                     //Do falling if odd
        trig_pulse_time += ADC_TRIG_DELAY;        //Setup next edge time trigger
        break;

                                            //Get ADC samples from packet phase of ADC state machine
      case (adc_state == 9) => get_adc_data(c_adc, adc_samps[0]): //Get ADC packet (2 x 16b samps)
        get_adc_data(c_adc, adc_samps[1]);  //Get second packet
        chkct(c_adc, 1);                    //Wait for end token on ADC channel
        i_adc.complete();                   //Signal to client we're ready
        adc_state = 0;                      //Reset tigger state machine
        break;

                                            //Provide ADC samples to client method
      case i_adc.read(unsigned short adc_val[4]) -> int ret_val:
        adc_val[0] = adc_samps[0] >> 16;    //Ch 0 is 2 MSB
        adc_val[1] = adc_samps[0] & 0xffff; //Ch 1 is 2 LSB
        adc_val[2] = adc_samps[1] >> 16;    //Ch 2 is 2 MSB
        adc_val[3] = adc_samps[1] & 0xffff; //Ch 3 is 2 LSB
        ret_val = adc_state ? 0 : 1;        //Return zero if mid conversion, 1 if complete
      break;

    }//select
  }//while 1
}
