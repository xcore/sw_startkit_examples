/******************************************************************************\
 * The copyrights, all other intellectual and industrial
 * property rights are retained by XMOS and/or its licensors.
 * Terms and conditions covering the use of this code can
 * be found in the Xmos End User License Agreement.
 *
 * Copyright XMOS Ltd 2014
 *
 * In the case where this code is a modification of existing code
 * under a separate license, the separate license terms are shown
 * below. The modifications to the code are still covered by the
 * copyright notice above.
 *
\******************************************************************************/

#include "app_conf.h"
#include "app_global.h"
#include "dsp.h"
#include "coeffs.h"
#include "biquadCascade.h"
#include "debug_print.h"
#include "xscope.h"

typedef enum {
  DSP_OFF,
  DSP_ON
} dsp_state_t;

int do_gain(int sample, int gain){/* Apply gain, 0 to 7fffffff*/
  long long value = (long long) sample * (long long) gain;

  int ivalue = value >> 31;

  // Clipping
  if (ivalue > 0x007fffff)
    ivalue = 0x007fffff;
  else if (ivalue < -0x00800000)
    ivalue = -0x00800000;

  return ivalue;
}

void dsp(streaming chanend c_audio,
    client startkit_led_if i_led,
    client startkit_button_if i_button,
    server control_if i_control)
{
    biquadState bs;
    initBiquads(bs, 20);
    
    int gain = MAX_GAIN;

    int inp_samps[NUM_APP_CHANS];
    int equal_samps[NUM_APP_CHANS];
    int out_samps[NUM_APP_CHANS];

    dsp_state_t cur_proc_state = DSP_OFF;

    // initialise samples buffers
    for (int chan_cnt = 0; chan_cnt < NUM_APP_CHANS; chan_cnt++)
    {
        inp_samps[chan_cnt] = 0;
        equal_samps[chan_cnt] = 0;
        out_samps[chan_cnt] = 0;
    }

    debug_printf("Effect off\n");
    i_led.set_multiple(0b000000000, LED_OFF);

    // Loop forever
    while(1)
    {
        // Send/Receive samples over Audio coar channel
#pragma loop unroll
        for (int chan_cnt = 0; chan_cnt < NUM_APP_CHANS; chan_cnt++)
        {
            c_audio :> inp_samps[chan_cnt];
            inp_samps[chan_cnt] >>= 5;
            c_audio <: out_samps[chan_cnt] << 5;
        }
        xscope_int(0,inp_samps[0]);
        xscope_int(1,out_samps[0]);
        xscope_int(2, gain);

        for (int chan_cnt = 0; chan_cnt < NUM_APP_CHANS; chan_cnt++)
        {
            equal_samps[chan_cnt] =  biquadCascade(bs, inp_samps[chan_cnt]);
        }

        select {
            case i_button.changed():
                if (i_button.get_value() == BUTTON_DOWN) {
                    switch(cur_proc_state) {
                    case DSP_ON:
                        debug_printf("Effect off\n");
                        cur_proc_state = DSP_OFF;
                        i_led.set_multiple(0b000000000, LED_OFF);
                        break;

                    case DSP_OFF:
                        debug_printf("Effect on\n");
                        cur_proc_state = DSP_OFF;
                        cur_proc_state = DSP_ON;
                        i_led.set_multiple(0b111111111, LED_OFF);
                        break;
                    }
                }
                break;

            case i_control.set_gain(int new_gain) :
                gain = new_gain;
                debug_printf("Gain + (%x)\n", gain);
                break;

            case i_control.set_dbs(int index, int dbs) :
                if (dbs < 0 || dbs >= DBS)
                {
                  debug_printf("Invalid DB value %d, use 0-%d\n", dbs, DBS);
                  break;
                }

                if (index < BANKS)
                {
                  bs.desiredDb[index] = dbs;
                  debug_printf("db[%x] set to %d\n", index, bs.desiredDb[index]);
                }
                else
                {
                  debug_printf("All channels set to %d\n", dbs);
                  for (int i = 0; i < BANKS; i++)
                    bs.desiredDb[i] = dbs;
                }
                break;

            case i_control.print() :
                debug_printf("current db:");
                for (int i = 0; i < BANKS; i++)
                {
                  debug_printf(" %d", bs.b[i].db);
                }
                debug_printf("\n");
                break;

            default:
                break;
        }

        switch(cur_proc_state)
        {
            case DSP_ON:
                for (int chan_cnt = 0; chan_cnt < NUM_APP_CHANS; chan_cnt++)
                    out_samps[chan_cnt] = equal_samps[chan_cnt];
                break;

            case DSP_OFF:
                for (int chan_cnt = 0; chan_cnt < NUM_APP_CHANS; chan_cnt++)
                    out_samps[chan_cnt] = inp_samps[chan_cnt];
                break;

            default:
                break;
        }

        for (int chan_cnt = 0; chan_cnt < NUM_APP_CHANS; chan_cnt++)
            out_samps[chan_cnt] = do_gain(out_samps[chan_cnt], gain);
    } // while(1)
}

