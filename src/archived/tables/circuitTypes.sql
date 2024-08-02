SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.circuitTypes (
		circuitTypeID INT NOT NULL,
		circuitType varchar(50),
	) ON [PRIMARY] 
	GO