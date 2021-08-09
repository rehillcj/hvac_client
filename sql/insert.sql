INSERT INTO modes (id, mode) VALUES ('1', 'off');
INSERT INTO modes (id, mode) VALUES ('2', 'heat');
INSERT INTO modes (id, mode) VALUES ('3', 'cool');
INSERT INTO modes (id, mode) VALUES ('4', 'circulator');

INSERT INTO setback (id, mode) VALUES ('1', 'auto');
INSERT INTO setback (id, mode) VALUES ('2', 'hold');

INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('1',   'master bedroom boosters',              'arduino_mqtt', 'garage 2',                     'd00',  'f',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('2',   'basement heat',                        'arduino_mqtt', 'hvac 1',                       'd00',  'f',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('3',   'basement cool',                        'arduino_mqtt', 'hvac 1',                       'd01',  'f',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('4',   'basement circulator',                  'arduino_mqtt', 'hvac 1',                       'd02',  'f',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('5',   'basement humidifier',                  'arduino_mqtt', 'hvac 1',                       'd03',  'f',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('6',   'first floor heat',                     'arduino_mqtt', 'hvac 2',                       'd00',  'f',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('7',   'first floor cool',                     'arduino_mqtt', 'hvac 2',                       'd01',  'f',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('8',   'first floor circulator',               'arduino_mqtt', 'hvac 2',                       'd02',  'f',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('9',   'first floor humidifier',               'arduino_mqtt', 'hvac 2',                       'd03',  'f',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('10',  'attic fan east #1',                    'apc_snmp',     'pdu_switch8_attic_path',       'd04',  't',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('11',  'attic fan east #2',                    'apc_snmp',     'pdu_switch8_attic_path',       'd05',  't',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('12',  'attic fan east #3',                    'apc_snmp',     'pdu_switch8_attic_path',       'd06',  't',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('13',  'attic fan east #4',                    'apc_snmp',     'pdu_switch8_attic_path',       'd07',  't',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('14',  'attic fan west #1',                    'apc_snmp',     'pdu_switch8_attic_driveway',   'd04',  't',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('15',  'attic fan west #2',                    'apc_snmp',     'pdu_switch8_attic_driveway',   'd05',  't',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('16',  'attic fan west #3',                    'apc_snmp',     'pdu_switch8_attic_driveway',   'd06',  't',    now());
INSERT INTO actuator (id, description, db, unit, port, state, date_time) VALUES ('17',  'attic fan west #4',                    'apc_snmp',     'pdu_switch8_attic_driveway',   'd07',  't',    now());

INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('1',   'temperature analog guest bedroom',     'arduino_mqtt', 'bedroom guest',        'a00', '0.0:0.0:0.0:0.0:0.1:0.0', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('2',   'temperature i2c guest bedroom',        'arduino_mqtt', 'bedroom guest',        'i00', '0.0:0.0:0.0:0.0:1.0:0.0', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('3',   'barometric pressure guest bedroom',    'arduino_mqtt', 'bedroom guest',        'i02', '0.0:0.0:0.0:0.0:1.0:0.0', '100000.000', '100000.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('4',   'relative humidity guest bedroom',      'arduino_mqtt', 'bedroom guest',        'i01', '0.0:0.0:0.0:0.0:1.0:0.0', '35.000', '35.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('5',   'temperature analog bar',               'arduino_mqtt', 'bar',                  'a00', '0.0:0.0:0.0:0.0:0.0555:-17.777', '24.000', '24.000',    now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('6',   'temperature i2c bar',                  'arduino_mqtt', 'bar',                  'i00', '0.0:0.0:0.0:0.0:1.0:0.0', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('7',   'barometric pressure bar',              'arduino_mqtt', 'bar',                  'i02', '0.0:0.0:0.0:0.0:1.0:0.0', '100000.000', '100000.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('8',   'relative humidity bar',                'arduino_mqtt', 'bar',                  'i01', '0.0:0.0:0.0:0.0:1.0:0.0', '35.000', '35.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('9',   'temperature analog theater',           'arduino_mqtt', 'theater',              'a00', '0.0:0.0:0.0:0.0:0.0555:-17.777', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('10',  'temperature i2c theater',              'arduino_mqtt', 'theater',              'i00', '0.0:0.0:0.0:0.0:1.0:0.0', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('11',  'barometric pressure theater',          'arduino_mqtt', 'theater',              'i02', '0.0:0.0:0.0:0.0:1.0:0.0', '100000.000', '100000.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('12',  'relative humidity theater',            'arduino_mqtt', 'theater',              'i01', '0.0:0.0:0.0:0.0:1.0:0.0', '35.000', '35.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('13',  'temperature analog master bedroom',    'arduino_mqtt', 'bedroom master',       'a00', '0.0:0.0:0.0:0.0:0.0555:-17.777', '24.000', '24.000',    now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('14',  'temperature i2c master bedroom',       'arduino_mqtt', 'bedroom master',       'i00', '0.0:0.0:0.0:0.0:1.0:0.0', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('15',  'barometric pressure master bedroom',   'arduino_mqtt', 'bedroom master',       'i02', '0.0:0.0:0.0:0.0:1.0:0.0', '100000.000', '100000.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('16',  'relative humidity master bedroom',     'arduino_mqtt', 'bedroom master',       'i01', '0.0:0.0:0.0:0.0:1.0:0.0', '35.000', '35.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('17',  'temperature analog dining room',       'arduino_mqtt', 'dining room',          'a00', '0.0:0.0:0.0:0.0:0.0555:-17.777', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('18',  'temperature i2c dining room',          'arduino_mqtt', 'dining room',          'i00', '0.0:0.0:0.0:0.0:1.0:0.0', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('19',  'barometric pressure dining room',      'arduino_mqtt', 'dining room',          'i02', '0.0:0.0:0.0:0.0:1.0:0.0', '100000.000', '100000.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('20',  'relative humidity dining room',        'arduino_mqtt', 'dining room',          'i01', '0.0:0.0:0.0:0.0:1.0:0.0', '35.000', '35.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('21',  'temperature analog kitchen',           'arduino_mqtt', 'kitchen',              'a00', '0.0:0.0:0.0:0.0:0.0555:-17.777', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('22',  'temperature i2c kitchen',              'arduino_mqtt', 'kitchen',              'i00', '0.0:0.0:0.0:0.0:1.0:0.0', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('23',  'barometric pressure kitchen',          'arduino_mqtt', 'kitchen',              'i02', '0.0:0.0:0.0:0.0:1.0:0.0', '100000.000', '100000.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('24',  'relative humidity kitchen',            'arduino_mqtt', 'kitchen',              'i01', '0.0:0.0:0.0:0.0:1.0:0.0', '35.000', '35.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('25',  'temperature analog hvac #1',           'arduino_mqtt', 'hvac 1',               'a00', '0.0:0.0:0.0:0.0:0.0555:-17.777', '24.000', '24.000',    now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('26',  'temperature i2c hvac #1',              'arduino_mqtt', 'hvac 1',               'i00', '0.0:0.0:0.0:0.0:1.0:0.0', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('27',  'barometric pressure hvac #1',          'arduino_mqtt', 'hvac 1',               'i02', '0.0:0.0:0.0:0.0:1.0:0.0', '100000.000', '100000.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('28',  'relative humidity hvac #1',            'arduino_mqtt', 'hvac 1',               'i01', '0.0:0.0:0.0:0.0:1.0:0.0', '35.000', '35.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('29',  'temperature analog hvac #2',           'arduino_mqtt', 'hvac 2',               'a00', '0.0:0.0:0.0:0.0:0.0555:-17.77', '24.000', '24.000',     now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('30',  'temperature i2c hvac #2',              'arduino_mqtt', 'hvac 2',               'i00', '0.0:0.0:0.0:0.0:1.0:0.0', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('31',  'barometric pressure hvac #2',          'arduino_mqtt', 'hvac 2',               'i02', '0.0:0.0:0.0:0.0:1.0:0.0', '100000.000', '100000.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('32',  'relative humidity hvac #2',            'arduino_mqtt', 'hvac 2',               'i01', '0.0:0.0:0.0:0.0:1.0:0.0', '35.000', '35.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('33',  'temperature analog laundry',           'arduino_mqtt', 'laundry 1',            'a00', '0.0:0.0:0.0:0.0:0.0555:-17.777', '24.000', '24.000',    now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('34',  'temperature i2c laundry',              'arduino_mqtt', 'laundry 1',            'i00', '0.0:0.0:0.0:0.0:1.0:0.0', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('35',  'barometric pressure laundry',          'arduino_mqtt', 'laundry 1',            'i02', '0.0:0.0:0.0:0.0:1.0:0.0', '100000.000', '100000.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('36',  'relative humidity laundry',            'arduino_mqtt', 'laundry 1',            'i01', '0.0:0.0:0.0:0.0:1.0:0.0', '35.000', '35.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('37',  'temperature analog attic west',        'arduino_mqtt', 'attic driveway',       'a00', '0.0:0.0:0.0:0.0:0.0555:-17.777', '24.000', '24.000',    now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('38',  'temperature i2c attic west',           'arduino_mqtt', 'attic driveway',       'i00', '0.0:0.0:0.0:0.0:1.0:0.0', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('39',  'barometric pressure attic west',       'arduino_mqtt', 'attic driveway',       'i02', '0.0:0.0:0.0:0.0:1.0:0.0', '100000.000', '100000.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('40',  'relative humidity attic west',         'arduino_mqtt', 'attic driveway',       'i01', '0.0:0.0:0.0:0.0:1.0:0.0', '35.000', '35.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('41',  'temperature analog attic east',        'arduino_mqtt', 'attic pathway',        'a00', '0.0:0.0:0.0:0.0:0.0555:-17.777', '24.000', '24.000',    now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('42',  'temperature i2c attic east',           'arduino_mqtt', 'attic pathway',        'i00', '0.0:0.0:0.0:0.0:1.0:0.0', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('43',  'barometric pressure attic east',       'arduino_mqtt', 'attic pathway',        'i02', '0.0:0.0:0.0:0.0:1.0:0.0', '100000.000', '100000.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('44',  'relative humidity attic east',         'arduino_mqtt', 'attic pathway',        'i01', '0.0:0.0:0.0:0.0:1.0:0.0', '35.000', '35.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('45',  'temperature analog garage',            'arduino_mqtt', 'garage 1',             'a00', '0.0:0.0:0.0:0.0:0.0555:-17.777', '24.000', '24.000',    now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('46',  'temperature i2c garage',               'arduino_mqtt', 'garage 1',             'i00', '0.0:0.0:0.0:0.0:1.0:0.0', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('47',  'barometric pressure garage',           'arduino_mqtt', 'garage 1',             'i02', '0.0:0.0:0.0:0.0:1.0:0.0', '100000.000', '100000.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('48',  'relative humidity garage',             'arduino_mqtt', 'garage 1',             'i01', '0.0:0.0:0.0:0.0:1.0:0.0', '35.000', '35.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('49',  'temperature analog ambient',           'arduino_mqtt', 'exterior north',       'a00', '0.0:0.0:0.0:0.0:0.0555:-17.777', '24.000', '24.000',    now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('50',  'temperature i2c ambient',              'arduino_mqtt', 'exterior north',       'i00', '0.0:0.0:0.0:0.0:1.0:0.0', '24.000', '24.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('51',  'barometric pressure ambient',          'arduino_mqtt', 'exterior north',       'i02', '0.0:0.0:0.0:0.0:1.0:0.0', '100000.000', '100000.000',   now());
INSERT INTO sensor (id, description, db, unit, port, bias, state_raw, state_adjusted, date_time) VALUES ('52',  'relative humidity ambient',            'arduino_mqtt', 'exterior north',       'i01', '0.0:0.0:0.0:0.0:1.0:0.0', '35.000', '35.000',   now());

INSERT INTO location (id, description, sensor, mode, setpoint, setback, date_time) VALUES ('1', 'guest bedroom',        'temperature i2c guest bedroom',        'off',  '24.000',       'hold', now());
INSERT INTO location (id, description, sensor, mode, setpoint, setback, date_time) VALUES ('2', 'basement bar',         'temperature i2c bar',                  'off',  '24.000',       'hold', now());
INSERT INTO location (id, description, sensor, mode, setpoint, setback, date_time) VALUES ('3', 'basement theater',     'temperature i2c theater',              'off',  '24.000',       'hold', now());
INSERT INTO location (id, description, sensor, mode, setpoint, setback, date_time) VALUES ('4', 'dining room',          'temperature i2c dining room',          'off',  '24.000',       'hold', now());
INSERT INTO location (id, description, sensor, mode, setpoint, setback, date_time) VALUES ('5', 'master bedroom',       'temperature i2c master bedroom',       'off',  '24.000',       'hold', now());
INSERT INTO location (id, description, sensor, mode, setpoint, setback, date_time) VALUES ('6', 'kitchen',              'temperature i2c kitchen',              'off',  '24.000',       'hold', now());
INSERT INTO location (id, description, sensor, mode, setpoint, setback, date_time) VALUES ('7', 'laundry',              'temperature i2c laundry',              'off',  '24.000',       'hold', now());
INSERT INTO location (id, description, sensor, mode, setpoint, setback, date_time) VALUES ('8', 'attic east',           'temperature i2c attic east',           'off',  '24.000',       'hold', now());
INSERT INTO location (id, description, sensor, mode, setpoint, setback, date_time) VALUES ('9', 'attic west',           'temperature i2c attic west',           'off',  '24.000',       'hold', now());
INSERT INTO location (id, description, sensor, mode, setpoint, setback, date_time) VALUES ('10', 'first floor zone',    'temperature i2c dining room',          'off',  '24.000',       'hold', now());
INSERT INTO location (id, description, sensor, mode, setpoint, setback, date_time) VALUES ('11', 'basement zone',       'temperature i2c bar',                  'off',  '24.000',       'hold', now());
INSERT INTO location (id, description, sensor, mode, setpoint, setback, date_time) VALUES ('12', 'first floor humidity', 'relative humidity hvac #2',           'off',  '30.000',       'hold', now());


INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('1',  'guest bedroom',        'basement heat',                        'heat',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('2',  'guest bedroom',        'basement circulator',                  'heat',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('3',  'guest bedroom',        'basement cool',                        'cool',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('4',  'guest bedroom',        'basement circulator',                  'cool',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('5',  'guest bedroom',        'basement circulator',                  'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('6',  'basement bar',         'basement heat',                        'heat',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('7',  'basement bar',         'basement circulator',                  'heat',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('8',  'basement bar',         'basement cool',                        'cool',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('9',  'basement bar',         'basement circulator',                  'cool',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('10', 'basement bar',         'basement circulator',                  'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('11', 'basement theater',     'basement heat',                        'heat',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('12', 'basement theater',     'basement circulator',                  'heat',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('13', 'basement theater',     'basement cool',                        'cool',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('14', 'basement theater',     'basement circulator',                  'cool',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('15', 'basement theater',     'basement circulator',                  'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('16', 'laundry',              'basement heat',                        'heat',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('17', 'laundry',              'basement circulator',                  'heat',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('18', 'laundry',              'basement cool',                        'cool',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('19', 'laundry',              'basement circulator',                  'cool',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('20', 'laundry',              'basement circulator',                  'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('21', 'dining room',          'first floor heat',                     'heat',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('22', 'dining room',          'first floor circulator',               'heat',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('23', 'dining room',          'first floor cool',                     'cool',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('24', 'dining room',          'first floor circulator',               'cool',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('25', 'dining room',          'first floor circulator',               'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('26', 'kitchen',              'first floor heat',                     'heat',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('27', 'kitchen',              'first floor circulator',               'heat',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('28', 'kitchen',              'first floor cool',                     'cool',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('29', 'kitchen',              'first floor circulator',               'cool',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('30', 'kitchen',              'first floor circulator',               'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('31', 'master bedroom',       'first floor heat',                     'heat',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('32', 'master bedroom',       'first floor circulator',               'heat',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('33', 'master bedroom',       'master bedroom boosters',              'heat',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('34', 'master bedroom',       'first floor cool',                     'cool',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('35', 'master bedroom',       'first floor circulator',               'cool',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('36', 'master bedroom',       'master bedroom boosters',              'cool',         '1', '1');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('37', 'master bedroom',       'first floor circulator',               'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('38', 'master bedroom',       'master bedroom boosters',              'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('39', 'attic east',           'attic fan east #1',                    'cool',         '1',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('40', 'attic east',           'attic fan east #1',                    'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('41', 'attic east',           'attic fan east #2',                    'cool',         '2',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('42', 'attic east',           'attic fan east #2',                    'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('43', 'attic east',           'attic fan east #3',                    'cool',         '4',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('44', 'attic east',           'attic fan east #3',                    'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('45', 'attic east',           'attic fan east #4',                    'cool',         '6',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('46', 'attic east',           'attic fan east #4',                    'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('47', 'attic west',           'attic fan west #1',                    'cool',         '1',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('48', 'attic west',           'attic fan west #1',                    'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('49', 'attic west',           'attic fan west #2',                    'cool',         '2',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('50', 'attic west',           'attic fan west #2',                    'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('51', 'attic west',           'attic fan west #3',                    'cool',         '4',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('52', 'attic west',           'attic fan west #3',                    'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('53', 'attic west',           'attic fan west #4',                    'cool',         '6',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('54', 'attic west',           'attic fan west #4',                    'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('55', 'first floor zone',     'first floor circulator',               'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('56', 'basement zone',        'basement circulator',                  'circulator',   '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('57', 'first floor humidity', 'first floor humidifier',               'heat',         '0',   '0');
INSERT INTO location_actuator (id, location, actuator, mode, threshold_on, threshold_off) VALUES ('58', 'first floor humidity', 'first floor humidifier',               'circulator',   '0',   '0');

INSERT INTO contact (id, description, db, unit, port, state, date_time) VALUES ('1',    'attic hatch',                  'arduino_mqtt', 'attic driveway', 'd08', 't', now());
INSERT INTO contact (id, description, db, unit, port, state, date_time) VALUES ('2',    'attic fan west closet switch', 'arduino_mqtt', 'attic driveway', 'd07', 't', now());
INSERT INTO contact (id, description, db, unit, port, state, date_time) VALUES ('3',    'attic fan east closet switch', 'arduino_mqtt', 'attic pathway',  'd00', 't', now());
