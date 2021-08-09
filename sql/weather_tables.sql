DROP VIEW v_weather_summary_imperial;
DROP VIEW v_weather_summary_si;

DROP TABLE weather_summary;
DROP TABLE weather_long;
DROP TABLE weather_short;
DROP TABLE weather_current;
DROP TABLE weather_control;

CREATE TABLE weather_control (	description VARCHAR,
                                val VARCHAR,
                                comment VARCHAR
                             );
ALTER TABLE weather_control OWNER TO controller;
GRANT ALL ON weather_control TO controller;
INSERT INTO weather_control (description, val, comment)
                     VALUES ('current update rate', '2', 'time in seconds that the weather.bash script pauses in between iterations');
INSERT INTO weather_control (description, val, comment)
                     VALUES ('temperature sensor', '1', '0 indicates analog sensor, 1 indicates digital sensor');
INSERT INTO weather_control (description, val, comment)
                     VALUES ('short term retention', '14 days', 'time elapsed before a record is flushed from the short term table');
INSERT INTO weather_control (description, val, comment)
                     VALUES ('anemometer address', '192.168.6.32', 'IP address of Arduino that is connected to the anemometer');

CREATE TABLE weather_summary (
                                temp_current FLOAT,
                                pressure_current FLOAT,
                                pressure_trend_short FLOAT,
                                humidity_current FLOAT,
                                speed_current FLOAT,
                                bearing_current FLOAT,
                                temp_adjusted_current FLOAT,
                                temp_dew_current FLOAT,
                                temp_max_24hour_short FLOAT,
                                temp_max_time_24hour_short TIMESTAMP,
                                temp_min_24hour_short FLOAT,
                                temp_min_time_24hour_short TIMESTAMP,
                                gust_max_24hour_short FLOAT,
                                gust_max_time_24hour_short TIMESTAMP,
                                update_last TIMESTAMP
                              );
ALTER TABLE weather_summary OWNER TO controller;
GRANT ALL ON weather_summary TO controller;

INSERT INTO weather_summary (	temp_current,
                                pressure_current,
                                pressure_trend_short,
                                humidity_current,
                                speed_current,
                                bearing_current,
                                temp_adjusted_current,
                                temp_dew_current,
                                temp_max_24hour_short,
                                temp_max_time_24hour_short,
                                temp_min_24hour_short,
                                temp_min_time_24hour_short,
                                gust_max_24hour_short,
                                gust_max_time_24hour_short,
                                update_last
                              )  
                         VALUES	('0.0', '0.0', '0.0', '0.0', '0.0', '0.0', '0.0', '0.0', '0.0', now(), '0.0', now(), '0.0', now(), now());


CREATE TABLE weather_current (	id serial,
                                temp_analog FLOAT,
                                temp_digital FLOAT,
                                pressure FLOAT,
                                humidity FLOAT,
                                speed FLOAT,
                                gust FLOAT,
                                bearing FLOAT,
                                temp_index FLOAT,
                                temp_chill FLOAT,
                                temp_dew FLOAT,
                                date_time TIMESTAMP
                              );
ALTER TABLE weather_current OWNER TO controller;
GRANT ALL ON weather_current TO controller;

CREATE TABLE weather_short (	id SERIAL,
                                temp_avg FLOAT,
                                pressure_avg FLOAT,
                                pressure_trend FLOAT,
                                humidity_avg FLOAT,
                                speed_avg FLOAT,
                                gust_max FLOAT,
                                bearing_avg FLOAT,
                                temp_index_max FLOAT,
                                temp_chill_min FLOAT,
                                temp_dew_avg FLOAT,
                                date_time TIMESTAMP
                              );
ALTER TABLE weather_short OWNER TO controller;
GRANT ALL ON weather_short TO controller;





CREATE TABLE weather_long (     temp_max FLOAT,
                                temp_avg FLOAT,
                                temp_min FLOAT,
                                pressure_max FLOAT,
                                pressure_avg FLOAT,
                                pressure_min FLOAT,
                                humidity_max FLOAT,
                                humidity_avg FLOAT,
                                humidity_min FLOAT,
                                speed_avg FLOAT,
                                gust_max FLOAT,
                                bearing_avg FLOAT,
                                temp_index_max FLOAT,
                                temp_chill_min FLOAT,
                                temp_dew_max FLOAT,
                                temp_dew_avg FLOAT,
                                temp_dew_min FLOAT,
                                date_time DATE
                              );
ALTER TABLE weather_long OWNER TO controller;
GRANT ALL ON weather_long TO controller;


