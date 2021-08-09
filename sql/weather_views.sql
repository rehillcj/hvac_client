--DROPS
DROP VIEW v_weather_summary_imperial;
DROP VIEW v_weather_summary_si;



--VIEWS

CREATE OR REPLACE VIEW v_weather_summary_imperial AS
    SELECT      ROUND(CAST(((temp_current * 1.8) + 32.0) AS NUMERIC), 1) AS temperature_current,
                ROUND(CAST(((temp_adjusted_current * 1.8) + 32.0) AS NUMERIC), 1) AS temp_adjusted_current,
                ROUND(CAST(((temp_dew_current * 1.8) + 32.0) AS NUMERIC), 1) AS temp_dew_current,
                ROUND(CAST(((temp_max_24hour_short * 1.8) + 32.0) AS NUMERIC), 1) AS temp_max_24hour_short,
                temp_max_time_24hour_short,
                ROUND(CAST(((temp_min_24hour_short * 1.8) + 32.0) AS NUMERIC), 1) AS temp_min_24hour_short,
                temp_min_time_24hour_short,

                ROUND(CAST(((pressure_current * .0296133971) / 100.0) AS NUMERIC), 2) AS pressure_current,
                ROUND(CAST(pressure_trend_short AS NUMERIC), 2) AS pressure_trend_short,

                ROUND(CAST(humidity_current AS NUMERIC), 0) AS humidity_current,

                ROUND(CAST((speed_current * 0.621371) AS NUMERIC), 0) AS speed_current,
                ROUND(CAST((gust_max_24hour_short * 0.621371) AS NUMERIC), 0) AS gust_max_24hour_short,
                gust_max_time_24hour_short,
                bearing_current,

                update_last
    FROM weather_summary;
ALTER VIEW v_weather_summary_imperial OWNER TO controller;
GRANT ALL ON v_weather_summary_imperial TO controller;

CREATE OR REPLACE VIEW v_weather_summary_si AS
    SELECT      ROUND(CAST(temp_current AS NUMERIC), 1) AS temperature_current,
                ROUND(CAST(temp_adjusted_current AS NUMERIC), 1) AS temp_adjusted_current,
                ROUND(CAST(temp_dew_current AS NUMERIC), 1) AS temp_dew_current,
                ROUND(CAST(temp_max_24hour_short AS NUMERIC), 1) AS temp_max_24hour_short,
                temp_max_time_24hour_short,
                ROUND(CAST(temp_min_24hour_short AS NUMERIC), 1) AS temp_min_24hour_short,
                temp_min_time_24hour_short,

                ROUND(CAST(pressure_current AS NUMERIC), 2) AS pressure_current,
                ROUND(CAST(pressure_trend_short AS NUMERIC), 2) AS pressure_trend_short,

                ROUND(CAST(humidity_current AS NUMERIC), 0) AS humidity_current,

                ROUND(CAST(speed_current AS NUMERIC), 0) AS speed_current,
                ROUND(CAST(gust_max_24hour_short AS NUMERIC), 0) AS gust_max_24hour_short,
                gust_max_time_24hour_short,
                bearing_current,

                update_last
    FROM weather_summary;
ALTER VIEW v_weather_summary_si OWNER TO controller;
GRANT ALL ON v_weather_summary_si TO controller;
