SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	adds new region entry onto tblRegionSpelling
 --EXEC [dbo].[SP_Region_AddRegionDetails] 107,33,1,'h'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Region_AddRegionDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Region_AddRegionDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Region_AddRegionDetails]
	@configurationId INT,
    @regionId INT,
    @languageId INT,
    @regionName NVARCHAR(MAX)
AS
BEGIN
	DECLARE @SpellingId INT  = 0;
	IF EXISTS(select tblRegionSpelling.regionName FROM tblRegionSpelling INNER JOIN tblRegionSpellingMap ON tblRegionSpellingMap.SpellingID = tblRegionSpelling.SpellingID
    WHERE tblRegionSpellingMap.ConfigurationID = @configurationId AND tblRegionSpellingMap.IsDeleted = 0 AND tblRegionSpelling.regionName = @regionName AND tblRegionSpelling.languageId =@languageId) 
		 BEGIN
		   SET @SpellingId =3
		 END
		ELSE
		 BEGIN
		   BEGIN TRY
             INSERT INTO dbo.tblRegionSpelling (RegionID,RegionName,LanguageId,CustomChangeBitMask)VALUES(@regionId,@regionName,@languageId,1)
	         SET @SpellingId=SCOPE_IDENTITY();
	         EXEC SP_ConfigManagement_HandleAdd @ConfigurationId,'tblRegionSpelling',@SpellingId
			END TRY
			BEGIN CATCH
				SET @SpellingId =-1
			END CATCH
	     END
		 SELECT @SpellingId as SpellingId
    
END    
GO  