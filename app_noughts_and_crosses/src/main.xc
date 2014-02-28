// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
#include <xs1.h>
#include <platform.h>
#include "game.h"
#include "user_player.h"
#include "computer_player.h"

/**
  The tic-tac-toe demo is a program that plays tic-tac-toe (also known as
  noughts and crosses) on a XMOS startKIT development board. It is provided
  as a demonstation program of how to program the device.
  The 3x3 display of LEDs shows the board status:

    - Full LEDs: user player (marking a O)
    - Dimmed LEDs: computer player (marking a 1)

  When it is the user's move, one of the LEDs flashes - this is a cursor and
  it can be moved by swiping the sliders. Pressing the button makes a move,
  and the computer player will make the next move.

  The application consists of four tasks:

    * The ``startkit_gpio_driver`` task drives the LEDs on the device (using
      PWM to make the lights glow at different levels of intensity), the
      capacitive sensors on the sliders and the button. It has three
      interface connections connected to it - one for the button, one for the
      LEDs and one for the slider.
    * The ``game`` task which controls the game state. It is connected to the
      two player tasks and to the gpio task to drive the LEDs to display the
      game state.
    * The ``user_player`` task which receives notifications from
      and sends commands to the game task. It also connects to the
      gpio task to read the sliders and buttons when the user player makes
      a move.
    * The ``cpu_player`` task which receives notifications from and send
      commands to the game task. It uses an internal AI algorithm to determine
      what move to make.

  .. aafig::

                `gpio_driver`    `      `user player task` `cpu player task`
                +--------+              +-------+          +-------+
                |        | `button_if`  |       |          |       |
                |        +<-------------+       |          |       |
          I/O<--+        | `slider_if`  |       |          |       |
                |        +<-------------+       +--+    +--+       |
                |        |              |       |  |    |  |       |
                +--+-----+              +-------+  |    |  |       |
                   ^                               |    |  +-------+
                   |           `game task`         |    |
                   |           +-------+           |    |
                   |           |       |           |    |
                   +-----------+       +<----------+    |
                   `led_if`    |       |  `game_if`     |
                               |       +<---------------+
                               |       |
                               +-------+

  The four tasks are spread across two logical cores. One
  logical core runs the gpio driver which needs to be responsive to the I/O
  pins. The other core runs the other three tasks which do not have real-time
  constraints and share the core via co-operative multitasking.

**/

/**
  The main program consists of a ``par`` statement to run all the tasks in
  parallel with three tasks placed on the same core. The declarations
  are typedefs of interface types to connect the tasks together.
*/

// The port structure required for the GPIO task
startkit_gpio_ports gpio_ports =
  {XS1_PORT_32A, XS1_PORT_4A, XS1_PORT_4B, XS1_CLKBLK_1};

int main() {
  startkit_button_if i_button;
  startkit_led_if i_led;
  slider_if i_slider_x, i_slider_y;
  player_if i_game[2];
  par {
    on tile[0].core[0]: game(i_game, i_led);
    on tile[0].core[0]: user_player(i_game[0],
                                    i_slider_x, i_slider_y, i_button);
    on tile[0].core[0]: computer_player(i_game[1]);
    on tile[0]: startkit_gpio_driver(i_led, i_button,
                                     i_slider_x, i_slider_y,
                                     gpio_ports);

  }
  return 0;
}
