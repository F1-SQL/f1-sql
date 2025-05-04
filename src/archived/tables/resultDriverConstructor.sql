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
    ) ON [PRIMARY]
    GO