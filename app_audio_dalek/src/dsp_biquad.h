/******************************************************************************\
 * Header:  dsp_biquad
 * File:    dsp_biquad.h
 *
 * Description: Definitions, types, and prototypes for dsp_biquad.xc
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

#ifndef _DSP_BIQUAD_H_
#define _DSP_BIQUAD_H_

#include <xs1.h>
#include <print.h>

#include "types64bit.h"
#include "app_global.h"
#include "common_utils.h"
#include "biquad_simple.h"
#include "startkit_gpio.h"

#ifdef USE_XSCOPE
#include <xscope.h>
#endif // ifdef USE_XSCOPE

#define FX_STR_LEN 10 // Holds Filter names

typedef struct FX_STR_TAG // Structure to hold one filter name
{
	char nam[FX_STR_LEN]; // name string
} FX_STR_S;

typedef struct FX_NAMES_TAG // Structure to hold all filter names
{
	FX_STR_S names[NUM_FILT_MODES]; // array of structures containing a filter name
} FX_NAMES_S;


/******************************************************************************/
void dsp_biquad( // Coar that applies BiQuad filter to stream of audio samples
	streaming chanend c_dsp_eq, // Channel connecting to DSP-control coar (bi-directional)
	S32_T biquad_id, // Identifies which BiQuad to use
	client startkit_led_if i_led,
	client startkit_button_if i_button,
	chanend c_gain
);
/******************************************************************************/

#endif // _DSP_BIQUAD_H_
/******************************************************************************/
// dsp_biquad.h
