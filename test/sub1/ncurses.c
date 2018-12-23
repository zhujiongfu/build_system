/**
	> File Name: test/sub1/ncurses.c
	> Author: zhujiongfu
	> Mail: zhujiongfu@live.cn 
	> Created Time: Sat 22 Dec 2018 04:47:14 PM CST
 */

#include<stdio.h>
#include <string.h>
#include <ncurses.h>
#include <test.h>

int ncurses_show_text(void)
{
    initscr();
    raw();
    noecho();
    curs_set(0);

    char* c = "Hello, World!";

    mvprintw(LINES/2,(COLS-strlen(c))/2,c);
    refresh();

    getch();
    endwin();

    return 0;
}
