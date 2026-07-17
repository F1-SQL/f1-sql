CREATE TABLE [dbo].[driverTeam]
(
[driver_key] INT NOT NULL,
[team_key] INT NOT NULL,
[meeting_key] INT NOT NULL,
[session_key] INT NOT NULL
);

GO

INSERT INTO [dbo].[driverTeam] ([driver_key],[team_key],[meeting_key],[session_key])
SELECT DISTINCT
	driver_key,
	team_key,
  meeting_key,
  session_key
FROM	
	[dbo].[drivers]
WHERE team_key IS NOT NULL