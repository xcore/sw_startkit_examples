// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <platform.h>
#include <xscope.h>
#include "app_global.h"
#include "startkit_gpio.h"
#include "audio_io.h"
#include "dsp.h"
#include "control.h"

on stdcore[0]: startkit_gpio_ports gpio_ports =
  {XS1_PORT_32A, XS1_PORT_4A, XS1_PORT_4B, XS1_CLKBLK_3};

#ifdef USE_XSCOPE
void xscope_user_init(void) // 'C' constructor function (NB called before main)
{
    xscope_register(3,
        XSCOPE_CONTINUOUS, "Left in",  XSCOPE_INT, "n",
        XSCOPE_CONTINUOUS, "Left out", XSCOPE_INT, "n",
        XSCOPE_CONTINUOUS, "Mod",      XSCOPE_INT, "n"
        ); // xscope_register

    xscope_config_io(XSCOPE_IO_BASIC); // Enable XScope printing
}
#endif

// A function to simply consume cycles
void filler()
{
  set_core_fast_mode_on();
  while (1) { }
}

int main (void)
{
    chan c_host_data;                 // Channel to receive control messages from the host
    streaming chan c_aud_dsp;         // Channel for audio between I/O and DSP core
    startkit_led_if i_led;            // Interface between control core and LED controller
    startkit_button_if i_button;      // Interface between control core and button listener component
    slider_if i_slider_x, i_slider_y; // Unused slider interface
    control_if i_control;             // Interface between the control and DSP cores

    par
    {
        xscope_host_data(c_host_data);

        on stdcore[0]: audio_io(c_aud_dsp);

        on stdcore[0]: dsp(c_aud_dsp, i_control);

        on stdcore[0]: startkit_gpio_driver(i_led, i_button,
            i_slider_x, i_slider_y, gpio_ports);

        on stdcore[0]: control(c_host_data, i_led, i_button, i_control);

        // Fill the unused cores to prove that the DSP works with 8 cores active
        on stdcore[0]: filler();
        on stdcore[0]: filler();
        on stdcore[0]: filler();
        on stdcore[0]: filler();
    }

    return 0;
}
