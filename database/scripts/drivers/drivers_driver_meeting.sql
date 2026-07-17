CREATE TABLE [dbo].[driverMeeting]
(
[driver_key] INT NOT NULL,
[meeting_key] INT NOT NULL
);

GO

INSERT INTO [dbo].[driverMeeting] ([driver_key],[meeting_key])
SELECT DISTINCT
	[driver_key],
	[meeting_key]
FROM	
	[dbo].[drivers];