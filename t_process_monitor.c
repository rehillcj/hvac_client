/*
 * Copyright (C) 2003 Parnart, Inc.
 * Arlington, Virginia USA
 *(703) 528-3280 http://www.parnart.com
 *
 * All rights reserved.
 *
*/

/*----------------------------------------------------------------*/
/* t_process_monitor.c						  */
/*----------------------------------------------------------------*/

#include <libpq-fe.h>
#include <ncurses.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/io.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "hvac.h"

int make_connection(int *);

void t_process_monitor(s_data_t *data)
{
	struct timeval timeout;
	int sockfd;
	struct stat statbuf;
	mode_t modes;
	pid_t pid;
	FILE *pidfd;

	//pthread_mutex_t *pmut_write = &data->mut_write;

	pid = getpid();
	pidfd = fopen(data->pid_path, "a");
	fprintf(pidfd, "t_monitor: %i\n", pid);
	fclose(pidfd);

	while(!data->error){

		//application cleanup procedure
		memset(&statbuf, 0, sizeof(statbuf));
		stat(data->pid_path, &statbuf);
		modes = statbuf.st_mode;
		if(!S_ISREG(modes)){

			data->error = ERROR_READ_PID;
			timeout.tv_sec = (long) 1;
			timeout.tv_usec = (long) 0;
			select(0, (fd_set *) 0, (fd_set *) 0, (fd_set *) 0, &timeout);
			make_connection(&sockfd); //this causes the listener thread to exit gracefully
			
		}
		if (data->curses)
			getmaxyx(data->w_main, data->winheight, data->winwidth);


		timeout.tv_sec = (long) 0;
		timeout.tv_usec = (long) 500000;
		select(0, (fd_set *) 0, (fd_set *) 0, (fd_set *) 0, &timeout);
	}
}

int make_connection(int *sockfd){

	struct sockaddr_in address;
	int len;

	*sockfd = socket(AF_INET, SOCK_STREAM, 0);
	address.sin_family = AF_INET;
	address.sin_addr.s_addr = inet_addr("127.0.0.1");
	address.sin_port = htons(PORT_LISTENER);
	len = sizeof(address);
	connect(*sockfd, (struct sockaddr *) &address, len);

	return(TRUE);

}
