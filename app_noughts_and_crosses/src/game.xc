#include "game.h"
#include "random.h"
#include "scoring.h"
#include <string.h>
#include <xassert.h>
#include <print.h>

static void clear_board(char board[3][3])
{
  for (int i = 0; i < 3; i++)
    for (int j = 0; j < 3; j++)
      board[i][j] = BOARD_EMPTY;
}

static int get_led_level(board_val_t val)
{
  switch (val) {
  case BOARD_EMPTY:
    return 0;
  case BOARD_O:
    return LED_ON;
  case BOARD_X:
    return (LED_ON/16);
  }
  return 0;
}

static void display_board(client startkit_led_if i_led,
                          char board[3][3])
{
  for (int i = 0; i < 3; i++)
    for (int j = 0; j < 3; j++) {
      i_led.set(i, j, get_led_level(board[i][j]));
    }
}

static void display_ending(client startkit_led_if i_led,
                           char board[3][3],
                           board_val_t winner)
{
  // flash the winners moves for a bit
  int num_flashes = 4;
  int flash_delay = 20000000;
  int val = 0;
  for (int count = 0; count < num_flashes*2; count++) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        int level;
        if (winner == BOARD_EMPTY)
          level == val ? LED_ON : 0;
        else if (board[i][j] == winner)
          level = val ? get_led_level(winner) : 0;
        else
          level = 0;
        i_led.set(i, j, level);
      }
    }
    timer tmr;
    int t;
    tmr :> t;
    tmr when timerafter(t+flash_delay) :> void;
    val = ~val;
  }
}

[[combinable]]
void game(server player_if players[2], client startkit_led_if i_led)
{
  char board[3][3];
  int cursor_x = -1, cursor_y;
  timer tmr;
  int time;
  int cursor_val = 0;
  int flash_period = 200 * 1000 * 100;
  clear_board(board);
  int starting_player = my_random(2);
  players[starting_player].move_required();
  while (1) {
    select {
    case players[int i].play(unsigned row, unsigned col):
      board_val_t mark = (i == 0 ? BOARD_O : BOARD_X);
      assert(row < 3 && col < 3);
      assert(board[row][col] == BOARD_EMPTY);
      board[row][col] = mark;
      display_board(i_led, board);
      int end_of_game, winner;
      score(board, end_of_game, winner);
      if (end_of_game) {
        display_ending(i_led, board, winner);
        clear_board(board);
        display_board(i_led, board);
        int starting_player = my_random(2);
        players[starting_player].move_required();
      }
      else {
        players[1-i].move_required();
      }
      break;

    case players[int i].get_board(char pboard[3][3]):
      memcpy(pboard, board, sizeof(board));
      break;

    case players[int i].set_cursor(unsigned row, unsigned col):
      assert(row < 3 && col < 3);
      if (cursor_x != -1)
        i_led.set(cursor_x, cursor_y,
                  get_led_level(board[cursor_x][cursor_y]));
      cursor_x = row; cursor_y = col;
      i_led.set(cursor_x, cursor_y, cursor_val);
      tmr :> time;
      cursor_val = 0;
      break;

    case players[int i].get_my_val() -> board_val_t val:
      val = (i == 0 ? BOARD_O : BOARD_X);
      break;

    case players[int i].clear_cursor():
      if (cursor_x != -1)
        i_led.set(cursor_x, cursor_y,
                  get_led_level(board[cursor_x][cursor_y]));
      cursor_x = -1;
      break;

    case (cursor_x != -1) => tmr when timerafter(time + flash_period) :> void:
      i_led.set(cursor_x, cursor_y, cursor_val);
      cursor_val = LED_ON - cursor_val;
      time += flash_period;
      break;
    }
  }
}
