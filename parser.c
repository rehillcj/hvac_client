/*
 * Copyright (C) 2003 Parnart, Inc.
 * Arlington, Virginia USA
 *(703) 528-3280 http://www.parnart.com
 *
 * All rights reserved.
 *
*/

/*----------------------------------------------------------------*/
/* parser.c							  */
/*----------------------------------------------------------------*/

#include <ctype.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>

void parse_init(char *initfile, char *datafile, char *cmpstring)
{
        int i, j;
        char string_raw[100], string_filtered[100];
	FILE *config_file;

	config_file = fopen(initfile, "r");

	while((fgets(string_raw, 200, config_file) != NULL)){
		if (string_raw[0] == 0x23 || isspace(string_raw[0])) /* # starts comment line */
			continue;

		memset(string_filtered, 0, sizeof(string_filtered));
		i = 0;
		j = 0;
		while ((string_raw[i] != '#') && (i <= strlen(string_raw) - 1)){
			if (!(isspace(string_raw[i]))){
				string_filtered[j] = string_raw[i];
				j++;
			}
			i++;
		}
		for (i = 0; i <= strlen(string_filtered) - 1; i++)
			if (islower(string_filtered[i]))
				string_filtered[i] = toupper(string_filtered[i]);

		/*if (!strncmp(string_filtered, cmpstring, (sizeof(cmpstring) + 1))){*/
		if (!strncmp(string_filtered, cmpstring, strlen(cmpstring))){
			/*printf("%s\t%s\n", string_filtered, cmpstring);*/
			memset(string_filtered, 0, sizeof(string_filtered));
			i = 0;
			while (string_raw[i] != '=')
				i++;
			i++;
			while (string_raw[i] == ' ')
				i++;
			j = 0;
			while ((string_raw[i] != '#') && (string_raw[i] != 0x0D) && (string_raw[i] != 0x0A)){
				string_filtered[j] = string_raw[i];
				i++;
				j++;
			}
			sprintf(datafile, "%s", string_filtered);
			continue;
		}
	}
	fclose(config_file);
	return;
}
