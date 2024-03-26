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
	) ON [PRIMARY] 
	GO