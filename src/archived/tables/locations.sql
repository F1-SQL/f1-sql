SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.locations (
		locationID INT NOT NULL,
		locationName varchar(255),
	) ON [PRIMARY] 
	GO