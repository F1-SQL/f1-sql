ALTER TABLE [dbo].[sessions] ADD [type_key] INT;

GO

UPDATE s 

SET s.type_key = st.[session_type_key]

FROM [dbo].[sessions] s

INNER JOIN [dbo].[sessionTypes] st ON s.session_type = st.[type_name]