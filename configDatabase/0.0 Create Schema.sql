Create database RichInF1Config;


CREATE TABLE Package 
(
	PackageID INT IDENTITY(1,1),
	PackageName varchar(100),
	PackageGUID UNIQUEIDENTIFIER,
	Description varchar(100)
)

ALTER TABLE Package ADD CONSTRAINT PK_Package_PackageID PRIMARY KEY (PackageID);

CREATE TABLE PackageConfig 
(
	PackageID INT NOT NULL,
	ConfigName varchar(50) NOT NULL,
	ConfigValue varchar(500) NULL
)

ALTER TABLE PackageConfig ADD CONSTRAINT PK_PackageConfig_PackageID PRIMARY KEY (PackageID);

INSERT INTO PackageConfig (PackageID,ConfigName)
VALUES
(1,'BasePath'),
(1,'CircuitsFileName'),
(1,'ConstructorsFileName'),
(1,'DriverFileName')