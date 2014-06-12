// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "audio_io.h"

// Global Structure for  I2S resources
on stdcore[0] : r_i2s i2s_resource_s =
{
    XS1_CLKBLK_1,
    XS1_CLKBLK_2,
    PORT_MCLK_IN,             // Master Clock
    PORT_I2S_BCLK,            // Bit Clock
    PORT_I2S_LRCLK,           // LR Clock

#if I2S_MASTER_NUM_CHANS_ADC == 4
    {PORT_I2S_ADC0, PORT_I2S_ADC1},
#elif I2S_MASTER_NUM_CHANS_ADC == 2
    {PORT_I2S_ADC0},
#else
#error Unsupported No Of I2S_MASTER_NUM_CHANS_ADC Channels
#endif

#if I2S_MASTER_NUM_CHANS_DAC == 4
    {PORT_I2S_DAC0, PORT_I2S_DAC1}
#elif I2S_MASTER_NUM_CHANS_DAC == 2
    {PORT_I2S_DAC0}
#else
#error Unsupported No Of I2S_MASTER_NUM_CHANS_DAC Channels
#endif

}; // r_i2s

on stdcore[0] : port p_i2c = PORT_I2C;
on stdcore[0] : out port p_gpio = PORT_GPIO;

void audio_hw_init() // Initialise Hardware
{
    // Initialise the I2C bus
    i2c_master_init(p_i2c);
}

void audio_hw_config(unsigned samFreq)
{
    // Note we do this everytime since we reset CODEC on Sample-Frequency change
    codec_config(samFreq, MCLK_FREQ);
}

void audio_io(streaming chanend c_aud)
{
    unsigned mclk_bclk_div = MCLK_FREQ/(SAMP_FREQ * 64); // Calculate Bit-clock frequency

    audio_hw_init();	        // Configure the CODECs
    audio_hw_config(SAMP_FREQ); // Configure the clocking
    i2s_master(i2s_resource_s, c_aud, mclk_bclk_div); // Call I2S master loop
}
