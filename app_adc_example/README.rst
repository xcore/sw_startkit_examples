ADC Example
===========

:scope: Example
:description: A simple demo that lights LEDs proportionally to the ADC inputs
:keywords: LEDs, startKIT, ADC


Very simple example of using the ADC module. It uses the ADC in one shot mode (each time trigger is called every 200ms from a timer) and then reads the 4 values after conversion complete notification received. It also shows an example of a select (wait on multiple events) because it also listens to the button, and lights additional LEDs when that is pressed.

Touch the ADC0..ADC3 pads/pins in the bottom left hand corner to light the LEDs! 

The values are also printed on the screen (ensure xscope i/o is enabled in the GUI, or use xrun --xscope at the command line).