-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	sets the cat type for given place name
-- =============================================

GO
IF OBJECT_ID('[dbo].[sp_placenames_updatecattype]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_updatecattype]
END
GO
CREATE PROC sp_placenames_updatecattype
@configurationId INT,
@placeNameId INT,
@catTypeId INT,
@modlistinfo [ModListTable] READONLY
AS
BEGIN

declare @updateKey int, @as4xxxCatId INT
DECLARE @TempModListTable TABLE( Id INT,Row INT, Columns INT,Resolution INT)

	exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblGeoRef', @placeNameId, @updateKey out

	SET @as4xxxCatId = (SELECT [dbo].[FN_GetCatValuesBasedOnASXICatValues](@catTypeId))

	UPDATE tblGeoRef SET AsxiCatTypeId=@catTypeId, CatTypeId = @as4xxxCatId WHERE ID=@updateKey;

	exec dbo.SP_SetIsDirty @configurationId ,@modlistinfo
	

END

GO