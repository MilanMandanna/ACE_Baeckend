-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 19-Sep-2022
-- Description:	Function to get all values from modlist table
-- Sample SELECT * from [dbo].[FN_GetModListValues](67, 1)
-- =============================================

IF EXISTS (SELECT 1
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'[dbo].[FN_GetModListValues]')
                  AND TYPE IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
    DROP FUNCTION [dbo].[FN_GetModListValues];  
GO 
CREATE FUNCTION [dbo].[FN_GetModListValues]
	(
		@configurationId INT,
		@isDirty BIT
	)
	RETURNS TABLE 
AS
RETURN 
(
	SELECT M.*
	FROM tblModList M
		INNER JOIN tblModListMap MM
	ON M.ModlistID = MM.ModlistID
	WHERE MM.ConfigurationID = @configurationId AND M.isDirty = @isDirty AND MM.IsDeleted = 0 AND M.FileJSON IS NOT NULL
)