#include <stdio.h>

static void inline print_test()
{
	printf("test %s(%d)\n", __func__, __LINE__);
}

void print_helloworld();
int ncurses_show_text(void);
