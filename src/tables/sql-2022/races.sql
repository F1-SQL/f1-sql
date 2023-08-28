/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001$SQLEXPRESS22 at 08/28/2023 19:28:47
	See https://dbatools.io/Export-DbaScript for more information
*/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
