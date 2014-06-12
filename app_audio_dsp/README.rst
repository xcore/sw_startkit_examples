Startkit Audio DSP Example
==========================

:scope: Example
:description: Basic DSP evaluation application
:keywords: biquad, DRC, audio, dsp, startkit
:boards: XA-SK-AUDIO

The button cycles through the available DSP modes:
   * None
   * Biquads
   * DRC
   * Biquads and DRC

There are two host control applications, a command-line (host_dsp_control) and a GUI (host_dsp_gui)
which is a QT application.

In order to connect the control application the target application must be run using the xSCOPE
server::

    xrun --xscope-port localhost:12346 bin/startkit_audio_dsp.xe

*Note*: the port (12346) is simply an example.
*Note*: the application will not start until a control application is connected

Command-line controller
-----------------------

The command-line controller is connected using::

    cd host_dsp_control
    ./dsp_control -p 12346

*Note*: the port (-p 12346) simply has to match the one used with xrun.

The usage commands available through the command-line controller are shown by simply pressing 'h+ENTER'.

GUI controller
--------------

The GUI controller is in the host_dsp_gui/ folder. QT will be required. It was developed with
Qt Creator 5.3.0. To build it simply open the provided .pro file. Then run it and it will connect
to the device. There is currently a hard-coded assumption that the port is 12346 in this
controller.

*Note*: it is possible to connect multiple controller at the same time.

Real-time xSCOPE
----------------

In order to view the audio signals in and out, and the level detection state you can connect the
real-time xSCOPE view in the xTIMEcomposer tools.

*Note*: xTIMEcomposer 13.1.1 or newer is required to connect real-time xSCOPE simultaneously with
a controller.

