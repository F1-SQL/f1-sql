SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.circuits (
		circuitId int  NOT NULL,
		circuitRef varchar(255) NOT NULL DEFAULT '',
		name varchar(255) NOT NULL DEFAULT '',
		location varchar(255),
		country varchar(255),
		lat float,
		lng float,
		alt int,
		url varchar(255) NOT NULL DEFAULT '',
		locationID INT,
		countryID INT,
		circuitDirectionID INT,
		circuitTypeID INT,
		CONSTRAINT PK_circuits_circuitId PRIMARY KEY CLUSTERED (circuitId ASC)
		WITH
			(
				PAD_INDEX = OFF,
				IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON,
				ALLOW_PAGE_LOCKS = ON
			) ON [PRIMARY]
	) ON [PRIMARY] 
	GO