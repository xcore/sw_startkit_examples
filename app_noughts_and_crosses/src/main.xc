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

main() {
    chan i_to_o, s_to_o;
    par {
        strategy(s_to_o);
        user_input(i_to_o);
        user_output(s_to_o, i_to_o);
    }
}
