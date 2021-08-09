DROP TRIGGER update_humidity ON sensor;
DROP TRIGGER update_weather_short ON weather_short;
DROP TRIGGER update_weather_current ON weather_current;

DROP FUNCTION update_humidity();
DROP FUNCTION update_weather_current();
DROP FUNCTION update_weather_short();


--this function updates the 'location' table to adjust the current humidity setpoint in the furnace intake.
--the trigger does this whenever the outdoor temperature is updated
CREATE OR REPLACE FUNCTION update_humidity() RETURNS TRIGGER  AS $update_humidity$
DECLARE
  v_hcurrent float;
BEGIN
  SELECT sensor.state_adjusted INTO v_hcurrent FROM sensor WHERE description = 'relative humidity hvac #2';
  IF (new.description = 'temperature i2c ambient') THEN

    -- Farenheit version
    --IF (new.state_adjusted < 50.0) THEN
    --  UPDATE location SET mode = 'heat', setpoint = ((new.state_adjusted * 0.5) + 25.0) WHERE description = 'first floor humidity';
    -- Celsius version
    IF (new.state_adjusted < 10.0) THEN
      UPDATE location SET mode = 'heat', setpoint = ((new.state_adjusted * 0.9) + 41.0) WHERE description = 'first floor humidity';
    ELSE
      UPDATE location SET mode = 'off', setpoint = v_hcurrent WHERE description = 'first floor humidity';
    END IF;

    IF (new.state_adjusted > 25.0) THEN
            UPDATE location SET setpoint = (new.state_adjusted + 2.0) where description = 'attic east' and mode = 'cool';
            UPDATE location SET setpoint = (new.state_adjusted + 2.0) where description = 'attic west' and mode = 'cool';
    END IF;

  END IF;

  return new;
END;
$update_humidity$ LANGUAGE plpgsql;
ALTER FUNCTION update_humidity() OWNER TO controller;
CREATE TRIGGER update_humidity BEFORE UPDATE ON sensor FOR EACH ROW EXECUTE PROCEDURE update_humidity();



--this function runs whenever the weather_current table has a new row inserted into it by the "weather.bash" shell script.
--it takes the raw values of temperature, RH, and barometric pressure and calculates the heat index, wind chill, and dew point for the current
--raw values.  then it compares the timestamp of the last two values in the weather_current table.  if the minute of the timestamp changes, it
--calculates the averages or appropriate max/min for each of the values in the weather_current table and inserts those values into the
--weather_short table.  this becomes an average value record for that minute in time.  finally, it zaps all the values in the weather_current
--table and starts building a new table at the rate defined by the 'while...loop' in weather.bash
CREATE OR REPLACE FUNCTION update_weather_current() RETURNS TRIGGER  AS $update_weather_current$
--CREATE OR REPLACE FUNCTION update_weather_current() RETURNS VOID  AS $$
DECLARE
    v_row_sensor sensor%rowtype;
    v_temp_analog float;
    v_temp_digital float;
    v_temp float;
    v_temp_avg float;
    v_temp_celsius float;
    v_temp_adjusted float;
    v_pressure float;
    v_humidity float;
    v_temp_index_hard float;
    v_temp_index_easy float;
    v_temp_index_adj float;
    v_temp_index float;
    v_temp_chill float;
    v_temp_dew_gamma float;
    v_temp_dew float;
    v_pressure_trend float;

    v_id_last integer;
    v_test1 integer;
    v_test2 integer;

    v_farenheit float;
    v_temp_analog_avg float;
    v_temp_digital_avg float;
    v_pressure_avg float;
    v_humidity_avg float;
    v_speed_avg float;
    v_gust_max float;
    v_bearing_avg float;
    v_temp_index_max float;
    v_temp_chill_min float;
    v_temp_dew_avg float;
    
    v_temp_selector VARCHAR;

    C1 float;
    C2 float;
    C3 float;
    C4 float;
    C5 float;
    C6 float;
    C7 float;
    C8 float;
    C9 float;

