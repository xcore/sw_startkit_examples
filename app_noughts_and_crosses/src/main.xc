#include "strategy.h"
#include "user_input.h"
#include "user_output.h"

#include <xscope.h>
#include <xs1.h>

void xscope_user_init(void) {
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
