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

void t_dbtrigger_dio_apc_snmp(s_data_t *data) {

	int i, j, k;
	char sqlbuff[1024], tbuff[512], printbuff[SIZE_PRINTBUFF], notifybuff[256];
	pid_t pid;
	FILE *pidfd;
	PGresult *res1, *res2;
	PGnotify *notify;
	PGconn *conn_apc_snmp;
        PGconn *conn_hvac;
        
        struct timeval timeout;
        
        pthread_mutex_t *pmut_sql_hvac = &data->mut_sql_hvac;

	pid = getpid();
	pidfd = fopen(data->pid_path, "a");
	fprintf(pidfd, "t_dbtrigger_dio_apc_snmp: %i\n", pid);
	fclose(pidfd);

	memset(tbuff, 0, sizeof(tbuff));
	sprintf(tbuff, "host=%s user=%s dbname=%s", data->dbhost_apc_snmp, data->dbuser_apc_snmp, data->dbname_apc_snmp);
	conn_apc_snmp = PQconnectdb(tbuff);
	if (PQstatus(conn_apc_snmp) != CONNECTION_OK) {
		memset(printbuff, 0, SIZE_PRINTBUFF);
		sprintf(printbuff, "exiting on error, connecting to apc_snmp database in 't_dbtrigger_dio_apc_snmp' failed: %s", PQerrorMessage(conn_apc_snmp));
		do_print(data, printbuff, RED);
		PQfinish(conn_apc_snmp);
		exit(ERROR_DB_CONNECT_APC_SNMP);
	}
        memset(printbuff, 0, SIZE_PRINTBUFF);
        sprintf(printbuff, "t_dbtrigger_dio_apc_snmp thread libpq connection to %s, fd: %i", tbuff, PQsocket(conn_apc_snmp));
        do_print(data, printbuff, RED);

	memset(tbuff, 0, sizeof(tbuff));
	sprintf(tbuff, "host=%s user=%s dbname=%s", data->dbhost_hvac, data->dbuser_hvac, data->dbname_hvac);
	conn_hvac = PQconnectdb(tbuff);
	if (PQstatus(conn_hvac) != CONNECTION_OK) {
		memset(printbuff, 0, SIZE_PRINTBUFF);
		sprintf(printbuff, "exiting on error, connecting to hvac database in 't_dbtrigger_dio_apc_snmp' failed: %s", PQerrorMessage(conn_hvac));
		do_print(data, printbuff, RED);
		PQfinish(conn_hvac);
		exit(ERROR_DB_CONNECT_HVAC);
	}
        memset(printbuff, 0, SIZE_PRINTBUFF);
        sprintf(printbuff, "t_dbtrigger_dio_apc_snmp thread libpq connection to %s, fd: %i", tbuff, PQsocket(conn_hvac));
        do_print(data, printbuff, RED);

	res1 = PQexec(conn_apc_snmp, "LISTEN dio_apc_snmp");
	if (PQresultStatus(res1) != PGRES_COMMAND_OK) {
		PQclear(res1);
		PQfinish(conn_apc_snmp);
		exit(1);
	}
	PQclear(res1);
        memset(printbuff, 0, SIZE_PRINTBUFF);
        sprintf(printbuff, "listening for dio_apc_snmp message on database apc_snmp");
        do_print(data, printbuff, RED);
        	
	while(!data->error){

	        int socksql;
	        fd_set input_mask;
		
		if (db_conn_error(conn_hvac))
			data->error = ERROR_DB_CONNECT_HVAC;
		if (db_conn_error(conn_apc_snmp))
			data->error = ERROR_DB_CONNECT_APC_SNMP;

		socksql = PQsocket(conn_apc_snmp);
		FD_ZERO(&input_mask);
		FD_SET(socksql, &input_mask);
		if (select(socksql + 1, &input_mask, NULL, NULL, NULL) < 0) {
			PQfinish(conn_apc_snmp);
			exit(1);
		}

		PQconsumeInput(conn_apc_snmp);
		while ((notify = PQnotifies(conn_apc_snmp)) != NULL) {
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
			sprintf(sqlbuff, "select id, name from unit where id = '%s'", tbuff);
			res1 = PQexec(conn_apc_snmp, sqlbuff);
                        i++;
                        memset(tbuff, 0, sizeof(tbuff));
                        k = 0;
                        
                        memset(printbuff, 0, sizeof(printbuff));
                        sprintf(printbuff, "%02d (%s)", atoi(PQgetvalue(res1, 0, 0)), PQgetvalue(res1, 0, 1));
                        do_print(data, printbuff, MAGENTA);
                        while (notifybuff[i] != '|') {
                                memset(sqlbuff, 0, sizeof(sqlbuff));
                                sprintf(sqlbuff, "update actuator set state = '%c' where unit = '%s' and port = 'd%02d' and db='apc_snmp'", notifybuff[i], PQgetvalue(res1, 0, 1), k);
                                pthread_mutex_lock(pmut_sql_hvac);
                                res2 = PQexec(conn_hvac, sqlbuff);
                                pthread_mutex_unlock(pmut_sql_hvac);
                                PQclear(res2);
                                i++;
                                k++;
		
				timeout.tv_sec = (long) 0;
				timeout.tv_usec = (long) 25000;
				select(0, (fd_set *) 0, (fd_set *) 0, (fd_set *) 0, &timeout);

                        }
                        PQclear(res1);
		}
	}

	PQfinish(conn_hvac);
	PQfinish(conn_apc_snmp);
}
