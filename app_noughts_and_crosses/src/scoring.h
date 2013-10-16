#ifndef __scoring_h__
#define __scoring_h__

/** Function that scores a board - returns one of the three scores above.
 *
 *  \param end_of_game   set to 1 if the board position is the end of game
 *  \param winner        set to the winner or BOARD_EMPTY if no winner
 */
void score(char board[3][3], int &end_of_game, int &winner);

#endif // __scoring_h__
