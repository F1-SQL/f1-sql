SET NOCOUNT ON;

CREATE TABLE circuits (
  circuitId int  NOT NULL,
  circuitRef varchar(255) NOT NULL DEFAULT '',
  name varchar(255) NOT NULL DEFAULT '',
  location varchar(255),
  country varchar(255),
  lat float,
  lng float,
  alt int,
  url varchar(255) NOT NULL DEFAULT ''
)

ALTER TABLE circuits ADD CONSTRAINT PK_circuits_circuitId PRIMARY KEY (circuitId);
ALTER TABLE circuits ADD CONSTRAINT UK_circuits_url UNIQUE(url);

CREATE TABLE constructorResults (
  constructorResultsId int  NOT NULL,
  raceId int NOT NULL DEFAULT 0,
  constructorId int NOT NULL DEFAULT 0,
  points float,
  status varchar(255)
) 

ALTER TABLE constructorResults ADD CONSTRAINT PK_constructorResults_constructorResultsId PRIMARY KEY (constructorResultsId);


CREATE TABLE constructorStandings (
  constructorStandingsId INT  NOT NULL,
  raceId INT NOT NULL DEFAULT 0,
  constructorId INT NOT NULL DEFAULT 0,
  points float NOT NULL DEFAULT 0,
  position INT,
  positionText varchar(255),
  wins INT NOT NULL DEFAULT 0
);

ALTER TABLE constructorStandings ADD CONSTRAINT PK_constructorStandings_constructorResultsId PRIMARY KEY (constructorStandingsId)

CREATE TABLE constructors (
  constructorId INT  NOT NULL,
  constructorRef varchar(255) NOT NULL DEFAULT '',
  name varchar(255) NOT NULL DEFAULT '',
  nationality varchar(255),
  url varchar(2048) NOT NULL DEFAULT ''
);

ALTER TABLE constructors ADD CONSTRAINT PK_constructors_constructorId PRIMARY KEY (constructorId)
ALTER TABLE constructors ADD CONSTRAINT UK_constructors_name UNIQUE(name);

CREATE TABLE driverStandings (
  driverStandingsId INT  NOT NULL,
  raceId INT NOT NULL DEFAULT 0,
  driverId INT NOT NULL DEFAULT 0,
  points float NOT NULL DEFAULT 0,
  position INT,
  positionText varchar(255),
  wins INT NOT NULL DEFAULT 0
);

ALTER TABLE driverStandings ADD CONSTRAINT PK_driverStandings_driverStandingsId PRIMARY KEY (driverStandingsId)

CREATE TABLE drivers (
  driverId INT  NOT NULL,
  driverRef varchar(255) NOT NULL DEFAULT '',
  number INT,
  code varchar(3),
  forename varchar(255) NOT NULL DEFAULT '',
  surname varchar(255) NOT NULL DEFAULT '',
  dob date,
  nationality varchar(255),
  url varchar(2048) NOT NULL DEFAULT ''
);

ALTER TABLE drivers ADD CONSTRAINT PK_driverss_driverId PRIMARY KEY (driverId)

CREATE TABLE lapTimes (
  raceId INT NOT NULL,
  driverId INT NOT NULL,
  lap INT NOT NULL,
  position INT,
  time varchar(255),
  milliseconds INT
);

ALTER TABLE lapTimes ADD CONSTRAINT PK_lapTimes_raceId_driverId_lap PRIMARY KEY (raceId,driverId,lap)

CREATE TABLE pitStops (
  raceId INT NOT NULL,
  driverId INT NOT NULL,
  stop INT NOT NULL,
  lap INT NOT NULL,
  time time NOT NULL,
  duration varchar(255),
  milliseconds INT
);

ALTER TABLE pitStops ADD CONSTRAINT PK_pitStops_raceId_driverId_stop PRIMARY KEY (raceId,driverId,stop)

