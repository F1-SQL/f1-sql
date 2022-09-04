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
CREATE TABLE [dbo].[lapTimes](
	[raceId] [int] NOT NULL,
	[driverId] [int] NOT NULL,
	[lap] [int] NOT NULL,
	[position] [int] NULL,
	[time] [varchar](255) COLLATE Latin1_General_CI_AS NULL,
	[milliseconds] [int] NULL,
 CONSTRAINT [PK_lapTimes_raceId_driverId_lap] PRIMARY KEY CLUSTERED 
(
	[raceId] ASC,
	[driverId] ASC,
	[lap] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lapTimes] ADD  DEFAULT (NULL) FOR [position]
GO
ALTER TABLE [dbo].[lapTimes] ADD  DEFAULT (NULL) FOR [time]
GO
ALTER TABLE [dbo].[lapTimes] ADD  DEFAULT (NULL) FOR [milliseconds]
GO
ALTER TABLE [dbo].[lapTimes]  WITH CHECK ADD  CONSTRAINT [FK_lap_times_drivers] FOREIGN KEY([driverId])
REFERENCES [dbo].[drivers] ([driverId])
GO
ALTER TABLE [dbo].[lapTimes] CHECK CONSTRAINT [FK_lap_times_drivers]
GO
ALTER TABLE [dbo].[lapTimes]  WITH CHECK ADD  CONSTRAINT [FK_lap_times_raceId] FOREIGN KEY([raceId])
REFERENCES [dbo].[races] ([raceId])
GO
ALTER TABLE [dbo].[lapTimes] CHECK CONSTRAINT [FK_lap_times_raceId]
GO
