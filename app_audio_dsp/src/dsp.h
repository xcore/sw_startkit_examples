// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef _DSP_H_
#define _DSP_H_

#include "control.h"

void dsp(
    streaming chanend c_audio,
    server control_if i_control
);

#endif // _DSP_H_
