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
	) ON [PRIMARY] 
	GO