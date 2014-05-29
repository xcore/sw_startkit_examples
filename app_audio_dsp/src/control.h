#ifndef __control_h__
#define __control_h__

#define MAX_GAIN 0x7fffffff

#define GET_BIQUAD_ENABLED(x)    (x & 0x1)
#define SET_BIQUAD_ENABLED(x, v) ((x & ~0x1) | (v & 0x1))
#define GET_DRC_ENABLED(x)       (x & 0x2)
#define SET_DRC_ENABLED(x, v)    ((x & ~0x2) | ((v & 0x1) << 1))

typedef int dsp_state_t;

#include "startkit_gpio.h"
#include "drc.h"

typedef interface control_if {
  void set_effect(dsp_state_t state);

  void set_dbs(int chan_index, int index, int dbs);
  int  get_dbs(int chan_index, int index);

  void set_drc_entry(int index, drcControl &control);
  drcControl get_drc_entry(int index);

  void set_gain(int gain);
} control_if;

void control(chanend c_host_data,
    client startkit_led_if i_led,
    client startkit_button_if i_button,
    client control_if i_control);

#endif // __control_h__
