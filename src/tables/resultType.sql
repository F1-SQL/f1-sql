SET
    ANSI_NULLS ON 
    GO
SET
    QUOTED_IDENTIFIER ON 
    GO
CREATE TABLE
    dbo.resultType (
        [resultTypeID] [int] NOT NULL,
	[resultType] [varchar](255) NULL,
        CONSTRAINT PK_resultType_resultTypeID PRIMARY KEY CLUSTERED (resultTypeID ASC)
        WITH
            (
                PAD_INDEX = OFF,
                IGNORE_DUP_KEY = OFF,
                ALLOW_ROW_LOCKS = ON,
                ALLOW_PAGE_LOCKS = ON
            ) ON [PRIMARY]
    ) ON [PRIMARY] 
    GO