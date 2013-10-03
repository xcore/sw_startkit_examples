The spinning LED
================

This is a slightly more complex version of the spinning bar. Rather than
spinning a bar a single LED is spun around the edge of the 3x3 square, but
its movement is smoothed out by antialiasing. A LED will gradually be
switched on whilst the previous LED is gradually switched off.

It just requires a single main program that outputs a sequence of values to
the LEDs. When the postition has moved a fraction of X% between two LEDs,
then the next LED pattern is driven for X% of the time, and then the old
pattern is driven for 100-X% of the time. The PWM periodicity is 1ms, so a
1% duty cycle results in a 10 us on and 990 us off period.

As an added bonus the middle LED is flipped on every rotation.
