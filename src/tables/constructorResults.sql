SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.constructorResults (
		constructorResultsId int  NOT NULL,
		raceId int NOT NULL DEFAULT 0,
		constructorId int NOT NULL DEFAULT 0,
		points float,
		status varchar(255),
		positionTextID INT,
		CONSTRAINT PK_constructorResults_constructorResultsId PRIMARY KEY CLUSTERED (constructorResultsId ASC)
		WITH
			(
				PAD_INDEX = OFF,
				IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON,
				ALLOW_PAGE_LOCKS = ON
			) ON [PRIMARY]
	) ON [PRIMARY] 
	GO