USE f1db
SET NOCOUNT ON;

CREATE TABLE circuits (
  circuitId int  NOT NULL,
  circuitRef varchar(255) NOT NULL DEFAULT '',
  name varchar(255) NOT NULL DEFAULT '',
  location varchar(255) DEFAULT NULL,
  country varchar(255) DEFAULT NULL,
  lat float DEFAULT NULL,
  lng float DEFAULT NULL,
  alt int DEFAULT NULL,
  url varchar(255) NOT NULL DEFAULT ''
)

ALTER TABLE circuits ADD CONSTRAINT PK_circuits_circuitId PRIMARY KEY (circuitId);
ALTER TABLE circuits ADD CONSTRAINT UK_circuits_url UNIQUE(url);

CREATE TABLE constructorResults (
  constructorResultsId int  NOT NULL,
  raceId int NOT NULL DEFAULT 0,
  constructorId int NOT NULL DEFAULT 0,
  points float DEFAULT NULL,
  status varchar(255) DEFAULT NULL
) 

ALTER TABLE constructorResults ADD CONSTRAINT PK_constructorResults_constructorResultsId PRIMARY KEY (constructorResultsId);


CREATE TABLE constructorStandings (
  constructorStandingsId INT  NOT NULL,
  raceId INT NOT NULL DEFAULT 0,
  constructorId INT NOT NULL DEFAULT 0,
  points float NOT NULL DEFAULT 0,
  position INT DEFAULT NULL,
  positionText varchar(255) DEFAULT NULL,
  wins INT NOT NULL DEFAULT 0
);

ALTER TABLE constructorStandings ADD CONSTRAINT PK_constructorStandings_constructorResultsId PRIMARY KEY (constructorStandingsId)

CREATE TABLE constructors (
  constructorId INT  NOT NULL,
  constructorRef varchar(255) NOT NULL DEFAULT '',
  name varchar(255) NOT NULL DEFAULT '',
  nationality varchar(255) DEFAULT NULL,
  url varchar(2048) NOT NULL DEFAULT ''
);

ALTER TABLE constructors ADD CONSTRAINT PK_constructors_constructorId PRIMARY KEY (constructorId)
ALTER TABLE constructors ADD CONSTRAINT UK_constructors_name UNIQUE(name);

CREATE TABLE driverStandings (
  driverStandingsId INT  NOT NULL,
  raceId INT NOT NULL DEFAULT 0,
  driverId INT NOT NULL DEFAULT 0,
  points float NOT NULL DEFAULT 0,
  position INT DEFAULT NULL,
  positionText varchar(255) DEFAULT NULL,
  wins INT NOT NULL DEFAULT 0
);

ALTER TABLE driverStandings ADD CONSTRAINT PK_driverStandings_driverStandingsId PRIMARY KEY (driverStandingsId)

CREATE TABLE drivers (
  driverId INT  NOT NULL,
  driverRef varchar(255) NOT NULL DEFAULT '',
  number INT DEFAULT NULL,
  code varchar(3) DEFAULT NULL,
  forename varchar(255) NOT NULL DEFAULT '',
  surname varchar(255) NOT NULL DEFAULT '',
  dob date DEFAULT NULL,
  nationality varchar(255) DEFAULT NULL,
  url varchar(2048) NOT NULL DEFAULT ''
);

ALTER TABLE drivers ADD CONSTRAINT PK_driverss_driverId PRIMARY KEY (driverId)

CREATE TABLE lapTimes (
  raceId INT NOT NULL,
  driverId INT NOT NULL,
  lap INT NOT NULL,
  position INT DEFAULT NULL,
  time varchar(255) DEFAULT NULL,
  milliseconds INT DEFAULT NULL
);

ALTER TABLE lapTimes ADD CONSTRAINT PK_lapTimes_raceId_driverId_lap PRIMARY KEY (raceId,driverId,lap)

CREATE TABLE pitStops (
  raceId INT NOT NULL,
  driverId INT NOT NULL,
  stop INT NOT NULL,
  lap INT NOT NULL,
  time time NOT NULL,
  duration varchar(255) DEFAULT NULL,
  milliseconds INT DEFAULT NULL
);

ALTER TABLE pitStops ADD CONSTRAINT PK_pitStops_raceId_driverId_stop PRIMARY KEY (raceId,driverId,stop)

