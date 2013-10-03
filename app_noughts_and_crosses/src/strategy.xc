// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "strategy.h"
#include "random.h"

#include <stdio.h>

#define EMPTY ' '
#define ME    'O'
#define THEM  'X'

#define WON_SCORE     ( 1 << 16)
#define LOST_SCORE    (-1 << 16)
#define NEUTRAL_SCORE (0)

/** Function that scores a board - returns one of the three scores above.
 */
int score(char board[3][3], int who) {
    for(int j = 0; j < 3; j++) {
        if (board[0][j] == EMPTY) {
            continue;
        }
        int cnt = 0;
        for(int i = 1; i < 3; i++) {
            if (board[i][j] == board[0][j]) {
                cnt++;
            }
        }
        if (cnt ==  2) {
            return board[0][j] == who ? WON_SCORE : LOST_SCORE;
        }
    }
    for(int j = 0; j < 3; j++) {
        if (board[j][0] == EMPTY) {
            continue;
        }
        int cnt = 0;
        for(int i = 1; i < 3; i++) {
            if (board[j][i] == board[j][0]) {
                cnt++;
            }
        }
        if (cnt ==  2) {
            return board[j][0] == who ? WON_SCORE : LOST_SCORE;
        }
    }
    if (board[1][1] != EMPTY) {
        if (board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
            return board[1][1] == who ? WON_SCORE : LOST_SCORE;
        }
    }
    if (board[1][1] != EMPTY) {
        if (board[2][0] == board[1][1] && board[1][1] == board[0][2]) {
            return board[1][1] == who ? WON_SCORE : LOST_SCORE;
        }
    }
    return NEUTRAL_SCORE;
}

/** Standard game search - brute force. Pick longest game if there is a choice.
 */

int best_move(char board[3][3], int who, int &best_i, int &best_j) {
    int initial_score = LOST_SCORE * 1024;
    int best_score = initial_score;

    for(int i = 0; i < 3; i++) {
        for(int j = 0; j < 3; j++) {
            if (board[i][j] == EMPTY) {
                board[i][j] = who;
                int s = score(board, who);
                int bi, bj;
                if (s == NEUTRAL_SCORE) {
                    s = 2 * -best_move(board, who == ME ? THEM : ME, bi, bj);
                }
                if (s > best_score) {
                    best_i = i;
                    best_j = j;
                    best_score = s;
                }
                board[i][j] = EMPTY;
            }
        }
    }
    if (initial_score == best_score) {
        return 0;                          // No moves left.
    } else {
        return best_score;                 // At least one move, this is the best one.
    }
}

/** Strategy process. Flips a random number to decide who starts, make a
 * random first move if required, and then wait for the user move, compute
 * a new move, and report the new move. When finished, reinitialise the board, and start again.
 */
void strategy(chanend to_output) {
    char board[3][3];
    timer t;
    int now;

    while(1) {
        int i, j;
        int finished = 0;
        for(int i = 0; i < 3; i++) {
            for(int j = 0; j < 3; j++) {
                board[i][j] = EMPTY;
            }
        }
        int computer_starts = my_random(2);
        to_output <: computer_starts;
        if (computer_starts) {
            i = my_random(3);
            j = my_random(3);
            to_output <: i;
            to_output <: j;
            to_output <: 0;
            board[i][j] = ME;
        }
        while(!finished) {
            to_output :> i;
            to_output :> j;
            board[i][j] = THEM;
            int s = best_move(board, ME, i, j);
            board[i][j] = ME;
            to_output <: i;
            to_output <: j;
            finished = 1;
            for(int i = 0; i < 3; i++) {
                for(int j = 0; j < 3; j++) {
                    if (board[i][j] == EMPTY) {
                        finished = 0;
                    }
                }
            }
            finished |= score(board, ME) != NEUTRAL_SCORE;
            to_output <: finished;
        }
    }
}
