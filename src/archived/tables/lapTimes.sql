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
	) ON [PRIMARY] 
	GO