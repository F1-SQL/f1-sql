/*Races*/
ALTER TABLE [dbo].[races] ADD CONSTRAINT FK_Races_Year FOREIGN KEY ([Year]) REFERENCES dbo.Seasons ([Year]);
ALTER TABLE [dbo].[races] ADD CONSTRAINT FK_Races_CircuitID FOREIGN KEY (CircuitID) REFERENCES dbo.circuits (CircuitID);