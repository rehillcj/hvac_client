/*
 * Copyright (C) 2003 Parnart, Inc.
 * Arlington, Virginia USA
 *(703) 528-3280 http://www.parnart.com
 *
 * All rights reserved.
 *
*/

/*----------------------------------------------------------------*/
/* signal_handlers.c						  */
/*----------------------------------------------------------------*/

#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <time.h>
#include <unistd.h>
#include <sys/io.h>
#include <sys/stat.h>
#include <sys/types.h>

void handler(int sig)
{
	struct tm pltime;
	time_t now;
	pid_t pid;
	uid_t uid;
	FILE *fd;
	char app_name[25], pid_path[100], tmp_path[100];
	char timestring[22];
	struct stat statbuf;
	mode_t modes;

	time(&now);
	localtime_r(&now, &pltime);
	memset(timestring, 0, sizeof(timestring));
	strftime(timestring, 21, "20%y/%m/%d %H:%M:%S", &pltime);

	memset(app_name, 0, sizeof(app_name));
	memset(pid_path, 0, sizeof(pid_path));
	memset(tmp_path, 0, sizeof(tmp_path));

	pid = getpid();
	sprintf(tmp_path, "/tmp/%i", pid);
	memset(&statbuf, 0, sizeof(statbuf));
	stat(tmp_path, &statbuf);
	modes = statbuf.st_mode;
	if(S_ISREG(modes)){
		fd = fopen(tmp_path, "r");
		fgets(app_name, (sizeof(app_name) - 1), fd);
		app_name[strlen(app_name) - 1] = 0x00;
		fclose(fd);
	}

	uid = getuid();
	if (uid == 0)
		sprintf(pid_path, "/var/run/%s.pid", app_name);
	else	sprintf(pid_path, "/var/run/user/%i/%s.pid", uid, app_name);

	if (sig == SIGINT){
		unlink(tmp_path);
		unlink(pid_path);
	}
}


