/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001$SQLEXPRESS22 at 08/28/2023 19:28:44
	See https://dbatools.io/Export-DbaScript for more information
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[circuitDirection](
	[circuitDirectionID] [int] NOT NULL,
	[circuitDirection] [varchar](255) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_circuitDirection_circuitDirectionID] PRIMARY KEY CLUSTERED 
(
	[circuitDirectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