CREATE TABLE qualifying (
  qualifyId INT  NOT NULL,
  raceId INT NOT NULL DEFAULT 0,
  driverId INT NOT NULL DEFAULT 0,
  constructorId INT NOT NULL DEFAULT 0,
  number INT NOT NULL DEFAULT 0,
  position INT,
  q1 varchar(255),
  q2 varchar(255),
  q3 varchar(255)
);

ALTER TABLE qualifying ADD CONSTRAINT PK_qualifying_qualifyId PRIMARY KEY (qualifyId)

CREATE TABLE races (
  raceId INT  NOT NULL,
  year INT NOT NULL DEFAULT 0,
  round INT NOT NULL DEFAULT 0,
  circuitId INT NOT NULL DEFAULT 0,
  name varchar(255) NOT NULL DEFAULT '',
  date date NOT NULL DEFAULT '0000-00-00',
  time time,
  url varchar(2048),
  fp1_date date,
  fp1_time time,
  fp2_date date,
  fp2_time time,
  fp3_date date,
  fp3_time time,
  quali_date date,
  quali_time time,
  sprint_date date,
  sprint_time time
);

ALTER TABLE races ADD CONSTRAINT PK_races_raceId PRIMARY KEY (raceId)
ALTER TABLE races ADD CONSTRAINT UK_races_url UNIQUE(url);

