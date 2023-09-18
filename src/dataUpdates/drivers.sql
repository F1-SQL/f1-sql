UPDATE d 

SET d.nationalityID = n.nationalityID 

FROM [dbo].[drivers] d

INNER JOIN [dbo].[nationalities] n ON d.nationality = n.nationality