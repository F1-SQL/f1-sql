SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.circuitDirection (
		circuitDirectionID INT NOT NULL,
		circuitDirection varchar(255),
	) ON [PRIMARY] 
	GO