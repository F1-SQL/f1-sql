/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001$SQLEXPRESS17 at 08/15/2023 13:21:27
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[circuitTypes](
	[circuitTypeID] [int] NOT NULL,
	[circuitType] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_circuitTypes_circuitTypeID] PRIMARY KEY CLUSTERED 
(
	[circuitTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
