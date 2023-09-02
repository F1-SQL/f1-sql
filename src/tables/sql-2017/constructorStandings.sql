SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[constructorStandings](
	[constructorStandingsId] [int] NOT NULL,
	[raceId] [int] NOT NULL,
	[constructorId] [int] NOT NULL,
	[points] [float] NOT NULL,
	[position] [int] NULL,
	[wins] [int] NOT NULL,
	[positionTextID] [int] NULL,
 CONSTRAINT [PK_constructorStandings_constructorResultsId] PRIMARY KEY CLUSTERED 
(
	[constructorStandingsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
