GPIO Driver for startKIT
========================

:scope: Example
:description: A module for driving the LEDS, button and capsense on
              startKIT boards
:keywords: startKIT, leds, capacitive, buttons


This module provides a driver for the startKIT gpio functionality. It
allows users to react to swiper events and button presses and also
drive PWM output to different levels of brightness on the leds.

Due to the board design of the startKIT, the LEDs and button share a
single 32-bit port. Additionally, the capactive sensor wires a routed
very close to the LEDs. This means that the buttons and sensors can
only be sampled when the LEDs are not driving. This module handles
this synchronization is a separate task.
