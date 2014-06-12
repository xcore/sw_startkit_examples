// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "level.h"
#include "debug_print.h"
#include "app_conf.h"

void initLevelState(levelState &ls, int attack_micro_sec, int release_micro_sec, int threshold_percent)
{
  ls.level = 0;
  ls.attack_micro_sec = attack_micro_sec;
  if (attack_micro_sec == 0)
    ls.attack_rate = MAX_LEVEL;
  else
    ls.attack_rate = MAX_LEVEL / attack_micro_sec * MIRCO_SEC_PER_SAMPLE;

  ls.release_micro_sec = release_micro_sec;
  if (ls.release_micro_sec == 0)
    ls.release_rate = MAX_LEVEL;
  else
    ls.release_rate = MAX_LEVEL / release_micro_sec * MIRCO_SEC_PER_SAMPLE;

  ls.threshold_percent = threshold_percent;
  ls.threshold = (MAX_VALUE / 100) * threshold_percent;
}

void computeLevel(levelState &ls, int xn)
{
  if (xn < 0)
    xn = -xn;

  if (xn > ls.threshold) {
    ls.level += ls.attack_rate;
    if (ls.level > MAX_LEVEL)
      ls.level = MAX_LEVEL;
    
  } else {
    ls.level -= ls.release_rate;
    if (ls.level < 0) 
      ls.level = 0;
  }
}

