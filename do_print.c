/*
 * Copyright (C) 2021 Parnart, Inc.
 * Arlington, Virginia USA
 * (703) 528-3280 http://www.parnart.com
 *
 * All rights reserved.
 *
*/

/*----------------------------------------------------------------*/
/* do_print.c							  */
/*----------------------------------------------------------------*/

#include <libpq-fe.h>
#include <ncurses.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include "hvac.h"


void do_print(s_data_t *data, char *buff, int color){
	char timebuff[128];
	time_t current_time = time(NULL);
	struct tm *p = localtime(&current_time);
	pthread_mutex_t *pmut_print = &data->mut_print;
	
	strftime(timebuff, sizeof(timebuff), "%Y-%m-%d %H:%M:%S", p);

	pthread_mutex_lock(pmut_print);
	if ((data->verbose) && (data->print)){
		if (data->curses){
			getyx(data->w_main, data->winrow_main, data->wincol_main);
			if (data->winrow_main < data->winheight - 2)
				data->winrow_main++;
			else	scroll(data->w_main);
			wmove(data->w_main, data->winrow_main, 2);
			wattron(data->w_main, COLOR_PAIR(color));
			wprintw(data->w_main, "%s %s", timebuff, buff);
			wattron(data->w_main, COLOR_PAIR(1));
			wrefresh(data->w_main);
		} else	printf("%s %s\n", timebuff, buff);
	}
	pthread_mutex_unlock(pmut_print);
	
	return;
}
	
void curses_shutdown(s_data_t *data, int dwell) {
	sleep(dwell);
	if (data->curses) {
		wclear(data->w_main);
		wrefresh(data->w_main);
		wclear(data->w_banner);
		wrefresh(data->w_banner);
		//sleep(1);
		endwin();
	}

}