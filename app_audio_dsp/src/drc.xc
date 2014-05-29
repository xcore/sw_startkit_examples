#include "drc.h"
#include "debug_print.h"
#include "xclib.h"

/* Apply gain, 0 to 7fffffff*/
static int do_gain(int sample, int gain)
{
  long long value = (long long) sample * (long long) gain;
  return value >> 31;
}

#define DRC_GAIN(x) (x), ((x==100) ? 0x7fffffffll : (0x7fffffffll / (long long)100 * (long long)x))

drcControl drcTable[DRC_NUM_THRESHOLDS] = {
  { 0x00200000u, DRC_GAIN(70) },
  { 0x00400000u, DRC_GAIN(50) },
  { 0x00600000u, DRC_GAIN(30) }
};

void initDrc()
{
}

int drc(int xn)
{
  int negative = 0;
  if (xn < 0) {
    xn = -xn;
    negative = 1;
  }
  for (int i = 0; i < DRC_NUM_THRESHOLDS; i++) {
    if (xn > drcTable[i].threshold) {
      xn = drcTable[i].threshold + do_gain(xn - drcTable[i].threshold, drcTable[i].gain_factor);
    }
  }
  if (negative)
    return -xn;
  else
    return xn;
}

