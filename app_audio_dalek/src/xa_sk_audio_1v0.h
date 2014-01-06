
/* General output port bit definitions */
//These are on port as defined by #define PORT_GPIO in app_global.h

#define P_GPIO_SPDIF_EN         0x01    /* SPDIF enable*/
#define P_GPIO_MCLK_SEL         0x02    /* MCLK frequency select. 0 - 22.5792MHz, 1 - 24.576MHz. */
#define P_GPIO_COD_RST_N        0x04    /* CODEC RESET. Active low. */
#define P_GPIO_LED              0x08    /* LED. Active high. */
