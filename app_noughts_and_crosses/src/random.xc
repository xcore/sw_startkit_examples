#include "random.h"
#include <xs1.h>

int my_random(int v) {
    timer t;
    unsigned time, r;
    int r0 = 0;
    for(int i = 0x070b; i <= 0x0a0b; i += 0x100) {
        r0 = (r0 << 1) ^ getps(i);                   // This gets the RO values
    }
    r = r0;                                          // The last 4 bits are xored in.
    setps(0x060b, 0xF);                              // enable RO
    t :> time;
    t when timerafter(time+5000) :> int _;           // Run RO for 50 us
    setps(0x060b, 0);                                // disable RO
    r0 = 0;
    for(int i = 0x070b; i <= 0x0a0b; i += 0x100) {
        r0 = (r0 << 1) ^ getps(i);                   // XOR RO values, specifically last 4 bits
    }
    r ^= r0;                                         // last 4 bits are random.
    return r % v;    // this will have a bias when v is not a power of 2.
}