CREATE TABLE qualifying (
  qualifyId INT  NOT NULL,
  raceId INT NOT NULL DEFAULT 0,
  driverId INT NOT NULL DEFAULT 0,
  constructorId INT NOT NULL DEFAULT 0,
  number INT NOT NULL DEFAULT 0,
  position INT DEFAULT NULL,
  q1 varchar(255) DEFAULT NULL,
  q2 varchar(255) DEFAULT NULL,
  q3 varchar(255) DEFAULT NULL
);

ALTER TABLE qualifying ADD CONSTRAINT PK_qualifying_qualifyId PRIMARY KEY (qualifyId)

CREATE TABLE races (
  raceId INT  NOT NULL,
  year INT NOT NULL DEFAULT 0,
  round INT NOT NULL DEFAULT 0,
  circuitId INT NOT NULL DEFAULT 0,
  name varchar(255) NOT NULL DEFAULT '',
  date date NOT NULL DEFAULT '0000-00-00',
  time time DEFAULT NULL,
  url varchar(2048) DEFAULT NULL,
  fp1_date date DEFAULT NULL,
  fp1_time time DEFAULT NULL,
  fp2_date date DEFAULT NULL,
  fp2_time time DEFAULT NULL,
  fp3_date date DEFAULT NULL,
  fp3_time time DEFAULT NULL,
  quali_date date DEFAULT NULL,
  quali_time time DEFAULT NULL,
  sprint_date date DEFAULT NULL,
  sprint_time time DEFAULT NULL
);

ALTER TABLE races ADD CONSTRAINT PK_races_raceId PRIMARY KEY (raceId)
ALTER TABLE races ADD CONSTRAINT UK_races_url UNIQUE(url);

CREATE TABLE results (
  resultId INT  NOT NULL,
  raceId INT NOT NULL DEFAULT 0,
  driverId INT NOT NULL DEFAULT 0,
  constructorId INT NOT NULL DEFAULT 0,
  number INT NULL,
  grid INT NOT NULL DEFAULT 0,
  position INT DEFAULT NULL,
  positionText varchar(255) NOT NULL DEFAULT '',
  positionOrder INT NOT NULL DEFAULT 0,
  points float NOT NULL DEFAULT 0,
  laps INT NOT NULL DEFAULT 0,
  time varchar(255) DEFAULT NULL,
  milliseconds INT DEFAULT NULL,
  fastestLap INT DEFAULT NULL,
  rank INT DEFAULT 0,
  fastestLapTime varchar(255) DEFAULT NULL,
  fastestLapSpeed varchar(255) DEFAULT NULL,
  statusId INT NOT NULL DEFAULT 0
);

ALTER TABLE results ADD CONSTRAINT PK_results_resultId PRIMARY KEY (resultId)

CREATE TABLE seasons (
  year INT NOT NULL DEFAULT 0,
  url varchar(2048) NOT NULL DEFAULT ''
);

ALTER TABLE seasons ADD CONSTRAINT PK_seasons_year PRIMARY KEY (year)


CREATE TABLE sprintResults (
  resultId INT  NOT NULL,
  raceId INT NOT NULL DEFAULT 0,
  driverId INT NOT NULL DEFAULT 0,
  constructorId INT NOT NULL DEFAULT 0,
  number INT NOT NULL DEFAULT 0,
  grid INT NOT NULL DEFAULT 0,
  position INT DEFAULT NULL,
  positionText varchar(255) NOT NULL DEFAULT '',
  positionOrder INT NOT NULL DEFAULT 0,
  points float NOT NULL DEFAULT 0,
  laps INT NOT NULL DEFAULT 0,
  time varchar(255) DEFAULT NULL,
  milliseconds INT DEFAULT NULL,
  fastestLap INT DEFAULT NULL,
  fastestLapTime varchar(255) DEFAULT NULL,
  statusId INT NOT NULL DEFAULT 0
);

ALTER TABLE sprintResults ADD CONSTRAINT PK_sprintResults_sprintResultId PRIMARY KEY (resultId)

CREATE TABLE status (
  statusId INT  NOT NULL,
  status varchar(255) NOT NULL DEFAULT ''
);

ALTER TABLE status ADD CONSTRAINT PK_status_statusId PRIMARY KEY (statusId)