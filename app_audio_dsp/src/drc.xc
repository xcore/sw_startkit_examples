#include "drc.h"
#include "debug_print.h"
#include "xclib.h"

/* Apply gain, 0 to 7fffffff*/
static int do_gain(int sample, int gain)
{
  long long value = (long long) sample * (long long) gain;
  return value >> 31;
}

typedef struct drcControl {
  int base;
  int gain;
} drcControl;

#define DRC_GAIN(x) ((x==100) ? 0x7fffffffll : (0x7fffffffll / (long long)100 * (long long)x))

#define DRC_NUM_THRESHOLDS 3

drcControl drcTable[DRC_NUM_THRESHOLDS] = {
  { 0x00100000u, DRC_GAIN(70) },
  { 0x00400000u, DRC_GAIN(50) },
  { 0x01000000u, DRC_GAIN(30) }
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
    if (xn > drcTable[i].base) {
      xn = drcTable[i].base + do_gain(xn - drcTable[i].base, drcTable[i].gain);
    }
  }
  if (negative)
    return -xn;
  else
    return xn;
}

