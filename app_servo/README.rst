Servo test
==========

:scope: Example
:description: Simple demo that exercises the servo library module
:keywords: servo, PWM, PPM, startKIT

Simple test for the servo module. Ramps all 4 signals from min to max over a few seconds

Implementation
--------------

There are two tasks:

* A task to drive the servo on a single wide port. This uses the
  driver found in ``module_strtkit_servo``
* A task that generates ramp up/down commands for the servo driver

