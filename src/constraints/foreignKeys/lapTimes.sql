ALTER TABLE [dbo].[LapTimes] ADD CONSTRAINT FK_LapTimes_DriverID FOREIGN KEY (driverID) REFERENCES dbo.drivers (driverID);
ALTER TABLE [dbo].[LapTimes] ADD CONSTRAINT FK_LapTimes_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID);
