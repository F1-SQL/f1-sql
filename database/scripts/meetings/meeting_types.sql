ALTER TABLE [dbo].[meetings] ADD type_key INT

GO

UPDATE [dbo].[meetings] 

SET type_key = 2

WHERE meeting_name LIKE '%Grand Prix%'

GO

UPDATE [dbo].[meetings] 

SET type_key = 1

WHERE meeting_name LIKE '%Testing%'