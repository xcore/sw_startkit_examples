#include "user_player.h"
#include <print.h>

/** The user player task connects to the game task and the gpio task.
    It is either in a playing state or idle state. When it gets a
    move request notification from the game task, it moves into the playing
    state and sets up the cursor in the game task. Whilst in the playing state
    it reacts to slider and button events to move the cursor
    and complete the game move.
*/

[[combinable]]
void user_player(client player_if i_game,
                 client slider_if i_slider_x,
                 client slider_if i_slider_y,
                 client startkit_button_if i_button)
{
  /** The task has some local state - a variable to determine whether it
      is in a playing state or not, ``x`` and  ``y`` variables to store
      the current position of the cursor and a local copy of the board state.
  */
  int playing = 0;
  int x = 0, y = 0;
  char board[3][3];

  /** The main body of the task consists of a ``while (1) select`` loop. */
  while (1) {
    select {
    /** The first case in the select reacts when the game tasks requests
        a move is played. This causes the player task to enter the playing
        state. At this point the task takes a copy of the board state and
        sets up the cursor by interacting with the game task. */
    case i_game.move_required():
      // Get a local copy of the board state
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

    /** If the button is pressed it causes an event on the connection
        to the gpio driver. The following case reacts to this event and
        if the task is in the playing state and the cursor is at an empty
        space on the board, it calls the ``play`` function over
        the connection to the game task to play the move, and then leave the
        playing state. */
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

    /** The task also reacts to changes in the slider. In this case it
        moves the cursor if the slider notifies the task of a
        ``LEFTING`` or ``RIGHTING`` event (indicating that the user
        has swiped left or right).
    */
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

      /** The case to handle the vertical slider is similar. Handling
          move requests, slider swipes and button presses completes the
          player task.
      **/
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
