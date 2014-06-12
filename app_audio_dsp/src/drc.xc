// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "drc.h"
#include "debug_print.h"
#include "xclib.h"
#include "app_conf.h"
#include "level.h"

static int do_gain(int sample, int gain)
{
  long long value = (long long) sample * (long long) gain;
  return value >> 31;
}

static int merge(int a, int b, int a_not_b)
{
  long long tmp_a = (long long) a * (long long) a_not_b;
  long long tmp_b = (long long) b * (long long) (MAX_GAIN - a_not_b);

  a = tmp_a >> 31;
  b = tmp_b >> 31;

  return a + b;
}

#define DRC_THRESHOLD(x) (x), ((x==100) ? MAX_VALUE : (MAX_VALUE / (long long)100 * (long long)x))
#define DRC_GAIN(x) (x), ((x==100) ? MAX_GAIN : (MAX_GAIN / (long long)100 * (long long)x))

drcControl drcTable[DRC_NUM_THRESHOLDS] = {
  { DRC_THRESHOLD(60), DRC_GAIN(70) },
  { DRC_THRESHOLD(70), DRC_GAIN(60) },
  { DRC_THRESHOLD(80), DRC_GAIN(50) }
};

void initDrc()
{
}

int drc(int xn, int level)
{
  int drc_value = xn;
  int negative = 0;

  if (xn < 0) {
    drc_value = -xn;
    negative = 1;
  }

  for (int i = 0; i < DRC_NUM_THRESHOLDS; i++) {
    if (drc_value > drcTable[i].threshold) {
      drc_value = drcTable[i].threshold + do_gain(drc_value - drcTable[i].threshold, drcTable[i].gain_factor);
    }
  }

  if (negative)
    drc_value = -drc_value;

  return merge(drc_value, xn, level << LEVEL_TO_GAIN_SHIFT);
}

