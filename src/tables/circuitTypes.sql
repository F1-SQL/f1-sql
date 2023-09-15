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
		CONSTRAINT PK_circuitTypes_circuitTypeID PRIMARY KEY CLUSTERED (circuitTypeID ASC)
		WITH
			(
				PAD_INDEX = OFF,
				IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON,
				ALLOW_PAGE_LOCKS = ON
			) ON [PRIMARY]
	) ON [PRIMARY] 
	GO