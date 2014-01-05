/*
 *      startKIT port mapping.h
 *
 *      Created on: Dec 27, 2013
 *      Author: ShannonS
 *      Website: www.shannonstrutz.com
 *      E-mail: strutz.shannon@gmail.com
 *
 *      This is offered under the MIT License
 *
 *      This file currently supports the following slices:
 *      Audio Slice
 *      Ethernet Slice
 *      GPIO Slice
 *      IS-BUS Slice
 *      LCD Slice
 *      Multi-UART Slice
 *      SDRAM Slice
 *      WIFI Slice
 *
 *      And the following startKIT peripherals:
 *      Generic PCIe Slot
 *      3x3 LED matrix + LED D1 and D2
 *      J7 GPIO Header
 *      Rpi Header, J8 GPIO Header, XMOS Links, and Pushbutton
 *      Touch Sliders
 *      SPI Flash
 *      ADC Sample
 *
 *      Uncomment whatever you would like to use although follow these rules:
 *      1)You cannot use the PICe and GPIO header J7 at the same time
 *      2)Raspberry Pi communication through SPI
 *      3)The 3x3 LED Matrix, LEDs D1 & D2, and Push-button are unavailable if the Rpi header is in use
 *      4)If you are using the onboard LEDs/button, you cannot use the J8 header
 *
 *      On-board perhipheral useage Notes:
 *      1)The Pushbutton is active low
 *      2)Contrary to the startKIT Hardware Guide, the 3x3 Matrix LEDs are active low
 *      3)LEDs D1 & D2 are active high
 *
 *
 *      The MIT License (MIT)
 *
 *      Copyright (c) <2013> <Shannon Strutz>
 *
 *      Permission is hereby granted, free of charge, to any person obtaining a copy
 *      of this software and associated documentation files (the "Software"), to deal
 *      in the Software without restriction, including without limitation the rights
 *      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *      copies of the Software, and to permit persons to whom the Software is
 *      furnished to do so, subject to the following conditions:
 *
 *      The above copyright notice and this permission notice shall be included in
 *      all copies or substantial portions of the Software.
 *
 *      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *      THE SOFTWARE.
 *
 */

#ifndef STARTKIT_PORT_MAPPING_H_
#define STARTKIT_PORT_MAPPING_H_

//////////////////////////////////////
//startKIT PCIe port mappings for Audio Slice

/*
    port    BCLK           =   XS1_PORT_1F;     //I2S Bit Clock
out port    DAC_DATA0      =   XS1_PORT_1G;     //I2S DAC DATA Channel 0
    port    MCLK           =   XS1_PORT_1E;     //I2S Master Clock
    port    LRCLK          =   XS1_PORT_1H;     //I2S LR Clock
out port    SPDIF_OUT      =   XS1_PORT_1K;     //SPDIF transmit
    port    UART_RX        =   XS1_PORT_1I;     //I2S ADC DATA Channel 0
out port    I2C_SCL        =   XS1_PORT_1L;     //I2S ADC DATA Channel 1
in  port    MIDI_IN        =   XS1_PORT_1J;     //From MIDI Connector
out port    MCRL           =   XS1_PORT_4C;     //MCLK Function Select Port                 4C1
                                                //Codec Reset                               4C2
                                                //User LED output                           4C3
    port    SCL_SDA        =   XS1_PORT_4D;     //I2C clock for codec configuration         4D0
                                                //I2C data for codec configuration          4D1
out port    DAC_DATA1      =   XS1_PORT_1M;     //I2S DAC DATA Channel 1
    port    PLL_SYNC       =   XS1_PORT_1P;     //PLL
out port    MIDI_OUT       =   XS1_PORT_4E;     //To MIDI connector                         4E3
*/

//////////////////////////////////////
//startKIT PCIe port mappings for Ethernet Slice
//https://www.xmos.com/en/support/documentation/xkits?subcategory=sliceKIT&product=15830&component=16082&page=1

