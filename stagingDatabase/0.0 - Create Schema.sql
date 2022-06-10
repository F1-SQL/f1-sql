CREATE DATABASE [RichInF1Staging];

GO

USE [RichInF1Staging];

GO

CREATE SCHEMA Ref;

GO

/*
****************************
CREATE THE REF TABLES
****************************
*/

CREATE TABLE Ref.Seasons
(
	ID INT IDENTITY(1,1) NOT NULL,
	SeasonRefID  INT NOT NULL,
	Season INT
);

CREATE TABLE Ref.Country
(
	ID INT IDENTITY(1,1) NOT NULL,
	CountryID INT NOT NULL,
	Country	varchar(50)
)

CREATE TABLE Ref.CircuitType
(
	ID INT IDENTITY(1,1) NOT NULL,
	TypeRefID INT NOT NULL,
	CircuitType varchar(30) NOT NULL	
)

CREATE TABLE Ref.CircuitDirections
(
	ID INT IDENTITY(1,1) NOT NULL,
	DirectionRefID INT NOT NULL,
	Direction varchar(100)	
)

/*
****************************
CREATE MAIN TABLES
****************************
*/

CREATE TABLE dbo.Drivers
(
	ID INT IDENTITY(1,1) NOT NULL,
	DriverID INT NOT NULL,
	DriverName nvarchar(50),	
	CountryID INT,
	RaceEntries	INT,
	RaceStarts INT,
	PolePositions INT,
	RaceWins INT,
	Podiums INT,
	FastestLaps INT,	
	Points DECIMAL(6,2)
);

CREATE TABLE dbo.DriversStandings
(
DriverStandingID INT NOT NULL IDENTITY(1,1),
DriverID INT,
SeasonID INT,
Points DECIMAL(6,2) DEFAULT 0,
DateAdded DATETIME DEFAULT GETDATE(),
LastUpdated DATETIME 
);

CREATE TABLE dbo.DriversSeasons
(
	ID INT IDENTITY(1,1) NOT NULL,
	DriverID INT NOT NULL,	
	SeasonRefID INT
);

CREATE TABLE dbo.DriversChampionships
(
	ID INT IDENTITY(1,1) NOT NULL,
	DriverID  INT NOT NULL,	
	SeasonRefID INT
)

CREATE TABLE dbo.Constructors
(
	ID INT IDENTITY(1,1) NOT NULL,
	ConstructorID INT NOT NULL,
	Constructor varchar(100),		
	CountryID INT,	
	RacesEntered INT,	
	RacesStarted INT, 	
	Drivers INT,	
	TotalEntries INT,	
	Wins INT,	
	Points INT,	
	Poles INT,	
	FL INT,	
	Podiums INT,	
	WCC INT,
	WDC INT,
);

CREATE TABLE dbo.ConstructorsSeasons
(
	ID INT IDENTITY(1,1) NOT NULL,
	ConstructorID INT,
	SeasonID INT
);


CREATE TABLE dbo.ConstructorStandings
(
ConstructorStandingID INT NOT NULL IDENTITY(1,1),
ConstructorID INT,
SeasonID INT,
Points DECIMAL(6,2) DEFAULT 0,
DateAdded DATETIME DEFAULT GETDATE(),
LastUpdated DATETIME 
);


CREATE TABLE dbo.ConstructorNationality
(
	ID INT IDENTITY(1,1) NOT NULL,
	ContructorID INT,	
	CountryID INT
);


CREATE TABLE dbo.Circuits
(
	CircuitID INT NOT NULL,
	Circuit varchar(200) NOT NULL,	
	GrandsPrix varchar(200) NOT NULL,		
	TypeRefID INT,	
	DirectionRefID INT,	
	LastLengthUsed DECIMAL(5,3),	
	GrandsPrixHeld INT
);


CREATE TABLE dbo.CircuitImages
(
	ImageID INT IDENTITY(1,1) NOT NULL,
	CircuitID INT,
	ImageURL nvarchar(1000)
);


CREATE TABLE dbo.CircuitsLocation
(
	LocationID INT IDENTITY(1,1) NOT NULL,
	CircuitID INT,
	CircuitLocation varchar(50),
	CountryID INT,
	Locale varchar(50),
	Longitude GEOGRAPHY,
	Latitude GEOGRAPHY
);


CREATE TABLE dbo.CircuitSeasons
(
	ID INT IDENTITY(1,1) NOT NULL,
	CircuitID INT,	
	SeasonID INT
);

CREATE TABLE dbo.DriversTeams
(
ID INT IDENTITY(1,1) NOT NULL,
DriverID INT NOT NULL,
ConstructorID INT NOT NULL,
SeasonID INT NOT NULL
);

