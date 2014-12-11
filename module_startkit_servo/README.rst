Servo Driver for startKIT
========================-

:scope: Example
:description: A module for generating servo control signals startKIT
:keywords: startKIT, servo, PWM, PPM

Provides a simple example of generating multiple timed pulses from a single wide (4,8,16 or 32b) port, using a single logical. Currently set at 20ms period, 700-2300us high time, it provides an ideal way of driving multiple servos. It makes use of a tools version 13 feature of soft timers, meaning the code declares one timer per servo channel (for each pin) and one for the end of frame. Ie. N+1. It means that only one timer is consumed, regardless of channels. It also uses an interface to set set the duty.


There is a price to pay for having multiple events handled by a single core - if multiple events arrive at the same time (eg. duties all set to the same value) then some transitions will be delayed. This has been calculated to be about 0.5% error (from min to max position) worst case when 8 channels are used on a single port, ot 0.15% error on a 4 channel system on a single 4b port.

This has been tested on startKIT with the lines wired directly from the 3v3 I/O. It seemed to work fine, even though the servo was powered from 5V.

There is more info in the code (including API) in servo.h and servo.xc. Also, see app_servo for a usage example.

Happy servoing!

