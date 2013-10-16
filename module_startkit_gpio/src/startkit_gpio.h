#ifndef _startkit_gpio_h_
#define _startkit_gpio_h_
#include "slider.h"

 /** Enum for controlling led levels.
  *
  *  Leds can be set in the range LED_OFF .. LED_ON. The exact resolution
  *  depends on the driver.
  */
 enum led_val {
   LED_OFF = 0x0,
   LED_ON  = 0xFFFF
 };

 /** Interface for controlling leds on the startkit.
  */
 typedef interface startkit_led_if  {
   /** Set an led output level.
    *
    *  Use this function to set a single led in the range LED_OFF .. LED_ON
    */
   void set(unsigned row, unsigned col, unsigned val);

   /** Set multiple led values.
    *
    *  Use this function to set the level of several leds at once.
    *  The first argument is a bitmask where the least signifcant nine
    *  bits map to the led array in the following way:
    *
    *       8 7 6
    *       5 4 3
    *       2 1 0
    *
    *  If the bit is set in the mask then the led is set to the second argument.
    *  If the bit is not set then the led is set to LED_OFF.
    */
   void set_multiple(unsigned mask, unsigned val);

 } startkit_led_if;

 /** Enum for representing button state */
 typedef enum button_val {
   BUTTON_UP,
   BUTTON_DOWN
 } button_val_t;

 /** Interface for interacting with buttons */
 typedef interface startkit_button_if {
   /** This notification occurs when the button changes state (i.e. goes
    *  up->down or down->up).
    *
    *  You can select on this in your program e.g. ::
    *
    *  void f(client startkit_button_if i_button) {
    *    ...
    *    select {
    *      case i_button.change():
    *         button_val_t val = get_value();
    *         ....
    *
    */
   [[notification]] slave void changed();

   /** Get the current value of the button.
    *
    *  This returns either BUTTON_UP or BUTTON_DOWN.
    */
   [[clears_notification]] button_val_t get_value();

 } startkit_button_if;


 /* Simple LED driver
  *
  * This task will drive leds according to commands received via the
  * interface startkit_led_if. It has no resolution or pwm, so leds will either
  * be turned on or off depending on whether the level is greater or less
  * than LED_ON/2.
  *
  * The drive is distributable, so will not take up any compute on a logical core
  * of its own unless it is connected to clients on a different tile.
  */
 [[distributable]]
 void startkit_led_driver(server startkit_led_if c_led[n], unsigned n, port p32);

/** Ports/clocks for startkit GPIO, the ports
 *  should be XS1_PORT_32A, XS1_PORT_4A, XS1_PORT_4B.
 *
 */
typedef struct startkit_gpio_ports
{
  port p32;  // 32-bit port for leds/button
  port capx;  // 4-bit capsense port - x slider
  port capy;  // 4-bit capsense port - y slider
  clock clk;  // clock for capsense (if capsense required)
} startkit_gpio_ports;


 /** startKIT gpio driver.
  *
  *  This task drives pwm output on the leds to varying brightness and
  *  also reads the button on the board.
  *
  *  It requires the startKIT's 32 bit port (XS1_PORT_32A) to be passed
  *  as the last argument.
  *
  *  Clients can connect via the first two arguments. Several clients can
  *  connect to set led levels.
  *
  *  The function is combinable so can share a logical core with other combinable
  *  tasks. If combined is will use cooperative multitasking to periodically
  *  drive the pwm and sample the button value.
  */
 [[combinable]]
 void startkit_gpio_driver(server startkit_led_if ?i_led,
                           server startkit_button_if ?i_button,
                           server slider_if ?i_slider_x,
                           server slider_if ?i_slider_y,
                           startkit_gpio_ports &ps);



 #endif // _startkit_gpio_h_
