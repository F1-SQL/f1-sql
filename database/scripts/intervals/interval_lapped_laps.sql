ALTER TABLE [dbo].[intervals] ADD lapped_laps INT;

GO

UPDATE [dbo].[intervals]

SET lapped_laps = REPLACE(REPLACE(REPLACE(REPLACE([interval],'+',''),'LAPS',''),'LAP',''),'L','')

WHERE ([interval] LIKE '%lap%' OR [interval] LIKE '%L');

GO

UPDATE [dbo].[intervals]
	SET [interval] = NULL
WHERE ([interval] LIKE '%lap%' OR [interval] LIKE '%L');