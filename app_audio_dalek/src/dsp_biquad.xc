/******************************************************************************\
 * File:	dsp_biquad.xc
 *
 * Description: Coar that applies BiQuad filter to stream of audio samples
 *
 * Version: 0v1
 * Build:
 *
 * The copyrights, all other intellectual and industrial
 * property rights are retained by XMOS and/or its licensors.
 * Terms and conditions covering the use of this code can
 * be found in the Xmos End User License Agreement.
 *
 * Copyright XMOS Ltd 2012
 *
 * In the case where this code is a modification of existing code
 * under a separate license, the separate license terms are shown
 * below. The modifications to the code are still covered by the
 * copyright notice above.
 *
\******************************************************************************/

#include "dsp_biquad.h"
#include "startkit_gpio.h"

// DSP-control coar.

/******************************************************************************/
void process_all_chans( // Do DSP effect processing
	S32_T out_samps[],	// Output Processed audio sample buffer
	S32_T inp_samps[],	// Input unprocessed audio sample buffer
	S32_T biquad_id, // Identifies which BiQuad to use
	S32_T min_chans	// Minimum of input/output channels
)
{
	S32_T chan_cnt; // Channel counter


	for(chan_cnt = 0; chan_cnt < min_chans; chan_cnt++)
	{ // Apply non-linear gain shaping (Loudness)
		out_samps[chan_cnt] = use_biquad_filter( biquad_id ,inp_samps[chan_cnt] ,chan_cnt );
//MB~	out_samps[chan_cnt] = inp_samps[chan_cnt]; //MB~ DBG
	} // for chan_cnt

} // process_all_chans
/******************************************************************************/

int do_gain(int sample, int gain){/* Apply gain, 0 to 7fffffff*/
	return (((long long) sample) * (long long) gain) >> 31;
}



void dsp_biquad( // Coar that applies a BiQuad filter to a set of of audio sample streams
	streaming chanend c_dsp, // DSP end of channel connecting to Audio_IO and DSP coars (bi-directional)
	S32_T biquad_id, // Identifies which BiQuad to use
	client startkit_led_if i_led,
	client startkit_button_if i_button,
	chanend c_gain
)
{
	// NB Setup correct number of channels in Makefile
	S32_T inp_samps[NUM_BIQUAD_CHANS];	// Unequalised input audio sample buffer
	S32_T equal_samps[NUM_BIQUAD_CHANS];	// Equalised audio sample buffer
	S32_T out_samps[NUM_BIQUAD_CHANS];	// Output audio sample buffer

	S32_T chan_cnt; // Channel counter

	S32_T gain = 0; // Start with volume at 0

	FX_NAMES_S filt_names = { {{"Low_Pass"}, {"High_Pass"}, {"Band_Pass"}, {"Band_Stop"}, {"Custom"}} };

	PROC_STATE_ENUM cur_proc_state	= DRY_ONLY; // Initialise processing state to EFFECT On.
	BIQUAD_PARAM_S cur_param_s = { LO_PASS ,DEF_SAMP_FREQ ,DEF_SIG_FREQ ,DEF_QUAL_FACT };	// Default BiQuad parameters


	// initialise samples buffers
	for (chan_cnt = 0; chan_cnt < NUM_BIQUAD_CHANS; chan_cnt++)
	{
		inp_samps[chan_cnt] = 0;
		equal_samps[chan_cnt] = 0;
		out_samps[chan_cnt] = 0;
	}

	config_biquad_filter( biquad_id ,cur_param_s );	// Initial BiQuad Configuration
	printstrln("Effect off");
	i_led.set_multiple(0b111111111, LED_OFF);

	// Loop forever
	while(1)
	{
		// Send/Receive samples over Audio coar channel
#pragma loop unroll
		for (chan_cnt = 0; chan_cnt < NUM_BIQUAD_CHANS; chan_cnt++)
		{
			c_dsp :> inp_samps[chan_cnt];

			c_dsp <: out_samps[chan_cnt];

		}
		xscope_int(0,inp_samps[0]);
		xscope_int(1,out_samps[0]);
		xscope_int(2, gain);

		select{
			case i_button.changed():
				if (i_button.get_value() == BUTTON_DOWN){
					switch(cur_proc_state){
					case EFFECT: // Copy equalised samples to output
						cur_proc_state = DRY_ONLY; // Switch to Fade-out Effect
						printstrln("Effect off");
						i_led.set_multiple(0b111111111, LED_OFF);
						break; // case EFFECT:

					case DRY_ONLY: // No Effect (Dry signal only)
						cur_proc_state = EFFECT; // Switch to Fade-In Effect
						printstrln( filt_names.names[cur_param_s.filt_mode].nam );
						// Change filter mode ready for EFFECT
						cur_param_s.filt_mode = increment_circular_offset( (cur_param_s.filt_mode + 1) ,ALL_PASS );
						config_biquad_filter( biquad_id ,cur_param_s );	// Update BiQuad Configuration
						i_led.set_multiple(1 << cur_param_s.filt_mode, LED_ON);
						break;

					default:
						printstrln("illegal state");
						assert(0 == 1);
						break;
					}

				}
				break;

			case c_gain :> gain:
				break;

			default:
				break;
			}


		// Do DSP Processing ...
		process_all_chans( equal_samps ,inp_samps ,biquad_id ,NUM_BIQUAD_CHANS );

		// Check current processing State
		switch(cur_proc_state)
		{
			case EFFECT: // Copy equalised samples to output
				for (chan_cnt = 0; chan_cnt < NUM_BIQUAD_CHANS; chan_cnt++)
				{ // NB Add a bit of filtering to prevent clicks on transitions
					out_samps[chan_cnt] = equal_samps[chan_cnt];
				} // for chan_cnt

			break; // case EFFECT:


			case DRY_ONLY: // No Effect (Dry signal only)
				for (chan_cnt = 0; chan_cnt < NUM_BIQUAD_CHANS; chan_cnt++)
				{ // NB Add a bit of filtering to prevent clicks on transitions
					out_samps[chan_cnt] = inp_samps[chan_cnt];
				} // for chan_cnt
			break; // case DRY_ONLY:

			default:
				assert(0 == 1); // ERROR: Unsupported state
			break; // default:
		} // switch(cur_proc_state)

		//Apply gain
		for (chan_cnt = 0; chan_cnt < NUM_BIQUAD_CHANS; chan_cnt++){
			out_samps[chan_cnt] = do_gain(out_samps[chan_cnt], gain);
		}
	} // while(1)

} // dsp_biquad
/*****************************************************************************/
// dsp_biquad.xc
