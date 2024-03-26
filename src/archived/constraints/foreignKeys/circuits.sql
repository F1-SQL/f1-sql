ALTER TABLE [dbo].[circuits] ADD CONSTRAINT FK_Circuits_CountryID  FOREIGN KEY (CountryID) REFERENCES [dbo].[countries] (CountryID);
ALTER TABLE [dbo].[circuits] ADD CONSTRAINT FK_Circuits_CircuitDirectionID  FOREIGN KEY (circuitDirectionID) REFERENCES [dbo].[circuitDirection] (circuitDirectionID);
ALTER TABLE [dbo].[circuits] ADD CONSTRAINT FK_Circuits_CircuitTypeID  FOREIGN KEY (circuitTypeID) REFERENCES [dbo].[circuitTypes] (circuitTypeID);
ALTER TABLE [dbo].[circuits] ADD CONSTRAINT FK_Circuits_LocationID  FOREIGN KEY (locationID) REFERENCES [dbo].[locations] (locationID);