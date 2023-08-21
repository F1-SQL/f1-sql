/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001$SQLEXPRESS22 at 08/15/2023 13:22:26
	See https://dbatools.io/Export-DbaScript for more information
*/
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
	[positionTextID] [int] NULL,
 CONSTRAINT [PK_results_resultId] PRIMARY KEY CLUSTERED 
(
	[resultId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO