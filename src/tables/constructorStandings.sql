SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.constructorStandings (
		constructorStandingsId INT  NOT NULL,
		raceId INT NOT NULL DEFAULT 0,
		constructorId INT NOT NULL DEFAULT 0,
		points float NOT NULL DEFAULT 0,
		position INT,
		positionText varchar(255),
		wins INT NOT NULL DEFAULT 0,
		positionTextID INT,
		CONSTRAINT PK_constructorStandings_constructorResultsId PRIMARY KEY CLUSTERED (constructorStandingsId ASC)
		WITH
			(
				PAD_INDEX = OFF,
				IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON,
				ALLOW_PAGE_LOCKS = ON
			) ON [PRIMARY]
	) ON [PRIMARY] 
	GO