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
	) ON [PRIMARY] 
	GO