/*
 * Copyright (C) 2018 Parnart, Inc.
 * Arlington, Virginia USA
 *(703) 528-3280 http://www.parnart.com
 *
 * All rights reserved.
 *
*/

/*----------------------------------------------------------------*/
/* t_dbtrigger.c						  */
/*----------------------------------------------------------------*/
#include <errno.h>
#include <libpq-fe.h>
#include <ncurses.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include <time.h>
#include <unistd.h>
//#include <arpa/inet.h>
//#include <netinet/in.h>
//#include <sys/io.h>
//#include <sys/ioctl.h>
//#include <sys/socket.h>
//#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
//#include <sys/wait.h>

#include "hvac.h"

void t_dbtrigger_i2c(s_data_t *data) {

	int i, j, k, num_out, num_in, len, attempts;
	char sqlbuff[1024], tbuff[512], printbuff[SIZE_PRINTBUFF], notifybuff[256];
	pid_t pid;
	FILE *pidfd;
	PGresult *res1, *res2;
	PGnotify *notify;
	ConnStatusType status;
	PGconn *conn_arduino;
        PGconn *conn_hvac = data->conn_hvac;
        
        pthread_mutex_t *pmut_sql = &data->mut_sql;

	pid = getpid();
	pidfd = fopen(data->pid_path, "a");
	fprintf(pidfd, "t_dbtrigger_i2c: %i\n", pid);
	fclose(pidfd);

	memset(tbuff, 0, sizeof(tbuff));
	sprintf(tbuff, "host=%s user=%s dbname=%s", data->dbhost_arduino, data->dbuser_arduino, data->dbname_arduino);
	conn_arduino = PQconnectdb(tbuff);
	if (PQstatus(conn_arduino) != CONNECTION_OK) {
		data->code = 4;
		memset(printbuff, 0, SIZE_PRINTBUFF);
		sprintf(printbuff, "exiting on error code 4, connection to arduino database in 't_dbtrigger_i2c' failed: %s", PQerrorMessage(conn_arduino));
		do_print(&data, printbuff, RED);
		PQfinish(conn_arduino);
		exit(4);
	}
        memset(printbuff, 0, SIZE_PRINTBUFF);
        sprintf(printbuff, "t_dbtrigger_i2c thread libpq connection to %s, fd: %i", tbuff, PQsocket(conn_arduino));
        do_print(data, printbuff, RED);
	pthread_mutex_lock(pmut_sql);
	res1 = PQexec(conn_arduino, "LISTEN i2c_arduino");
	pthread_mutex_unlock(pmut_sql);
	if (PQresultStatus(res1) != PGRES_COMMAND_OK) {
		PQclear(res1);
		PQfinish(conn_arduino);
		exit(1);
	}
	PQclear(res1);
	
	while(!data->quit){

	        int socksql;
	        fd_set input_mask;
		
		socksql = PQsocket(conn_arduino);
		FD_ZERO(&input_mask);
		FD_SET(socksql, &input_mask);
		if (select(socksql + 1, &input_mask, NULL, NULL, NULL) < 0) {
			PQfinish(conn_arduino);
			exit(1);
		}

		pthread_mutex_lock(pmut_sql);
		PQconsumeInput(conn_arduino);
		while ((notify = PQnotifies(conn_arduino)) != NULL) {
			memset(printbuff, 0, sizeof(printbuff));
			sprintf(printbuff, "ASYNC NOTIFY of '%s' PID %d: %s", notify->relname, notify->be_pid, notify->extra);
			do_print(data, printbuff, MAGENTA);
			memset(notifybuff, 0, sizeof(notifybuff));
			sprintf(notifybuff, "%s", notify->extra);
			PQfreemem(notify);
			i = 0;
			j = 0;
			memset(tbuff, 0, sizeof(tbuff));
			while (notifybuff[i] != ':'){
			        tbuff[j] = notifybuff[i];
			        i++;
			        j++;
                        }
			memset(sqlbuff, 0, sizeof(sqlbuff));
			sprintf(sqlbuff, "select name from unit where id = '%s'", tbuff);
			res1 = PQexec(conn_arduino, sqlbuff);
                        i++;
                        for (k = 0; k < 3; k++) {
                                memset(tbuff, 0, sizeof(tbuff));
                                j = 0;
                                while (notifybuff[i] != '|') {
                                        tbuff[j] = notifybuff[i];
                                        i++;
                                        j++;
                                }
        			memset(sqlbuff, 0, sizeof(sqlbuff));
	        		sprintf(sqlbuff, "update sensor set state = '%s' where unit = '%s' and port = 'i%i'", tbuff, PQgetvalue(res1, 0, 0), k);
        			res2 = PQexec(conn_hvac, sqlbuff);
        			PQclear(res2);
        			memset(printbuff, 0, sizeof(printbuff));
	        		sprintf(printbuff, "sensor: %s\tport: i%i\tstate: %s", PQgetvalue(res1, 0, 0), k, tbuff);
		        	do_print(data, printbuff, MAGENTA);
                                i++;
                        }
                        PQclear(res1);
		}
		pthread_mutex_unlock(pmut_sql);
	}
	PQfinish(conn_arduino);
}
