ALTER TABLE [SequelFormulaNew].[dbo].[weather] ADD ObservationTime TIME

UPDATE [SequelFormulaNew].[dbo].[weather] SET ObservationTime = CAST([date] as time) FROM [SequelFormulaNew].[dbo].[weather]