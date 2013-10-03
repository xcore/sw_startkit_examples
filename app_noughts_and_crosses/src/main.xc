#include "strategy.h"
#include "user_input.h"
#include "user_output.h"

#include <xscope.h>
#include <xs1.h>

void xscope_user_init(void) {
    xscope_register(3,
                    XSCOPE_CONTINUOUS, "X Value", XSCOPE_INT, "Value",
                    XSCOPE_CONTINUOUS, "Y Value", XSCOPE_INT, "Value",
                    XSCOPE_CONTINUOUS, "Z Value", XSCOPE_INT, "Value");
    xscope_config_io(XSCOPE_IO_BASIC);
}

t() {
    timer tmr;
    int time;
tmr :> time;
    while(1) {
        for(int i = 0; i < 100; i++) {
            xscope_probe_data(0, i);
            xscope_probe_data(1, 123123123);
            tmr when timerafter(time+= i*100) :> void;
        }
    }
}

main() {
    chan i_to_o, i_to_s, s_to_o;
    par {
        strategy(i_to_s, s_to_o);
        user_input(i_to_s, i_to_o);
        user_output(s_to_o, i_to_o);
//        t();
    }
}
