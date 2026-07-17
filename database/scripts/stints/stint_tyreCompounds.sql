ALTER TABLE [dbo].[stints] ADD [compound_key] INT;

GO

UPDATE s

SET s.compound_key = ct.[compound_key]

FROM [dbo].[stints] s 

INNER JOIN [dbo].[compoundTypes] ct ON s.compound = ct.[compound_name]