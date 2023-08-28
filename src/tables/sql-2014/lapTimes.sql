/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001$SQLEXPRESS14 at 08/28/2023 19:26:21
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[lapTimes](
	[raceId] [int] NOT NULL,
	[driverId] [int] NOT NULL,
	[lap] [int] NOT NULL,
	[position] [int] NULL,
	[milliseconds] [int] NULL,
	[time] [time](3) NULL,
 CONSTRAINT [PK_lapTimes_raceId_driverId_lap] PRIMARY KEY CLUSTERED 
(
	[raceId] ASC,
	[driverId] ASC,
	[lap] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
