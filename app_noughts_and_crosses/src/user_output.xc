// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <stdio.h>

const int map[3][3] = {
    { 0x80000, 0x40000, 0x20000 },
    { 0x01000, 0x00800, 0x00400 },
    { 0x00200, 0x00100, 0x00080 },
};

port p32 = XS1_PORT_32A;

void sleep(int x) {
    timer tmr;
    int t;
    tmr :> t;
    t += x * 200000;
    tmr when timerafter(t) :> void;
}

int p32_word = 0;

int create_word(char display[3][3], int cursorx, int cursory) {
    static int index = 0;
    const int fast_bit = 7;
    const int slow_bit = 32;
    static int press = 0;
    int word = 0xE1F80;
    int ok = 0;
    int button;

    index++;
    for(int i = 0; i < 3; i++) {
        for(int j = 0; j < 3; j++) {
            int on_cursor = i == cursorx && j == cursory;
            if (display[i][j] == 'X') {
                if (on_cursor) {
                    if ((index & slow_bit) || ((index & fast_bit) == fast_bit)) {
                        word &= ~map[i][j];
                    }
                } else {
                    word &= ~map[i][j];
                }
                continue;
            }
            if (display[i][j] == 'O') {
                if (on_cursor) {
                    if ((index & slow_bit) && ((index & fast_bit) == fast_bit)) {
                        word &= ~map[i][j];
                    }
                } else {
                    if ((index & fast_bit) == fast_bit) {
                        word &= ~map[i][j];
                    }
                }
                continue;
            }
            if (on_cursor) {
                if ((index & slow_bit)) {
                    word &= ~map[i][j];
                    ok = 1;
                }
            }
        }
    }
    p32 :> button;
    p32 :> button;
    p32_word = word;
    p32 <: p32_word;
    if ((button & 1) == 0) {
        press++;
    } else {
        press = 0;
    }
    if (press > 10 && ok) {
        press = -0x7fffffff;
        return 1;
    }
    return 0;
}

void user_output(chanend from_strategy, chanend from_input) {
    while(1) {
        char display[3][3];
        int computer_starts;
        int cursorx, cursory;

        for(int i = 0; i < 3; i++) {
            for(int j = 0; j < 3; j++) {
                display[i][j] = ' ';
            }
        }
        from_strategy :> computer_starts;
        if (computer_starts) {
            cursorx = -1;      // Cursor off-board - computer's turn
            cursory = -1;
        } else {
            cursorx = 0;       // Cursor on-board - player's turn
            cursory = 0;
        }
        int finished = 0;
        while(!finished) {
            int x, y;
            select {
            case from_strategy :> x:
                from_strategy :> y;
                from_strategy :> finished;
                display[x][y] = 'O';
                for(int i = 0; i < 3; i++) {
                    for(int j = 0; j < 3; j++) {
                        if (display[i][j] == ' ') {
                            cursorx = i; cursory = j;
                        }
                    }
                }
                break;
            default:
                break;
            }
//        printf("%d %d\n", cursorx, cursory);
            p32 :> int _;
            from_input <: 0;
            from_input :> x;
            from_input :> y;
            p32 :> p32_word;
            if (cursorx+x < 3 && cursorx+x >= 0) cursorx += x;
            if (cursory+y < 3 && cursory+y >= 0) cursory += y;
            if (create_word(display, cursorx, cursory)) {
                display[cursorx][cursory] = 'X';
                from_strategy <: cursorx;
                from_strategy <: cursory;
                cursorx = -1;
                cursory = -1;
            }
            sleep(1);
        }
        for(int i = 0; i < 300; i++) {
            create_word(display, -1, -1);
            sleep(1);
        }
    }
}
