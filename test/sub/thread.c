#include <stdlib.h>
#include <pthread.h>
#include "thread.h"

void *thr_fn(void *arg)
{
	return ((void *)0);
}

void create_thread()
{
	pthread_t ntid;
	int err;

	err = pthread_create(&ntid, NULL, thr_fn, NULL);
	if (err != 0)
		exit(1);
}
