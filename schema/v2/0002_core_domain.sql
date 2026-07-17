/* F1 SQL schema v2 core domain tables. All timestamps are UTC. */
IF SCHEMA_ID(N'f1sql') IS NULL
    EXEC(N'CREATE SCHEMA f1sql');
GO

IF OBJECT_ID(N'f1sql.Season', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.Season
    (
        SeasonKey smallint NOT NULL,
        CONSTRAINT PK_Season PRIMARY KEY (SeasonKey),
        CONSTRAINT CK_Season_Key CHECK (SeasonKey >= 1950)
    );
END;
GO

IF OBJECT_ID(N'f1sql.Circuit', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.Circuit
    (
        CircuitKey nvarchar(128) NOT NULL,
        Name nvarchar(255) NOT NULL,
        Locality nvarchar(255) NULL,
        Country nvarchar(128) NULL,
        Latitude decimal(9, 6) NULL,
        Longitude decimal(9, 6) NULL,
        CONSTRAINT PK_Circuit PRIMARY KEY (CircuitKey),
        CONSTRAINT UQ_Circuit_Name UNIQUE (Name),
        CONSTRAINT CK_Circuit_Latitude CHECK (Latitude IS NULL OR Latitude BETWEEN -90 AND 90),
        CONSTRAINT CK_Circuit_Longitude CHECK (Longitude IS NULL OR Longitude BETWEEN -180 AND 180)
    );
END;
GO

IF OBJECT_ID(N'f1sql.Driver', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.Driver
    (
        DriverKey nvarchar(128) NOT NULL,
        GivenName nvarchar(128) NOT NULL,
        FamilyName nvarchar(128) NOT NULL,
        PermanentNumber smallint NULL,
        CONSTRAINT PK_Driver PRIMARY KEY (DriverKey),
        CONSTRAINT CK_Driver_PermanentNumber CHECK (PermanentNumber IS NULL OR PermanentNumber BETWEEN 1 AND 99)
    );
END;
GO

IF OBJECT_ID(N'f1sql.Constructor', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.Constructor
    (
        ConstructorKey nvarchar(128) NOT NULL,
        Name nvarchar(255) NOT NULL,
        CONSTRAINT PK_Constructor PRIMARY KEY (ConstructorKey),
        CONSTRAINT UQ_Constructor_Name UNIQUE (Name)
    );
END;
GO

IF OBJECT_ID(N'f1sql.Meeting', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.Meeting
    (
        MeetingKey nvarchar(32) NOT NULL,
        SeasonKey smallint NOT NULL,
        RoundNumber smallint NOT NULL,
        Name nvarchar(255) NOT NULL,
        ScheduledAtUtc datetime2(3) NOT NULL,
        CircuitKey nvarchar(128) NOT NULL,
        HasSprint bit NOT NULL,
        CONSTRAINT PK_Meeting PRIMARY KEY (MeetingKey),
        CONSTRAINT FK_Meeting_Season FOREIGN KEY (SeasonKey) REFERENCES f1sql.Season (SeasonKey),
        CONSTRAINT FK_Meeting_Circuit FOREIGN KEY (CircuitKey) REFERENCES f1sql.Circuit (CircuitKey),
        CONSTRAINT UQ_Meeting_SeasonRound UNIQUE (SeasonKey, RoundNumber),
        CONSTRAINT CK_Meeting_Round CHECK (RoundNumber > 0)
    );
END;
GO

IF OBJECT_ID(N'f1sql.Session', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.Session
    (
        SessionKey nvarchar(64) NOT NULL,
        MeetingKey nvarchar(32) NOT NULL,
        SessionType nvarchar(32) NOT NULL,
        StartUtc datetime2(3) NULL,
        EndUtc datetime2(3) NULL,
        Status nvarchar(32) NOT NULL,
        CONSTRAINT PK_Session PRIMARY KEY (SessionKey),
        CONSTRAINT FK_Session_Meeting FOREIGN KEY (MeetingKey) REFERENCES f1sql.Meeting (MeetingKey),
        CONSTRAINT UQ_Session_MeetingType UNIQUE (MeetingKey, SessionType),
        CONSTRAINT CK_Session_Status CHECK (Status IN (N'scheduled', N'complete', N'delayed', N'cancelled', N'unavailable')),
        CONSTRAINT CK_Session_TimeOrder CHECK (EndUtc IS NULL OR StartUtc IS NULL OR EndUtc >= StartUtc)
    );
END;
GO

IF OBJECT_ID(N'f1sql.Participant', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.Participant
    (
        SessionKey nvarchar(64) NOT NULL,
        DriverKey nvarchar(128) NOT NULL,
        ConstructorKey nvarchar(128) NOT NULL,
        DriverNumber smallint NULL,
        CONSTRAINT PK_Participant PRIMARY KEY (SessionKey, DriverKey),
        CONSTRAINT FK_Participant_Session FOREIGN KEY (SessionKey) REFERENCES f1sql.Session (SessionKey),
        CONSTRAINT FK_Participant_Driver FOREIGN KEY (DriverKey) REFERENCES f1sql.Driver (DriverKey),
        CONSTRAINT FK_Participant_Constructor FOREIGN KEY (ConstructorKey) REFERENCES f1sql.Constructor (ConstructorKey),
        CONSTRAINT CK_Participant_DriverNumber CHECK (DriverNumber IS NULL OR DriverNumber BETWEEN 1 AND 99)
    );
END;
GO

IF OBJECT_ID(N'f1sql.Result', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.Result
    (
        SessionKey nvarchar(64) NOT NULL,
        DriverKey nvarchar(128) NOT NULL,
        ConstructorKey nvarchar(128) NOT NULL,
        DriverNumber smallint NULL,
        ClassifiedPosition smallint NULL,
        PositionText nvarchar(32) NULL,
        Points decimal(9, 3) NOT NULL,
        Laps int NULL,
        DurationMs int NULL,
        Status nvarchar(128) NULL,
        CONSTRAINT PK_Result PRIMARY KEY (SessionKey, DriverKey),
        CONSTRAINT FK_Result_Participant FOREIGN KEY (SessionKey, DriverKey)
            REFERENCES f1sql.Participant (SessionKey, DriverKey),
        CONSTRAINT FK_Result_Constructor FOREIGN KEY (ConstructorKey) REFERENCES f1sql.Constructor (ConstructorKey),
        CONSTRAINT CK_Result_Position CHECK (ClassifiedPosition IS NULL OR ClassifiedPosition > 0),
        CONSTRAINT CK_Result_Points CHECK (Points >= 0),
        CONSTRAINT CK_Result_Laps CHECK (Laps IS NULL OR Laps >= 0),
        CONSTRAINT CK_Result_Duration CHECK (DurationMs IS NULL OR DurationMs >= 0)
    );
END;
GO

IF OBJECT_ID(N'f1sql.Lap', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.Lap
    (
        SessionKey nvarchar(64) NOT NULL,
        DriverKey nvarchar(128) NOT NULL,
        LapNumber int NOT NULL,
        LapTimeMs int NULL,
        Sector1TimeMs int NULL,
        Sector2TimeMs int NULL,
        Sector3TimeMs int NULL,
        SpeedI1Kph decimal(8, 3) NULL,
        SpeedI2Kph decimal(8, 3) NULL,
        SpeedFlKph decimal(8, 3) NULL,
        SpeedStKph decimal(8, 3) NULL,
        CONSTRAINT PK_Lap PRIMARY KEY (SessionKey, DriverKey, LapNumber),
        CONSTRAINT FK_Lap_Participant FOREIGN KEY (SessionKey, DriverKey)
            REFERENCES f1sql.Participant (SessionKey, DriverKey),
        CONSTRAINT CK_Lap_Number CHECK (LapNumber > 0),
        CONSTRAINT CK_Lap_Times CHECK (LapTimeMs IS NULL OR LapTimeMs >= 0)
    );
END;
GO

IF OBJECT_ID(N'f1sql.Stint', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.Stint
    (
        SessionKey nvarchar(64) NOT NULL,
        DriverKey nvarchar(128) NOT NULL,
        StintNumber int NOT NULL,
        Compound nvarchar(32) NULL,
        StartLap int NULL,
        EndLap int NULL,
        FreshTyre bit NULL,
        CONSTRAINT PK_Stint PRIMARY KEY (SessionKey, DriverKey, StintNumber),
        CONSTRAINT FK_Stint_Participant FOREIGN KEY (SessionKey, DriverKey)
            REFERENCES f1sql.Participant (SessionKey, DriverKey),
        CONSTRAINT CK_Stint_Number CHECK (StintNumber > 0),
        CONSTRAINT CK_Stint_Laps CHECK (EndLap IS NULL OR StartLap IS NULL OR EndLap >= StartLap)
    );
END;
GO

IF OBJECT_ID(N'f1sql.PitStop', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.PitStop
    (
        SessionKey nvarchar(64) NOT NULL,
        DriverKey nvarchar(128) NOT NULL,
        StopNumber int NOT NULL,
        LapNumber int NULL,
        DurationMs int NULL,
        PitInUtc datetime2(3) NULL,
        PitOutUtc datetime2(3) NULL,
        CONSTRAINT PK_PitStop PRIMARY KEY (SessionKey, DriverKey, StopNumber),
        CONSTRAINT FK_PitStop_Participant FOREIGN KEY (SessionKey, DriverKey)
            REFERENCES f1sql.Participant (SessionKey, DriverKey),
        CONSTRAINT CK_PitStop_Number CHECK (StopNumber > 0),
        CONSTRAINT CK_PitStop_Duration CHECK (DurationMs IS NULL OR DurationMs >= 0),
        CONSTRAINT CK_PitStop_TimeOrder CHECK (PitOutUtc IS NULL OR PitInUtc IS NULL OR PitOutUtc >= PitInUtc)
    );
END;
GO

IF OBJECT_ID(N'f1sql.Weather', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.Weather
    (
        SessionKey nvarchar(64) NOT NULL,
        ObservedAtUtc datetime2(3) NOT NULL,
        AirTempC decimal(8, 3) NULL,
        TrackTempC decimal(8, 3) NULL,
        HumidityPct decimal(6, 3) NULL,
        WindSpeedKph decimal(8, 3) NULL,
        RainfallMm decimal(8, 3) NULL,
        CONSTRAINT PK_Weather PRIMARY KEY (SessionKey, ObservedAtUtc),
        CONSTRAINT FK_Weather_Session FOREIGN KEY (SessionKey) REFERENCES f1sql.Session (SessionKey),
        CONSTRAINT CK_Weather_Humidity CHECK (HumidityPct IS NULL OR HumidityPct BETWEEN 0 AND 100),
        CONSTRAINT CK_Weather_NonNegative CHECK (
            (WindSpeedKph IS NULL OR WindSpeedKph >= 0) AND (RainfallMm IS NULL OR RainfallMm >= 0)
        )
    );
END;
GO

IF OBJECT_ID(N'f1sql.RaceControl', N'U') IS NULL
BEGIN
    CREATE TABLE f1sql.RaceControl
    (
        SessionKey nvarchar(64) NOT NULL,
        MessageNumber int NOT NULL,
        MessageAtUtc datetime2(3) NULL,
        Category nvarchar(64) NULL,
        Message nvarchar(2000) NOT NULL,
        CONSTRAINT PK_RaceControl PRIMARY KEY (SessionKey, MessageNumber),
        CONSTRAINT FK_RaceControl_Session FOREIGN KEY (SessionKey) REFERENCES f1sql.Session (SessionKey),
        CONSTRAINT CK_RaceControl_Number CHECK (MessageNumber > 0)
    );
END;
GO
