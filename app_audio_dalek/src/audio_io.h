/******************************************************************************\
 * Header:  audio_io
 * File:    audio_io.h
 *
 * Description: Definitions, types, and prototypes for audio_io.xc
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

#ifndef _AUDIO_IO_H_
#define _AUDIO_IO_H_

#include <platform.h>
#include "i2c.h"
#include "codec.h"
#include "i2s_master.h"
#include "app_global.h"

/******************************************************************************/
void audio_io(
	streaming chanend c_aud // Audio end of channel between I/O and DSP coar
);
/******************************************************************************/

#endif // _AUDIO_IO_H_
/******************************************************************************/
// audio_io.h
