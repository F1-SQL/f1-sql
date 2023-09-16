SET
    ANSI_NULLS ON 
    GO
SET
    QUOTED_IDENTIFIER ON 
    GO
CREATE TABLE
    dbo.circuitMap (
        [circuitId] INT NOT NULL,
	[latitude] DECIMAL(8,6) NOT NULL,
	[longitudes] DECIMAL(9,6) NOT NULL,
  [url] varchar(255),
        CONSTRAINT PK_circuitMap_circuitId PRIMARY KEY CLUSTERED (circuitId ASC)
        WITH
            (
                PAD_INDEX = OFF,
                IGNORE_DUP_KEY = OFF,
                ALLOW_ROW_LOCKS = ON,
                ALLOW_PAGE_LOCKS = ON
            ) ON [PRIMARY]
    ) ON [PRIMARY] 
    GO