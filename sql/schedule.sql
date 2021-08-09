DROP VIEW v_schedule_si;
DROP VIEW v_schedule_imperial;
DROP TABLE schedule;

CREATE TABLE schedule (	id SERIAL PRIMARY KEY,
                        mode varchar REFERENCES modes(mode),
                        dow INTEGER CHECK (dow >= 0 AND dow < 7), 
                        tod TIME WITHOUT TIME ZONE,
                        location varchar REFERENCES location(description),
                        setpoint FLOAT);

ALTER TABLE schedule OWNER TO controller;
GRANT ALL ON schedule TO controller;

CREATE VIEW v_schedule_imperial AS
      SELECT id, mode, dow, tod, location, ROUND(((setpoint::NUMERIC * 1.8) + 32.0), 0) AS setpoint FROM schedule ORDER BY mode, tod, location;
ALTER VIEW v_schedule_imperial OWNER TO controller;
GRANT ALL on v_schedule_imperial TO controller;

CREATE VIEW v_schedule_si AS
      SELECT id, mode, dow, tod, location, ROUND(setpoint::NUMERIC, 0) AS setpoint FROM schedule ORDER BY mode, tod, location;
ALTER VIEW v_schedule_si OWNER TO controller;
GRANT ALL on v_schedule_si TO controller;




INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '0', '08:00', 'master bedroom', '23');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '0', '09:00', 'kitchen', '23');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '0', '10:00', 'master bedroom', '18');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '0', '10:00', 'kitchen', '18');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '0', '10:00', 'dining room', '21');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '0', '22:00', 'dining room', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '0', '22:00', 'master bedroom', '19');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '1', '06:00', 'master bedroom', '23');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '1', '06:45', 'kitchen', '23');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '1', '07:30', 'master bedroom', '18');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '1', '09:00', 'kitchen', '18');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '1', '09:00', 'dining room', '21');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '1', '22:00', 'dining room', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '1', '22:00', 'master bedroom', '19');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '2', '06:00', 'master bedroom', '23');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '2', '06:45', 'kitchen', '23');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '2', '07:30', 'master bedroom', '18');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '2', '09:00', 'kitchen', '18');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '2', '09:00', 'dining room', '21');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '2', '22:00', 'dining room', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '2', '22:00', 'master bedroom', '19');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '3', '06:00', 'master bedroom', '23');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '3', '06:45', 'kitchen', '23');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '3', '07:30', 'master bedroom', '18');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '3', '09:00', 'kitchen', '18');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '3', '09:00', 'dining room', '21');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '3', '22:00', 'dining room', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '3', '22:00', 'master bedroom', '19');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '4', '06:00', 'master bedroom', '23');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '4', '06:45', 'kitchen', '23');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '4', '07:30', 'master bedroom', '18');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '4', '09:00', 'kitchen', '18');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '4', '09:00', 'dining room', '21');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '4', '22:00', 'dining room', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '4', '22:00', 'master bedroom', '19');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '5', '06:00', 'master bedroom', '23');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '5', '06:45', 'kitchen', '23');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '5', '07:30', 'master bedroom', '18');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '5', '09:00', 'kitchen', '18');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '5', '09:00', 'dining room', '21');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '5', '22:00', 'dining room', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '5', '22:00', 'master bedroom', '19');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '6', '08:00', 'master bedroom', '23');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '6', '09:00', 'kitchen', '23');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '6', '10:00', 'master bedroom', '18');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '6', '10:00', 'kitchen', '18');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '6', '10:00', 'dining room', '21');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '6', '22:00', 'dining room', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '6', '22:00', 'master bedroom', '19');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '0', '23:00', 'basement bar', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '1', '23:00', 'basement bar', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '2', '23:00', 'basement bar', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '3', '23:00', 'basement bar', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '4', '23:00', 'basement bar', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '5', '23:00', 'basement bar', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '6', '23:00', 'basement bar', '17');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '0', '23:00', 'basement theater', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '1', '23:00', 'basement theater', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '2', '23:00', 'basement theater', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '3', '23:00', 'basement theater', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '4', '23:00', 'basement theater', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '5', '23:00', 'basement theater', '17');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('heat', '6', '23:00', 'basement theater', '17');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '0', '08:00', 'master bedroom', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '0', '08:00', 'dining room', '26');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '0', '22:00', 'master bedroom', '24');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '1', '08:00', 'master bedroom', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '1', '08:00', 'dining room', '26');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '1', '22:00', 'master bedroom', '24');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '2', '08:00', 'master bedroom', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '2', '08:00', 'dining room', '26');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '2', '22:00', 'master bedroom', '24');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '3', '08:00', 'master bedroom', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '3', '08:00', 'dining room', '26');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '3', '22:00', 'master bedroom', '24');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '4', '08:00', 'master bedroom', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '4', '08:00', 'dining room', '26');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '4', '22:00', 'master bedroom', '24');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '5', '08:00', 'master bedroom', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '5', '08:00', 'dining room', '26');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '5', '22:00', 'master bedroom', '24');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '6', '08:00', 'master bedroom', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '6', '08:00', 'dining room', '26');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '6', '22:00', 'master bedroom', '24');


INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '0', '23:00', 'basement bar', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '1', '23:00', 'basement bar', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '2', '23:00', 'basement bar', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '3', '23:00', 'basement bar', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '4', '23:00', 'basement bar', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '5', '23:00', 'basement bar', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '6', '23:00', 'basement bar', '30');

INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '0', '23:00', 'basement theater', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '1', '23:00', 'basement theater', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '2', '23:00', 'basement theater', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '3', '23:00', 'basement theater', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '4', '23:00', 'basement theater', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '5', '23:00', 'basement theater', '30');
INSERT INTO schedule (mode, dow, tod, location, setpoint) VALUES ('cool', '6', '23:00', 'basement theater', '30');





CREATE OR REPLACE FUNCTION update_schedule() RETURNS VOID AS $$
DECLARE
      r RECORD;
BEGIN
      FOR r IN
            (SELECT	location.id, schedule.setpoint
            FROM	location, schedule
            WHERE	location.mode = schedule.mode
            AND	location.description = schedule.location
            AND	schedule.dow = EXTRACT(DOW FROM now())
            AND	to_char(schedule.tod, 'HH24:MI') = to_char(now(), 'HH24:MI')
            AND	location.setback = 'auto')
      LOOP
            UPDATE location SET setpoint = r.setpoint WHERE id = r.id;

      END LOOP;
END;
$$ LANGUAGE plpgsql;
ALTER FUNCTION update_schedule() OWNER TO controller;
