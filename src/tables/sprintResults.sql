SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.sprintResults (
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
		statusId INT NOT NULL DEFAULT 0,
		positionTextID INT,
		time_converted time(3),
		[timeDifference] DATETIME NULL,
		[fastestLapTime_converted] TIME(3) NULL,
		CONSTRAINT PK_sprintResults_sprintResultId PRIMARY KEY CLUSTERED (resultId ASC)
		WITH
			(
				PAD_INDEX = OFF,
				IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON,
				ALLOW_PAGE_LOCKS = ON
			) ON [PRIMARY]
	) ON [PRIMARY]
	 GO