SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.drivers (
		driverId INT  NOT NULL,
		driverRef varchar(255) NOT NULL,
		number INT,
		code varchar(3),
		forename varchar(255) NOT NULL,
		surname varchar(255) NOT NULL,
		dob date,
		nationality varchar(255),
		url varchar(2048) NOT NULL,
		nationalityID INT,
	) ON [PRIMARY] 
	GO