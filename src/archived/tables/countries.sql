SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.countries (
		countryID INT NOT NULL,
		country varchar(255),
	) ON [PRIMARY] 
	GO