BEGIN
    
    --the arduino program outputs the Davis 7911 anemometer
    --in MPH, so this needs to be converted to SI for database
    new.speed = new.speed * 1.60934;
    new.gust = new.gust * 1.60934;

    --Farenheit
    C1 = -42.379;
    C2 = 2.04901523;
    C3 = 10.14333127;
    C4 = -0.22475541;
    C5 = -0.00683783;
    C6 = -0.05481717;
    C7 = 0.0122374;
    C8 = .00085282;
    C9 = -0.00000199;
    --Celsius
    --C1 = -8.78469475556;
    --C2 = 1.61139411;
    --C3 = 2.33854883889;
    --C4 = -0.14611605;
    --C5 = -0.012308094;
    --C6 = -0.0164248277778;
    --C7 = 0.002211732;
    --C8 = 0.00072546;
    --C9 = -0.000003582;


    --determine which sensor to use for temperature
    SELECT val INTO v_temp_selector FROM weather_control WHERE description = 'temperature sensor';


    FOR v_row_sensor IN SELECT * FROM sensor WHERE unit = 'exterior north'
    LOOP
      IF (v_row_sensor.description = 'temperature analog ambient') THEN
        v_temp_analog = v_row_sensor.state_adjusted;
      ELSEIF (v_row_sensor.description = 'temperature i2c ambient') THEN
        v_temp_digital = v_row_sensor.state_adjusted;
      ELSEIF (v_row_sensor.description = 'barometric pressure ambient') THEN
        v_pressure = v_row_sensor.state_adjusted;
      ELSEIF (v_row_sensor.description = 'relative humidity ambient') THEN
        v_humidity = v_row_sensor.state_adjusted;
      END IF;
    END LOOP;

    --set v_temp either the analog or digital sensor for calculations
    v_temp = v_temp_analog;
    IF (v_temp_selector = '1') THEN
         v_temp = v_temp_digital;
    END IF;

    v_farenheit = (v_temp * 1.8) + 32;
        
    --heat index calculation
    v_temp_index_easy = 0.5 * (v_farenheit + 61.0 + ((v_farenheit - 68.0) * 1.2) + (v_humidity * 0.094));
    v_temp_index = v_temp_index_easy;
    IF (((v_temp_index_easy + v_farenheit) / 2.0) > 80.0) THEN
      v_temp_index_hard = C1
                          + (C2 * v_farenheit)
                          + (C3 * v_humidity)
                          + (C4 * v_farenheit * v_humidity)
                          + (C5 * v_farenheit * v_temp * v_temp)
                          + (C6 * v_farenheit * v_humidity)
                          + (C7 * v_farenheit * v_farenheit * v_humidity)
                          + (C8 * v_farenheit * v_humidity * v_humidity)
                          + (C9 * v_farenheit * v_farenheit * v_humidity * v_humidity);
      IF ((v_humidity < 13.0) AND ((v_farenheit > 80.0) AND (v_farenheit < 112.0))) THEN
        v_temp_index_adj = ((13.0 - v_humidity) / 4.0) * |/( (17.0 - abs(v_farenheit - 95.0)) / 17.0);
        v_temp_index_hard = v_temp_index_hard - v_temp_index_adj;
      ELSEIF ((v_humidity > 85.0) AND ((v_farenheit > 80.0) AND (v_farenheit < 87.0))) THEN
        v_temp_index_adj = ((v_humidity - 85.0) / 10.0) * ((87.0 - v_farenheit) / 5.0);
        v_temp_index_hard = v_temp_index_hard + v_temp_index_adj;
      END IF;
      v_temp_index = v_temp_index_hard;
    END IF;
    IF ((v_temp_index <= v_temp) OR (v_temp < 70.0)) THEN
      v_temp_index = v_farenheit;
    END IF;

    --wind chill calculation
    v_temp_chill = v_farenheit;
    IF ((v_farenheit < 50.0) AND (new.speed > 3.0)) THEN
      v_temp_chill = 35.74 + (0.6215 * v_farenheit) - (35.75 * power(new.speed, 0.16)) + (0.4275 * v_farenheit * power(new.speed, 0.16));
      IF (v_temp_chill >= v_farenheit) THEN
        v_temp_chill = v_farenheit;
      END IF;
    END IF;

    v_temp_adjusted = v_farenheit;
    IF (v_temp_chill < v_temp_adjusted) THEN
      v_temp_adjusted = v_temp_chill;
    ELSEIF (v_temp_index > v_farenheit) THEN
      v_temp_adjusted = v_temp_index;
    END IF;

    --convert back to Celsius for return
    v_temp_index = (v_temp_index - 32.0) * (5.0 / 9.0);
    v_temp_chill = (v_temp_chill - 32.0) * (5.0 / 9.0);
    v_temp_adjusted = (v_temp_adjusted - 32.0) * (5.0 / 9.0);

    --dew point calculation - this is in Celsius !!
    v_temp_dew_gamma = ln(v_humidity / 100) + ((18.678 * v_temp) / (257.14 + v_temp));
    v_temp_dew = (257.14 * v_temp_dew_gamma) / (18.678 - v_temp_dew_gamma);
    IF (v_temp_dew >= v_temp) THEN
        v_temp_dew = v_temp;
    END IF;

    --RAISE NOTICE 'hi_hard %', v_hi_hard;
    --RAISE NOTICE 'hi_easy %', v_hi_easy;
    --RAISE NOTICE 'temp index %', v_hi;
    --RAISE NOTICE 'ta: %', v_ta;
    --RAISE NOTICE 'td: %', v_td;
    --RAISE NOTICE 'bp: %', v_bp;
    --RAISE NOTICE 'rh: %', v_rh;
    --RAISE NOTICE 'wc: %', v_wc;
    --SELECT sensor.state INTO v_hcurrent FROM sensor WHERE description = 'relative humidity hvac #2';


    SELECT pressure_trend INTO v_pressure_trend FROM weather_short WHERE id = (SELECT MAX(id) from weather_short);
    UPDATE weather_summary SET	temp_current = v_temp, 
                                pressure_current= v_pressure,
                                pressure_trend_short = v_pressure_trend,
                                humidity_current = v_humidity,
                                speed_current = new.speed,
                                bearing_current = new.bearing,
                                temp_adjusted_current = v_temp_adjusted,
                                temp_dew_current = v_temp_dew,
                                update_last = now();
                            
    new.temp_analog = v_temp_analog;
    new.temp_digital = v_temp_digital;
    new.pressure = v_pressure;
    new.humidity = v_humidity;
    new.temp_index = v_temp_index;
    new.temp_chill = v_temp_chill;
    new.temp_dew = v_temp_dew;
    new.date_time = now();


    SELECT MAX(id) INTO v_id_last FROM weather_current;

    --RAISE NOTICE 'max id: % %', v_id_last, (v_id_last - 1);
    v_test1 = extract(minute from (select date_time from weather_current where id = v_id_last));
    v_test2 = extract(minute from (select date_time from weather_current where id = (v_id_last - 1)));
    --RAISE NOTICE 'last minute: %', v_test1;
    --RAISE NOTICE 'next to last minute %', v_test2;
    IF (v_test1 != v_test2) THEN
      SELECT    AVG(temp_analog),
                AVG(temp_digital),
                AVG(pressure),
                AVG(humidity),
                AVG(speed),
                MAX(gust),
                AVG(bearing),
                MAX(temp_index),
                MIN(temp_chill),
                AVG(temp_dew)
      INTO      v_temp_analog_avg,
                v_temp_digital_avg,
                v_pressure_avg,
                v_humidity_avg,
                v_speed_avg,
                v_gust_max,
                v_bearing_avg,
                v_temp_index_max,
                v_temp_chill_min,
                v_temp_dew_avg
      FROM weather_current WHERE id < v_id_last;

      --determine which value to use for the short term average temperature      
      v_temp_avg = v_temp_analog_avg;
      IF (v_temp_selector = '1') THEN
          v_temp_avg = v_temp_digital_avg;
      END IF;          

      INSERT INTO weather_short ( temp_avg,
                                  pressure_avg,
                                  humidity_avg,
                                  speed_avg,
                                  gust_max,
                                  bearing_avg,
                                  temp_index_max,
                                  temp_chill_min,
                                  temp_dew_avg,
                                  date_time)
      VALUES 			( v_temp_avg,
                                  v_pressure_avg,
                                  v_humidity_avg,
                                  v_speed_avg,
                                  v_gust_max,
                                  v_bearing_avg,
                                  v_temp_index_max,
                                  v_temp_chill_min,
                                  v_temp_dew_avg,
                                  now()
                                );

      UPDATE weather_summary SET 
          temp_max_24hour_short = (SELECT MAX(temp_avg) FROM weather_short WHERE date_time > (now() - INTERVAL '1 day')),
          temp_min_24hour_short = (SELECT MIN(temp_avg) FROM weather_short WHERE date_time > (now() - INTERVAL '1 day')), 
          gust_max_24hour_short = (SELECT MAX(gust_max) FROM weather_short WHERE date_time > (now() - INTERVAL '1 day')); 
      UPDATE weather_summary SET
          temp_max_time_24hour_short = (SELECT MAX(date_time) FROM weather_short WHERE temp_avg = (SELECT temp_max_24hour_short FROM weather_summary)),
          temp_min_time_24hour_short = (SELECT MAX(date_time) FROM weather_short WHERE temp_avg = (SELECT temp_min_24hour_short FROM weather_summary)),
          gust_max_time_24hour_short = (SELECT MAX(date_time) FROM weather_short WHERE gust_max = (SELECT gust_max_24hour_short FROM weather_summary)),
          update_last = now();


      --RAISE NOTICE 'temp analog avg: %', v_temp_analog_avg;
      --RAISE NOTICE 'temp digital avg %', v_temp_digital_avg;
      --RAISE NOTICE 'pressure avg %', v_pressure_avg;
      --RAISE NOTICE 'humidity avg %', v_humidity_avg;
      --RAISE NOTICE 'speed avg %', v_speed_avg;
      --RAISE NOTICE 'gust max %', v_gust_max;
      --RAISE NOTICE 'bearing avg %', v_bearing_avg;
      --RAISE NOTICE 'temp heat index max %', v_temp_index_max;
      --RAISE NOTICE 'temp wind chill min %', v_temp_chill_min;
      --RAISE NOTICE 'temp dewpoint avg %', v_temp_dew_avg;

      DELETE FROM weather_current WHERE id < v_id_last;
    END IF;

    RETURN new;
  --RETURN;
