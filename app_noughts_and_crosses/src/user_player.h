#ifndef __user_player_h__
#define __user_player_h__
#include "game.h"
#include "startkit_gpio.h"

[[combinable]]
void user_player(client player_if,
                 client slider_if i_slider_x,
                 client slider_if i_slider_y,
                 client startkit_button_if i_button);

#endif // __user_player_h__
