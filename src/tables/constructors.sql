SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.constructors (
		constructorId INT  NOT NULL,
		constructorRef varchar(255) NOT NULL DEFAULT '',
		name varchar(255) NOT NULL DEFAULT '',
		nationality varchar(255),
		url varchar(2048) NOT NULL DEFAULT '',
		nationalityID INT,
		CONSTRAINT PK_constructors_constructorId PRIMARY KEY CLUSTERED (constructorId ASC)
		WITH
			(
				PAD_INDEX = OFF,
				IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON,
				ALLOW_PAGE_LOCKS = ON
			) ON [PRIMARY]
	) ON [PRIMARY] 
	GO