/*
 * Copyright (C) 2018 Conrad Rehill (703) 528-3280
 * All rights reserved.
 *
 * This software may be freely copied, modified, and redistributed
 * provided that this copyright notice is preserved on all copies.
 *
 * There is no warranty or other guarantee of fitness of this software
 * for any purpose.  It is provided solely "as is".
 *
*/

/*----------------------------------------------------------------*/
/* arduino.h							  */
/*----------------------------------------------------------------*/

//#define FALSE			0
//#define TRUE			1
#define UNSET			0x00
#define PORT_LISTENER		49717
#define PORT_HTTP		80
#define MAX_CONNECTIONS		100

#define WHITE                   1
#define RED                     2
#define GREEN                   3
#define YELLOW                  4
#define MAGENTA                 5
#define CYAN                    6
#define BLUE                    7
#define BLACK                   8

#define SIZE_PATHBUFF		512
#define SIZE_PRINTBUFF		1024
#define SIZE_DB_ARG		128

#define ERROR_READ_CONFIG		1
#define ERROR_READ_PID			2
#define ERROR_DB_CONNECT_HVAC		5
#define ERROR_DB_CONNECT_ARDUINO	6
#define ERROR_DB_CONNECT_APC_SNMP	7
#define ERROR_DB_LISTEN_ARDUINO		8


typedef	 struct s_data {
	char verbose;
	char curses;
	char error;
        char print;
        char quit;
        char code;

	char app_path[SIZE_PATHBUFF];
	char app_name[SIZE_PATHBUFF];
	char init_path[SIZE_PATHBUFF];
	char pid_path[SIZE_PATHBUFF];
	char db_name[SIZE_DB_ARG];
	char db_user[SIZE_DB_ARG];
	char dbhost_arduino[SIZE_DB_ARG];
	char dbhost_apc_snmp[SIZE_DB_ARG];
	char dbhost_hvac[SIZE_DB_ARG];
	char dbuser_arduino[SIZE_DB_ARG];
	char dbuser_apc_snmp[SIZE_DB_ARG];
	char dbuser_hvac[SIZE_DB_ARG];
	char dbname_arduino[SIZE_DB_ARG];
	char dbname_apc_snmp[SIZE_DB_ARG];
	char dbname_hvac[SIZE_DB_ARG];
	char host_anemometer[SIZE_DB_ARG];	
	//PGconn *conn_arduino;
	//PGconn *conn_apc_snmp;
	//PGconn *conn_hvac;
	
	fd_set *fds_read;
	fd_set *fds_read_test;
	int *fd_highest;
	int *numconnections;
	int *server_sockfd;

	pthread_mutex_t mut_sql_arduino;
	pthread_mutex_t mut_sql_apc_snmp;
	pthread_mutex_t mut_sql_hvac;
	pthread_mutex_t mut_print;
	//pthread_mutex_t mut_write;
	//pthread_mutex_t mut_read;
	//pthread_cond_t con_read;

	WINDOW *w_main, *w_banner;
	int winwidth;
	int winheight;
	int winrow_main;
	int wincol_main;

	} s_data_t;

void parse_init(char *, char *, char *);
void t_listener(s_data_t *);
void t_processloop(s_data_t *);
void t_process_monitor(s_data_t *);
void t_dbtrigger(s_data_t *);
void t_dbtrigger_i2c(s_data_t *);
void t_dbtrigger_ain(s_data_t *);
void t_dbtrigger_dio_arduino(s_data_t *);
void t_dbtrigger_dio_apc_snmp(s_data_t *);
void t_discovery(s_data_t *);
void t_exterior(s_data_t *);
void handler(int);
void do_print(s_data_t *, char *, int);
int db_conn_error(PGconn *);
void curses_shutdown(s_data_t *, int);

void t_keyboard_handler(s_data_t *);
unsigned char kb_getc_w(void);
unsigned char kb_getc(void);
void set_tty_raw(void);
void set_tty_cooked(void);
