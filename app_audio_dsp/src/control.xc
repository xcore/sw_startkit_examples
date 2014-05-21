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

void control(chanend c_host_data, client control_if i_control)
{
  xscope_connect_data_from_host(c_host_data);

  unsigned int buffer[256/4]; // The maximum read size is 256 bytes
  unsigned char *char_ptr = (unsigned char *)buffer;
  int bytes_read = 0;

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

                if (bank_char == 'a')
                  i_control.set_dbs(BANKS, dbs);
                else
                  i_control.set_dbs(bank, dbs);
              }
              break;

            case 'g':
              {
                int gain = convert_atoi_substr(&ptr);
                gain = (MAX_GAIN / 100) * gain;
                i_control.set_gain(gain);
              }
              break;

            case 'p':
              i_control.print();
              break;
              
            default:
              debug_printf("Unrecognised command '%c'\n", cmd);
              break;
        }
      }
      break;
    }
  }
}

