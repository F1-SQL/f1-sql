
ALTER TABLE dbo.constructorResults ADD CONSTRAINT DF_constructorResults_raceId DEFAULT ((0)) FOR raceId;
ALTER TABLE dbo.constructorResults ADD CONSTRAINT DF_constructorResults_constructorId DEFAULT ((0)) FOR constructorId;
		