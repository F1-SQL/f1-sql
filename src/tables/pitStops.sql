SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.pitStops (
		raceId INT NOT NULL,
		driverId INT NOT NULL,
		stop INT NOT NULL,
		lap INT NOT NULL,
		time time NOT NULL,
		duration varchar(255),
		milliseconds INT,
		[duration_converted] DECIMAL(18,3),
		CONSTRAINT PK_pitStops_raceId_driverId_stop PRIMARY KEY CLUSTERED (raceId ASC, driverId ASC, stop ASC)
		WITH
			(
				PAD_INDEX = OFF,
				IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON,
				ALLOW_PAGE_LOCKS = ON
			) ON [PRIMARY]
	) ON [PRIMARY] 
	GO