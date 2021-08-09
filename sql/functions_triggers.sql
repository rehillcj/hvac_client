--CREATE ROLE hvac;
--CREATE DATABASE hvac;
--ALTER DATABASE OWNER TO controller;


DROP TRIGGER check_mode ON location;
DROP TRIGGER update_timestamp_location ON location;
DROP TRIGGER update_timestamp_actuator ON actuator;
DROP TRIGGER update_sensor ON sensor;
DROP TRIGGER insert_log ON log;

--FUNCTIONS

CREATE OR REPLACE FUNCTION check_mode() RETURNS TRIGGER AS $check_mode$
DECLARE
  v_unit varchar;
  rows integer;
  error text;
BEGIN
  SELECT actuator.unit INTO v_unit
    FROM actuator, location_actuator
    WHERE location_actuator.location = new.description
    AND location_actuator.mode = new.mode
    AND actuator.description = location_actuator.actuator;
  --raise notice 'unit %', v_unit;
  rows := 0;
  IF (new.mode = 'cool') THEN
    SELECT COUNT (*) INTO rows
    FROM location, actuator, location_actuator
    WHERE actuator.unit = v_unit
    AND actuator.description = location_actuator.actuator
    AND location_actuator.location = location.description
    AND location.description <> new.description
    AND location.mode = 'heat';
    IF (rows > 0) THEN
      error := 'error: attempt to set ' || v_unit || 'to cool when actuator is set to heat by another location';
      INSERT INTO log (description, date_time) VALUES (error, now());
      new.mode := 'heat';
    END IF;
  END IF;

  IF (new.mode = 'heat') THEN
    SELECT COUNT(*) INTO rows
    FROM location, actuator, location_actuator
    WHERE actuator.unit = v_unit
    AND actuator.description = location_actuator.actuator
    AND location_actuator.location = location.description
    AND location.description <> new.description
    AND location.mode = 'cool';
    IF (rows > 0) THEN
      error := 'error: attempt to set ' || v_unit || ' to heat when actuator is set to cool by another location';
      INSERT INTO log (description, date_time) VALUES (error, now());
      new.mode := 'cool';
    END IF;
  END IF;
  return new;
END;
$check_mode$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_log() returns trigger AS $insert_log$
DECLARE
BEGIN
  new.date_time := now();
  return new;
END;
$insert_log$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_timestamp() returns trigger AS $update_timestamp$
DECLARE
BEGIN
  new.date_time := now();
  return new;
END;
$update_timestamp$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_sensor() returns trigger AS $update_sensor$
DECLARE
BEGIN
  new.date_time := now();
  new.state_adjusted = 
        (cast (split_part(new.bias, ':', 1) as float) * power(new.state_raw, 5) +
         cast (split_part(new.bias, ':', 2) as float) * power(new.state_raw, 4) +
         cast (split_part(new.bias, ':', 3) as float) * power(new.state_raw, 3) +
         cast (split_part(new.bias, ':', 4) as float) * power(new.state_raw, 2) +
         cast (split_part(new.bias, ':', 5) as float) * power(new.state_raw, 1) +
         cast (split_part(new.bias, ':', 6) as float));
  return new;
END;
$update_sensor$ LANGUAGE plpgsql;


--TRIGGERS

CREATE TRIGGER check_mode BEFORE UPDATE ON location FOR EACH ROW EXECUTE PROCEDURE check_mode();
CREATE TRIGGER update_timestamp_location BEFORE UPDATE ON location FOR EACH ROW EXECUTE PROCEDURE update_timestamp();
CREATE TRIGGER update_timestamp_actuator BEFORE UPDATE ON actuator FOR EACH ROW EXECUTE PROCEDURE update_timestamp();
CREATE TRIGGER update_sensor BEFORE UPDATE ON sensor FOR EACH ROW EXECUTE PROCEDURE update_sensor();
CREATE TRIGGER insert_log BEFORE INSERT ON log FOR EACH ROW EXECUTE PROCEDURE insert_log();



ALTER FUNCTION check_mode() 				OWNER TO controller;
ALTER FUNCTION insert_log() 				OWNER TO controller;
--ALTER FUNCTION update_location()			OWNER TO controller;


