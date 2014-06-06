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
#include "drc.h"
#include "level.h"
#include "xscope.h"


/* Apply gain:
 * A value of ((1 << (shift + 1)) - 1) will produce no volume change.
 * So, with a shift of 31, the gain value of 0x7fffffff has no affect.
 * The shift value must be in the range 0..31
 */
static int do_gain(int sample, int gain, int shift)
{
  long long value = (long long) sample * (long long) gain;
  int ivalue = value >> shift;

  // Clipping
  if (ivalue > MAX_VALUE)
    ivalue = MAX_VALUE;
  else if (ivalue < MIN_VALUE)
    ivalue = MIN_VALUE;

  return ivalue;
}

static inline void handle_control(server control_if i_control, dsp_state_t &state, int &pre_gain, int &gain,
    biquadState bs[], levelState ls[])
{
  select {
    case i_control.set_effect(dsp_state_t next_state) :
      state = next_state;
      break;

    case i_control.set_pre_gain(int new_gain) :
      pre_gain = new_gain;
      break;

    case i_control.set_gain(int new_gain) :
      gain = new_gain;
      break;

    case i_control.set_dbs(int chan_index, int bank, int dbs) :
      for (int c = 0; c < NUM_APP_CHANS; c++) {
        for (int i = 0; i < BANKS; i++) {
          if ((chan_index == NUM_APP_CHANS || chan_index == c) &&
              (bank == BANKS || bank == i)) {
            bs[c].desiredDb[i] = dbs;
          }
        }
      }
      break;

    case i_control.set_drc_entry(int index, drcControl &control) :
      drcTable[index] = control;
      break;

    case i_control.get_drc_entry(int index) -> drcControl control:
      control = drcTable[index];
      break;

    case i_control.set_level_entry(int index, levelState &state) :
      for (int i = 0; i < NUM_APP_CHANS; i++) {
        if (index == NUM_APP_CHANS || index == i)
          ls[i] = state;
      }
      break;

    case i_control.get_level_entry(int index) -> levelState state:
      state = ls[index];
      break;

    case i_control.get_dbs(int chan_index, int index) -> int dbs:
      if (index < BANKS) {
        dbs = bs[chan_index].b[index].db;
      } else {
        dbs = 0;
      }
      break;

    default:
      break;
  }
}

void dsp(streaming chanend c_audio, server control_if i_control)
{
  biquadState bs[NUM_APP_CHANS];
  levelState ls[NUM_APP_CHANS];

  int pre_gain = 0; // Initial gain is set in the control core
  int gain = 0; // Initial gain is set in the control core

  int inp_samps[NUM_APP_CHANS];
  int equal_samps[NUM_APP_CHANS];
  int out_samps[NUM_APP_CHANS];

  dsp_state_t cur_proc_state = 0;

  initDrc();

  for (int chan_cnt = 0; chan_cnt < NUM_APP_CHANS; chan_cnt++)
  {
    // Initialise all state
    initBiquads(bs[chan_cnt], 20);
    initLevelState(ls[chan_cnt], 1000000, 4000000, 20);
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

    // Perform pre-amp gain
    for (int chan_cnt = 0; chan_cnt < NUM_APP_CHANS; chan_cnt++)
      inp_samps[chan_cnt] = do_gain(inp_samps[chan_cnt], pre_gain, PRE_GAIN_BITS);

    xscope_int(0, inp_samps[0]);
    xscope_int(1, out_samps[0]);
    xscope_int(2, ls[0].level);

    for (int chan_cnt = 0; chan_cnt < NUM_APP_CHANS; chan_cnt++)
    {
      computeLevel(ls[chan_cnt], inp_samps[chan_cnt]);
      int b_sample = biquadCascade(bs[chan_cnt], inp_samps[chan_cnt]);

      int d_sample;
      if (GET_BIQUAD_ENABLED(cur_proc_state)) {
        d_sample = drc(b_sample, ls[chan_cnt].level);
      } else {
        d_sample = drc(inp_samps[chan_cnt], ls[chan_cnt].level);
      }

      if (GET_DRC_ENABLED(cur_proc_state)) {
        equal_samps[chan_cnt] = d_sample;
      } else {
        equal_samps[chan_cnt] = b_sample;
      }
    }

    handle_control(i_control, cur_proc_state, pre_gain, gain, bs, ls);

    if (cur_proc_state) {
      for (int chan_cnt = 0; chan_cnt < NUM_APP_CHANS; chan_cnt++)
        out_samps[chan_cnt] = equal_samps[chan_cnt];
    } else {
      for (int chan_cnt = 0; chan_cnt < NUM_APP_CHANS; chan_cnt++)
        out_samps[chan_cnt] = inp_samps[chan_cnt];
    }

    for (int chan_cnt = 0; chan_cnt < NUM_APP_CHANS; chan_cnt++)
      out_samps[chan_cnt] = do_gain(out_samps[chan_cnt], gain, 31);
  } // while(1)
}

