#include "drc.h"
#include "debug_print.h"
#include "stdio.h"
#include "xclib.h"

#define MAX_VALUE ((1 << 23) - 1)
#define MIN_VALUE (-(1 << 23))

/* Apply gain, 0 to 7fffffff*/
int do_gain(int sample, int gain)
{
  long long value = (long long) sample * (long long) gain;

  int ivalue = value >> 31;

  // Clipping
  if (ivalue > MAX_VALUE)
    ivalue = MAX_VALUE;
  else if (ivalue < MIN_VALUE)
    ivalue = MIN_VALUE;

  return ivalue;
}

typedef struct drcControl {
  int input_offset;
  int output_offset;
  int gain;
} drcControl;

#define COMPUTED_AT_RUNTIME 0
#define DRC_GAIN(x) ((x==100) ? 0x7fffffffll : (0x7fffffffll / (long long)100 * (long long)x))

drcControl drcTable[] = {
  { 0x80000000u, COMPUTED_AT_RUNTIME, DRC_GAIN(5) }, // clz 0
  { 0x40000000u, COMPUTED_AT_RUNTIME, DRC_GAIN(5) }, // clz 1
  { 0x20000000u, COMPUTED_AT_RUNTIME, DRC_GAIN(5) }, // clz 2
  { 0x10000000u, COMPUTED_AT_RUNTIME, DRC_GAIN(5) }, // clz 3
  { 0x08000000u, COMPUTED_AT_RUNTIME, DRC_GAIN(10) }, // clz 4
  { 0x04000000u, COMPUTED_AT_RUNTIME, DRC_GAIN(10) }, // clz 5
  { 0x02000000u, COMPUTED_AT_RUNTIME, DRC_GAIN(20) }, // clz 6
  { 0x01000000u, COMPUTED_AT_RUNTIME, DRC_GAIN(20) }, // clz 7
  { 0x00800000u, COMPUTED_AT_RUNTIME, DRC_GAIN(40) }, // clz 8
  { 0x00400000u, COMPUTED_AT_RUNTIME, DRC_GAIN(40) }, // clz 9
  { 0x00200000u, COMPUTED_AT_RUNTIME, DRC_GAIN(60) }, // clz 10
  { 0x00100000u, COMPUTED_AT_RUNTIME, DRC_GAIN(60) }, // clz 11
  { 0x00080000u, COMPUTED_AT_RUNTIME, DRC_GAIN(80) }, // clz 12
  { 0x00040000u, COMPUTED_AT_RUNTIME, DRC_GAIN(80) }, // clz 13
  { 0x00020000u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 14
  { 0x00010000u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 15
  { 0x00008000u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 16
  { 0x00004000u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 17
  { 0x00002000u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 18
  { 0x00001000u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 19
  { 0x00000800u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 20
  { 0x00000400u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 21
  { 0x00000200u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 22
  { 0x00000100u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 23
  { 0x00000080u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 24
  { 0x00000040u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 25
  { 0x00000020u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 26
  { 0x00000010u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 27
  { 0x00000008u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 28
  { 0x00000004u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 29
  { 0x00000002u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 30
  { 0x00000001u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 31
  { 0x00000000u, COMPUTED_AT_RUNTIME, DRC_GAIN(100) }, // clz 32
};

void compute_slope_values()
{
  drcTable[0].output_offset = 0;

  for (int i = 31; i >= 0; i--) {
    unsigned x_diff = drcTable[i].input_offset - drcTable[i+1].input_offset;
    drcTable[i].output_offset = drcTable[i+1].output_offset + do_gain(x_diff, drcTable[i+1].gain);
  }
}

static int table_ready = 0;

void initDrc()
{
  if (!table_ready) {
    compute_slope_values();
    table_ready = 1;
  }
}

int drc(int xn)
{
  int negative = 0;
  if (xn < 0) {
    xn = -xn;
    negative = 1;
  }
  int bits = clz(xn);

  int slope = do_gain(xn - drcTable[bits].input_offset, drcTable[bits].gain);
  int value = drcTable[bits].output_offset + slope;
  if (negative)
    return -value;
  else
    return value;
}

