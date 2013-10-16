Absolute position
=================

:scope: Example
:description: A simple demo showing the use of slides and leds on startKIT.
:keywords: capacitive, sensors, startKIT

This program demonstrates that sliders can be used to read an (approximate)
X and Y location. The position is highlighted by means of an (anti aliased)
LED. Moving a finger along either slider will move the LED along.


Implementation
--------------

There are three tasks:

* A task to drive the leds and capacitive sensors. This uses the
  driver found in ``module_starkit_gpio``
* A task that performs the output. It averages out a virtual ball position
  and sets the LED levels to display its position in an antialised manner.
* A task that reacts to the capacitive sense events and uses them to
  update the ball display task.
