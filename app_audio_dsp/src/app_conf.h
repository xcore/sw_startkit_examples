// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef _APP_CONF_H_
#define _APP_CONF_H_

/** Number of audio channels used in this application */
#define NUM_APP_CHANS 2

#define MAX_GAIN  0x7fffffff

// The signal values are signed 24-bit values
#define MAX_VALUE ((1 << 23) - 1)
#define MIN_VALUE (-(1 << 23))

#endif // _APP_CONF_H_
