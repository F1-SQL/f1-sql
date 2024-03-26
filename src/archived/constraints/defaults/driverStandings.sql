ALTER TABLE dbo.driverStandings ADD CONSTRAINT DF_driverStandings_raceId DEFAULT ((0)) FOR raceId;
ALTER TABLE dbo.driverStandings ADD CONSTRAINT DF_driverStandings_driverId DEFAULT ((0)) FOR driverId;
ALTER TABLE dbo.driverStandings ADD CONSTRAINT DF_driverStandings_points DEFAULT ((0)) FOR points;
ALTER TABLE dbo.driverStandings ADD CONSTRAINT DF_driverStandings_wins DEFAULT ((0)) FOR wins;