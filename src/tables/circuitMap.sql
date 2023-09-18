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
    ) ON [PRIMARY] 
    GO