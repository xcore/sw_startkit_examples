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

#include "coeffs.h"
#include "xscope.h"
#include "control.h"
#include "debug_print.h"
#include "c_utils.h"

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

  debug_printf("Effect off\n");
  dsp_state_t current_effect_state = DSP_OFF;
  i_control.set_effect(0);
  i_led.set_multiple(0b000000000, LED_OFF);

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
                char bank_char = get_next_char(&tmp);
                int bank = convert_atoi_substr(&ptr);
                int dbs = convert_atoi_substr(&ptr);

                if (dbs < 0 || dbs >= DBS) {
                  debug_printf("Invalid DB value %d, use 0-%d\n", dbs, DBS-1);
                  break;
                }

                if (bank < 0 || bank >= BANKS) {
                  debug_printf("Invalid bank value %d, use 0-%d or 'a' for all\n", bank, BANKS-1);
                  break;
                }

                if (bank_char == 'a') {
                  debug_printf("All channels set to %d\n", dbs);
                  i_control.set_dbs(BANKS, dbs);
                } else {
                  debug_printf("db[%x] set to %d\n", bank, dbs);
                  i_control.set_dbs(bank, dbs);
                }
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

            case 'p':
              debug_printf("Effect %s: current gain %d, dbs: ",
                  (current_effect_state == DSP_ON) ? "on" : "off", gain);

              for (int i = 0; i < BANKS; i++) {
                debug_printf(" %d", i_control.get_dbs(i));
              }
              debug_printf("\n");
              break;
              
            default:
              debug_printf("Unrecognised command '%c'\n", cmd);
              break;
        }
      }
      break;

      case i_button.changed():
        if (i_button.get_value() == BUTTON_DOWN) {
          switch(current_effect_state) {
          case DSP_ON:
            debug_printf("Effect off\n");
            i_led.set_multiple(0b000000000, LED_OFF);
            i_control.set_effect(0);
            current_effect_state = DSP_OFF;
            break;

          case DSP_OFF:
            debug_printf("Effect on\n");
            i_led.set_multiple(0b111111111, LED_ON);
            i_control.set_effect(1);
            current_effect_state = DSP_ON;
            break;
          }
        }
        break;
    }
  }
}

