#include "user_player.h"
#include <print.h>

[[combinable]]
void user_player(client player_if i_game,
                 client slider_if i_slider_x,
                 client slider_if i_slider_y,
                 client startkit_button_if i_button)
{
  int playing = 0;
  int x = 0, y = 0;
  char board[3][3];
  while (1) {
    select {
    case i_game.move_required():
      i_game.get_board(board);
      // Find an empty place to place the cursor
      int found = 0;
      for (int i = 0; i < 3 && !found; i++) {
        for (int j = 0 ; j < 3 && !found; j++) {
          if (board[i][j] == BOARD_EMPTY) {
            x = i;
            y = j;
            found = 1;
          }
        }
      }
      i_game.set_cursor(x, y);
      playing = 1;
      break;

    case i_button.changed():
      button_val_t val = i_button.get_value();
      if (playing && val == BUTTON_DOWN) {
        if (board[x][y] == BOARD_EMPTY) {
          // Make the move
          i_game.clear_cursor();
          i_game.play(x, y);
          playing = 0;
        }
      }
      break;

    case i_slider_x.changed_state():
      sliderstate state = i_slider_x.get_slider_state();
      if (!playing)
        break;
      if (state != LEFTING && state != RIGHTING)
        break;
      int dir = state == LEFTING ? 1 : -1;
      int new_x = x + dir;
      if (new_x >= 0 && new_x < 3) {
        x = new_x;
        i_game.set_cursor(x, y);
      }
      break;

    case i_slider_y.changed_state():
      sliderstate state = i_slider_y.get_slider_state();
      if (!playing)
        break;
      if (state != LEFTING && state != RIGHTING)
        break;
      int dir = state == LEFTING ? 1 : -1;
      int new_y = y + dir;
      if (new_y >= 0 && new_y < 3) {
        y = new_y;
        i_game.set_cursor(x, y);
      }
      break;
    }
  }
}