/*
    port    RX_DV           =   XS1_PORT_1K;   //Phy RX Data Valid
    port    RX_CLK          =   XS1_PORT_1J;   //Phy RX CLK (input to XMOS)
    port    TX_CLK          =   XS1_PORT_1I;   //Phy TX CLK (output from XMOS)
    port    TX_EN           =   XS1_PORT_1L;   //TX Data Enable
    port    RXD             =   XS1_PORT_4C;   //Phy RX Data 0,1,2, and 3.
                                               //RX0 = 4C0, RX1 = 4C1, RX2 = 4C2, RX3 = 4C3
    port    TXD             =   XS1_PORT_4D;   //Phy TX Data 0,1,2, and 3.
                                               //TX0 = 4D0, TX1 = 4D1, TX2 = 4D2, TX3 = 4D3
    port    MDIO            =   XS1_PORT_1M;   //MDIO not available in Circle
    port    MDC             =   XS1_PORT_1N;   //MDIO not available in Circle
    port    INT_N           =   XS1_PORT_1O;   //MDIO not available in Circle
    port    RXERR           =   XS1_PORT_1P;   //RXERR not used in software
*/

//////////////////////////////////////
//startKIT PCIe port mappings for the GPIO Slice
//https://www.xmos.com/en/support/documentation/xkits?subcategory=sliceKIT&product=15831&component=16079&page=1

/*
    port    GPIO_0          =   XS1_PORT_1F;    //1-Bit port free for GPIO
    port    GPIO_1          =   XS1_PORT_1G;    //1-Bit port free for GPIO
    port    GPIO_2          =   XS1_PORT_1E;    //1-Bit port free for GPIO
    port    GPIO_3          =   XS1_PORT_1H;    //1-Bit port free for GPIO
    port    UART_TX         =   XS1_PORT_1K;    //RS232 TX
    port    UART_RX         =   XS1_PORT_1I;    //RS232 RX
    port    I2C_SCL         =   XS1_PORT_1L;    //I2C Clock for ADC
    port    I2C_SDA         =   XS1_PORT_1J;    //I2C Data for ADC
    port    LED             =   XS1_PORT_4C;    //General Purpose Output, connected to LED0,1,2, and 3
    port    GPO             =   XS1_PORT_4D;    //General Purpose Output, connected to GPO2,3,4, and 5
    port    BUTTON_A        =   XS1_PORT_1M;    //Input from Button A
    port    BUTTON_B        =   XS1_PORT_1N;    //Input from Button B
    port    GPI0            =   XS1_PORT_1O;    //General Purpose Input
    port    GPI1            =   XS1_PORT_1P;    //General Purpose Input
    port    GPI2_5          =   XS1_PORT_4E;    //General Purpose Input
*/

//////////////////////////////////////
//startKIT PICe port mappings for the IS-BUS Slice
//Derived from slice schematic

/*
    port    CAN_RX          =   XS1_PORT_1I;    //CAN RX
    port    CAN_TX          =   XS1_PORT_1L;    //CAN TX
    port    LED0            =   XS1_PORT_1K;    //General output to LED0
    port    LED1            =   XS1_PORT_1M;    //General output to LED1
    port    LIN_RX          =   XS1_PORT_4D;    //Line In Recieve , is on Port 4D, bit location 0
    port    IS_Comb         =   XS1_PORT_4C;    //Combined port, handles the following:
                                                //4C0 - RS485 DE/RE
                                                //4C1 - CAN_RS
                                                //4C2 - LIN_TX
                                                //4C3 - LIN_NSLP
    port    RS485_TXD_RXD   =   XS1_PORT_1J;    //Bidirectional connection for RS485
*/

//////////////////////////////////////
//startKIT PCIe port mappings for the LCD Slice
//https://www.xmos.com/en/support/documentation/xkits?subcategory=sliceKIT&product=15832&component=16085&page=1

