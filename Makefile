#
# Copyright (C) 2003 Conrad Rehill (703) 528-3280
# All rights reserved.
#
# This software may be freely copied, modified, and redistributed
# provided that this copyright notice is preserved on all copies.
#
# There is no warranty or other guarantee of fitness of this software
# for any purpose.  It is provided solely "as is".
#
#

#----------------------------------------------------------------
# pronoc 33/53 Server Program Makefile
#----------------------------------------------------------------

SHELL=/bin/bash

EXECUTABLE= hvac
OBJ= main.o signal_handlers.o t_process_monitor.o t_loop.o t_dbtrigger_i2c.o t_dbtrigger_ain.o t_dbtrigger_dio_arduino.o t_dbtrigger_dio_apc_snmp.o parser.o kbhit.o t_keyboard_handler.o do_print.o
INCLUDEDIR=.
CFLAGS= -I$(INCLUDEDIR) -I/usr/include/postgresql -Wall
LDFLAGS= -lpthread -lpq -lncurses
CC = gcc

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -o $@ $(LDFLAGS)
	chmod 775 $(EXECUTABLE)

main.o: main.c hvac.h
	$(CC) $(CFLAGS) -c main.c -o $*.o
parser.o: parser.c hvac.h
	$(CC) $(CFLAGS) -c $*.c
signal_handlers.o: signal_handlers.c hvac.h
	$(CC) $(CFLAGS) -c $*.c
t_process_monitor.o: t_process_monitor.c hvac.h
	$(CC) $(CFLAGS) -c $*.c
t_loop.o: t_loop.c hvac.h
	$(CC) $(CFLAGS) -c $*.c
t_dbtrigger_i2c.o: t_dbtrigger_i2c.c hvac.h
	$(CC) $(CFLAGS) -c $*.c
t_dbtrigger_ain.o: t_dbtrigger_ain.c hvac.h
	$(CC) $(CFLAGS) -c $*.c
t_dbtrigger_dio_arduino.o: t_dbtrigger_dio_arduino.c hvac.h
	$(CC) $(CFLAGS) -c $*.c
t_dbtrigger_dio_apc_snmp.o: t_dbtrigger_dio_apc_snmp.c hvac.h
	$(CC) $(CFLAGS) -c $*.c
#t_exterior.o: t_exterior.c hvac.h
#	$(CC) $(CFLAGS) -c $*.c
t_keyboard_handler.o: t_keyboard_handler.c hvac.h
	$(CC) $(CFLAGS) -c $*.c
t_kbhit.o: t_kbhit.c hvac.h
	$(CC) $(CFLAGS) -c $*.c
do_print.o: do_print.c hvac.h
	$(CC) $(CFLAGS) -c $*.c
	

clean:
	rm -f ./*.o
	rm -f ./$(EXECUTABLE)
	rm -f ./a.out
	rm -f ./core

install:
	cp -f ./hvac.conf /usr/local/etc
	cp -f ./hvac /usr/local/bin
