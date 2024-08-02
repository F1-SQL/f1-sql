/*Qual*/
ALTER TABLE [dbo].[qualifying] ADD CONSTRAINT FK_Qualifying_DriverID FOREIGN KEY (driverID) REFERENCES dbo.drivers (driverID)
ALTER TABLE [dbo].[qualifying] ADD CONSTRAINT FK_Qualifying_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID)
ALTER TABLE [dbo].[qualifying] ADD CONSTRAINT FK_Qualifying_ConstructorID FOREIGN KEY (ConstructorID) REFERENCES dbo.constructors (ConstructorID)

/*Races*/
ALTER TABLE [dbo].[races] ADD CONSTRAINT FK_Races_Year FOREIGN KEY ([Year]) REFERENCES dbo.Seasons ([Year])
ALTER TABLE [dbo].[races] ADD CONSTRAINT FK_Races_CircuitID FOREIGN KEY (CircuitID) REFERENCES dbo.circuits (CircuitID)

/*Results*/
ALTER TABLE [dbo].[Results] ADD CONSTRAINT FK_Results_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID)
ALTER TABLE [dbo].[Results] ADD CONSTRAINT FK_Results_StatusID FOREIGN KEY (StatusID) REFERENCES dbo.[Status] (StatusID)
ALTER TABLE [dbo].[Results] ADD CONSTRAINT FK_Results_PositionTextID FOREIGN KEY (positionTextID) REFERENCES [dbo].[positionText] (positionTextID) 
ALTER TABLE [dbo].[Results] ADD CONSTRAINT FK_Results_ResultTypeID FOREIGN KEY (resultTypeId) REFERENCES [dbo].[resultType] (resultTypeID)

/*Pit Stops*/
ALTER TABLE [dbo].[PitStops] ADD CONSTRAINT FK_PitStops_DriverID FOREIGN KEY (driverID) REFERENCES dbo.drivers (driverID)
ALTER TABLE [dbo].[PitStops] ADD CONSTRAINT FK_PitStops_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID)

/*Lap Times*/
ALTER TABLE [dbo].[LapTimes] ADD CONSTRAINT FK_LapTimes_DriverID FOREIGN KEY (driverID) REFERENCES dbo.drivers (driverID)
ALTER TABLE [dbo].[LapTimes] ADD CONSTRAINT FK_LapTimes_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID)

/*Driver Standings*/
ALTER TABLE [dbo].[driverStandings] ADD CONSTRAINT FK_DriverStandings_DriverID FOREIGN KEY (driverID) REFERENCES dbo.drivers (driverID)
ALTER TABLE [dbo].[driverStandings] ADD CONSTRAINT FK_DriverStandings_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID)
ALTER TABLE [dbo].[driverStandings] ADD CONSTRAINT FK_DriverStandings_PositionTextID FOREIGN KEY (positionTextID) REFERENCES [dbo].[positionText] (positionTextID)


/*Constructor Standings*/
ALTER TABLE [dbo].[constructorStandings] ADD CONSTRAINT FK_ConstructorStandings_ConstructorID FOREIGN KEY (constructorID) REFERENCES dbo.constructors (constructorID)
ALTER TABLE [dbo].[constructorStandings] ADD CONSTRAINT FK_ConstructorStandings_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID)
ALTER TABLE [dbo].[constructorStandings] ADD CONSTRAINT FK_ConstructorStandings_PositionTextID FOREIGN KEY (positionTextID) REFERENCES [dbo].[positionText] (positionTextID)

/*Constructor Results*/
ALTER TABLE [dbo].[constructorResults] ADD CONSTRAINT FK_ConstructorResults_ConstructorID FOREIGN KEY (constructorID) REFERENCES dbo.constructors (constructorID)
ALTER TABLE [dbo].[constructorResults] ADD CONSTRAINT FK_ConstructorResults_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID)
ALTER TABLE [dbo].[constructorResults] ADD CONSTRAINT FK_ConstructorResults_positionTextID FOREIGN KEY (positionTextID) REFERENCES [dbo].[positionText] (positionTextID)

/*Circuits */
ALTER TABLE [dbo].[circuits] ADD CONSTRAINT FK_Circuits_CountryID  FOREIGN KEY (CountryID) REFERENCES [dbo].[countries] (CountryID)
ALTER TABLE [dbo].[circuits] ADD CONSTRAINT FK_Circuits_CircuitDirectionID  FOREIGN KEY (circuitDirectionID) REFERENCES [dbo].[circuitDirection] (circuitDirectionID)
ALTER TABLE [dbo].[circuits] ADD CONSTRAINT FK_Circuits_CircuitTypeID  FOREIGN KEY (circuitTypeID) REFERENCES [dbo].[circuitTypes] (circuitTypeID)
ALTER TABLE [dbo].[circuits] ADD CONSTRAINT FK_Circuits_LocationID  FOREIGN KEY (locationID) REFERENCES [dbo].[locations] (locationID)

/*Constructors*/
ALTER TABLE [dbo].[constructors] ADD CONSTRAINT FK_constructors_NationalityID FOREIGN KEY (NationalityID) REFERENCES [dbo].[nationalities] (NationalityID);

/*Drivers*/
ALTER TABLE [dbo].[drivers] ADD CONSTRAINT FK_Drivers_NationalityID FOREIGN KEY (NationalityID) REFERENCES [dbo].[nationalities] (NationalityID);

/*Driver Numbers*/
ALTER TABLE [dbo].[driverNumbers] ADD CONSTRAINT PK_driverNumbers_driverID FOREIGN KEY (driverID) REFERENCES [dbo].[drivers] (driverID);
ALTER TABLE [dbo].[driverNumbers] ADD CONSTRAINT PK_driverNumbers_constructorID FOREIGN KEY (constructorID) REFERENCES [dbo].[constructors] (constructorId);
ALTER TABLE [dbo].[driverNumbers] ADD CONSTRAINT PK_driverNumbers_season FOREIGN KEY (season) REFERENCES [dbo].[seasons](year);

/*resultDriverConstructor*/
ALTER TABLE [dbo].[resultDriverConstructor] ADD CONSTRAINT PK_resultDriverConstructor_resultID FOREIGN KEY (resultID) REFERENCES [dbo].[results] (resultID);
ALTER TABLE [dbo].[resultDriverConstructor] ADD CONSTRAINT PK_resultDriverConstructor_driverID FOREIGN KEY (driverID) REFERENCES [dbo].[drivers] (driverID);
ALTER TABLE [dbo].[resultDriverConstructor] ADD CONSTRAINT PK_resultDriverConstructor_constructorID FOREIGN KEY (constructorID) REFERENCES [dbo].[constructors] (constructorID);

/*circuitMap*/
ALTER TABLE circuitMap ADD CONSTRAINT FK_circuitMap_circuitId FOREIGN KEY (circuitId) REFERENCES [dbo].[circuits] (circuitId);