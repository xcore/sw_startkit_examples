/******************************************************************************\
 * File:	audio_io.xc
 *  
 * Description: Audio I/O Coar
 *
 * Version: 0v1
 * Build:
 *
 * The copyrights, all other intellectual and industrial
 * property rights are retained by XMOS and/or its licensors.
 * Terms and conditions covering the use of this code can
 * be found in the Xmos End User License Agreement.
 *
 * Copyright XMOS Ltd 2012
 *
 * In the case where this code is a modification of existing code
 * under a separate license, the separate license terms are shown
 * below. The modifications to the code are still covered by the
 * copyright notice above.
 *
\******************************************************************************/

#include "audio_io.h"

// Global Structure for  I2S resources		
on stdcore[AUDIO_IO_TILE] : r_i2s i2s_resource_s =
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

on stdcore[AUDIO_IO_TILE] : port p_i2c = PORT_I2C;
on stdcore[AUDIO_IO_TILE] : out port p_gpio = PORT_GPIO;

/*****************************************************************************/
void audio_hw_init() // Initialise HardWare
{
	// Initialise the I2C bus
	i2c_master_init( p_i2c );
} // audio_hw_init
/*****************************************************************************/
void audio_hw_config( // Setup the CODEC for use.
	unsigned samFreq // Sample frequency
)
{
	// Note we do this everytime since we reset CODEC on Sample-Frequency change
	codec_config( samFreq ,MCLK_FREQ );
}
/*****************************************************************************/
void audio_io( // Audio I/O coar
	streaming chanend c_aud // Audio end of channel between I/O and DSP coars
)
{
	unsigned mclk_bclk_div = MCLK_FREQ/(SAMP_FREQ * 64); // Calculate Bit-clock frequency


	audio_hw_init();	// Configure the CODECs

	audio_hw_config( SAMP_FREQ ); // Configure the clocking
            
	i2s_master( i2s_resource_s ,c_aud ,mclk_bclk_div ); // Call I2S master loop
} // audio_io
/*****************************************************************************/
// audio_io.xc
