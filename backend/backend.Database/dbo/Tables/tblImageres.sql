CREATE TABLE tblImageres(
  ID INT PRIMARY KEY IDENTITY, 
  resolution NVARCHAR(200), 
  IsDefault BIT DEFAULT 0, 
  Description NVARCHAR(MAX)
) 