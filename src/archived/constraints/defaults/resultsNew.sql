ALTER TABLE dbo.resultsNew ADD CONSTRAINT DF_resultsNew_grid DEFAULT ((0)) FOR [grid];
ALTER TABLE dbo.resultsNew ADD CONSTRAINT DF_resultsNew_positionOrder DEFAULT ((0)) FOR [positionOrder];
ALTER TABLE dbo.resultsNew ADD CONSTRAINT DF_resultsNew_points DEFAULT ((0)) FOR [points];
ALTER TABLE dbo.resultsNew ADD CONSTRAINT DF_resultsNew_laps DEFAULT ((0)) FOR [laps];
ALTER TABLE dbo.resultsNew ADD CONSTRAINT DF_resultsNew_rank DEFAULT ((0)) FOR [rank];
ALTER TABLE dbo.resultsNew ADD CONSTRAINT DF_resultsNew_statusId DEFAULT ((0)) FOR [statusId];