/*Qual*/
ALTER TABLE [dbo].[qualifying] ADD CONSTRAINT FK_Qualifying_DriverID FOREIGN KEY (driverID) REFERENCES dbo.drivers (driverID);
ALTER TABLE [dbo].[qualifying] ADD CONSTRAINT FK_Qualifying_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID);
ALTER TABLE [dbo].[qualifying] ADD CONSTRAINT FK_Qualifying_ConstructorID FOREIGN KEY (ConstructorID) REFERENCES dbo.constructors (ConstructorID);