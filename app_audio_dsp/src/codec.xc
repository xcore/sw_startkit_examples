// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "codec.h"
#include "debug_print.h"

#define DO_READ_STATUS 0

void codec_config(unsigned sampleFrequency, unsigned mClk)
{
    timer t;
    unsigned time;
    unsigned tmp;

    unsigned char data[1] = {0};

    /* Set CODEC in reset */
    tmp = P_GPIO_COD_RST_N;

    /* Set master clock select appropriately */
    if ((sampleFrequency % 22050) == 0)
    {
        tmp &= ~P_GPIO_MCLK_SEL;
    }
    else //if((sampleFrequency % 24000) == 0)
    {
        tmp |= P_GPIO_MCLK_SEL;
    }

    /* Output to port */
    p_gpio <: tmp;

    /* Hold in reset for 2ms while waiting for MCLK to stabilise */
    t :> time;
    time += 200000;
    t when timerafter(time) :> int _;

    /* CODEC out of reset */
    tmp |= P_GPIO_COD_RST_N;
    p_gpio <: tmp;

    /* Set power down bit in the CODEC over I2C */
    IIC_REGWRITE(CODEC_DEV_ID_ADDR, 0x01);

#if DO_READ_STATUS
    /* Read CODEC device ID to make sure everything is OK */
    IIC_REGREAD(CODEC_DEV_ID_ADDR, data);

    int codec_dev_id = data[0];
    if (((codec_dev_id & 0xF0) >> 4) != 0xC)
        debug_print("Unexpected CODEC Device ID, expected 0xC, got %x", codec_dev_id);
#endif

    /* Now set all registers as we want them :
    Mode Control Reg:
    Set FM[1:0] as 11. This sets Slave mode.
    Set MCLK_FREQ[2:0] as 010. This sets MCLK to 512Fs in Single, 256Fs in Double and 128Fs in Quad Speed Modes.
    This means 24.576MHz for 48k and 22.5792MHz for 44.1k.
    Set Popguard Transient Control.
    So, write 0x35. */
    IIC_REGWRITE(CODEC_MODE_CTRL_ADDR,    0x35);

    /* ADC & DAC Control Reg:
       Leave HPF for ADC inputs continuously running.
       Digital Loopback: OFF
       DAC Digital Interface Format: I2S
       ADC Digital Interface Format: I2S
       So, write 0x09. */
    IIC_REGWRITE(CODEC_ADC_DAC_CTRL_ADDR, 0x09);

    /* Transition Control Reg:
       No De-emphasis. Don't invert any channels. Independent vol controls. Soft Ramp and Zero Cross enabled.*/
    IIC_REGWRITE(CODEC_TRAN_CTRL_ADDR,    0x60);

    /* Mute Control Reg: Turn off AUTO_MUTE */
    IIC_REGWRITE(CODEC_MUTE_CTRL_ADDR,    0x00);

    /* DAC Chan A Volume Reg:
       We don't require vol control so write 0x00 (0dB) */
    IIC_REGWRITE(CODEC_DACA_VOL_ADDR,     0x00);

    /* DAC Chan B Volume Reg:
       We don't require vol control so write 0x00 (0dB)  */
    IIC_REGWRITE(CODEC_DACB_VOL_ADDR,     0x00);

    /* Clear power down bit in the CODEC over I2C */
    IIC_REGWRITE(CODEC_PWR_CTRL_ADDR, 0x00);
}
