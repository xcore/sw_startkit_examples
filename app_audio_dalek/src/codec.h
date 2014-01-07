/******************************************************************************\
 * Header:  config
 * File:    config.h
 *  
 * Description: Definitions, types, and prototypes for config.xc
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

#ifndef _CODEC_H_
#define _CODEC_H_

#include <print.h>
#include "i2c.h"
#include "xa_sk_audio_1v0.h"

extern port p_i2c;
extern out port p_gpio;


#define CODEC1_I2C_DEVICE_ADDR       (0x90)
#define CODEC2_I2C_DEVICE_ADDR       (0x92)

#define CODEC_DEV_ID_ADDR           0x01
#define CODEC_PWR_CTRL_ADDR         0x02
#define CODEC_MODE_CTRL_ADDR        0x03
#define CODEC_ADC_DAC_CTRL_ADDR     0x04
#define CODEC_TRAN_CTRL_ADDR        0x05
#define CODEC_MUTE_CTRL_ADDR        0x06
#define CODEC_DACA_VOL_ADDR         0x07
#define CODEC_DACB_VOL_ADDR         0x08

#define IIC_REGWRITE(reg, val) {data[0] = val; i2c_master_write_reg(CODEC1_I2C_DEVICE_ADDR, reg, data, 1, p_i2c);data[0] = val; i2c_master_write_reg(CODEC2_I2C_DEVICE_ADDR, reg, data, 1, p_i2c);} 
#define IIC_REGREAD(reg, val)  {i2c_master_read_reg(CODEC1_I2C_DEVICE_ADDR, reg, val, 1, p_i2c);}

/*****************************************************************************/
void codec_config( // Configure Codec
	unsigned samFreq, // Sample Frequency
	unsigned mClk // Master Clock
);
/*****************************************************************************/

#endif // _CODEC_H_
/*****************************************************************************/
// codec.h
