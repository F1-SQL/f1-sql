SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.positionText (
		positionTextID INT NOT NULL,
		positionText varchar(50),
		positionCode varchar(3),
	) ON [PRIMARY] 
	GO