/*
    port    I2C_SCL         =   XS1_PORT_1E;    //I2C clock for touch controller
    port    I2C_SDA         =   XS1_PORT_1H;    //I2C data for touch controller
    port    V_SYNC          =   XS1_PORT_1K;    //LCD Vertical Sync
    port    PENIRQ          =   XS1_PORT_1J;    //Interrupt from touch controller - THIS IS ACTIVE LOW!
    port    H_SYNC          =   XS1_PORT_1I;    //LCD Horizontal Sync
    port    LCD_DE          =   XS1_PORT_1L;    //LCD Data Enable
    port    LCD_R01_G12     =   XS1_PORT_4C;    //LCD Parallel RGB Data R0, R1, G1, and G2
    port    LCD_R234_G0     =   XS1_PORT_4D;    //LCD Parallel RGB Data R2, R3, R4, and G0
    port    LCD_G3          =   XS1_PORT_1M;    //LCD Parallel RGB Data G3
    port    LCD_G4          =   XS1_PORT_1N;    //LCD Parallel RGB Data G4
    port    LCD_G5          =   XS1_PORT_1O;    //LCD Parallel RGB Data G5
    port    LCD_B0          =   XS1_PORT_1P;    //LCD Parallel RGB Data B0
    port    LCD_B1234       =   XS1_PORT_4E;    //LCD Parallel RGB Data B1, B2, B3, and B4
*/

//////////////////////////////////////
//startKIT PCIe port mappings for the Multi-UART Slice
//https://www.xmos.com/en/support/documentation/xkits?subcategory=sliceKIT&product=15828&component=16081&page=1

/*
    port    CLK_OUT         =   XS1_PORT_1F;    //Output Clock
    port    RXD0123         =   XS1_PORT_4C;    //RX Data for UART #0, #1, #2, #3
    port    RXD4567         =   XS1_PORT_4D;    //RX Data for UART #4, #5, #6, #7
    port    TXD0            =   XS1_PORT_1M;    //TX Data for UART #0
    port    TXD1            =   XS1_PORT_1N;    //TX Data for UART #1
    port    TXD2            =   XS1_PORT_1O;    //TX Data for UART #2
    port    TXD3            =   XS1_PORT_1P;    //TX Data for UART #3
    port    TXD4567         =   XS1_PORT_4E;    //TX Data for UART #4, #5, #6, #7
*/

//////////////////////////////////////
//startKIT PCIe port mappings for the SDRAM Slice
//https://www.xmos.com/en/support/documentation/xkits?subcategory=sliceKIT&product=15829&component=16080

/*

    port    SD_WE           =   XS1_PORT_1K;    //SDRAM Write Enable
    port    SD_CAS          =   XS1_PORT_1J;    //SDRAM CAS
    port    SD_RAS          =   XS1_PORT_1I;    //SDRAM RAS
    port    SD_CLK          =   XS1_PORT_1L;    //SDRAM Clock driven from XCore
    port    SD_ADQ0167      =   XS1_PORT_4C;    //SDRAM Address and Data for bits 0, 1, 6, and 7
    port    SD_ADQ2345      =   XS1_PORT_4E;    //SDRAM Address and Data for bits 2, 3, 4, and 5
    port    SD_ADQ8         =   XS1_PORT_1M;    //SDRAM Address and Data for bit 8
    port    SD_ADQ9         =   XS1_PORT_1N;    //SDRAM Address and Data for bit 9
    port    SD_ADQ10        =   XS1_PORT_1O;    //SDRAM Address and Data for bit 10
    port    SD_ADQ11        =   XS1_PORT_1P;    //SDRAM Address and Data for bit 11
    port    SD_ABD          =   XS1_PORT_4E;    //SDRAM Address and Data for bit 12
                                                //SDRAM Bank Address and Data DQ13/BA0
                                                //SDRAM Bank Address and Data DQ14/BA1
                                                //SDRAM Data DQ15

*/

//////////////////////////////////////
//startKIT PCIe port mappings for the WIFI Slice
//Derived from slice schematic

