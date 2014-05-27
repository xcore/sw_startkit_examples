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
#include "xscope.h"

#define MAX_VALUE ((1 << 23) - 1)
#define MIN_VALUE (-(1 << 23))

int do_gain(int sample, int gain){/* Apply gain, 0 to 7fffffff*/
  long long value = (long long) sample * (long long) gain;

  int ivalue = value >> 31;

  // Clipping
  if (ivalue > MAX_VALUE)
    ivalue = MAX_VALUE;
  else if (ivalue < MIN_VALUE)
    ivalue = MIN_VALUE;

  return ivalue;
}

void dsp(streaming chanend c_audio,
    server control_if i_control)
{
    biquadState bs;
    initBiquads(bs, 20);
    
    int gain = 0; // Initial gain is set in the control core

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

    // Loop forever
    while(1)
    {
        // Send/Receive samples over Audio coar channel
#pragma loop unroll
        for (int chan_cnt = 0; chan_cnt < NUM_APP_CHANS; chan_cnt++)
        {
            c_audio :> inp_samps[chan_cnt];
            inp_samps[chan_cnt] >>= 8;
            c_audio <: out_samps[chan_cnt] << 8;
        }
        xscope_int(0,inp_samps[0]);
        xscope_int(1,out_samps[0]);
        xscope_int(2, gain);

        for (int chan_cnt = 0; chan_cnt < NUM_APP_CHANS; chan_cnt++)
        {
            equal_samps[chan_cnt] =  biquadCascade(bs, inp_samps[chan_cnt]);
        }

        select {
            case i_control.set_effect(int effect_on) :
                if (effect_on) {
                  cur_proc_state = DSP_ON;
                } else if (!effect_on) {
                  cur_proc_state = DSP_OFF;
                }
                break;

            case i_control.set_gain(int new_gain) :
                gain = new_gain;
                break;

            case i_control.set_dbs(int index, int dbs) :
                if (index < BANKS) {
                  bs.desiredDb[index] = dbs;
                } else {
                  for (int i = 0; i < BANKS; i++) {
                    bs.desiredDb[i] = dbs;
                  }
                }
                break;

            case i_control.get_dbs(int index) -> int dbs:
                if (index < BANKS) {
                  dbs = bs.b[index].db;
                } else {
                  dbs = 0;
                }
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

