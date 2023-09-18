SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.circuits (
		circuitId int  NOT NULL,
		circuitRef varchar(255) NOT NULL,
		name varchar(255) NOT NULL,
		location varchar(255),
		country varchar(255),
		lat float,
		lng float,
		alt int,
		url varchar(255) NOT NULL,
		locationID INT,
		countryID INT,
		circuitDirectionID INT,
		circuitTypeID INT,
	) ON [PRIMARY] 
	GO