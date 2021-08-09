/*
 * Copyright (C) 2003 Parnart, Inc.
 * Arlington, Virginia USA
 *(703) 528-3280 http://www.parnart.com
 *
 * All rights reserved.
 *
*/

/*----------------------------------------------------------------*/
/* main.c							  */
/*----------------------------------------------------------------*/

#include <libpq-fe.h>
#include <ncurses.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h> //threads
#include <signal.h>  //signal handler
#include <string.h>
#include <syslog.h>
#include <unistd.h>  //getopt
#include <netinet/in.h>
#include <sys/io.h>
#include <sys/resource.h>
#include <sys/socket.h>
#include <sys/stat.h>

#include "hvac.h"

int main(int argc, char *argv[]){

	int i, j, k, opt, nice;
	s_data_t data;
	struct tm pltime;
	//struct timeval timeout;
	time_t now;
	char timestring[22], tbuff[256], printbuff[SIZE_PRINTBUFF], tmp_path[SIZE_PATHBUFF];
	char *pid_path = data.pid_path;
	char *app_path = data.app_path;
	char *app_name = data.app_name;
	char *init_path = data.init_path;
	char *dbhost_arduino = data.dbhost_arduino;
	char *dbhost_apc_snmp = data.dbhost_apc_snmp;
	char *dbhost_hvac = data.dbhost_hvac;
	char *dbuser_arduino = data.dbuser_arduino;
	char *dbuser_apc_snmp = data.dbuser_apc_snmp;
	char *dbuser_hvac = data.dbuser_hvac;
	char *dbname_arduino = data.dbname_arduino;
	char *dbname_apc_snmp = data.dbname_apc_snmp;
	char *dbname_hvac = data.dbname_hvac;
	char *host_anemometer = data.host_anemometer;
		
	struct sigaction sa, sa_old;
	struct stat statbuf;
	mode_t modes;
	
	pthread_t process_monitor, dbtrigger_i2c, dbtrigger_ain, dbtrigger_dio_arduino, dbtrigger_dio_apc_snmp, processloop;
	//pthread_t exterior;
	//pthread_mutex_t *pmut_sql_arduino, *pmut_sql_apc_snmp, *pmut_sql_hvac;
	
	PGconn *conn_arduino, *conn_apc_snmp, *conn_hvac;
	PGresult *res1, *res2, *res3;
	pid_t pid;
	uid_t uid;
	FILE *fd;
	unsigned char daemonize;
	
	bool hatch, mode_east, mode_west, switch_east_old, switch_east_new, switch_west_old, switch_west_new;
	int rand_binary;

	
	//seed random number generator
	srand(time(0));
	
	//process command line arguments
	memset(app_path, 0, SIZE_PATHBUFF);
	sprintf(app_path, argv[0]);
	for (i = 0, j = 0; i <= strlen(app_path) - 1; i++)
		if (app_path[i] == 0x2F)
			j = i;
	memset(app_name, 0, SIZE_PATHBUFF);
	for (i = (j == 0) ? 0 : (j + 1), k = 0; i <= (strlen(app_path) - 1); i++, k++)
		app_name[k] = app_path[i];
	app_name[k] = 0;
	
	memset(init_path, 0, SIZE_PATHBUFF);
	sprintf(init_path, "/usr/local/etc/%s.conf", app_name);
	
	
	data.verbose = FALSE;
	data.curses = FALSE;
	data.error = 0;
	nice = 0;
	daemonize = 1;

	while((opt = getopt(argc, argv, "dn:vf:ch")) != -1){	//process command line overrides of defaults
		switch(opt){
			case 'd':
				daemonize = 0;
				break;
			case 'n':
				nice = atoi(optarg);
			case 'v':
				daemonize = 0;
				data.verbose = TRUE;
				break;
			case 'f':
				memset(init_path, 0, SIZE_PATHBUFF);
				sprintf(init_path, "%s", optarg);
				break;
			case 'c':
				data.curses = TRUE;
				data.verbose = TRUE;
				daemonize = 0;
				break;
			case 'h':
				printf("%s\n", argv[0]);
				printf("\tthis program must be run as user 'controller'\n");
				printf("\t-n <nice> : nice value (-15)\n");
				printf("\t-d        : run in foreground\n");
				printf("\t-f <file> : start with configuration file <file>\n");
				printf("\t-v        : run in verbose mode (implies -d)\n");
				printf("\t-c        : run in curses mode (implies -d -v)\n");
				printf("\t-h        : print this message\n\n");
				printf("HVAC controller, version 0.10\n");
				printf("Copyright 2018 Parnart, Inc.\n\n");
				exit(-1);
				break;
			case '?':
				printf("try -h for option list\n");
				exit(-1);
				break;
		}
	}
        if (data.curses) {
                initscr();
                start_color();
                init_pair(WHITE, COLOR_WHITE, COLOR_BLACK);
                init_pair(RED, COLOR_RED, COLOR_BLACK);
                init_pair(GREEN, COLOR_GREEN, COLOR_BLACK);
                init_pair(YELLOW, COLOR_YELLOW, COLOR_BLACK);
                init_pair(MAGENTA, COLOR_MAGENTA, COLOR_BLACK);
                init_pair(CYAN, COLOR_CYAN, COLOR_BLACK);
                init_pair(BLUE, COLOR_BLUE, COLOR_BLACK);
                init_pair(BLACK, COLOR_BLACK, COLOR_WHITE);
                getmaxyx(stdscr, data.winheight, data.winwidth);
                data.w_main = newwin(data.winheight - 6, data.winwidth - 2, 1, 1);
                wattron(data.w_main, COLOR_PAIR(WHITE));
                data.winrow_main = 0;
                data.wincol_main = 2;
                scrollok(data.w_main, TRUE);
                //wmove(data.w_main, 0, 0); // was 1, 2
                wrefresh(data.w_main);

                data.w_banner = newwin(4, data.winwidth - 2, (data.winheight - 4), 1);
                scrollok(data.w_banner, FALSE);
                wattron(data.w_banner, COLOR_PAIR(WHITE));
                wattron(data.w_banner, A_BOLD);
                wmove(data.w_banner, 1, 3);
                wprintw(data.w_banner, "arduino mqtt processor started %s", timestring);
                wmove(data.w_banner, 1, (data.winwidth - 33));
                wprintw(data.w_banner, "copyright 2021, Conrad Rehill");
                wmove(data.w_banner, 2, 3);
                wprintw(data.w_banner, "type 'q' to quit, 'p' to suspend screen output");
                wrefresh(data.w_banner);

        }

	pthread_mutex_init(&data.mut_sql_arduino, NULL);
	pthread_mutex_init(&data.mut_sql_apc_snmp, NULL);
	pthread_mutex_init(&data.mut_sql_hvac, NULL);
	//pmut_sql_arduino = &data.mut_sql_arduino;
	//pmut_sql_apc_snmp = &data.mut_sql_apc_snmp;
	//pmut_sql_hvac = &data.mut_sql_hvac;

	time(&now);
	localtime_r(&now, &pltime);
	strftime(timestring, 21, "20%y/%m/%d %H:%M:%S", &pltime);

	memset(printbuff, 0, SIZE_PRINTBUFF);
	sprintf(printbuff, "%s application start", timestring);
	do_print(&data, printbuff, RED);


	memset(&statbuf, 0, sizeof(statbuf));
	stat(init_path, &statbuf);
	modes = statbuf.st_mode;
	if (S_ISREG(modes)) {
		memset(dbhost_arduino, 0, SIZE_DB_ARG);
		parse_init(init_path, dbhost_arduino, "DBHOST_ARDUINO");
		if (strlen(dbhost_arduino) < 1) {
			memset(dbhost_arduino, 0, SIZE_DB_ARG);
			sprintf(dbhost_arduino, "127.0.0.1");
			memset(printbuff, 0, SIZE_PRINTBUFF);
			sprintf(printbuff, "config file entry 'dbhost_arduino' not defined. default to '%s'.", dbhost_arduino);
			do_print(&data, printbuff, WHITE);
		}
		memset(dbhost_apc_snmp, 0, SIZE_DB_ARG);
		parse_init(init_path, dbhost_apc_snmp, "DBHOST_APC_SNMP");
		if (strlen(dbhost_apc_snmp) < 1) {
			memset(dbhost_apc_snmp, 0, SIZE_DB_ARG);
			sprintf(dbhost_apc_snmp, "127.0.0.1");
			memset(printbuff, 0, SIZE_PRINTBUFF);
			sprintf(printbuff, "config file entry 'dbhost_apc_snmp' not defined. default to '%s'.", dbhost_apc_snmp);
			do_print(&data, printbuff, WHITE);
		}
		memset(dbhost_hvac, 0, SIZE_DB_ARG);
		parse_init(init_path, dbhost_hvac, "DBHOST_HVAC");
		if (strlen(dbhost_hvac) < 1) {
			memset(dbhost_hvac, 0, SIZE_DB_ARG);
			sprintf(dbhost_hvac, "127.0.0.1");
			memset(printbuff, 0, SIZE_PRINTBUFF);
			sprintf(printbuff, "config file entry 'dbhost_hvac' not defined. default to '%s'.", dbhost_hvac);
			do_print(&data, printbuff, WHITE);
		}
		memset(dbuser_arduino, 0, SIZE_DB_ARG);
		parse_init(init_path, dbuser_arduino, "DBUSER_ARDUINO");
		if (strlen(dbuser_arduino) < 1) {
			memset(dbuser_arduino, 0, SIZE_DB_ARG);
			sprintf(dbuser_arduino, "controller");
			memset(printbuff, 0, SIZE_PRINTBUFF);
			sprintf(printbuff, "config file entry 'dbuser_arduino' not defined. default to '%s'.", dbuser_arduino);
			do_print(&data, printbuff, WHITE);
		}
		memset(dbuser_apc_snmp, 0, SIZE_DB_ARG);
		parse_init(init_path, dbuser_apc_snmp, "DBUSER_APC_SNMP");
		if (strlen(dbuser_apc_snmp) < 1) {
			memset(dbuser_apc_snmp, 0, SIZE_DB_ARG);
			sprintf(dbuser_apc_snmp, "controller");
			memset(printbuff, 0, SIZE_PRINTBUFF);
			sprintf(printbuff, "config file entry 'dbuser_apc_snmp' not defined. default to '%s'.", dbuser_apc_snmp);
			do_print(&data, printbuff, WHITE);
		}
		memset(dbuser_hvac, 0, SIZE_DB_ARG);
		parse_init(init_path, dbuser_hvac, "DBUSER_HVAC");
		if (strlen(dbuser_hvac) < 1) {
			memset(dbuser_hvac, 0, SIZE_DB_ARG);
			sprintf(dbuser_hvac, "controller");
			memset(printbuff, 0, SIZE_PRINTBUFF);
			sprintf(printbuff, "config file entry 'dbuser_hvac' not defined. default to '%s'.", dbuser_hvac);
			do_print(&data, printbuff, WHITE);
		}
		memset(dbname_arduino, 0, SIZE_DB_ARG);
		parse_init(init_path, dbname_arduino, "DBNAME_ARDUINO");
		if (strlen(dbname_arduino) < 1) {
			memset(dbname_arduino, 0, SIZE_DB_ARG);
			sprintf(dbname_arduino, "arduino_mqtt");
			memset(printbuff, 0, SIZE_PRINTBUFF);
			sprintf(printbuff, "config file entry 'dbname_arduino' not defined. default to '%s'.", dbname_arduino);
			do_print(&data, printbuff, WHITE);
		}
		memset(dbname_apc_snmp, 0, SIZE_DB_ARG);
		parse_init(init_path, dbname_apc_snmp, "DBNAME_APC_SNMP");
		if (strlen(dbname_apc_snmp) < 1) {
			memset(dbname_apc_snmp, 0, SIZE_DB_ARG);
			sprintf(dbname_apc_snmp, "apc_snmp");
			memset(printbuff, 0, SIZE_PRINTBUFF);
			sprintf(printbuff, "config file entry 'dbname_apc_snmp' not defined. default to '%s'.", dbname_apc_snmp);
			do_print(&data, printbuff, WHITE);
		}
		memset(dbname_hvac, 0, SIZE_DB_ARG);
		parse_init(init_path, dbname_hvac, "DBNAME_HVAC");
		if (strlen(dbname_hvac) < 1) {
			memset(dbname_hvac, 0, SIZE_DB_ARG);
			sprintf(dbname_hvac, "hvac_mqtt");
			memset(printbuff, 0, SIZE_PRINTBUFF);
			sprintf(printbuff, "config file entry 'dbname_hvac' not defined. default to '%s'.", dbname_hvac);
			do_print(&data, printbuff, WHITE);
		}
		memset(host_anemometer, 0, SIZE_DB_ARG);
		parse_init(init_path, host_anemometer, "HOST_ANEMOMETER");
		if (strlen(host_anemometer) < 1) {
			memset(printbuff, 0, SIZE_PRINTBUFF);
			sprintf(printbuff, "no anemometer host defined. skipping wind measurents.");
			do_print(&data, printbuff, WHITE);
		}
	} else {
		memset(printbuff, 0, SIZE_PRINTBUFF);
		sprintf(printbuff, "exiting on error, config file not readable.");
		do_print(&data, printbuff, WHITE);
		exit(ERROR_READ_CONFIG);
	}


	memset(tbuff, 0, sizeof(tbuff));
	sprintf(tbuff, "host=%s user=%s dbname=%s", dbhost_arduino, dbuser_arduino, dbname_arduino);
	conn_arduino = PQconnectdb(tbuff);
	if (PQstatus(conn_arduino) != CONNECTION_OK) {
		memset(printbuff, 0, SIZE_PRINTBUFF);
		sprintf(printbuff, "exiting on error, connecting to arduino database failed: %s", PQerrorMessage(conn_arduino));
		do_print(&data, printbuff, RED);
		PQfinish(conn_arduino);
		exit(ERROR_DB_CONNECT_ARDUINO);
	}
        memset(printbuff, 0, SIZE_PRINTBUFF);
        sprintf(printbuff, "main thread - libpq connection to %s, fd: %i", tbuff, PQsocket(conn_arduino));
        do_print(&data, printbuff, RED);

	memset(tbuff, 0, sizeof(tbuff));
	sprintf(tbuff, "host=%s user=%s dbname=%s", dbhost_apc_snmp, dbuser_apc_snmp, dbname_apc_snmp);
	conn_apc_snmp = PQconnectdb(tbuff);
	if (PQstatus(conn_apc_snmp) != CONNECTION_OK) {
		memset(printbuff, 0, SIZE_PRINTBUFF);
		sprintf(printbuff, "exiting on error, connecting to APC SNMP database failed: %s", PQerrorMessage(conn_apc_snmp));
		do_print(&data, printbuff, RED);
		PQfinish(conn_apc_snmp);
		exit(ERROR_DB_CONNECT_APC_SNMP);
	}
        memset(printbuff, 0, SIZE_PRINTBUFF);
        sprintf(printbuff, "main thread - libpq connection to %s, fd: %i", tbuff, PQsocket(conn_apc_snmp));
        do_print(&data, printbuff, RED);

	memset(tbuff, 0, sizeof(tbuff));
	sprintf(tbuff, "host=%s user=%s dbname=%s", dbhost_hvac, dbuser_hvac, dbname_hvac);
	conn_hvac = PQconnectdb(tbuff);
	if (PQstatus(conn_hvac) != CONNECTION_OK) {
		memset(printbuff, 0, SIZE_PRINTBUFF);
		sprintf(printbuff, "exiting on error, connecting to HVAC database failed: %s", PQerrorMessage(conn_hvac));
		do_print(&data, printbuff, RED);
		PQfinish(conn_hvac);
		exit(ERROR_DB_CONNECT_HVAC);
	}
        memset(printbuff, 0, SIZE_PRINTBUFF);
        sprintf(printbuff, "main thread - libpq connection to %s, fd: %i", tbuff, PQsocket(conn_hvac));
        do_print(&data, printbuff, RED);

        res1 = PQexec(conn_hvac, "insert into log (description) values ('application start')");
        PQclear(res1);

	//daemonize application
	if (daemonize){
		if ((pid = fork()) < 0)
			return(-1);
		else if (pid != 0)
			exit(0);
		setsid();
		chdir("/");
		umask(0);
	}

	pid = getpid();
	iopl(3);
	setpriority(PRIO_PROCESS, pid, nice);
	//set up signal handler for Ctrl-C & broken pipe (socket failure)
	sa.sa_handler = handler;
	//sigfillset(&sa.sa_mask);
	sigemptyset(&sa.sa_mask);
	sigaddset(&sa.sa_mask, SIGINT);
	sigaddset(&sa.sa_mask, SIGPIPE);
	sigaddset(&sa.sa_mask, SIGCHLD);
	sa.sa_flags = 0;
	sigaction(SIGINT, &sa, &sa_old);
	sigaction(SIGPIPE, &sa, &sa_old);

	uid = getuid();
	if (uid == 0)
		sprintf(pid_path, "/var/run/%s.pid", data.app_name);
	else	sprintf(pid_path, "/var/run/user/%i/%s.pid", uid, data.app_name);
	sprintf(tmp_path, "/tmp/%i", pid);
	unlink(tmp_path);
	unlink(pid_path);
	fd = fopen(tmp_path, "w");
	fprintf(fd, "%s\n", app_name);
	fclose(fd);

	fd = fopen(pid_path, "w");
	fprintf(fd, "main: %i\n", pid);
	fclose(fd);

	pthread_create(&dbtrigger_i2c, NULL, (void *) t_dbtrigger_i2c, &data);
	sleep(1);
	pthread_create(&dbtrigger_ain, NULL, (void *) t_dbtrigger_ain, &data);
	sleep(1);
	pthread_create(&dbtrigger_dio_arduino, NULL, (void *) t_dbtrigger_dio_arduino, &data);
	sleep(1);
	pthread_create(&dbtrigger_dio_apc_snmp, NULL, (void *) t_dbtrigger_dio_apc_snmp, &data);
	//sleep(1);
	pthread_create(&process_monitor, NULL, (void *) t_process_monitor, &data);
	sleep(1);
	pthread_create(&processloop, NULL, (void *) t_processloop, &data);
	sleep(1);
	//pthread_create(&exterior, NULL, (void *) t_exterior, &data);
	//sleep(1);
		
	//pthread_detach(exterior);
	pthread_detach(processloop);
	pthread_detach(dbtrigger_i2c);
	pthread_detach(dbtrigger_ain);
	pthread_detach(dbtrigger_dio_arduino);
	pthread_detach(dbtrigger_dio_apc_snmp);
	pthread_detach(process_monitor);

	/*switch_east_old = FALSE;
	switch_west_old = FALSE;
	memset(tbuff, 0, sizeof(tbuff));
	sprintf(tbuff, "select * from contact where unit like 'attic_%%';");
	res1 = PQexec(conn_hvac, tbuff);
	for (i = 0; i < PQntuples(res1); i++) {
		if (!strcmp(PQgetvalue(res1, i, 1), "attic fan east closet switch") && !strcmp(PQgetvalue(res1, i, 5), "t"))
			switch_east_old = TRUE;
		if (!strcmp(PQgetvalue(res1, i, 1), "attic fan west closet switch") && !strcmp(PQgetvalue(res1, i, 5), "t"))
			switch_west_old = TRUE;
	}
	PQclear(res1);
	
	memset(tbuff, 0, sizeof(tbuff));
	if (switch_east_old == TRUE)
		sprintf(tbuff, "update location set mode = 'circulator' where description = 'attic east';");
	else	sprintf(tbuff, "update location set mode = 'off' where description = 'attic east';");
	res1 = PQexec(conn_hvac, tbuff);
	PQclear(res1);

	memset(tbuff, 0, sizeof(tbuff));
	if (switch_west_old == TRUE)
		sprintf(tbuff, "update location set mode = 'circulator' where description = 'attic west';");
	else	sprintf(tbuff, "update location set mode = 'off' where description = 'attic west';");
	res1 = PQexec(conn_hvac, tbuff);
	PQclear(res1);*/

	while (!data.error) {
		if (db_conn_error(conn_hvac))
			data.error = ERROR_DB_CONNECT_HVAC;
		if (db_conn_error(conn_arduino))
			data.error = ERROR_DB_CONNECT_ARDUINO;
		if (db_conn_error(conn_apc_snmp))
			data.error = ERROR_DB_CONNECT_APC_SNMP;

		//memset(tbuff, 0, sizeof(tbuff));
		//sprintf(tbuff, "begin; lock table location;");
		//res1 = PQexec(data.conn_hvac, tbuff);
		//PQclear(res1);
		
		hatch = FALSE;
		switch_east_new = FALSE;
		switch_west_new = FALSE;
		memset(tbuff, 0, sizeof(tbuff));
		sprintf(tbuff, "select * from contact where unit like '%%attic%%';");
		res1 = PQexec(conn_hvac, tbuff);
		for (i = 0; i < PQntuples(res1); i++) {
			if (!strcmp(PQgetvalue(res1, i, 1), "attic hatch") && !strcmp(PQgetvalue(res1, i, 5), "t"))
				hatch = TRUE;
			if (!strcmp(PQgetvalue(res1, i, 1), "attic fan east closet switch") && !strcmp(PQgetvalue(res1, i, 5), "t"))
				switch_east_new = TRUE;
			if (!strcmp(PQgetvalue(res1, i, 1), "attic fan west closet switch") && !strcmp(PQgetvalue(res1, i, 5), "t"))
				switch_west_new = TRUE;
		}
		PQclear(res1);
		if (switch_east_new != switch_east_old) {
			memset(tbuff, 0, sizeof(tbuff));
			if (switch_east_new == TRUE)
				sprintf(tbuff, "update location set mode = 'circulator' where description = 'attic east';");
			else	sprintf(tbuff, "update location set mode = 'off' where description = 'attic east';");
			res1 = PQexec(conn_hvac, tbuff);
			PQclear(res1);
		}
		if (switch_west_new != switch_west_old) {
			memset(tbuff, 0, sizeof(tbuff));
			if (switch_west_new == TRUE)
				sprintf(tbuff, "update location set mode = 'circulator' where description = 'attic west';");
			else	sprintf(tbuff, "update location set mode = 'off' where description = 'attic west';");
			res1 = PQexec(conn_hvac, tbuff);
			PQclear(res1);
		}
		switch_east_old = switch_east_new;
		switch_west_old = switch_west_new;

		if (hatch == TRUE) {
			mode_east = TRUE;
			mode_west = TRUE;
			memset(tbuff, 0, sizeof(tbuff));
			sprintf(tbuff, "select * from location where description like '%%attic%%';");
			res1 = PQexec(conn_hvac, tbuff);
			for (i = 0; i < PQntuples(res1); i++) {
				if (!strcmp(PQgetvalue(res1, i, 1), "attic east") && !strcmp(PQgetvalue(res1, i, 3), "off"))
					mode_east = FALSE;
				if (!strcmp(PQgetvalue(res1, i, 1), "attic west") && !strcmp(PQgetvalue(res1, i, 3), "off"))
					mode_west = FALSE;
			}		
			PQclear(res1);
			if (mode_east && mode_west){
				rand_binary = rand() % 2;
				memset(tbuff, 0, sizeof(tbuff));
				if (rand_binary == 0)
					sprintf(tbuff, "update location set mode = 'off' where description = 'attic east';");
				else	sprintf(tbuff, "update location set mode = 'off' where description = 'attic west';");
				res1 = PQexec(conn_hvac, tbuff);
				PQclear(res1);
			}					
		}
		
		/*humidity equation */
		//humidity = .5T + 25 for T = -20 to 40 F, no humidity needed above 50 F			
		//humidifier is controlled directly by database entries.
		//PQclear(res1);

		memset(tbuff, 0, sizeof(tbuff));
		sprintf(tbuff, "select distinct actuator$description from v_dashboard order by actuator$description;");
		res1 = PQexec(conn_hvac, tbuff);

		for (i = 0; i < PQntuples(res1); i++) {
			int count_total = 0;
			int count_req_on = 0;
			int count_req_off = 0;
			
			memset(tbuff, 0, sizeof(tbuff));
			sprintf(tbuff, "select count(*) from v_dashboard where actuator$description = '%s';", PQgetvalue(res1, i, 0));
			res2 = PQexec(conn_hvac, tbuff);
			if (PQntuples(res2))
				count_total = atoi(PQgetvalue(res2, 0, 0));
			PQclear(res2);
				
			memset(tbuff, 0, sizeof(tbuff));
			sprintf(tbuff, "select count(*) from v_dashboard where actuator$description = '%s' and calculated$req_on = 't';", PQgetvalue(res1, i, 0));
			res2 = PQexec(conn_hvac, tbuff);
			if (PQntuples(res2))
				count_req_on = atoi(PQgetvalue(res2, 0, 0));
			PQclear(res2);
			
			memset(tbuff, 0, sizeof(tbuff));
			sprintf(tbuff, "select count(*) from v_dashboard where actuator$description = '%s' and calculated$req_off = 't';", PQgetvalue(res1, i, 0));
			res2 = PQexec(conn_hvac, tbuff);
			if (PQntuples(res2))
				count_req_off = atoi(PQgetvalue(res2, 0, 0));
			PQclear(res2);
			memset(tbuff, 0, sizeof(tbuff));
			sprintf(tbuff, "select actuator$db, actuator$unit, actuator$port, actuator$state from v_dashboard where actuator$description = '%s';", PQgetvalue(res1, i, 0));
			res2 = PQexec(conn_hvac, tbuff);
			memset(tbuff, 0, sizeof(tbuff));
			if (PQntuples(res2)) {
				//TURN OFF
				if ((count_req_off == count_total) && (!strcmp(PQgetvalue(res2, 0, 3), "t"))) {
					sprintf(tbuff, "update request_dio set %s='f' where unit = (select id from unit where name = '%s');", PQgetvalue(res2, 0, 2), PQgetvalue(res2, 0, 1));
					if (!strcmp(PQgetvalue(res2, 0, 0), "arduino_mqtt"))
						res3 = PQexec(conn_arduino, tbuff);
					else	res3 = PQexec(conn_apc_snmp, tbuff);
					PQclear(res3);
				}

				//TURN ON
				if ((count_req_on > 0) && (!strcmp(PQgetvalue(res2, 0, 3), "f"))) {
					sprintf(tbuff, "update request_dio set %s='t' where unit = (select id from unit where name = '%s');", PQgetvalue(res2, 0, 2), PQgetvalue(res2, 0, 1));
					if (!strcmp(PQgetvalue(res2, 0, 0), "arduino_mqtt"))
						res3 = PQexec(conn_arduino, tbuff);
					else	res3 = PQexec(conn_apc_snmp, tbuff);
					PQclear(res3);
				}

			}
			PQclear(res2);						
		}
		PQclear(res1);

		//memset(tbuff, 0, sizeof(tbuff));
		//sprintf(tbuff, "commit");
		//res1 = PQexec(data.conn_hvac, tbuff);
		//PQclear(res1);

		//this code turns off anything that is on which is in 'off' mode
		memset(tbuff, 0, sizeof(tbuff));
		sprintf(tbuff, "select * from v_device_off");
		res1 = PQexec(conn_hvac, tbuff);
		for (i = 0; i < PQntuples(res1); i++){
			memset(tbuff, 0, sizeof(tbuff));
			sprintf(tbuff, "update request_dio set %s = 'f' where unit = (select id from unit where name = '%s');", PQgetvalue(res1, 0, 4), PQgetvalue(res1, 0, 3));
			if (!strcmp(PQgetvalue(res1, 0, 2), "arduino_mqtt"))
				res2 = PQexec(conn_arduino, tbuff);
			else res2 = PQexec(conn_apc_snmp, tbuff);
			PQclear(res2);			
		}
		PQclear(res1);
		sleep(1);
	}


	//sleep a bit and then quit gracefully
	sleep(2);
	PQfinish(conn_hvac);
	PQfinish(conn_apc_snmp);
	PQfinish(conn_arduino);

	memset(printbuff, 0, SIZE_PRINTBUFF);
        sprintf(printbuff, "exiting normally with code %i.", data.code);
        do_print(&data, printbuff, BLACK);
        curses_shutdown(&data, 1);
        exit(data.code);

}

	
int db_conn_error (PGconn *conn) {
	int i = 0;
	while ((PQstatus(conn) != CONNECTION_OK) && (i < 60)) {
		PQreset(conn);
		sleep(1);
		i++;
	}
	if (PQstatus(conn) != CONNECTION_OK)
		return TRUE;
	else	return FALSE;		
}
