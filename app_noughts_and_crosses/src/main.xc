// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "strategy.h"
#include "user_input.h"
#include "user_output.h"

#include <xscope.h>
#include <xs1.h>

void xscope_user_init(void) {
    xscope_config_io(XSCOPE_IO_BASIC);
}

/** Main program for noughts and crosses. Fork off the strategy thread,
 * input and output.
 */
main() {
    chan i_to_o, s_to_o;
    par {
        strategy(s_to_o);
        user_input(i_to_o);
        user_output(s_to_o, i_to_o);
    }
}
