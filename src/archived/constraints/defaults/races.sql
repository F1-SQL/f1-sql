ALTER TABLE dbo.races ADD CONSTRAINT DF_races_year DEFAULT ((0)) FOR year;
ALTER TABLE dbo.races ADD CONSTRAINT DF_races_round DEFAULT ((0)) FOR round;
ALTER TABLE dbo.races ADD CONSTRAINT DF_races_circuitId DEFAULT ((0)) FOR circuitId;