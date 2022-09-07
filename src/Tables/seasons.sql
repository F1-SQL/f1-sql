/*
	Created by RIS-001\Rich using dbatools Export-DbaScript for objects on RIS-001 at 09/04/2022 08:08:02
	See https://dbatools.io/Export-DbaScript for more information
*/
USE [f1db]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[seasons](
	[year] [int] NOT NULL,
	[url] [varchar](2048) COLLATE Latin1_General_CI_AS NOT NULL,
 CONSTRAINT [PK_seasons_year] PRIMARY KEY CLUSTERED 
(
	[year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[seasons] ADD  DEFAULT ((0)) FOR [year]
GO
ALTER TABLE [dbo].[seasons] ADD  DEFAULT ('') FOR [url]
GO
