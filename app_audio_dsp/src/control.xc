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

#include "app_conf.h"
#include "coeffs.h"
#include "xscope.h"
#include "control.h"
#include "debug_print.h"
#include "c_utils.h"

static void inline set_effect(client control_if i_control,
    client startkit_led_if i_led,
    dsp_state_t &state,
    dsp_state_t new_state)
{
  state = new_state;
  debug_printf("Effect %d\n", state);
  i_control.set_effect(state);
  i_led.set_multiple(state, LED_ON);
}

static void print_usage()
{
  debug_printf("Supported commands:\n");
  debug_printf("  h|?      : print this help message\n");
  debug_printf("  b C B DB : Configure channel C bank B to DB\n");
  debug_printf("             C - 0-N selects channel, a selects all\n");
  debug_printf("             B - 0-N selects bank, a selects all\n");
  debug_printf("  g G     : Set the gain to G (value 0-100)\n");
  debug_printf("  d I T G : Configure DRC table index I. Set the threshold T and gain G\n");
  debug_printf("  q       : quit\n");
}

void control(chanend c_host_data,
    client startkit_led_if i_led,
    client startkit_button_if i_button,
    client control_if i_control)
{
  xscope_connect_data_from_host(c_host_data);

  unsigned int buffer[256/4]; // The maximum read size is 256 bytes
  unsigned char *char_ptr = (unsigned char *)buffer;
  int bytes_read = 0;

  // Set initial state
  int gain = 100;
  i_control.set_gain((MAX_GAIN / 100) * gain);

  dsp_state_t current_effect_state;
  set_effect(i_control, i_led, current_effect_state, 0);

  while (1) {
    select {
      case xscope_data_from_host(c_host_data, (unsigned char *)buffer, bytes_read):
        if (bytes_read < 1) {
          debug_printf("ERROR: Received '%d' bytes\n", bytes_read);
          break;
        }

        unsafe {
          const unsigned char * unsafe ptr = &char_ptr[0];
          char cmd = get_next_char(&ptr);

          switch (cmd) {
            case 'b':
              {
                const unsigned char * unsafe tmp = ptr;
                char chan_char = get_next_char(&tmp);
                int chan_index = convert_atoi_substr(&ptr);

                tmp = ptr;
                char bank_char = get_next_char(&tmp);
                int bank = convert_atoi_substr(&ptr);

                int dbs = convert_atoi_substr(&ptr);

                if (dbs < 0 || dbs >= DBS) {
                  debug_printf("Invalid DB value %d, use 0-%d\n", dbs, DBS-1);
                  break;
                }

                if (chan_index < 0 || chan_index >= NUM_APP_CHANS) {
                  debug_printf("Invalid channel value %d, use 0-%d or 'a' for all channels\n", chan_index, NUM_APP_CHANS-1);
                  break;
                }

                if (bank < 0 || bank >= BANKS) {
                  debug_printf("Invalid bank value %d, use 0-%d or 'a' for all banks\n", bank, BANKS-1);
                  break;
                }

                if (chan_char == 'a')
                  chan_index = NUM_APP_CHANS;

                if (bank_char == 'a')
                  bank = BANKS;

                i_control.set_dbs(chan_index, bank, dbs);
              }
              break;

            case 'g':
              {
                gain = convert_atoi_substr(&ptr);
                int gain_factor = (MAX_GAIN / 100) * gain;
                i_control.set_gain(gain_factor);
                debug_printf("Gain set to %d (%x)\n", gain, gain_factor);
              }
              break;

            case 'd':
              {
                debug_printf("Got %s\n", ptr);
                int index = convert_atoi_substr(&ptr);
                drcControl control;
                control.threshold = convert_atoi_substr(&ptr);
                control.gain = convert_atoi_substr(&ptr);
                control.gain_factor = (MAX_GAIN / 100) * control.gain;

                if (index < 0 || index >= DRC_NUM_THRESHOLDS) {
                  debug_printf("Invalid threshold index %d, use 0-%d\n", index, DRC_NUM_THRESHOLDS);
                  break;
                }

                i_control.set_drc_entry(index, control);
                debug_printf("Threshold %d set to %d (%x) above %d\n", index,
                    control.gain, control.gain_factor, control.threshold);
              }
              break;

            case 'p':
              debug_printf("Effect %d: current gain %d\n", current_effect_state, gain);

              for (int c = 0; c < NUM_APP_CHANS; c++) {
                debug_printf("  Channel%d dbs:", c);
                for (int i = 0; i < BANKS; i++) {
                  debug_printf(" %d", i_control.get_dbs(c, i));
                }
                debug_printf("\n");
              }

              debug_printf("DRC Table:\n");
              for (int d = 0; d < DRC_NUM_THRESHOLDS; d++) {
                drcControl control = i_control.get_drc_entry(d);
                debug_printf(" %d: threshold %d, gain %d (%x)\n", d,
                    control.threshold, control.gain, control.gain_factor);
              }
              break;

            case 'h':
            case '?':
              print_usage();
              break;

            default:
              debug_printf("Unrecognised command '%c'\n", cmd);
              break;
        }
      }
      break;

      case i_button.changed():
        if (i_button.get_value() == BUTTON_DOWN) {
          dsp_state_t new_state = current_effect_state + 1;
          if (new_state > 3)
            new_state = 0;
          set_effect(i_control, i_led, current_effect_state, new_state);
        }
        break;
    }
  }
}

