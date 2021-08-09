#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include <libpq-fe.h>

#define DB_FN_START	-4
#define DB_FN_STATUS	-3
#define DB_FN_EXEC	-2
#define DB_FN_RESULT	-1
#define DB_FN_SUCCESS	0

char sql_execute (PGconn *conn, char *sqlstring)
{
	ConnStatusType status;
	PGresult *result;
	char error;

	//printf("%s\n", sqlstring);

	error = DB_FN_STATUS;
	status = PQstatus(conn);
	if (status == CONNECTION_BAD) {
		PQreset(conn);
		return error;
	}

	error = DB_FN_EXEC;
	result = PQexec(conn, sqlstring);
	if (!result) {
		return error;
	}

	PQclear(result);
	
	return DB_FN_SUCCESS;
}
