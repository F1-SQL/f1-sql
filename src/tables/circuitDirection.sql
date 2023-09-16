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
		CONSTRAINT PK_circuitDirection_circuitDirectionID PRIMARY KEY CLUSTERED (circuitDirectionID ASC)
		WITH
			(
				PAD_INDEX = OFF,
				IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON,
				ALLOW_PAGE_LOCKS = ON
			) ON [PRIMARY]
	) ON [PRIMARY] 
	GO