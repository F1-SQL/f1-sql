ALTER TABLE dbo.driverNumbers ADD CONSTRAINT DF_driverNumbers_sub DEFAULT ((0)) FOR sub;
ALTER TABLE dbo.driverNumbers ADD CONSTRAINT DF_driverNumbers_retired DEFAULT ((0)) FOR retired;