Absolute position
=================

This program demonstrates that sliders can be used to read an (approximate)
X and Y location. The position is highlighted by means of an (anti aliased)
LED. moving a finger along either slider will move the LED along.


Implementation
--------------

There are two tasks:

* A task that performs the output. It PWMs the LEDs to show the position in
  an antialised manner.

* A task that operates the sliders. The repository
  ``sc_capacitive_sensing`` is used to implement the absolute positioning.

