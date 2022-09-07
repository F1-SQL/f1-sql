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
CREATE TABLE [dbo].[races](
	[raceId] [int] NOT NULL,
	[year] [int] NOT NULL,
	[round] [int] NOT NULL,
	[circuitId] [int] NOT NULL,
	[name] [varchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[date] [date] NOT NULL,
	[time] [time](7) NULL,
	[url] [varchar](2048) COLLATE Latin1_General_CI_AS NULL,
	[fp1_date] [date] NULL,
	[fp1_time] [time](7) NULL,
	[fp2_date] [date] NULL,
	[fp2_time] [time](7) NULL,
	[fp3_date] [date] NULL,
	[fp3_time] [time](7) NULL,
	[quali_date] [date] NULL,
	[quali_time] [time](7) NULL,
	[sprint_date] [date] NULL,
	[sprint_time] [time](7) NULL,
 CONSTRAINT [PK_races_raceId] PRIMARY KEY CLUSTERED 
(
	[raceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_races_url] UNIQUE NONCLUSTERED 
(
	[url] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT ((0)) FOR [year]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT ((0)) FOR [round]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT ((0)) FOR [circuitId]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT ('') FOR [name]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT ('0000-00-00') FOR [date]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT (NULL) FOR [time]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT (NULL) FOR [url]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT (NULL) FOR [fp1_date]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT (NULL) FOR [fp1_time]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT (NULL) FOR [fp2_date]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT (NULL) FOR [fp2_time]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT (NULL) FOR [fp3_date]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT (NULL) FOR [fp3_time]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT (NULL) FOR [quali_date]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT (NULL) FOR [quali_time]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT (NULL) FOR [sprint_date]
GO
ALTER TABLE [dbo].[races] ADD  DEFAULT (NULL) FOR [sprint_time]
GO
ALTER TABLE [dbo].[races]  WITH CHECK ADD  CONSTRAINT [FK_races_circuitId] FOREIGN KEY([circuitId])
REFERENCES [dbo].[circuits] ([circuitId])
GO
ALTER TABLE [dbo].[races] CHECK CONSTRAINT [FK_races_circuitId]
GO
ALTER TABLE [dbo].[races]  WITH CHECK ADD  CONSTRAINT [FK_races_year] FOREIGN KEY([year])
REFERENCES [dbo].[seasons] ([year])
GO
ALTER TABLE [dbo].[races] CHECK CONSTRAINT [FK_races_year]
GO
