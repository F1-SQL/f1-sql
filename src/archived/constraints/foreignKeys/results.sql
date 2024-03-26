ALTER TABLE [dbo].[Results] ADD CONSTRAINT FK_Results_RaceID FOREIGN KEY (RaceID) REFERENCES dbo.races (RaceID);
ALTER TABLE [dbo].[Results] ADD CONSTRAINT FK_Results_StatusID FOREIGN KEY (StatusID) REFERENCES dbo.[Status] (StatusID);
ALTER TABLE [dbo].[Results] ADD CONSTRAINT FK_Results_PositionTextID FOREIGN KEY (positionTextID) REFERENCES [dbo].[positionText] (positionTextID); 
ALTER TABLE [dbo].[Results] ADD CONSTRAINT FK_Results_ResultTypeID FOREIGN KEY (resultTypeId) REFERENCES [dbo].[resultType] (resultTypeID);
