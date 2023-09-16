SET
	ANSI_NULLS ON 
	GO
SET
	QUOTED_IDENTIFIER ON 
	GO
CREATE TABLE
	dbo.positionText (
		positionTextID INT NOT NULL,
		positionText varchar(50),
		positionCode varchar(3),
		CONSTRAINT PK_positionText_positionTextID PRIMARY KEY CLUSTERED (positionTextID ASC)
		WITH
			(
				PAD_INDEX = OFF,
				IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON,
				ALLOW_PAGE_LOCKS = ON
			) ON [PRIMARY]
	) ON [PRIMARY] 
	GO

INSERT INTO positionText (positionTextID,positionText,positionCode)
VALUES
(1,'1','1'),
(2,'2','2'),
(3,'3','3'),
(4,'4','4'),
(5,'5','5'),
(6,'6','6'),
(7,'7','7'),
(8,'8','8'),
(9,'9','9'),
(10,'10','10'),
(11,'11','11'),
(12,'12','12'),
(13,'13','13'),
(14,'14','14'),
(15,'15','15'),
(16,'16','16'),
(17,'17','17'),
(18,'18','18'),
(19,'19','19'),
(20,'20','20'),
(21,'21','21'),
(22,'22','22'),
(23,'23','23'),
(24,'24','24'),
(25,'25','25'),
(26,'26','26'),
(27,'27','27'),
(28,'28','28'),
(29,'29','29'),
(30,'30','30'),
(31,'31','31'),
(32,'32','32'),
(33,'33','33'),
(600,'Disqualified','D'),
(601,'Excluded','E'),
(602,'Failed To Qualify','F'),
(603,'Not Classified','N'),
(604,'Retired','R'),
(605,'Withdrew','W')