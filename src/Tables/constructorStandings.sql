/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001 at 09/04/2022 08:08:01
	See https://dbatools.io/Export-DbaScript for more information
*/
USE [f1db]
GO
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
	[positionText] [varchar](255) COLLATE Latin1_General_CI_AS NULL,
	[wins] [int] NOT NULL,
 CONSTRAINT [PK_constructorStandings_constructorResultsId] PRIMARY KEY CLUSTERED 
(
	[constructorStandingsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[constructorStandings] ADD  DEFAULT ((0)) FOR [raceId]
GO
ALTER TABLE [dbo].[constructorStandings] ADD  DEFAULT ((0)) FOR [constructorId]
GO
ALTER TABLE [dbo].[constructorStandings] ADD  DEFAULT ((0)) FOR [points]
GO
ALTER TABLE [dbo].[constructorStandings] ADD  DEFAULT (NULL) FOR [position]
GO
ALTER TABLE [dbo].[constructorStandings] ADD  DEFAULT (NULL) FOR [positionText]
GO
ALTER TABLE [dbo].[constructorStandings] ADD  DEFAULT ((0)) FOR [wins]
GO
ALTER TABLE [dbo].[constructorStandings]  WITH CHECK ADD  CONSTRAINT [FK_constructor_standings_constructorId] FOREIGN KEY([constructorId])
REFERENCES [dbo].[constructors] ([constructorId])
GO
ALTER TABLE [dbo].[constructorStandings] CHECK CONSTRAINT [FK_constructor_standings_constructorId]
GO
ALTER TABLE [dbo].[constructorStandings]  WITH CHECK ADD  CONSTRAINT [FK_constructor_standings_raceId] FOREIGN KEY([raceId])
REFERENCES [dbo].[races] ([raceId])
GO
ALTER TABLE [dbo].[constructorStandings] CHECK CONSTRAINT [FK_constructor_standings_raceId]
GO