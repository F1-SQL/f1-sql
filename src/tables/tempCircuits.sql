SET
    ANSI_NULLS ON 
    GO
SET
    QUOTED_IDENTIFIER ON 
    GO
CREATE TABLE
    dbo.tempCircuits (
        [Circuit] [nvarchar](50) NOT NULL,
        [circuitTypeID] [tinyint] NOT NULL,
        [circuitDirectionID] [tinyint] NOT NULL,
        [Location] [nvarchar](50) NOT NULL,
        [Country] [nvarchar](50) NOT NULL,
        [LastLengthUsed] [nvarchar](50) NOT NULL,
        [GrandsPrix] [nvarchar](50) NOT NULL,
        [Season] [nvarchar](150) NOT NULL,
        [GrandsPrixHeld] [tinyint] NOT NULL
    ) ON [PRIMARY] 
	GO