/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001$SQLEXPRESS16 at 08/28/2023 19:27:03
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sprintResults](
	[resultId] [int] NOT NULL,
	[raceId] [int] NOT NULL,
	[driverId] [int] NOT NULL,
	[constructorId] [int] NOT NULL,
	[number] [int] NOT NULL,
	[grid] [int] NOT NULL,
	[position] [int] NULL,
	[positionOrder] [int] NOT NULL,
	[points] [float] NOT NULL,
	[laps] [int] NOT NULL,
	[milliseconds] [int] NULL,
	[fastestLap] [int] NULL,
	[statusId] [int] NOT NULL,
	[positionTextID] [int] NULL,
	[time] [time](3) NULL,
	[fastestLapTime] [time](3) NULL,
 CONSTRAINT [PK_sprintResults_sprintResultId] PRIMARY KEY CLUSTERED 
(
	[resultId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
