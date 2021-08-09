DROP VIEW v_device_off;
DROP VIEW v_dashboard;
DROP VIEW v_status_sensors;
DROP VIEW v_status_actuators;
DROP VIEW v_status_location;
DROP VIEW v_location_si;
DROP VIEW v_location_imperial;
DROP VIEW v_sensor_si;
DROP VIEW v_sensor_imperial;
DROP VIEW v_sensor_imperial;
DROP VIEW v_sensor_si;
DROP VIEW v_location_si;
DROP VIEW v_location_imperial;

DROP TABLE log;
DROP TABLE location_actuator;
DROP TABLE location;
DROP TABLE sensor;
DROP TABLE contact;
DROP TABLE actuator;
DROP TABLE modes;
DROP TABLE setback;



CREATE TABLE setback            (id INTEGER PRIMARY KEY, mode VARCHAR UNIQUE NOT NULL);
ALTER TABLE setback OWNER TO controller;
GRANT ALL ON setback TO controller;

CREATE TABLE modes              (id INTEGER PRIMARY KEY, mode VARCHAR UNIQUE NOT NULL);
ALTER TABLE modes OWNER TO controller;
GRANT ALL ON modes TO controller;

CREATE TABLE actuator (id INTEGER PRIMARY KEY, description VARCHAR UNIQUE NOT NULL, db VARCHAR, unit VARCHAR, port VARCHAR, state BOOLEAN, date_time TIMESTAMP);
ALTER TABLE actuator OWNER TO controller;
GRANT ALL ON actuator TO controller;

CREATE TABLE sensor (id INTEGER PRIMARY KEY, description VARCHAR UNIQUE NOT NULL, db VARCHAR, unit VARCHAR, port VARCHAR, bias VARCHAR, state_raw FLOAT, state_adjusted FLOAT, date_time TIMESTAMP);
ALTER TABLE sensor OWNER TO controller;
GRANT ALL ON sensor TO controller;

CREATE TABLE location (id INTEGER PRIMARY KEY, description VARCHAR UNIQUE NOT NULL, sensor VARCHAR REFERENCES sensor(description), mode VARCHAR REFERENCES modes(mode), setpoint FLOAT, setback VARCHAR REFERENCES setback(mode), date_time TIMESTAMP);
ALTER TABLE location OWNER TO controller;
GRANT ALL ON location TO controller;

CREATE TABLE location_actuator (id INTEGER PRIMARY KEY, location VARCHAR REFERENCES location(description), actuator VARCHAR REFERENCES actuator(description), mode VARCHAR, threshold_on FLOAT, threshold_off FLOAT);
ALTER TABLE location_actuator OWNER TO controller;
GRANT ALL ON location_actuator TO controller;

CREATE TABLE log (id SERIAL PRIMARY KEY, description VARCHAR, date_time TIMESTAMP);
ALTER TABLE log OWNER TO controller;
GRANT ALL ON log TO controller;

CREATE TABLE contact (id INTEGER PRIMARY KEY, description VARCHAR UNIQUE NOT NULL, db VARCHAR, unit VARCHAR, port VARCHAR, state BOOLEAN, date_time TIMESTAMP);
ALTER TABLE contact OWNER TO CONTROLLER
GRANT ALL ON contact TO controller;



--VIEWS

CREATE VIEW v_status_location AS
        SELECT  location.id, location.description, location.setpoint, sensor.state_raw, sensor.state_adjusted, location.mode
        FROM    location, sensor
        WHERE   location.sensor = sensor.description
        ORDER BY        location.id;

CREATE VIEW v_status_actuators AS
        SELECT  id, description, state, date_time
        FROM    actuator
        ORDER BY        id;

