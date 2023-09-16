SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.lapTimes (
		raceId INT NOT NULL,
		driverId INT NOT NULL,
		lap INT NOT NULL,
		position INT,
		time varchar(255),
		milliseconds INT,
		time_converted TIME(3),
		CONSTRAINT PK_lapTimes_raceId_driverId_lap PRIMARY KEY CLUSTERED (raceId ASC, driverId ASC, lap ASC)
		WITH
			(
				PAD_INDEX = OFF,
				IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON,
				ALLOW_PAGE_LOCKS = ON
			) ON [PRIMARY]
	) ON [PRIMARY] 
	GO