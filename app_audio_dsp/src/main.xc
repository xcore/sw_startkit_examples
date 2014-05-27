/******************************************************************************\
 * File:	main.xc
 *
 * Modified from project found here https://github.com/xcore/sw_audio_effects
\******************************************************************************/

#include <xs1.h>
#include <platform.h>
#include <xscope.h>
#include "app_global.h"
#include "startkit_gpio.h"
#include "lfo.h"
#include "audio_io.h"
#include "dsp.h"
#include "control.h"

on stdcore[0]: startkit_gpio_ports gpio_ports =
  {XS1_PORT_32A, XS1_PORT_4A, XS1_PORT_4B, XS1_CLKBLK_3};

#ifdef USE_XSCOPE
/*****************************************************************************/
void xscope_user_init( void ) // 'C' constructor function (NB called before main)
{
    xscope_register(3,
        XSCOPE_CONTINUOUS, "Left in",  XSCOPE_INT, "n",
        XSCOPE_CONTINUOUS, "Left out", XSCOPE_INT, "n",
        XSCOPE_CONTINUOUS, "Mod",      XSCOPE_INT, "n"
        ); // xscope_register

    xscope_config_io(XSCOPE_IO_BASIC); // Enable XScope printing
} // xscope_user_init
#endif // ifdef USE_XSCOPE

/*****************************************************************************/
int main (void)
{
    chan c_host_data;
    streaming chan c_aud_dsp;         // Channel between I/O and DSP core
    startkit_led_if i_led;            // Interface between DSP core and LED controller
    startkit_button_if i_button;      // Interface between DSP core and button listner component
    slider_if i_slider_x, i_slider_y; // Interface between DSP core and slider component
    control_if i_control;

    par
    {
        xscope_host_data(c_host_data);

        on stdcore[0]: audio_io(c_aud_dsp);

        on stdcore[0]: dsp(c_aud_dsp, i_control);

        on stdcore[0]: startkit_gpio_driver(i_led, i_button,
            i_slider_x, i_slider_y, gpio_ports);

        on stdcore[0]: control(c_host_data, i_led, i_button, i_control);
    }

    return 0;
}
