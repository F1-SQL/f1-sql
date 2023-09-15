SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.driverNumbers (
		driverNumberID INT NOT NULL,
		number INT NOT NULL,
		driverID INT NOT NULL,
		constructorID INT,
		season INT,
		sub BIT DEFAULT 0,
		retired BIT DEFAULT 0,
		CONSTRAINT PK_driverNumbers_driverNumberID PRIMARY KEY CLUSTERED (driverNumberID ASC)
		WITH
			(
				PAD_INDEX = OFF,
				IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON,
				ALLOW_PAGE_LOCKS = ON
			) ON [PRIMARY]
	) ON [PRIMARY] 
	GO