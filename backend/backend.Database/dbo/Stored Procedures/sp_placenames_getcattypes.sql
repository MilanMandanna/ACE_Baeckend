-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	returns the place name cat type
-- =============================================

GO
IF OBJECT_ID('[dbo].[sp_placenames_getcattypes]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_getcattypes]
END
GO
CREATE PROC sp_placenames_getcattypes
@placeNameId INT,
@configurationId INT
AS
BEGIN

DECLARE @catId INT =0

select @catId=AsxiCatTypeId from config_tblGeoRef(@configurationId) WHERE ID=@placeNameId

SELECT CategoryTypeID,Description,
CASE WHEN CategoryTypeID=@catId THEN 1
ELSE 0 END AS isSelected
FROM tblCategoryType A 

END

GO