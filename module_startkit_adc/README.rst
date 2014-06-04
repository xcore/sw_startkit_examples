ADC Driver for startKIT
========================

:scope: Example
:description: A module for accessing the 4ch ADC on startKIT
:keywords: startKIT, ADC, analog, analogue


Presents the U8A/startKIT 12b ADC in an MCU-like manner by abstracting away
channels, link setup (for startKIT FLASH boot) and trigger requirements.


Enables all 4 channels and provides simple API for trigger, read and conversion complete event. Practical fastest sample rate (to aquire all 4 channels) with all cores running flat-out is about 50us (to trigger, aquire, notify and read). So about 20KHz. Assumes core sharing with startkit_GPIO task (slow).
Ie. This module is built for comfort rather than speed. Give it it's own core and only run 4 cores total,and this number jumps to about 6us, or about 165KHz. Much closer to max theoretical b/w of 1MHz/4 = 250KHz

Runs in two modes (self triggering periodically or trigger on request). Trigger function still callable in periodic mode and conversion finished notification available in period mode if needed. Task is combinable so you can run it with other low speed tasks in the same logical core! (eg. GPIO)
