SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.constructors (
		constructorId INT  NOT NULL,
		constructorRef varchar(255) NOT NULL,
		name varchar(255) NOT NULL,
		nationality varchar(255),
		url varchar(2048) NOT NULL,
		nationalityID INT,
	) ON [PRIMARY] 
	GO