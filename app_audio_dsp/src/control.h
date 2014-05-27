#ifndef __control_h__
#define __control_h__

#define MAX_GAIN 0x7fffffff

typedef enum {
  DSP_OFF,
  DSP_ON
} dsp_state_t;

#include "startkit_gpio.h"

typedef interface control_if {
  void set_effect(int effect_on);

  void set_dbs(int chan_index, int index, int dbs);
  int  get_dbs(int chan_index, int index);

  void set_gain(int gain);
} control_if;

void control(chanend c_host_data,
    client startkit_led_if i_led,
    client startkit_button_if i_button,
    client control_if i_control);

#endif // __control_h__
