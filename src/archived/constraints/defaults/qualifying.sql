ALTER TABLE dbo.qualifying ADD CONSTRAINT DF_qualifying_raceId DEFAULT ((0)) FOR raceId;
ALTER TABLE dbo.qualifying ADD CONSTRAINT DF_qualifying_driverId DEFAULT ((0)) FOR driverId;
ALTER TABLE dbo.qualifying ADD CONSTRAINT DF_qualifying_constructorId DEFAULT ((0)) FOR constructorId;
ALTER TABLE dbo.qualifying ADD CONSTRAINT DF_qualifying_number DEFAULT ((0)) FOR number;