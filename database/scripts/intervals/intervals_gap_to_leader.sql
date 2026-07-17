ALTER TABLE [dbo].[intervals] ADD laps_to_leader INT;

GO

UPDATE [dbo].[intervals]

SET laps_to_leader = REPLACE(REPLACE(REPLACE(REPLACE([gap_to_leader],'+',''),'LAPS',''),'LAP',''),'L','')

WHERE (gap_to_leader LIKE '%lap%' OR gap_to_leader LIKE '%L');

GO

UPDATE [dbo].[intervals]
	SET [gap_to_leader] = NULL
WHERE (gap_to_leader LIKE '%lap%' OR gap_to_leader LIKE '%L');