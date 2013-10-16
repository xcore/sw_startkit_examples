#ifndef __game_h__
#define __game_h__
#include "startkit_gpio.h"

typedef enum board_val_t {
  BOARD_EMPTY,
  BOARD_X,
  BOARD_O,
} board_val_t;

typedef interface player_if {
  void get_board(char board[3][3]);
  void set_cursor(unsigned row, unsigned col);
  void clear_cursor();

  board_val_t get_my_val();

  [[notification]] slave void move_required();
  [[clears_notification]] void play(unsigned row, unsigned col);
} player_if;

[[combinable]]
void game(server player_if players[2], client startkit_led_if i_led);

#endif // __game_h__
