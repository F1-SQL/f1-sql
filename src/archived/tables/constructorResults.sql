SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.constructorResults (
		constructorResultsId int NOT NULL,
		raceId int NOT NULL DEFAULT 0,
		constructorId int NOT NULL DEFAULT 0,
		points float,
		status varchar(255),
		positionTextID INT,
	) ON [PRIMARY] 
	GO