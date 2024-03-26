ALTER TABLE [SequelFormulaNew].[dbo].[stints] ADD [compound_key] INT

UPDATE s

SET s.compound_key = ct.[compound_key]

FROM [SequelFormulaNew].[dbo].[stints] s 

INNER JOIN [dbo].[compoundTypes] ct ON s.compound = ct.[compound_name]