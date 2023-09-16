SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.qualifying (
		qualifyId INT  NOT NULL,
		raceId INT NOT NULL DEFAULT 0,
		driverId INT NOT NULL DEFAULT 0,
		constructorId INT NOT NULL DEFAULT 0,
		number INT NOT NULL DEFAULT 0,
		position INT,
		q1 varchar(255),
		q2 varchar(255),
		q3 varchar(255),
		[q1_converted] TIME(3), 
		[q2_converted] TIME(3), 
		[q3_converted] TIME(3),
		CONSTRAINT PK_qualifying_qualifyId PRIMARY KEY CLUSTERED (qualifyId ASC)
		WITH
			(
				PAD_INDEX = OFF,
				IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON,
				ALLOW_PAGE_LOCKS = ON
			) ON [PRIMARY]
	) ON [PRIMARY] 
	GO