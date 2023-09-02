SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[drivers](
	[driverId] [int] NOT NULL,
	[driverRef] [varchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[number] [int] NULL,
	[code] [varchar](3) COLLATE Latin1_General_CI_AS NULL,
	[forename] [varchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[surname] [varchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[dob] [date] NULL,
	[url] [varchar](2048) COLLATE Latin1_General_CI_AS NOT NULL,
	[nationalityID] [int] NULL,
 CONSTRAINT [PK_driverss_driverId] PRIMARY KEY CLUSTERED 
(
	[driverId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
