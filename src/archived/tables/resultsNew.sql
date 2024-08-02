SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
    dbo.resultsNew (
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
        [time] [time](3) NULL,
    ) ON [PRIMARY] 
    GO