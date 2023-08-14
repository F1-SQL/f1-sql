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

/* Supplementary Data Items Extra Additions */

CREATE TABLE dbo.circuitTypes
(
	circuitTypeID INT NOT NULL,
	circuitType varchar(50)
);

ALTER TABLE dbo.circuitTypes ADD CONSTRAINT PK_circuitTypes_circuitTypeID PRIMARY KEY (circuitTypeID);

CREATE TABLE dbo.circuitDirection
(
	circuitDirectionID INT NOT NULL,
	circuitDirection varchar(50)
);

ALTER TABLE dbo.circuitDirection ADD CONSTRAINT PK_circuitDirection_circuitDirectionID PRIMARY KEY (circuitDirectionID);

CREATE TABLE dbo.nationalities
(
	nationalityID INT NOT NULL,
	nationality varchar(50)
);

ALTER TABLE dbo.nationalities ADD CONSTRAINT PK_nationalities_nationalityID PRIMARY KEY (nationalityID);

CREATE TABLE dbo.positionText
(
	positionTextID INT NOT NULL,
	positionText varchar(50),
  positionCode varchar(3)
);

ALTER TABLE dbo.positionText ADD CONSTRAINT PK_positionText_positionTextID PRIMARY KEY (positionTextID);

INSERT INTO positionText (positionTextID,positionText,positionCode)
VALUES
(1,'1','1'),
(2,'2','2'),
(3,'3','3'),
(4,'4','4'),
(5,'5','5'),
(6,'6','6'),
(7,'7','7'),
(8,'8','8'),
(9,'9','9'),
(10,'10','10'),
(11,'11','11'),
(12,'12','12'),
(13,'13','13'),
(14,'14','14'),
(15,'15','15'),
(16,'16','16'),
(17,'17','17'),
(18,'18','18'),
(19,'19','19'),
(20,'20','20'),
(21,'21','21'),
(22,'22','22'),
(23,'23','23'),
(24,'24','24'),
(25,'25','25'),
(26,'26','26'),
(27,'27','27'),
(28,'28','28'),
(29,'29','29'),
(30,'30','30'),
(31,'31','31'),
(32,'32','32'),
(33,'33','33'),
(600,'Disqualified','D'),
(601,'Excluded','E'),
(602,'Failed To Qualify','F'),
(603,'Not Classified','N'),
(604,'Retired','R'),
(605,'Withdrew','W')

CREATE TABLE dbo.countries
(
	countryID INT NOT NULL,
	country varchar(255)
);

ALTER TABLE dbo.countries ADD CONSTRAINT PK_countries_countryID PRIMARY KEY (countryID);