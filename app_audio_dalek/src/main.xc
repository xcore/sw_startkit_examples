/******************************************************************************\
 * File:	main.xc
 *
* Top level app for dalek simulator app.
* USes startKIT & audio slice hardware to provide various audio effects
* Use button to select biquad filter type
* Use sliders to control dalek effect (one does modulation depth, the other freq)
* Uses sawtooth LFO to amplitude modulate audio to make dalek effect
* Hint: enable xSCOPE RT to see input/output/LFO waveforms!
*
* Modified from project found here https://github.com/xcore/sw_audio_effects
\******************************************************************************/

#include "main.h"
#include "startkit_gpio.h"
#include "lfo.h"
#include <xs1.h>

on stdcore[DSP_TILE]: startkit_gpio_ports gpio_ports =
  {XS1_PORT_32A, XS1_PORT_4A, XS1_PORT_4B, XS1_CLKBLK_3};

#ifdef USE_XSCOPE
/*****************************************************************************/
void xscope_user_init( void ) // 'C' constructor function (NB called before main)
{
	xscope_register( 3
		,XSCOPE_CONTINUOUS ,"Left in" ,XSCOPE_INT ,"n"
		,XSCOPE_CONTINUOUS ,"Left out" ,XSCOPE_INT ,"n"
		,XSCOPE_CONTINUOUS ,"Mod" ,XSCOPE_INT ,"n"
	); // xscope_register

	xscope_config_io( XSCOPE_IO_BASIC ); // Enable XScope printing
} // xscope_user_init
#endif // ifdef USE_XSCOPE

/*****************************************************************************/
int main (void)
{
	streaming chan c_aud_dsp;       // Channel between I/O and DSP core
	chan c_gain;                    // Channel between LFO (low freq osc) and DSP core
	startkit_led_if i_led;          // Interface between DSP core and LED controller
	startkit_button_if i_button;    // Interface between DSP core and button listner component
	slider_if i_slider_x, i_slider_y; //Interface between DSP core and slider component

	par
	{
		on stdcore[AUDIO_IO_TILE]: audio_io( c_aud_dsp ); // Audio I/O core aka I2S

		on stdcore[DSP_TILE]: dsp_biquad( c_aud_dsp ,0, i_led, i_button, c_gain ); // BiQuad filter core

		on stdcore[DSP_TILE]: startkit_gpio_driver(i_led, i_button,
								   i_slider_x,
		                           i_slider_y,
		                           gpio_ports);
		on stdcore[DSP_TILE]: lfo(c_gain, i_slider_x, i_slider_y);
	}

	return 0;
} // main
/*****************************************************************************/
// main.xc
