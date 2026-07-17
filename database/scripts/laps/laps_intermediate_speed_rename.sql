EXEC sp_rename 'dbo.laps.i1_speed', 'first_intermediate_speed', 'COLUMN';

GO

EXEC sp_rename 'dbo.laps.i2_speed', 'second_intermediate_speed', 'COLUMN';
