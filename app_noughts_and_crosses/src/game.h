#ifndef __game_h__
#define __game_h__
#include "startkit_gpio.h"

/** The game task controls the board state and blinking cursor, displaying them
    via the LED connection to the GPIO driver task. The key interface is
    between the game task and the two player tasks. This includes functions
    for getting and updating the current game state.

    The game task uses notifications to inform the player tasks that a move is
    required.
*/

typedef enum board_val_t {
  BOARD_EMPTY,
  BOARD_X,
  BOARD_O,
} board_val_t;

typedef interface player_if {
  // This function will fill in the supplied board array with the
  // current game state.
  void get_board(char board[3][3]);

  // Set the user cursor to the specified position.
  void set_cursor(unsigned row, unsigned col);

  // Clear the user cursor from the board.
  void clear_cursor();

  // This function can be called by players to determine whether they
  // are the X piece or the O piece.
  board_val_t get_my_val();

  // This notification will be signalled by the game to the player when
  // a move is required from the player.
  [[notification]] slave void move_required();

  // This function is called by the player to make a move in the specified
  // position.
  [[clears_notification]] void play(unsigned row, unsigned col);
} player_if;

// This task controls the game state providing two connections to the
// two players of the game.
[[combinable]]
void game(server player_if players[2], client startkit_led_if i_led);

/** Note that game task is *combinable* allowing it to share processing time
    with other combinable tasks in between reacting to events.
**/

#endif // __game_h__
