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

#define ANALOG_CHANNEL 0

void t_dbtrigger_ain(s_data_t *data) {

	int i, j, k;
	char sqlbuff[1024], tbuff[512], printbuff[SIZE_PRINTBUFF], notifybuff[256];
	pid_t pid;
	FILE *pidfd;
	PGresult *res1, *res2;
	PGnotify *notify;
	PGconn *conn_arduino;
        PGconn *conn_hvac;
        
        pthread_mutex_t *pmut_sql_hvac = &data->mut_sql_hvac;

	pid = getpid();
	pidfd = fopen(data->pid_path, "a");
	fprintf(pidfd, "t_dbtrigger_ain: %i\n", pid);
	fclose(pidfd);

	memset(tbuff, 0, sizeof(tbuff));
	sprintf(tbuff, "host=%s user=%s dbname=%s", data->dbhost_arduino, data->dbuser_arduino, data->dbname_arduino);
	conn_arduino = PQconnectdb(tbuff);
	if (PQstatus(conn_arduino) != CONNECTION_OK) {
		memset(printbuff, 0, SIZE_PRINTBUFF);
		sprintf(printbuff, "exiting on error, connecting to arduino database in 't_dbtrigger_ain' failed: %s", PQerrorMessage(conn_arduino));
		do_print(data, printbuff, RED);
		PQfinish(conn_arduino);
		exit(ERROR_DB_CONNECT_ARDUINO);
	}
	memset(tbuff, 0, sizeof(tbuff));
	sprintf(tbuff, "host=%s user=%s dbname=%s", data->dbhost_hvac, data->dbuser_hvac, data->dbname_hvac);
	conn_hvac = PQconnectdb(tbuff);
	if (PQstatus(conn_hvac) != CONNECTION_OK) {
		memset(printbuff, 0, SIZE_PRINTBUFF);
		sprintf(printbuff, "exiting on error, connecting to hvac database in 't_dbtrigger_ain' failed: %s", PQerrorMessage(conn_hvac));
		do_print(data, printbuff, RED);
		PQfinish(conn_hvac);
		exit(ERROR_DB_CONNECT_HVAC);
	}

        memset(printbuff, 0, SIZE_PRINTBUFF);
        sprintf(printbuff, "t_dbtrigger_ain thread libpq connection to %s, fd: %i", tbuff, PQsocket(conn_arduino));
        do_print(data, printbuff, RED);
	res1 = PQexec(conn_arduino, "LISTEN status_ain_arduino_mqtt");
	if (PQresultStatus(res1) != PGRES_COMMAND_OK) {
		PQclear(res1);
		PQfinish(conn_arduino);
		exit(ERROR_DB_LISTEN_ARDUINO);
	}
	PQclear(res1);
	
	while(!data->error){

	        int socksql;
	        fd_set input_mask;
                
		if (db_conn_error(conn_hvac))
			data->error = ERROR_DB_CONNECT_HVAC;
		if (db_conn_error(conn_arduino))
			data->error = ERROR_DB_CONNECT_ARDUINO;
		
		socksql = PQsocket(conn_arduino);
		FD_ZERO(&input_mask);
		FD_SET(socksql, &input_mask);
		if (select(socksql + 1, &input_mask, NULL, NULL, NULL) < 0) {
			PQfinish(conn_arduino);
			exit(1);
		}

		PQconsumeInput(conn_arduino);
		//pthread_mutex_lock(pmut_sql_arduino);
		while ((notify = PQnotifies(conn_arduino)) != NULL) {
		        pthread_mutex_lock(pmut_sql_hvac);
			memset(printbuff, 0, sizeof(printbuff));
			sprintf(printbuff, "ASYNC NOTIFY of '%s' PID %d: %s", notify->relname, notify->be_pid, notify->extra);
			do_print(data, printbuff, YELLOW);
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
			sprintf(sqlbuff, "select id, name from unit where id = '%s'", tbuff);
			res1 = PQexec(conn_arduino, sqlbuff);
                        i++;

			memset(printbuff, 0, sizeof(printbuff));
			sprintf(printbuff, "%02d (%s)", atoi(PQgetvalue(res1, 0, 0)), PQgetvalue(res1, 0, 1));
			do_print(data, printbuff, YELLOW);
                        for (k = 0; k < 16; k++) {
                                memset(tbuff, 0, sizeof(tbuff));
                                j = 0;
                                while (notifybuff[i] != '|') {
                                        tbuff[j] = notifybuff[i];
                                        i++;
                                        j++;
                                }
                                if (k == ANALOG_CHANNEL) {
	        			//pthread_mutex_lock(pmut_sql_hvac);
        				memset(sqlbuff, 0, sizeof(sqlbuff));
	        			sprintf(sqlbuff, "update sensor set state_raw = '%.2f' where unit = '%s' and port = 'a%02d'", atof(tbuff), PQgetvalue(res1, 0, 1), k);
        				res2 = PQexec(conn_hvac, sqlbuff);
        				PQclear(res2);
	        			memset(printbuff, 0, sizeof(printbuff));
		        		sprintf(printbuff, "port: a%02d\tstate: %.0f", k, atof(tbuff));
			        	do_print(data, printbuff, YELLOW);
                        	        i++;
                        	        //pthread_mutex_unlock(pmut_sql_hvac);
				}
                        }
                        PQclear(res1);
                        pthread_mutex_unlock(pmut_sql_hvac);
		}
		//pthread_mutex_unlock(pmut_sql_arduino);
	}
	PQfinish(conn_arduino);
}