CREATE VIEW v_dashboard AS
        SELECT  location.description AS location$description,
                location.sensor AS location$sensor_adjusted,
                location.mode AS location$mode,
                location.setpoint AS location$setpoint,
                location_actuator.location AS location_actuator$location,
                location_actuator.actuator AS location_actuator$actuator,
                location_actuator.mode AS location_actuator$mode,
                location_actuator.threshold_on AS location_actuator$threshold_on,
                location_actuator.threshold_off AS location_actuator$threshold_off,
                actuator.description AS actuator$description,
                actuator.db AS actuator$db,
                actuator.unit AS actuator$unit,
                actuator.port AS actuator$port,
                actuator.state AS actuator$state,
                sensor.description AS sensor$description,
                sensor.db AS sensor$db, sensor.unit AS sensor$unit,
                sensor.port AS sensor$port, sensor.state_adjusted AS sensor$state_adjusted,
                (((location.setpoint - sensor.state_adjusted) > location_actuator.threshold_on) AND (location.mode = 'heat'))
        OR      (((sensor.state_adjusted - location.setpoint) > location_actuator.threshold_on) AND (location.mode = 'cool'))
        OR      (location.mode = 'circulator') AS calculated$req_on,
                (((sensor.state_adjusted - location.setpoint) > location_actuator.threshold_off) AND (location.mode = 'heat'))
        OR      (((location.setpoint - sensor.state_adjusted) > location_actuator.threshold_off) AND (location.mode = 'cool')) AS calculated$req_off
        FROM    location, location_actuator, actuator, sensor
        WHERE   location.description = location_actuator.location
        AND     location_actuator.actuator = actuator.description
        AND     sensor.description = location.sensor
        AND     location.mode = location_actuator.mode;
ALTER VIEW v_dashboard OWNER TO controller;
GRANT ALL ON v_dashboard TO controller;

CREATE VIEW v_device_off AS
        SELECT * FROM actuator AS a
        WHERE NOT EXISTS
                (SELECT * FROM
                        (SELECT DISTINCT actuator$description FROM v_dashboard) AS b
                WHERE   b.actuator$description = a.description)
        AND     a.state = TRUE;
ALTER VIEW v_device_off OWNER TO controller;
GRANT ALL ON v_device_off TO controller;

CREATE VIEW v_sensor_imperial AS
        ((SELECT id, description, db, unit, port, ROUND(((state_adjusted * 1.8) + 32)::NUMERIC, 1) AS state, date_time  FROM sensor WHERE port = 'a00')
        UNION
        (SELECT id, description, db, unit, port, ROUND(((state_adjusted * 1.8) + 32)::NUMERIC, 1) AS state, date_time FROM sensor WHERE port = 'i00')
        UNION
        (SELECT id, description, db, unit, port, ROUND(state_adjusted::NUMERIC, 2) AS state, date_time FROM sensor WHERE port = 'i01')
        UNION
       (SELECT id, description, db, unit, port, ROUND((state_adjusted * 0.0002953)::NUMERIC, 2) AS state, date_time FROM sensor WHERE port = 'i02'))
        ORDER BY id;
ALTER VIEW v_sensor_imperial OWNER TO controller;
GRANT ALL ON v_sensor_imperial TO controller;


CREATE VIEW v_sensor_si AS
        ((SELECT id, description, db, unit, port, ROUND(state_adjusted::NUMERIC, 1) AS state, date_time FROM sensor WHERE port = 'a00')
        UNION
        (SELECT id, description, db, unit, port, ROUND(state_adjusted::NUMERIC, 1) AS state, date_time FROM sensor WHERE port = 'i00')
        UNION
        (SELECT id, description, db, unit, port, ROUND(state_adjusted::NUMERIC, 1) AS state, date_time FROM sensor WHERE port = 'i01')
        UNION
        (SELECT id, description, db, unit, port, ROUND(state_adjusted::NUMERIC, 0) AS state, date_time FROM sensor WHERE port = 'i02'))

        ORDER BY id;
ALTER VIEW v_sensor_si OWNER TO controller;
GRANT ALL ON v_sensor_si TO controller;

CREATE VIEW v_location_si AS
        SELECT id, description, sensor, mode, ROUND(setpoint::NUMERIC, 0) AS setpoint, setback, date_time
        FROM location
        ORDER BY id;
ALTER VIEW v_location_si OWNER TO controller;
GRANT ALL ON v_location_si TO controller;

CREATE VIEW v_location_imperial AS
        (SELECT id, description, sensor, mode, ROUND(((setpoint * 1.8) + 32)::NUMERIC, 0) AS setpoint, setback, date_time
        FROM location
        WHERE sensor LIKE '%temperature%')
        UNION
        (SELECT * FROM location WHERE sensor NOT LIKE ('%temperature%'))

        ORDER BY id;
ALTER VIEW v_location_imperial OWNER TO controller;
GRANT ALL ON v_location_imperial TO controller;

