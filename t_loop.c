/*
 * Copyright (C) 2003 Parnart, Inc.
 * Arlington, Virginia USA
 *(703) 528-3280 http://www.parnart.com
 *
 * All rights reserved.
 *
*/

/*----------------------------------------------------------------*/
/* t_loop.c						  */
/*----------------------------------------------------------------*/

#include <fcntl.h>
#include <libpq-fe.h>
#include <ncurses.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/io.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>

#include "hvac.h"

void t_processloop(s_data_t *data)
{
	int i;
	char tbuff[512], printbuff[SIZE_PRINTBUFF];
	struct timeval timeout;
	
	pid_t pid;
	FILE *pidfd;
	
	//pthread_mutex_t *pmut_sql_arduino = &data->mut_sql_arduino;
	//pthread_mutex_t *pmut_sql_apc_snmp = &data->mut_sql_apc_snmp;
	pthread_mutex_t *pmut_sql_hvac = &data->mut_sql_hvac;
		
	PGconn *conn_hvac;
	PGconn *conn_arduino;
	PGconn *conn_apc_snmp;
	PGresult *res1, *res2, *res3;

	memset(tbuff, 0, sizeof(tbuff));
	sprintf(tbuff, "host=%s user=%s dbname=%s", data->dbhost_apc_snmp, data->dbuser_apc_snmp, data->dbname_apc_snmp);
	conn_apc_snmp = PQconnectdb(tbuff);
	if (PQstatus(conn_apc_snmp) != CONNECTION_OK) {
		memset(printbuff, 0, SIZE_PRINTBUFF);
		sprintf(printbuff, "exiting on error code 4, connection to apc_snmp database in 't_processloop' failed: %s", PQerrorMessage(conn_apc_snmp));
		do_print(data, printbuff, RED);
		PQfinish(conn_apc_snmp);
		exit(ERROR_DB_CONNECT_APC_SNMP);
	}

	memset(tbuff, 0, sizeof(tbuff));
	sprintf(tbuff, "host=%s user=%s dbname=%s", data->dbhost_arduino, data->dbuser_arduino, data->dbname_arduino);
	conn_arduino = PQconnectdb(tbuff);
	if (PQstatus(conn_arduino) != CONNECTION_OK) {
		memset(printbuff, 0, SIZE_PRINTBUFF);
		sprintf(printbuff, "exiting on error code 4, connection to arduino database in 't_processloop' failed: %s", PQerrorMessage(conn_arduino));
		do_print(data, printbuff, RED);
		PQfinish(conn_arduino);
		exit(ERROR_DB_CONNECT_ARDUINO);
	}

	memset(tbuff, 0, sizeof(tbuff));
	sprintf(tbuff, "host=%s user=%s dbname=%s", data->dbhost_hvac, data->dbuser_hvac, data->dbname_hvac);
	conn_hvac = PQconnectdb(tbuff);
	if (PQstatus(conn_hvac) != CONNECTION_OK) {
		memset(printbuff, 0, SIZE_PRINTBUFF);
		sprintf(printbuff, "exiting on error code 4, connection to hvac database in 't_processloop' failed: %s", PQerrorMessage(conn_hvac));
		do_print(data, printbuff, RED);
		PQfinish(conn_hvac);
		exit(ERROR_DB_CONNECT_HVAC);
	}

	pid = getpid();
	pidfd = fopen(data->pid_path, "a");
	fprintf(pidfd, "t_loop: %i\n", pid);
	fclose(pidfd);


	while(!data->error){
		if (db_conn_error(conn_hvac))
			data->error = ERROR_DB_CONNECT_HVAC;
		if (db_conn_error(conn_arduino))
			data->error = ERROR_DB_CONNECT_ARDUINO;
		if (db_conn_error(conn_apc_snmp))
			data->error = ERROR_DB_CONNECT_APC_SNMP;
		
		memset(printbuff, 0, SIZE_PRINTBUFF);
		sprintf(printbuff, "polling...");
		do_print(data, printbuff, RED);

		pthread_mutex_lock(pmut_sql_hvac);
		//THIS NEEDS TO BE CHANGED SUCH THAT THE WHERE CLAUSE IS REMOVED IN ORDER TO USE APC_SNMP DEVICES
		//res1 = PQexec(conn_hvac, "select * from actuator where db = 'arduino_mqtt' order by db, id");
		res1 = PQexec(conn_hvac, "select * from actuator order by db, id");
		pthread_mutex_unlock(pmut_sql_hvac);
		
		for (i = 0; i < PQntuples(res1); i++) {
			memset(tbuff, 0, sizeof(tbuff));
			sprintf(tbuff, "select %s from status_dio where unit = (select id from unit where name = '%s' and online = 't');", PQgetvalue(res1, i, 4), PQgetvalue(res1, i, 3));
			pthread_mutex_lock(pmut_sql_hvac);
			if (strcmp(PQgetvalue(res1, i, 2), "arduino_mqtt") == 0)
				res2 = PQexec(conn_arduino, tbuff);
			else if (strcmp(PQgetvalue(res1, i, 2), "apc_snmp") == 0)
				res2 = PQexec(conn_apc_snmp, tbuff);
			pthread_mutex_unlock(pmut_sql_hvac);

			if (PQntuples(res2)) {
				memset(tbuff, 0, sizeof(tbuff));
				sprintf(tbuff, "update actuator set state = '%s' where id = '%s';", PQgetvalue(res2, 0, 0), PQgetvalue(res1, i, 0));
				pthread_mutex_lock(pmut_sql_hvac);
				res3 = PQexec(conn_hvac, tbuff);
				PQclear(res3);
				pthread_mutex_unlock(pmut_sql_hvac);

				memset(printbuff, 0, SIZE_PRINTBUFF);
				sprintf(printbuff, "updating actuator status %s: %s (%s:%s)", PQgetvalue(res1, i, 0), PQgetvalue(res1, i, 1), PQgetvalue(res1, i, 3), PQgetvalue(res1, i, 4));
				do_print(data, printbuff, RED);
			}
			PQclear(res2);
		}	
		PQclear(res1);

		
		pthread_mutex_lock(pmut_sql_hvac);
		res1 = PQexec(conn_hvac, "select * from contact order by db, id");
		pthread_mutex_unlock(pmut_sql_hvac);
		for (i = 0; i < PQntuples(res1); i++) {
			memset(tbuff, 0, sizeof(tbuff));
			sprintf(tbuff, "select %s from status_dio where unit = (select id from unit where name = '%s' and online = 't');", PQgetvalue(res1, i, 4), PQgetvalue(res1, i, 3));
			pthread_mutex_lock(pmut_sql_hvac);
			if (strcmp(PQgetvalue(res1, i, 2), "arduino_mqtt") == 0)
				res2 = PQexec(conn_arduino, tbuff);
			else if (strcmp(PQgetvalue(res1, i, 2), "apc_snmp") == 0)
				res2 = PQexec(conn_apc_snmp, tbuff);
			pthread_mutex_unlock(pmut_sql_hvac);
			if (PQntuples(res2)) {
				memset(tbuff, 0, sizeof(tbuff));
				sprintf(tbuff, "update contact set state = '%s' where id = '%s';", PQgetvalue(res2, 0, 0), PQgetvalue(res1, i, 0));
				pthread_mutex_lock(pmut_sql_hvac);
				res3 = PQexec(conn_hvac, tbuff);
				PQclear(res3);
				pthread_mutex_unlock(pmut_sql_hvac);

				memset(printbuff, 0, SIZE_PRINTBUFF);
				sprintf(printbuff, "updating contact %s status: %s (%s:%s)", PQgetvalue(res1, i, 0), PQgetvalue(res1, i, 1), PQgetvalue(res1, i, 3), PQgetvalue(res1, i, 4));
				do_print(data, printbuff, RED);
			}
			PQclear(res2);				
		}	
		PQclear(res1);
		


		//pthread_mutex_unlock(pmut_sql_hvac);
		//memset(printbuff, 0, SIZE_PRINTBUFF);
		//sprintf(printbuff, "\npolling loop complete...\n");
		//do_print(data, printbuff, RED);

		timeout.tv_sec = (long) 15;
		timeout.tv_usec = (long) 27;
		select(0, (fd_set *) 0, (fd_set *) 0, (fd_set *) 0, &timeout);
	}

	PQfinish(conn_arduino);
	PQfinish(conn_hvac);
	PQfinish(conn_apc_snmp);
	
}
