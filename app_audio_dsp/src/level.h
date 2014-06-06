#ifndef __level_h__
#define __level_h__

#include "app_global.h"

#define NS_PER_SAMPLE (1000000000 / SAMP_FREQ)

#define LEVEL_BITS 29
#define MAX_LEVEL ((1 << LEVEL_BITS) - 1)
#define LEVEL_TO_GAIN_SHIFT (31 - LEVEL_BITS)

/**
 * The _percent and _ns members are only for user display
 */
typedef struct levelState {
  int level;
  int attack_ns;
  int attack_rate;
  int release_ns;
  int release_rate;
  int threshold_percent;
  int threshold;
} levelState;

extern void initLevelState(levelState &ls, int attack_ns, int release_ns, int threshold);

extern void computeLevel(levelState &ls, int xn);

#endif // __level_h__
