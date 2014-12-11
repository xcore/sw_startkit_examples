#ifndef SERVO_H_
#define SERVO_H_
#include <timer.h>

//Timing constants
#define MICROSECOND             (XS1_TIMER_HZ / 1000000)
#define SERVO_MIN_POS           (700 * MICROSECOND)
#define SERVO_MAX_POS           (2300 * MICROSECOND)
#define SERVO_CENTRE_POS        ((SERVO_MIN_POS + SERVO_MAX_POS) / 2)
#define SERVO_PERIOD            (20000 * MICROSECOND)

//Interface for setting duties.
//Param 1 - Channel number 0 -> (port_width - 1)
//Param 2 - duration/position in 10ns timer ticks. Will be clipped to MIN/MAX range
//Returns - void
interface servo_if{
    void set_pos(unsigned channel, int position);
};

//Task for controlling outputs. While (1) task that is controlled over interface
//Param 1 - Interface for calling set duty method
//Param 2 - The port used for servo control
//Param 3 - The width of the port used (1 - 32)
//Param 4 - Initial position (pulse width) for all channels
//Returns - void. While (1) so never returns
void servo_task(server interface servo_if i_servo, out port p_servo,
        static const unsigned port_width, static const unsigned initial_position);

#endif /* SERVO_H_ */
