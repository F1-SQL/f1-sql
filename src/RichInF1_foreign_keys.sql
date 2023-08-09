/* FOREIGN KEYS */

/*constructorResults*/
ALTER TABLE constructorResults ADD CONSTRAINT FK_constructorResults_raceId FOREIGN KEY (raceId) REFERENCES dbo.races (raceId);
ALTER TABLE constructorResults ADD CONSTRAINT FK_constructorResults_constructorId FOREIGN KEY (constructorId) REFERENCES dbo.constructors (constructorId);

/*constructor_standings*/
ALTER TABLE constructorstandings ADD CONSTRAINT FK_constructor_standings_raceId FOREIGN KEY (raceId) REFERENCES dbo.races (raceId);
ALTER TABLE constructorstandings ADD CONSTRAINT FK_constructor_standings_constructorId FOREIGN KEY (constructorId) REFERENCES dbo.constructors (constructorId);

/*driver_standings*/
ALTER TABLE driverstandings ADD CONSTRAINT FK_driver_standings_standings_raceId FOREIGN KEY (raceId) REFERENCES dbo.races (raceId);
ALTER TABLE driverstandings ADD CONSTRAINT FK_driver_standings_standings_driverid FOREIGN KEY (driverid) REFERENCES dbo.drivers (driverid);

/*lap_times*/
ALTER TABLE laptimes ADD CONSTRAINT FK_lap_times_raceId FOREIGN KEY (raceId) REFERENCES dbo.races (raceId);
ALTER TABLE laptimes ADD CONSTRAINT FK_lap_times_drivers FOREIGN KEY (driverid) REFERENCES dbo.drivers (driverid);

/*pit_stops*/
ALTER TABLE pitstops ADD CONSTRAINT FK_pit_stops_raceId FOREIGN KEY (raceId) REFERENCES dbo.races (raceId);
ALTER TABLE pitstops ADD CONSTRAINT FK_pit_stops_driverid FOREIGN KEY (driverid) REFERENCES dbo.drivers (driverid);

/*qualifying*/
ALTER TABLE qualifying ADD CONSTRAINT FK_qualifying_raceId FOREIGN KEY (raceId) REFERENCES dbo.races (raceId);
ALTER TABLE qualifying ADD CONSTRAINT FK_qualifying_driverid FOREIGN KEY (driverid) REFERENCES dbo.drivers (driverid);
ALTER TABLE qualifying ADD CONSTRAINT FK_qualifying_constructorId FOREIGN KEY (constructorId) REFERENCES dbo.constructors (constructorId);

/*races*/
ALTER TABLE races ADD CONSTRAINT FK_races_year FOREIGN KEY (year) REFERENCES dbo.seasons (year);
ALTER TABLE races ADD CONSTRAINT FK_races_circuitId FOREIGN KEY (circuitId) REFERENCES dbo.circuits (circuitId);

/*results*/
ALTER TABLE results ADD CONSTRAINT FK_results_raceId FOREIGN KEY (raceId) REFERENCES dbo.races (raceId);
ALTER TABLE results ADD CONSTRAINT FK_results_driverid FOREIGN KEY (driverid) REFERENCES dbo.drivers (driverid);
ALTER TABLE results ADD CONSTRAINT FK_results_constructorId FOREIGN KEY (constructorId) REFERENCES dbo.constructors (constructorId);

/*sprint_results*/
ALTER TABLE sprintresults ADD CONSTRAINT FK_sprint_results_raceId FOREIGN KEY (raceId) REFERENCES dbo.races (raceId);
ALTER TABLE sprintresults ADD CONSTRAINT FK_sprint_results_driverid FOREIGN KEY (driverid) REFERENCES dbo.drivers (driverid);
ALTER TABLE sprintresults ADD CONSTRAINT FK_sprint_results_constructorId FOREIGN KEY (constructorId) REFERENCES dbo.constructors (constructorId);