// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
#include <xs1.h>
#include <platform.h>
#include "game.h"
#include "user_player.h"
#include "computer_player.h"

startkit_gpio_ports gpio_ports =
  {XS1_PORT_32A, XS1_PORT_4A, XS1_PORT_4B, XS1_CLKBLK_1};

/** Main program for noughts and crosses. Fork off the strategy thread,
 * input and output.
 */
int main() {
  startkit_button_if i_button;
  startkit_led_if i_led;
  slider_if i_slider_x, i_slider_y;
  player_if i_game[2];
  par {
    on tile[0]: game(i_game, i_led);
    on tile[0]: user_player(i_game[0], i_slider_x, i_slider_y, i_button);
    on tile[0]: computer_player(i_game[1]);
    on tile[0]: startkit_gpio_driver(i_led, i_button,
                                     i_slider_x, i_slider_y,
                                     gpio_ports);

  }
  return 0;
}