END;
$update_weather_current$ LANGUAGE plpgsql;
ALTER FUNCTION update_weather_current() OWNER TO controller;
CREATE TRIGGER update_weather_current BEFORE INSERT ON weather_current FOR EACH ROW EXECUTE PROCEDURE update_weather_current();




--this function runs whenever a new record is pushed into the weather_short table.  first, it calculates the barometric pressure trend for the 
--previous three hours as the slope of the line with pressure (converted to millibars) as the dependent variable and fractional hours as the independent variable.
--it next looks to see if the last and next-to-last timestamps have the same or differnt 'day' values.  If they don't, then it calculates the
--averages, max/mins, and other values for the previous day and enters that data into the weather_long table as a summary for that calendar date.
CREATE OR REPLACE FUNCTION update_weather_short() RETURNS TRIGGER  AS $update_weather_short$
--CREATE OR REPLACE FUNCTION update_weather_short() RETURNS VOID  AS $$
DECLARE
    v_id_last integer;
    v_test1 integer;
    v_test2 integer;
    v_temp_max FLOAT;
    v_temp_avg FLOAT;
    v_temp_min FLOAT;
    v_pressure_max FLOAT;
    v_pressure_avg FLOAT;
    v_pressure_min FLOAT;
    v_humidity_max FLOAT;
    v_humidity_avg FLOAT;
    v_humidity_min FLOAT;
    v_speed_avg FLOAT;
    v_gust_max FLOAT;
    v_bearing_avg FLOAT;
    v_temp_index_max FLOAT;
    v_temp_chill_min FLOAT;
    v_temp_dew_max FLOAT;
    v_temp_dew_avg FLOAT;
    v_temp_dew_min FLOAT;
    v_date DATE;
    v_retention VARCHAR;
