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
		CONSTRAINT PK_positionText_positionTextID PRIMARY KEY CLUSTERED (positionTextID ASC)
		WITH
			(
				PAD_INDEX = OFF,
				IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON,
				ALLOW_PAGE_LOCKS = ON
			) ON [PRIMARY]
	) ON [PRIMARY] 
	GO