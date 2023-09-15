SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.drivers (
		driverId INT  NOT NULL,
		driverRef varchar(255) NOT NULL DEFAULT '',
		number INT,
		code varchar(3),
		forename varchar(255) NOT NULL DEFAULT '',
		surname varchar(255) NOT NULL DEFAULT '',
		dob date,
		nationality varchar(255),
		url varchar(2048) NOT NULL DEFAULT '',
		nationalityID INT,
		CONSTRAINT PK_driverss_driverId PRIMARY KEY CLUSTERED (driverId ASC)
		WITH
			(
				PAD_INDEX = OFF,
				IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON,
				ALLOW_PAGE_LOCKS = ON
			) ON [PRIMARY]
	) ON [PRIMARY] 
	GO