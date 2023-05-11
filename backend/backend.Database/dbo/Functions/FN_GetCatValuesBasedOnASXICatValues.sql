-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 20-June-2022
-- Description:	Function to retrieve category ID for AS4XXX based on ASXI4/5 category ID
-- Sample SELECT [dbo].[FN_GetCatValuesBasedOnASXICatValues](11)
-- =============================================

IF OBJECT_ID (N'[dbo].[FN_GetCatValuesBasedOnASXICatValues]', N'FN') IS NOT NULL  
    DROP FUNCTION [dbo].[FN_GetCatValuesBasedOnASXICatValues];  
GO 
CREATE FUNCTION [dbo].[FN_GetCatValuesBasedOnASXICatValues]
	(@asxiCatID INT)
RETURNS INT
AS
BEGIN
	DECLARE @categoryId INT

	IF (@asxiCatID = 1)
		SET @categoryId = 1
	ELSE IF (@asxiCatID = 2)
		SET @categoryId = 3
	ELSE IF (@asxiCatID = 3 OR @asxiCatID = 4 OR @asxiCatID = 11 OR @asxiCatID = 12 OR @asxiCatID = 13 OR @asxiCatID = 14)
		SET @categoryId = 2
	ELSE IF (@asxiCatID = 5)
		SET @categoryId = 4
	ELSE IF (@asxiCatID = 6)
		SET @categoryId = 5
	ELSE IF (@asxiCatID = 7)
		SET @categoryId = 6
	ELSE IF (@asxiCatID = 8)
		SET @categoryId = 7
	ELSE IF (@asxiCatID = 9  OR @asxiCatID = 15 OR @asxiCatID = 16)
		SET @categoryId = 8
	ELSE IF (@asxiCatID = 10)
		SET @categoryId = 9
	ELSE SET @categoryId = 1

	RETURN @categoryId
END
