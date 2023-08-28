/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001$SQLEXPRESS17 at 08/28/2023 19:27:37
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[nationalities](
	[nationalityID] [int] NOT NULL,
	[nationality] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_nationalities_nationalityID] PRIMARY KEY CLUSTERED 
(
	[nationalityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
