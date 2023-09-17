ALTER TABLE dbo.constructorStandings ADD CONSTRAINT DF_constructorStandings_raceId DEFAULT ((0)) FOR raceId;
ALTER TABLE dbo.constructorStandings ADD CONSTRAINT DF_constructorStandings_constructorId DEFAULT ((0)) FOR constructorId;
ALTER TABLE dbo.constructorStandings ADD CONSTRAINT DF_constructorStandings_points DEFAULT ((0)) FOR points;
ALTER TABLE dbo.constructorStandings ADD CONSTRAINT DF_constructorStandings_wins DEFAULT ((0)) FOR wins;