SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.races (
		raceId INT  NOT NULL,
		year INT NOT NULL DEFAULT 0,
		round INT NOT NULL DEFAULT 0,
		circuitId INT NOT NULL DEFAULT 0,
		name varchar(255) NOT NULL,
		date date NOT NULL,
		time time,
		url varchar(2048),
		fp1_date date,
		fp1_time time,
		fp2_date date,
		fp2_time time,
		fp3_date date,
		fp3_time time,
		quali_date date,
		quali_time time,
		sprint_date date,
		sprint_time time,
		CONSTRAINT PK_races_raceId PRIMARY KEY CLUSTERED (raceId ASC)
		WITH
			(
				PAD_INDEX = OFF,
				IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON,
				ALLOW_PAGE_LOCKS = ON
			) ON [PRIMARY]
	) ON [PRIMARY] 
	GO