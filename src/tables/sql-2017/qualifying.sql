/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001$SQLEXPRESS17 at 08/15/2023 13:21:28
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[qualifying](
	[qualifyId] [int] NOT NULL,
	[raceId] [int] NOT NULL,
	[driverId] [int] NOT NULL,
	[constructorId] [int] NOT NULL,
	[number] [int] NOT NULL,
	[position] [int] NULL,
	[q1] [varchar](255) COLLATE Latin1_General_CI_AS NULL,
	[q2] [varchar](255) COLLATE Latin1_General_CI_AS NULL,
	[q3] [varchar](255) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_qualifying_qualifyId] PRIMARY KEY CLUSTERED 
(
	[qualifyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
