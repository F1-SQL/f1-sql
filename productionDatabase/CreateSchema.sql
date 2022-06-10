--DROP DATABASE [FormulaOne];

CREATE DATABASE [FormulaOne];

GO

USE [FormulaOne];

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

ALTER TABLE Ref.Seasons ADD CONSTRAINT PK_Seasons_SeasonRefID PRIMARY KEY (SeasonRefID);

CREATE TABLE Ref.Country
(
	ID INT IDENTITY(1,1) NOT NULL,
	CountryID INT NOT NULL,
	Country	varchar(50)
)

ALTER TABLE Ref.Country ADD CONSTRAINT PK_Country_CountryID PRIMARY KEY (CountryID);

CREATE TABLE Ref.CircuitType
(
	ID INT IDENTITY(1,1) NOT NULL,
	TypeRefID INT NOT NULL,
	CircuitType varchar(30) NOT NULL	
)

ALTER TABLE Ref.CircuitType ADD CONSTRAINT PK_CircuitType_TypeRefID PRIMARY KEY (TypeRefID);

CREATE TABLE Ref.CircuitDirections
(
	ID INT IDENTITY(1,1) NOT NULL,
	DirectionRefID INT NOT NULL,
	Direction varchar(100)	
)

ALTER TABLE Ref.CircuitDirections ADD CONSTRAINT PK_CircuitDirections_DirectionRefID PRIMARY KEY (DirectionRefID);

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

ALTER TABLE dbo.Drivers ADD CONSTRAINT PK_Drivers_DriverID PRIMARY KEY (DriverID);

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

ALTER TABLE dbo.Constructors ADD CONSTRAINT PK_Constructors_ConstructorID PRIMARY KEY (ConstructorID);

CREATE TABLE dbo.ConstructorsSeasons
(
	ID INT IDENTITY(1,1) NOT NULL,
	ConstructorID INT,
	SeasonID INT
);

ALTER TABLE dbo.ConstructorsSeasons ADD CONSTRAINT PK_ConstructorsSeasons_ID PRIMARY KEY (ID);

CREATE TABLE dbo.ConstructorNationality
(
	ID INT IDENTITY(1,1) NOT NULL,
	ContructorID INT,	
	CountryID INT
);

ALTER TABLE dbo.ConstructorNationality ADD CONSTRAINT PK_ConstructorNationality_ID PRIMARY KEY (ID);

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

ALTER TABLE dbo.Circuits ADD CONSTRAINT PK_Circuits_CircuitID PRIMARY KEY (CircuitID);

CREATE TABLE dbo.CircuitImages
(
	ImageID INT IDENTITY(1,1) NOT NULL,
	CircuitID INT,
	ImageURL nvarchar(1000)
);

ALTER TABLE dbo.CircuitImages ADD CONSTRAINT PK_CircuitImages_ImageID PRIMARY KEY (ImageID);

CREATE TABLE dbo.CircuitsLocation
(
	LocationID INT IDENTITY(1,1) NOT NULL,
	CircuitID INT,
	CircuitLocation varchar(50),
	CountryID INT,
	Locale varchar(50),
	Longitude nvarchar(200),
	Latitude nvarchar(200)
);

ALTER TABLE dbo.CircuitsLocation ADD CONSTRAINT PK_CircuitsLocation_LocationID PRIMARY KEY (LocationID);

CREATE TABLE dbo.CircuitSeasons
(
	ID INT IDENTITY(1,1) NOT NULL,
	CircuitID INT,	
	SeasonID INT
);

ALTER TABLE dbo.CircuitSeasons ADD CONSTRAINT PK_CircuitSeasons_ID PRIMARY KEY (ID);

/*
****************************
CREATE THE RELATIONSHIPS 
****************************
*/

ALTER TABLE dbo.Drivers ADD CONSTRAINT FK_Drivers_CountryID FOREIGN KEY (CountryID) REFERENCES Ref.Country(CountryID);

ALTER TABLE dbo.DriversSeasons ADD CONSTRAINT FK_DriversSeasons_DriverID  FOREIGN KEY (DriverID) REFERENCES dbo.Drivers(DriverID);
ALTER TABLE dbo.DriversSeasons ADD CONSTRAINT FK_DriversSeasons_SeasonRefID  FOREIGN KEY (SeasonRefID) REFERENCES Ref.Seasons(SeasonRefID);

ALTER TABLE dbo.DriversChampionships ADD CONSTRAINT FK_DriversChampionships_DriverID  FOREIGN KEY (DriverID) REFERENCES dbo.Drivers(DriverID);
ALTER TABLE dbo.DriversChampionships ADD CONSTRAINT FK_DriversChampionships_SeasonRefID  FOREIGN KEY (SeasonRefID) REFERENCES Ref.Seasons(SeasonRefID);

ALTER TABLE dbo.CircuitsLocation ADD CONSTRAINT FK_CircuitsLocation_CountryID  FOREIGN KEY (CountryID) REFERENCES Ref.Country(CountryID);
ALTER TABLE dbo.CircuitsLocation ADD CONSTRAINT FK_CircuitsLocation_CircuitID  FOREIGN KEY (CircuitID) REFERENCES dbo.Circuits(CircuitID);

ALTER TABLE dbo.CircuitImages ADD CONSTRAINT FK_CircuitImages_CircuitID  FOREIGN KEY (CircuitID) REFERENCES dbo.Circuits(CircuitID);

ALTER TABLE dbo.Circuits ADD CONSTRAINT FK_Circuits_TypeRefID  FOREIGN KEY (TypeRefID) REFERENCES Ref.CircuitType(TypeRefID);
ALTER TABLE dbo.Circuits ADD CONSTRAINT FK_Circuits_DirectionRefID  FOREIGN KEY (DirectionRefID) REFERENCES Ref.CircuitDirections(DirectionRefID);

ALTER TABLE dbo.ConstructorNationality ADD CONSTRAINT FK_ConstructorNationality_ConstructorID  FOREIGN KEY (ContructorID) REFERENCES dbo.Constructors(ConstructorID);
ALTER TABLE dbo.ConstructorNationality ADD CONSTRAINT FK_ConstructorNationality_CountryID  FOREIGN KEY (CountryID) REFERENCES Ref.Country(CountryID);

ALTER TABLE dbo.ConstructorsSeasons ADD CONSTRAINT FK_ConstructorsSeasons_ConstructorID  FOREIGN KEY (ConstructorID) REFERENCES dbo.Constructors(ConstructorID);
ALTER TABLE dbo.ConstructorsSeasons ADD CONSTRAINT FK_ConstructorsSeasons_SeasonRefID  FOREIGN KEY (SeasonID) REFERENCES Ref.Seasons(SeasonRefID);

ALTER TABLE dbo.Constructors ADD CONSTRAINT FK_Constructors_CountryID  FOREIGN KEY (CountryID) REFERENCES Ref.Country(CountryID);

ALTER TABLE dbo.CircuitSeasons ADD CONSTRAINT FK_CircuitSeasons_CircuitID  FOREIGN KEY (CircuitID) REFERENCES dbo.Circuits(CircuitID);
ALTER TABLE dbo.CircuitSeasons ADD CONSTRAINT FK_CircuitSeasons_SeasonRefID  FOREIGN KEY (SeasonID) REFERENCES Ref.Seasons(SeasonRefID);