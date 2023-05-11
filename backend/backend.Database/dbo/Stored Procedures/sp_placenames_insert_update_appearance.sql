-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	inserts or updates the appearance
-- =============================================

GO

IF OBJECT_ID('[dbo].[sp_placenames_insert_update_appearance]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_insert_update_appearance]
END
GO
CREATE PROC sp_placenames_insert_update_appearance
@configurationId INT,
@geoRefId INT,
@appearanceId INT=0,
@isExclude INT =0,
@priority INT,
@modlistinfo [ModListTable] READONLY
AS
BEGIN
IF @appearanceId IS NULL OR @appearanceId=0
BEGIN

DECLARE @max_appearanceId INT=0;--DECLARE @appearanceId INT=0

--SELECT @max_appearanceId=MAX(AppearanceID) FROM tblAppearance(nolock);
--SET IDENTITY_INSERT [dbo].[tblAppearance] ON
INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,0,0,'3.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,0,0,'6.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,0,0,'60.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,0,0,'1620.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,0,0,'2025.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,30,0,'0.9719220000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,60,0,'0.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,120,0,'0.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,240,0,'0.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,480,0,'15.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,960,0,'30.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,1920,0,'75.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,3840,0,'150.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,7680,0,'300.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,15360,0,'600.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;
--SET IDENTITY_INSERT [dbo].[tblAppearance] OFF 
END
ELSE
BEGIN

	declare @updateKey int
	exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblAppearance', @appearanceId, @updateKey out
	UPDATE tblAppearance SET Exclude=@isExclude,Priority=@priority WHERE AppearanceID=@updateKey;
	exec dbo.SP_SetIsDirty @configurationId ,@modlistinfo
END

	
END

GO