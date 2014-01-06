Startkit Dalek example
=================================

:scope: Example
:description: Does ring modulation (AM of LFO) and applies a BiQuad filter to a stereo stream on the startKIT/audio slice boards
:keywords: biquad, filter, equalisation, audio, dsp, slicekit
:boards: XA-SK-AUDIO

The sliders control modulation depth and frequency of the triangular LFO.
Button toggles between Dry and Effect signals, each time the Effect is called a different filter is used. The LED shows where you are in the cycle.
The filter cycles through the following pre-defined types: Low Pass, High Pass, Band Pass, Band Stop, All Pass

   * The Audio_IO uses 1 logical core (aka thread).
   * The LFO uses 1 logical core.
   * The DSP BiQuad function uses 1 logical core.
   * The LED/Buttons/Slider interface uses 1 logical core too