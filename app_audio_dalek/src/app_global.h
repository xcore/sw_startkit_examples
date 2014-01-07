/******************************************************************************\
 * Header:  app_global
 * File:    app_global.h
 *
 * Description: Global Definitions, types, and prototypes for application
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



#ifndef _APP_GLOBAL_H_
#define _APP_GLOBAL_H_

// Comment-out if NOT using xscope
#define USE_XSCOPE 1

// Tile that Audio Slice is connected to
#define	AUDIO_IO_TILE 0	// Tile connected to Audio Slice board
#define	DSP_TILE 0 // Tile used by DSP functions

// Audio sample frequency (Hz)
#define SAMP_FREQ			48000

// Audio Slice hardware version
#define AUDIO_SLICE_HW_MAJOR 1
#define AUDIO_SLICE_HW_MINOR 1

// Audio clocking defines
// Master clock defines (Hz)
#define MCLK_FREQ_441       (512*44100)   // 44.1, 88.2 etc
#define MCLK_FREQ_48        (512*48000)   // 48, 96 etc

#if (SAMP_FREQ%22050==0)
#define MCLK_FREQ           MCLK_FREQ_441
#elif (SAMP_FREQ%24000==0)
#define MCLK_FREQ           MCLK_FREQ_48
#else
#error Unsupported sample frequency
#endif

// Bit clock divide
#define BCLK_DIV        (MCLK_FREQ / (SAMP_FREQ * 64))

// Ports
#if ((AUDIO_SLICE_HW_MAJOR == 1) && (AUDIO_SLICE_HW_MINOR == 1))
#define PORT_I2S_DAC0		XS1_PORT_1G
#define PORT_I2S_DAC1  		XS1_PORT_1H
#define PORT_I2S_ADC0  		XS1_PORT_1K
#define PORT_I2S_ADC1		XS1_PORT_1L
#define PORT_I2S_LRCLK		XS1_PORT_1I
#define PORT_I2S_BCLK		XS1_PORT_1F
#define PORT_MCLK_IN		XS1_PORT_1E

#define PORT_GPIO			XS1_PORT_4C
#define PORT_I2C			XS1_PORT_4D

#else
#error currently not un-supported slice hw version
#endif

#endif // ifndef _APP_GLOBAL_H_
/*****************************************************************************/
// app_global.h
