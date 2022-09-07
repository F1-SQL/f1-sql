/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001 at 09/04/2022 08:08:02
	See https://dbatools.io/Export-DbaScript for more information
*/
USE [f1db]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[results](
	[resultId] [int] NOT NULL,
	[raceId] [int] NOT NULL,
	[driverId] [int] NOT NULL,
	[constructorId] [int] NOT NULL,
	[number] [int] NULL,
	[grid] [int] NOT NULL,
	[position] [int] NULL,
	[positionText] [varchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[positionOrder] [int] NOT NULL,
	[points] [float] NOT NULL,
	[laps] [int] NOT NULL,
	[time] [varchar](255) COLLATE Latin1_General_CI_AS NULL,
	[milliseconds] [int] NULL,
	[fastestLap] [int] NULL,
	[rank] [int] NULL,
	[fastestLapTime] [varchar](255) COLLATE Latin1_General_CI_AS NULL,
	[fastestLapSpeed] [varchar](255) COLLATE Latin1_General_CI_AS NULL,
	[statusId] [int] NOT NULL,
 CONSTRAINT [PK_results_resultId] PRIMARY KEY CLUSTERED 
(
	[resultId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT ((0)) FOR [raceId]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT ((0)) FOR [driverId]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT ((0)) FOR [constructorId]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT ((0)) FOR [grid]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT (NULL) FOR [position]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT ('') FOR [positionText]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT ((0)) FOR [positionOrder]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT ((0)) FOR [points]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT ((0)) FOR [laps]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT (NULL) FOR [time]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT (NULL) FOR [milliseconds]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT (NULL) FOR [fastestLap]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT ((0)) FOR [rank]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT (NULL) FOR [fastestLapTime]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT (NULL) FOR [fastestLapSpeed]
GO
ALTER TABLE [dbo].[results] ADD  DEFAULT ((0)) FOR [statusId]
GO
ALTER TABLE [dbo].[results]  WITH CHECK ADD  CONSTRAINT [FK_results_constructorId] FOREIGN KEY([constructorId])
REFERENCES [dbo].[constructors] ([constructorId])
GO
ALTER TABLE [dbo].[results] CHECK CONSTRAINT [FK_results_constructorId]
GO
ALTER TABLE [dbo].[results]  WITH CHECK ADD  CONSTRAINT [FK_results_driverid] FOREIGN KEY([driverId])
REFERENCES [dbo].[drivers] ([driverId])
GO
ALTER TABLE [dbo].[results] CHECK CONSTRAINT [FK_results_driverid]
GO
ALTER TABLE [dbo].[results]  WITH CHECK ADD  CONSTRAINT [FK_results_raceId] FOREIGN KEY([raceId])
REFERENCES [dbo].[races] ([raceId])
GO
ALTER TABLE [dbo].[results] CHECK CONSTRAINT [FK_results_raceId]
GO
