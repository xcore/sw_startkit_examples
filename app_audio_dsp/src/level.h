#ifndef __level_h__
#define __level_h__

#include "app_global.h"

#define MIRCO_SEC_PER_SAMPLE (1000000 / SAMP_FREQ)

#define LEVEL_BITS 29
#define MAX_LEVEL ((1 << LEVEL_BITS) - 1)
#define LEVEL_TO_GAIN_SHIFT (31 - LEVEL_BITS)

/**
 * The _percent and _ns members are only for user display
 */
typedef struct levelState {
  int level;
  int attack_micro_sec;
  int attack_rate;
  int release_micro_sec;
  int release_rate;
  int threshold_percent;
  int threshold;
} levelState;

extern void initLevelState(levelState &ls, int attack_micro_sec, int release_micro_sec, int threshold);

extern void computeLevel(levelState &ls, int xn);

#endif // __level_h__
