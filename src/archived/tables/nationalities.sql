SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.nationalities (
		nationalityID INT NOT NULL,
		nationality varchar(50),
	) ON [PRIMARY] 
	GO