/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001$SQLEXPRESS17 at 08/28/2023 19:27:37
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
	[q1] [time](3) NULL,
	[q2] [time](3) NULL,
	[q3] [time](3) NULL,
 CONSTRAINT [PK_qualifying_qualifyId] PRIMARY KEY CLUSTERED 
(
	[qualifyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
