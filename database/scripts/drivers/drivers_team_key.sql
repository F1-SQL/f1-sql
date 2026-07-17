ALTER TABLE [dbo].[drivers] ADD [team_key] INT;

GO

UPDATE d

	SET d.[team_key] = t.[team_key]

FROM
	[dbo].[drivers]  d 

INNER JOIN [dbo].[teams] t 
	ON d.team_name = t.team_name;

GO

