#ifndef __control_h__
#define __control_h__

#define GET_BIQUAD_ENABLED(x)    (x & 0x1)
#define SET_BIQUAD_ENABLED(x, v) ((x & ~0x1) | (v & 0x1))
#define GET_DRC_ENABLED(x)       (x & 0x2)
#define SET_DRC_ENABLED(x, v)    ((x & ~0x2) | ((v & 0x1) << 1))

#define PRE_GAIN_BITS   29
#define PRE_GAIN_OFFSET ((1 << PRE_GAIN_BITS) - 1)

typedef int dsp_state_t;

#include "startkit_gpio.h"
#include "drc.h"
#include "level.h"

#define LEVEL_ATTACK    1
#define LEVEL_RELEASE   2
#define LEVEL_THRESHOLD 4

typedef interface control_if {
  void set_effect(dsp_state_t state);

  void set_dbs(int chan_index, int index, int dbs);
  int  get_dbs(int chan_index, int index);

  void set_drc_entry(int index, drcControl &control);
  drcControl get_drc_entry(int index);

  void set_level_entry(int index, levelState &state, int flags);
  levelState get_level_entry(int index);

  void set_pre_gain(int gain);
  void set_gain(int gain);
} control_if;

void control(chanend c_host_data,
    client startkit_led_if i_led,
    client startkit_button_if i_button,
    client control_if i_control);

#endif // __control_h__
