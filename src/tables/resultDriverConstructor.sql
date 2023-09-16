SET
    ANSI_NULLS ON 
    GO
SET
    QUOTED_IDENTIFIER ON 
    GO
CREATE TABLE
    dbo.resultDriverConstructor (
        [resultDriverConstructorID] INT IDENTITY(1,1) NOT NULL,
[resultID] INT NOT NULL,
[driverID] INT NOT NULL,
[constructorID] INT NOT NULL,
        CONSTRAINT PK_resultDriverConstructor_resultDriverConstructorID PRIMARY KEY CLUSTERED (resultDriverConstructorID ASC)
        WITH
            (
                PAD_INDEX = OFF,
                STATISTICS_NORECOMPUTE = OFF,
                IGNORE_DUP_KEY = OFF,
                ALLOW_ROW_LOCKS = ON,
                ALLOW_PAGE_LOCKS = ON
            ) ON [PRIMARY]
    ) ON [PRIMARY]
    GO