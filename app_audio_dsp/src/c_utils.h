// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef __C_UTILS_H__
#define __C_UTILS_H__

#include <xccompat.h>

#ifdef __XC__
extern "C" {
#endif

char get_next_char(const unsigned char **buffer);
int convert_atoi_substr(const unsigned char **buffer);

#ifdef __XC__
}
#endif

#endif // __C_UTILS_H__
