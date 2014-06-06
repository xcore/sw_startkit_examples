#include "level.h"
#include "debug_print.h"
#include "app_conf.h"

void initLevelState(levelState &ls, int attack_ns, int release_ns, int threshold_percent)
{
  ls.level = 0;
  ls.attack_ns = attack_ns;
  if (attack_ns == 0)
    ls.attack_rate = MAX_LEVEL;
  else
    ls.attack_rate = MAX_LEVEL / attack_ns * NS_PER_SAMPLE;

  ls.release_ns = release_ns;
  if (ls.release_ns == 0)
    ls.release_rate = MAX_LEVEL;
  else
    ls.release_rate = MAX_LEVEL / release_ns * NS_PER_SAMPLE;

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

