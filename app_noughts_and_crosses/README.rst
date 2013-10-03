Noughts and crosses (tic-tac-toe)
=================================


This is a program that plays noughts and crosses on a startKIT.
The 3x3 display of LEDs shows the board status:

 - full LEDs: X, user
 - dimmed LEDs: O, computer

WHen it is the user's move one of the LEDs flashes - this is a cursor and
it can be moved by swiping the sliders. Pressing the button makes a move,
and the XCORE will make the next move.


Implementation
--------------

There are three tasks:

* A task that performs the output. It PWMs the LEDs, shows the blinking
  cursor, and awaits input on the button: ``user_output.xc``

* A task that operates the sliders: ``user_input.xc``. The repository
  ``sc_capacitive_sensing`` is used to implement the sliders.

* A task that calculates the next move: ``strategy.xc``