/*
    port    SPI_CS_PWR      =   XS1_PORT_4C;    //4C0 handles SPI Chip Select and is active_low
                                                //4C1 handles Power Enable and is active_high
    port    SPI_CLK         =   XS1_PORT_1J;    //Serial Clock
    port    LEDS            =   XS1_PORT_4D;    //4D0 handles LED0
                                                //4D1 handles LED1
    port    SPI_DI          =   XS1_PORT_1K;    //Serial Data In (From XMOS to Wifi)
    port    SPI_DO          =   XS1_PORT_1I;    //Serial Data Out(From Wifi to XMOS)
    port    SPI_IRQ         =   XS1_PORT_1L;    //Serial Interrupt Request ACTIVE LOW!
*/

//////////////////////////////////////
//startKIT Generic PCIe Slot mappings
//Derived from startKIT Hardware Guide

/*
    port    P_A3            =   XS1_PORT_1E;    //PCIe Pin A3
    port    P_A4            =   XS1_PORT_1H;    //PCIe Pin A4
    port    P_B67_A67       =   XS1_PORT_4C;    //4C0 <- B6, 4C1 <- B7, 4C2 <- A6, 4C3 <- A7
    port    P_A8            =   XS1_PORT_1J;    //PICe Pin A8
    port    P_B911_A911     =   XS1_PORT_4D;    //4D0 <- B9, 4D1 <- B11, 4D2 <- A9, 4D3 <- A11
    port    P_A17823        =   XS1_PORT_4E;    //4E0 <- A17, 4E1 <- A18, 4E2 <- A12, 4E3 <- A13
    port    P_A15           =   XS1_PORT_1L;    //PCIe Pin A15
    port    P_B2            =   XS1_PORT_1F;    //PCIe Pin B2
    port    P_B4            =   XS1_PORT_1G;    //PCIe Pin B4
    port    P_B10           =   XS1_PORT_1K;    //PCIe Pin B10
    port    P_B12           =   XS1_PORT_1M;    //PCIe Pin B12
    port    P_B13           =   XS1_PORT_1N;    //PCIe Pin B13
    port    P_B15           =   XS1_PORT_1I;    //PCIe Pin B15
    port    P_B17           =   XS1_PORT_1O;    //PCie Pin B17
    port    P_B18           =   XS1_PORT_1P;    //PCIe Pin B18
*/


//////////////////////////////////////
//startKIT LED mappings
//Derived from startKIT Hardware Guide and experiementation
//Contrary to hardware guide, 3x3 LEDs are not active high

/*
out port    p32             =   XS1_PORT_32A;   //PORT 32A for 3x3 LED
out port    p1              =   XS1_PORT_1A;    //PORT 1A for D1 LED
out port    p2              =   XS1_PORT_1D;    //PORT 1D for D2 LED

#define     A1                  0b01111111111111111111
#define     A2                  0b11111110111111111111
#define     A3                  0b11111111110111111111
#define     B1                  0b10111111111111111111
#define     B2                  0b11111111011111111111
#define     B3                  0b11111111111011111111
#define     C1                  0b11011111111111111111
#define     C2                  0b11111111101111111111
#define     C3                  0b11111111111101111111
#define     D1                  p1
#define     D2                  p2
#define     LED3x3_off          0b11111111111111111111
*/

//////////////////////////////////////
//startKIT GPIO mapping
//Derived from startKIT Hardware Guide
/*
    port    GPIO1           =   XS1_PORT_1F;    //GPIO1
    port    GPIO2           =   XS1_PORT_1H;    //GPIO2
    port    GPIO3           =   XS1_PORT_1G;    //GPIO3
    port    GPIO4           =   XS1_PORT_1E;    //GPIO4
    port    GPIO_G1         =   XS1_PORT_4C;    //4C0 <- GPIO5, 4C1 <- GPIO7, 4C2 <- GPIO6, 4C3 <- GPIO8
    port    GPIO_G2         =   XS1_PORT_4D;    //4D0 <- GPIO9, 4D1 <- GPIO13, 4D2 <- GPIO12, 4D3 <- GPIO14
    port    GPIO10          =   XS1_PORT_1J;    //GPIO10
    port    GPIO11          =   XS1_PORT_1K;    //GPIO11
    port    GPIO15          =   XS1_PORT_1M;    //GPIO15
    port    GPIO_G3         =   XS1_PORT_4E;    //4E0 <- GPIO22, 4E1 <- GPIO24, 4E2 <- GPIO16, 4E3 <_ GPIO18
    port    GPIO17          =   XS1_PORT_1N;    //GPIO17
    port    GPIO19          =   XS1_PORT_1L;    //GPIO19
    port    GPIO20          =   XS1_PORT_1I;    //GPIO20
    port    GPIO21          =   XS1_PORT_1O;    //GPIO21
    port    GPIO23          =   XS1_PORT_1P;    //GPIO23
*/

