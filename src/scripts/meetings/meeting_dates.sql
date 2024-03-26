ALTER TABLE [SequelFormulaNew].[dbo].[meetings] ADD time_start TIME

UPDATE m

SET m.date_start = CAST([date_start] as date)

FROM [SequelFormulaNew].[dbo].[meetings] m

UPDATE m

SET m.time_start = CAST([date_start] as time)

FROM [SequelFormulaNew].[dbo].[meetings] m