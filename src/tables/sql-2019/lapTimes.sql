SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[lapTimes](
	[raceId] [int] NOT NULL,
	[driverId] [int] NOT NULL,
	[lap] [int] NOT NULL,
	[position] [int] NULL,
	[milliseconds] [int] NULL,
	[time] [time](3) NULL,
 CONSTRAINT [PK_lapTimes_raceId_driverId_lap] PRIMARY KEY CLUSTERED 
(
	[raceId] ASC,
	[driverId] ASC,
	[lap] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
