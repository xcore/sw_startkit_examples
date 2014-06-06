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
  if (state == new_state)
    return;

  state = new_state;
  debug_printf("Effect %d\n", state);
  i_control.set_effect(state);
  i_led.set_multiple(state, LED_ON);
}

static void print_usage()
{
  debug_printf("Supported commands:\n");
  debug_printf("  h|?       : print this help message\n");
  debug_printf("  b C B DB  : Configure channel C bank B to DB\n");
  debug_printf("              C - 0-N selects channel, a selects all\n");
  debug_printf("              B - 0-N selects bank, a selects all\n");
  debug_printf("  p G       : Set the pre-gain to G (value 0-100)\n");
  debug_printf("  g G       : Set the gain to G (value 0-100)\n");
  debug_printf("  t I T G   : Configure DRC table index I.\n");
  debug_printf("              Set the threshold T and gain G as a percent of full range (0-100)\n");
  debug_printf("  e b|d     : Enable either biquads (b) or DRC (d)\n");
  debug_printf("  d b|d     : Disable either biquads (b) or DRC (d)\n");
  debug_printf("  l C A R T : Configure the level detection for channel C.\n");
  debug_printf("              The attack A and release R times in ns\n");
  debug_printf("              The threshold T in percent of full range value (0-100)\n");
  debug_printf("  s         : Show the current state\n");
  debug_printf("  q         : quit\n");
}

static int validate_percent(int percent, const char *type_string)
{
  if (percent < 0 || percent > 100) {
    debug_printf("Invalid value '%d' for %s, please specify value in the range 0-100\n",
        percent, type_string);
    return 1;
  }
  return 0;
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
  int pre_gain = 0;
  i_control.set_pre_gain((((MAX_GAIN - PRE_GAIN_OFFSET) / 100) * pre_gain) + PRE_GAIN_OFFSET);
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
            case 'e':
            case 'd':
              {
                char effect = get_next_char(&ptr);
                dsp_state_t new_state = current_effect_state;
                switch (effect) {
                  case 'b':
                    new_state = SET_BIQUAD_ENABLED(current_effect_state, (cmd == 'e') ? 1 : 0);
                    break;

                  case 'd':
                    new_state = SET_DRC_ENABLED(current_effect_state, (cmd == 'e') ? 1 : 0);
                    break;

                  default:
                    debug_printf("Invalid effect '%c', use 'b' for biquads and 'd' for DRC\n", effect);
                    break;
                }
                set_effect(i_control, i_led, current_effect_state, new_state);
                break;
              }

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

            case 'p':
              {
                pre_gain = convert_atoi_substr(&ptr);
                if (validate_percent(gain, "gain"))
                  break;
                int gain_factor = (((MAX_GAIN - PRE_GAIN_OFFSET) / 100) * pre_gain) + PRE_GAIN_OFFSET;
                i_control.set_pre_gain(gain_factor);
                debug_printf("Pre gain set to %d (%x)\n", pre_gain, gain_factor);
              }
              break;

            case 'g':
              {
                gain = convert_atoi_substr(&ptr);
                if (validate_percent(gain, "gain"))
                  break;
                int gain_factor = (MAX_GAIN / 100) * gain;
                i_control.set_gain(gain_factor);
                debug_printf("Gain set to %d (%x)\n", gain, gain_factor);
              }
              break;

            case 't':
              {
                int index = convert_atoi_substr(&ptr);
                drcControl control;

                control.threshold_percent = convert_atoi_substr(&ptr);
                if (validate_percent(control.threshold_percent, "threshold"))
                  break;
                control.threshold = (MAX_VALUE / 100) * control.threshold_percent;

                control.gain_percent = convert_atoi_substr(&ptr);
                if (validate_percent(control.gain_percent, "gain"))
                  break;
                control.gain_factor = (MAX_GAIN / 100) * control.gain_percent;

                if (index < 0 || index >= DRC_NUM_THRESHOLDS) {
                  debug_printf("Invalid threshold index %d, use 0-%d\n", index, DRC_NUM_THRESHOLDS - 1);
                  break;
                }

                i_control.set_drc_entry(index, control);
              }
              break;

            case 'l':
              {
                const unsigned char * unsafe tmp = ptr;
                char chan_char = get_next_char(&tmp);
                int chan_index = convert_atoi_substr(&ptr);

                if (chan_index < 0 || chan_index >= NUM_APP_CHANS) {
                  debug_printf("Invalid channel index %d, use 0-%d\n", chan_index, NUM_APP_CHANS - 1);
                  break;
                }

                if (chan_char == 'a')
                  chan_index = NUM_APP_CHANS;

                levelState state;
                int attack_ns = convert_atoi_substr(&ptr);
                int release_ns = convert_atoi_substr(&ptr);
                int threshold_percent = convert_atoi_substr(&ptr);
                if (validate_percent(threshold_percent, "threshold"))
                  break;
                initLevelState(state, attack_ns, release_ns, threshold_percent);
                i_control.set_level_entry(chan_index, state);
              }
              break;

            case 's':
              debug_printf("Current pre-gain %d, gain %d\n", pre_gain, gain);
              debug_printf("Biquads %s\n", GET_BIQUAD_ENABLED(current_effect_state) ? "on" : "off");

              for (int c = 0; c < NUM_APP_CHANS; c++) {
                debug_printf("  Channel%d dbs:", c);
                for (int i = 0; i < BANKS; i++) {
                  debug_printf(" %d", i_control.get_dbs(c, i));
                }
                levelState state = i_control.get_level_entry(c);
                debug_printf("\n           Level threshold %d (%x), attack %d, release %d\n",
                    state.threshold_percent, state.threshold, state.attack_ns, state.release_ns);
              }

              debug_printf("DRC %s: Table:\n", GET_DRC_ENABLED(current_effect_state) ? "on" : "off");
              for (int d = 0; d < DRC_NUM_THRESHOLDS; d++) {
                drcControl control = i_control.get_drc_entry(d);
                debug_printf(" %d: threshold %d (%x), gain %d (%x)\n", d,
                    control.threshold_percent, control.threshold,
                    control.gain_percent, control.gain_factor);
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

