//adc.h for startKIT written by infiniteimprobability (xcore.com) June 2014
//
//Contains ADC task and ADC interface definition
//
//Aims to present the U8A/startKIT 12b ADC in an MCU-like manner by abstracting away
//channels, link setup (for startKIT FLASH boot) and trigger requirements.

//
//Enables all 4 channels and provides simple API for trigger, read and conversion complete event
//Practical fastest sample rate (to aquire all 4 channels) with all cores running flat-out
//is about 50us (to trigger, aquire, notify and read). So about 20KHz. Assumes core sharing with GPIO (slower)
//Ie. This module is built for comfort rather than speed. Give it it's own core and only run 4 cores total,
//and this number jumps to about 6us, or about 165KHz. Much closer to max theoritcal b/w of 1MHz/4 = 250KHz
//
//Runs in two modes (self tiggering periodically or trigger on request). Trigger function still callable
//in periodic mode and conversion finished notfication available in period mode if needed. Task is combinable
//so you can run it with other low speed tasks in the same logical core! (eg. GPIO)
//
//License = do what you like with it! But please post your projects on xcore.com for others to enjoy!

#ifndef ADC_H_
#define ADC_H_
#include <xs1.h>

#define ADC_TRIG_DELAY  40 //400ns minimum high/low time for ADC trigger signal
#define ADC_TRIG_PORT XS1_PORT_1A //ADC trigger pin. Defined by startKIT hardware


//ADC Methods
typedef interface adc {
//Initiates a trigger sequence. If trigger already in progress, this call is ignored
  [[guarded]] void trigger(void);
//Reads the 4 ADC values and places them in array of unsigned shorts passed.
//Value is 0 to 65520 unsigned. Actual ADC is 12b so bottom 4 bits always zero. Ie. left justified
//Optionally returns the ADC state - 1 if ADC trigger/aquisition complete, or 0 if in progress
  [[clears_notification]]  int read(unsigned short adc_val[4]);
//Call to client to indicate aquisition complete. Behaves a bit like ADC finish interrupt. Optional.
  [[notification]]  slave void complete(void);
} startkit_adc_if;

[[combinable]]
//Runs ADC task. Very low MIPS consumption so is good candidate for combining with other low speed tasks
//Pass i_adc control inteface and automatic trigger period in microseconds.
//If trigger period is set to zero, ADC will only convert on trigger() call.
void adc_task(server startkit_adc_if i_adc, chanend c_adc, int trigger_period);

#endif /* ADC_H_ */
