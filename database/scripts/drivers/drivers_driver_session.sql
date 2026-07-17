CREATE TABLE [dbo].[driverSession]
(
[driver_key] INT NOT NULL,
[session_key] INT NOT NULL
);

GO

INSERT INTO [dbo].[driverSession] ([driver_key],[session_key])
SELECT DISTINCT
	[driver_key],
	[session_key]
FROM	
	[dbo].[drivers]