//////////////////////////////////////
//startKIT Raspberry Pi, XMOS Links, J8 GPIO header mapping, on-board Pushbutton
//Derived from startKIT Hardware Guide, startKIT Bottom Silkscreen, and Adafruit Pi Cobbler
//Pushbutton is Active Low

/*
    port    PiLinkJ8         =  XS1_PORT_32A;     //Port  <- Rpi_Link function/ GPIO function / Alternate
                                                  //32A0  <- RPI_SDA          /   IO0         / On-board Pushbutton
                                                  //32A19 <- RPI_SCL          /   IO1
                                                  //32A18 <- IO4              /   IO4
                                                  //32A17 <- TX0              /   IO14
                                                  //32A16 <- Link D : 1 IN    /   NONE
                                                  //32A15 <- Link D : 0 IN    /   NONE
                                                  //32A14 <- Link D : 0 OUT   /   NONE
                                                  //32A13 <- Link D : 1 OUT   /   NONE
                                                  //32A12 <- RXD              /   IO15
                                                  //32A9  <- IO21             /   IO21
                                                  //32A7  <- IO23             /   IO23
                                                  //32A6  <- Link C : 1 IN    /   NONE
                                                  //32A5  <- Link C : 0 IN    /   NONE
                                                  //32A4  <- Link C : 0 OUT   /   NONE
                                                  //32A3  <- Link C : 1 OUT   /   NONE
                                                  //32A2  <- CE0              /   CE0
                                                  //32A1  <- CE1              /   CE1
                                                  //32A0  <- NC               /   NC

    port    Rpi2            =   XS1_PORT_32D;     //port <- Rpi function / GPIO fucntion
                                                  //32D11 <- IO18     /   IO18
                                                  //32D10 <- IO17     /   IO17
                                                  //32D8  <- IO22     /   IO22

    port    Rpi_MOSI        =   XS1_PORT_1A;      //MOSI / MOSI
    port    Rpi_MISO        =   XS1_PORT_1D;      //MISO / MISO
    port    Rpi_CLK         =   XS1_PORT_1C;      //CLK  / CLK
*/

//////////////////////////////////////
//startKIT Touch Slider mapping
//Derived from startKIT Hardware Guide

/*
                                                  //ports need to be polled to measure any touch
    port    SliderX         =   XS1_PORT_4A;      //4A0 <- Section 1, 4A1 <- Section 2, 4A2 <- Section 3, 4A3 <- Section 4
    port    SliderY         =   XS1_PORT_4B;      //4B0 <- Section 1, 4B1 <- Section 2, 4B2 <- Section 3, 4B3 <- Section 4
*/

//////////////////////////////////////
//startKIT SPI Flash mapping
//Derived from startKIT Hardware Guide

/*
    port    SPI_MISO        =   XS1_PORT_1A;      //SPI Flash MISO
    port    SPI_CS          =   XS1_PORT_1B;      //SPI Chip Select, active-low
    port    SPI_MCK         =   XS1_PORT_1C;      //SPI Master Clock
    port    SPI_MOSI        =   XS1_PORT_1D;      //SPI Flash MOSI
*/

//////////////////////////////////////
//startKIT Analog Sample mapping
//Derived from startKIT Hardware Guide

//  port    ADC_Sample      =   XS1_PORT_1A;      //ADC_sample port


#endif /* STARTKIT_PORT_MAPPING_H_ */
