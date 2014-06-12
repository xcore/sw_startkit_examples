// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef _AUDIO_IO_H_
#define _AUDIO_IO_H_

#include <platform.h>
#include "i2c.h"
#include "codec.h"
#include "i2s_master.h"
#include "app_global.h"

void audio_io(
	streaming chanend c_aud // Audio end of channel between I/O and DSP coar
);

#endif // _AUDIO_IO_H_
