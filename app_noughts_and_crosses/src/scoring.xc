#include "scoring.h"
#include "game.h"

/** Function that scores a board - returns one of the three scores above.
 */
void score(char board[3][3], int &end_of_game, int &winner) {
  end_of_game = 1;
  // check for a winning row
  for(int j = 0; j < 3; j++) {
    if (board[0][j] == BOARD_EMPTY) {
      continue;
    }
    int cnt = 0;
    for(int i = 1; i < 3; i++) {
      if (board[i][j] == board[0][j]) {
        cnt++;
      }
    }
    if (cnt ==  2) {
      winner = board[0][j];
      return;
    }
  }

  // check for a winning column
  for(int j = 0; j < 3; j++) {
    if (board[j][0] == BOARD_EMPTY) {
      continue;
    }
    int cnt = 0;
    for(int i = 1; i < 3; i++) {
      if (board[j][i] == board[j][0]) {
        cnt++;
      }
    }
    if (cnt == 2) {
      winner = board[j][0];
      return;
    }
  }

  // check for a winning diagonal
  if (board[1][1] != BOARD_EMPTY) {
    if (board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
      winner = board[1][1];
      return;
    }
  }
  if (board[1][1] != BOARD_EMPTY) {
    if (board[2][0] == board[1][1] && board[1][1] == board[0][2]) {
      winner = board[1][1];
      return;
    }
  }

  // There is no winner
  winner = BOARD_EMPTY;
  // Check if all spaces have been filled
  for (int i = 0; i < 3; i++)
    for (int j = 0; j < 3; j++)
      if (board[i][j] == BOARD_EMPTY)
        end_of_game = 0;

  return;
}