CREATE TABLE results (
  resultId INT  NOT NULL,
  raceId INT NOT NULL DEFAULT 0,
  driverId INT NOT NULL,
  constructorId INT NOT NULL,
  number INT NULL,
  grid INT NOT NULL DEFAULT 0,
  position INT,
  positionText varchar(255) NOT NULL,
  positionOrder INT NOT NULL DEFAULT 0,
  points float NOT NULL DEFAULT 0,
  laps INT NOT NULL DEFAULT 0,
  time varchar(255),
  milliseconds INT,
  fastestLap INT,
  rank INT DEFAULT 0,
  fastestLapTime varchar(255),
  fastestLapSpeed varchar(255),
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
  position INT,
  positionText varchar(255) NOT NULL,
  positionOrder INT NOT NULL DEFAULT 0,
  points float NOT NULL DEFAULT 0,
  laps INT NOT NULL DEFAULT 0,
  time varchar(255),
  milliseconds INT,
  fastestLap INT,
  fastestLapTime varchar(255),
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
	circuitDirection varchar(255)
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

CREATE TABLE dbo.locations
(
	locationID INT NOT NULL,
	locationName varchar(255)
);

ALTER TABLE dbo.locations ADD CONSTRAINT PK_locations_locationID PRIMARY KEY (locationID);

CREATE TABLE [dbo].[tempCircuits](
	[Circuit] [nvarchar](50) NOT NULL,
	[circuitTypeID] [tinyint] NOT NULL,
	[circuitDirectionID] [tinyint] NOT NULL,
	[Location] [nvarchar](50) NOT NULL,
	[Country] [nvarchar](50) NOT NULL,
	[LastLengthUsed] [nvarchar](50) NOT NULL,
	[GrandsPrix] [nvarchar](50) NOT NULL,
	[Season] [nvarchar](150) NOT NULL,
	[GrandsPrixHeld] [tinyint] NOT NULL
);

CREATE TABLE [dbo].[driverNumbers]
(
	driverNumberID INT NOT NULL,
	number INT NOT NULL,
	driverID INT NOT NULL,
	constructorID INT,
	season INT,
	sub BIT DEFAULT 0,
	retired BIT DEFAULT 0
);

ALTER TABLE [dbo].[driverNumbers] ADD CONSTRAINT PK_driverNumbers_driverNumberID PRIMARY KEY (driverNumberID);

CREATE TABLE [dbo].[resultsNew]
(
	[resultId] [int] NOT NULL IDENTITY(1,1),
	[resultTypeId] [int] NOT NULL,
	[raceId] [int] NOT NULL,
	[driverId] [int] NOT NULL,
	[constructorId] [int] NOT NULL,
	[number] [int] NULL,
	[grid] [int] NOT NULL DEFAULT 0,
	[position] [int] NULL,
	[positionOrder] [int] NOT NULL DEFAULT 0,
	[points] [float] NOT NULL DEFAULT 0,
	[laps] [int] NOT NULL DEFAULT 0,
	[milliseconds] [int] NULL,
	[fastestLap] [int] NULL,
	[rank] [int] NULL DEFAULT 0,
	[statusId] [int] NOT NULL DEFAULT 0,
	[positionTextID] [int] NULL,
	[fastestLapTime] [time](3) NULL,
	[fastestLapSpeed] [decimal](18, 3) NULL,
	[time] [time](3) NULL
)

ALTER TABLE [dbo].[resultsNew] ADD CONSTRAINT [PK_resultsNew_resultId] PRIMARY KEY (resultId);

CREATE TABLE [dbo].[resultType]
(
	[resultTypeID] [int] NOT NULL,
	[resultType] [varchar](255) NULL
);

ALTER TABLE [dbo].[resultType] ADD CONSTRAINT [PK_resultType_resultTypeID] PRIMARY KEY (resultTypeID);

CREATE TABLE [dbo].[resultDriverConstructor]
(
[resultDriverConstructorID] INT IDENTITY(1,1) NOT NULL,
[resultID] INT NOT NULL,
[driverID] INT NOT NULL,
[constructorID] INT NOT NULL 
);

ALTER TABLE [dbo].[resultDriverConstructor] ADD CONSTRAINT PK_resultDriverConstructor_resultDriverConstructorID PRIMARY KEY (resultDriverConstructorID);

CREATE TABLE [dbo].[circuitMap]
(
	[circuitId] INT NOT NULL,
	[latitude] DECIMAL(8,6) NOT NULL,
	[longitudes] DECIMAL(9,6) NOT NULL,
  [url] varchar(255)
);

ALTER TABLE circuitMap ADD CONSTRAINT PK_circuitMap_circuitId PRIMARY KEY (circuitId);

ALTER TABLE [dbo].[results] ADD positionTextID INT;
ALTER TABLE [dbo].[results] ADD [timeDifference] DATETIME NULL; 
ALTER TABLE [dbo].[results] ADD [fastestLapTime_Converted] TIME(3) NULL; 
ALTER TABLE [dbo].[results] ADD [fastestLapSpeed_Decimal] DECIMAL(18,3) NULL; 
ALTER TABLE [dbo].[results] ADD time_converted time(3);

ALTER TABLE [dbo].[circuits] ADD locationID INT;
ALTER TABLE [dbo].[circuits] ADD countryID INT;
ALTER TABLE [dbo].[circuits] ADD circuitDirectionID INT;
ALTER TABLE [dbo].[circuits] ADD circuitTypeID INT;

ALTER TABLE [dbo].[sprintResults] ADD positionTextID INT;
ALTER TABLE [dbo].[sprintResults] ADD time_converted time(3);
ALTER TABLE [dbo].[sprintResults] ADD [timeDifference] DATETIME NULL; 
ALTER TABLE [dbo].[sprintResults] ADD [fastestLapTime_converted] TIME(3) NULL; 

ALTER TABLE [dbo].[constructors] ADD nationalityID INT; 

ALTER TABLE [dbo].[drivers] ADD nationalityID INT;

ALTER TABLE [dbo].[constructorResults] ADD positionTextID INT;

ALTER TABLE [dbo].[constructorStandings] ADD positionTextID INT;

ALTER TABLE [dbo].[driverStandings] ADD positionTextID INT;

ALTER TABLE [dbo].[pitStops] ADD [duration_converted] DECIMAL(18,3);

ALTER TABLE [dbo].[qualifying] ADD [q1_converted] TIME(3), [q2_converted] TIME(3), [q3_converted] TIME(3);

ALTER TABLE [dbo].[lapTimes] ADD time_converted TIME(3);
