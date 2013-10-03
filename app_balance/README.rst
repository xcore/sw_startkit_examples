Balance the ball (LED)
======================

This program requires an accelerometer slice.

It shows a ball (represented by a LED with some antialiasing) and when the
startKIT is tilted the ball will roll to the edge.

Implementation
--------------

There are two tasks:

* A task that performs the output. It PWMs the LEDs to show the position in
  an antialised manner. Values are averaged over 32 samples before being used.

* A task that queries the accelerometer. It uses ``sc_i2c`` to communicate
  with the accelerometer.
