#!/bin/bash

#anemometer address and delay time is polled from the HVAC database weather_control table

while [ 1 ];
do
	SQL="select val from weather_control where description = 'current update rate';"
	DELAY=`psql -d hvac -t -c "$SQL" | sed 's/ //'`
	#echo "x"$DELAY"x"

	SQL="select val from weather_control where description = 'anemometer address';"
	ANEMOMETER=`psql -d hvac -t -c "$SQL" | sed 's/ //'`
	#echo "x"$ANEMOMETER"x"

	TEMP=`curl -s http://$ANEMOMETER | sed 's/W\^//' | sed 's/|!//'`
	#echo "CURL RAW:"$TEMP

	IFS='|';
	tokens=( $TEMP )
	SPEED=${tokens[0]}
	GUST=${tokens[1]}
	BEARING=${tokens[2]}
	#echo "SPEED:"$SPEED
	#echo "GUST:"$GUST
	#echo "BEARING:"$BEARING
	#echo ""

	SQL="insert into weather_current (speed, gust, bearing) values ('"$SPEED"', '"$GUST"', '"$BEARING"');"
	#echo $SQL
	psql -d hvac_mqtt -q -c "$SQL"
	
	sleep $DELAY
done;