BEGIN
    SELECT regr_slope((pressure_avg / 100.0), (EXTRACT(epoch FROM date_time) / 3600.0)) INTO new.pressure_trend FROM weather_short WHERE date_time >  (now() - INTERVAL '3 hours');

    -- put stuff here to push daily summary
    SELECT MAX(ID) into v_id_last FROM weather_short;
    v_test1 = EXTRACT(DAY FROM (SELECT date_time FROM weather_short WHERE id = v_id_last));
    v_test2 = EXTRACT(DAY FROM (SELECT date_time FROM weather_short WHERE id = (v_id_last - 1)));
    --RAISE NOTICE 'day last %', v_test1;
    --RAISE NOTICE 'day next to last %', v_test2;
    --RAISE NOTICE 'date next to last %', (SELECT date_time::DATE FROM weather_short WHERE id = (v_id_last - 1));
    IF (v_test1 != v_test2) THEN

        SELECT date_time::DATE into v_date FROM weather_short WHERE id = (v_id_last - 1);
        SELECT  MAX(temp_avg),
                AVG(temp_avg),
                MIN(temp_avg),
                MAX(pressure_avg),
                AVG(pressure_avg),
                MIN(pressure_avg),
                MAX(humidity_avg),
                AVG(humidity_avg),
                MIN(humidity_avg),
                AVG(speed_avg),
                MAX(gust_max),
                AVG(bearing_avg),
                MAX(temp_index_max),
                MIN(temp_chill_min),
                MAX(temp_dew_avg),
                AVG(temp_dew_avg),
                MIN(temp_dew_avg)

        INTO
                v_temp_max,
                v_temp_avg,
                v_temp_min,
                v_pressure_max,
                v_pressure_avg,
                v_pressure_min,
                v_humidity_max,
                v_humidity_avg,
                v_humidity_min,
                v_speed_avg,
                v_gust_max,
                v_bearing_avg,
                v_temp_index_max,
                v_temp_chill_min,
                v_temp_dew_max,
                v_temp_dew_avg,
                v_temp_dew_min
        FROM weather_short WHERE date_time::DATE = v_date;

        INSERT INTO weather_long (      temp_max,
                                        temp_avg,
                                        temp_min,
                                        pressure_max,
                                        pressure_avg,
                                        pressure_min,
                                        humidity_max,
                                        humidity_avg,
                                        humidity_min,
                                        speed_avg,
                                        gust_max,
                                        bearing_avg,
                                        temp_index_max,
                                        temp_chill_min,
                                        temp_dew_max,
                                        temp_dew_avg,
                                        temp_dew_min,
                                        date_time)
        VALUES (                        v_temp_max,
                                        v_temp_avg,
                                        v_temp_min,
                                        v_pressure_max,
                                        v_pressure_avg,
                                        v_pressure_min,
                                        v_humidity_max,
                                        v_humidity_avg,
                                        v_humidity_min,
                                        v_speed_avg,
                                        v_gust_max,
                                        v_bearing_avg,
                                        v_temp_index_max,
                                        v_temp_chill_min,
                                        v_temp_dew_max,
                                        v_temp_dew_avg,
                                        v_temp_dew_min,
                                        v_date);

    END IF;

    SELECT val INTO v_retention FROM weather_control WHERE description = 'short term retention';
    DELETE FROM weather_short WHERE date_time < (now() - v_retention::INTERVAL);

    RETURN new;
    --RETURN;
END;
$update_weather_short$ LANGUAGE plpgsql;
--$$ LANGUAGE plpgsql;
ALTER FUNCTION update_weather_short() OWNER TO controller;
CREATE TRIGGER update_weather_short BEFORE INSERT ON weather_short FOR EACH ROW EXECUTE PROCEDURE update_weather_short();
