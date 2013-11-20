#include "computer_player.h"
#include "game.h"
#include "random.h"
#include "scoring.h"

/** The computer player uses an auxiliary function to find a
   move for the computer to play. It fills the
   ``best_i`` and ``best_j`` reference parameters with the position
   of the best move based on an AI algorithm that searches possible
   future move combinations.
   The parameter ``board`` is the current board state and the parameter
   ``me`` indicates which type of piece the computer is playing.
*/
static void find_best_move(char board[3][3],
                           int &best_i,
                           int &best_j,
                           board_val_t me);

/** With this function, the computer player task is quite simple. It just
    waits for the game tasks to request a move, gets a copy of the
    board state, determines the best move to play and then communicates
    back with the game state playing the move. */

[[combinable]]
void computer_player(client player_if game)
{
  while (1) {
    select {
    case game.move_required():
      char board[3][3];
      int i, j;
      game.get_board(board);
      find_best_move(board, i, j, game.get_my_val());
      game.play(i, j);
      break;
    }
  }
}

/****/

static void find_best_move(char board[3][3],
                           int &best_i,
                           int &best_j,
                           board_val_t me)
{
  board_val_t who = me;
  int longest = -1;
  struct {int x; int y;} moves[9];
  int moves_left = 9;
  for (int i=0;i<3;i++) {
    for (int j=0;j<3;j++) {
      if (board[i][j] != BOARD_EMPTY) {
        moves_left--;
      } else {
        best_i = i;
        best_j = j;
      }
    }
  }

  if (moves_left == 9) {
    best_i = my_random(3);
    best_j = my_random(3);
    return;
  }

  int cur_move = 0;
  moves[0].x = -1;
  moves[0].y = 0;

  while (1) {
    int cur_x = moves[cur_move].x;
    int cur_y = moves[cur_move].y;
    int valid = 1;
    int end_of_game = 0;
    // step
    cur_x++;
    if (cur_x > 2) {
      cur_x = 0;
      cur_y++;
      if (cur_y > 2) {
        if (cur_move == 0) {
          return;
        }
        else {
          // backtrack
          cur_move--;
          who = who == BOARD_O ? BOARD_X : BOARD_O;
          board[moves[cur_move].x][moves[cur_move].y] = BOARD_EMPTY;
          continue;
        }
      }
    }
    moves[cur_move].x = cur_x;
    moves[cur_move].y = cur_y;

    //debug_printf("Move %d, trying (%d, %d)\n", cur_move, cur_x, cur_y);

    if (board[cur_x][cur_y] != BOARD_EMPTY)
      valid = 0;

    if (valid) {
      board[cur_x][cur_y] = who;
      // score the board
      int end_of_game, winner;
      score(board, end_of_game, winner);
      if (winner == me) {
        if (cur_move > longest) {
          longest = cur_move;
          best_i = moves[0].x;
          best_j = moves[0].y;
          //debug_printf("Found winning sequence (length=%d)\n", cur_move);
        }
      }
    }

    if (valid && !end_of_game && cur_move < moves_left - 1) {
      cur_move++;
      who = who == BOARD_O ? BOARD_X : BOARD_O;
      moves[cur_move].x = -1;
      moves[cur_move].y = 0;
    }
    else if (valid) {
      board[cur_x][cur_y] = BOARD_EMPTY;
    }
  }
  return;
}
