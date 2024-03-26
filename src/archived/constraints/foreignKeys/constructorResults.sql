ALTER TABLE [dbo].[constructorResults] ADD CONSTRAINT FK_ConstructorResults_ConstructorID FOREIGN KEY (constructorID) REFERENCES dbo.constructors (constructorID);
ALTER TABLE [dbo].[constructorResults] ADD CONSTRAINT FK_ConstructorResults_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID);
ALTER TABLE [dbo].[constructorResults] ADD CONSTRAINT FK_ConstructorResults_positionTextID FOREIGN KEY (positionTextID) REFERENCES [dbo].[positionText] (positionTextID);
