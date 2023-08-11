/*Qual*/
ALTER TABLE [dbo].[qualifying] ADD CONSTRAINT FK_Qualifying_DriverID FOREIGN KEY (driverID) REFERENCES dbo.drivers (driverID)
ALTER TABLE [dbo].[qualifying] ADD CONSTRAINT FK_Qualifying_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID)
ALTER TABLE [dbo].[qualifying] ADD CONSTRAINT FK_Qualifying_ConstructorID FOREIGN KEY (ConstructorID) REFERENCES dbo.constructors (ConstructorID)

/*Races*/
ALTER TABLE [dbo].[races] ADD CONSTRAINT FK_Races_Year FOREIGN KEY ([Year]) REFERENCES dbo.Seasons ([Year])
ALTER TABLE [dbo].[races] ADD CONSTRAINT FK_Races_CircuitID FOREIGN KEY (CircuitID) REFERENCES dbo.circuits (CircuitID)

/*Sprint Results*/
ALTER TABLE [dbo].[sprintResults] ADD CONSTRAINT FK_SprintResults_DriverID FOREIGN KEY (driverID) REFERENCES dbo.drivers (driverID)
ALTER TABLE [dbo].[sprintResults] ADD CONSTRAINT FK_SprintResults_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID)
ALTER TABLE [dbo].[sprintResults] ADD CONSTRAINT FK_SprintResults_ConstructorID FOREIGN KEY (ConstructorID) REFERENCES dbo.constructors (ConstructorID)
ALTER TABLE [dbo].[sprintResults] ADD CONSTRAINT FK_SprintResults_StatusID FOREIGN KEY (StatusID) REFERENCES dbo.[Status] (StatusID)

/*Results*/
ALTER TABLE [dbo].[Results] ADD CONSTRAINT FK_Results_DriverID FOREIGN KEY (driverID) REFERENCES dbo.drivers (driverID)
ALTER TABLE [dbo].[Results] ADD CONSTRAINT FK_Results_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID)
ALTER TABLE [dbo].[Results] ADD CONSTRAINT FK_Results_ConstructorID FOREIGN KEY (ConstructorID) REFERENCES dbo.constructors (ConstructorID)
ALTER TABLE [dbo].[Results] ADD CONSTRAINT FK_Results_StatusID FOREIGN KEY (StatusID) REFERENCES dbo.[Status] (StatusID)

/*Pit Stops*/
ALTER TABLE [dbo].[PitStops] ADD CONSTRAINT FK_PitStops_DriverID FOREIGN KEY (driverID) REFERENCES dbo.drivers (driverID)
ALTER TABLE [dbo].[PitStops] ADD CONSTRAINT FK_PitStops_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID)

/*Lap Times*/
ALTER TABLE [dbo].[LapTimes] ADD CONSTRAINT FK_LapTimes_DriverID FOREIGN KEY (driverID) REFERENCES dbo.drivers (driverID)
ALTER TABLE [dbo].[LapTimes] ADD CONSTRAINT FK_LapTimes_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID)

/*Driver Standings*/
ALTER TABLE [dbo].[driverStandings] ADD CONSTRAINT FK_DriverStandings_DriverID FOREIGN KEY (driverID) REFERENCES dbo.drivers (driverID)
ALTER TABLE [dbo].[driverStandings] ADD CONSTRAINT FK_DriverStandings_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID)

/*Constructor Standings*/
ALTER TABLE [dbo].[constructorStandings] ADD CONSTRAINT FK_ConstructorStandings_ConstructorID FOREIGN KEY (constructorID) REFERENCES dbo.constructors (constructorID)
ALTER TABLE [dbo].[constructorStandings] ADD CONSTRAINT FK_ConstructorStandings_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID)

/*Constructor Results*/
ALTER TABLE [dbo].[constructorResults] ADD CONSTRAINT FK_ConstructorResults_ConstructorID FOREIGN KEY (constructorID) REFERENCES dbo.constructors (constructorID)
ALTER TABLE [dbo].[constructorResults] ADD CONSTRAINT FK_ConstructorResults_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID)