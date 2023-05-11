SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/18/2022
-- Description:	returns list of cities in the asxiinset table for given configuration id 
-- Sample EXEC [dbo].[SP_AsxiInset_GetCities] '1','all'
-- =============================================

IF OBJECT_ID('[dbo].[SP_AsxiInset_GetCities]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInset_GetCities]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInset_GetCities]
    @configurationId Int,
	@type VARCHAR(250),
	@cityType NVARCHAR(200) = ''
AS
BEGIN
	IF (@type = 'all')
	BEGIN
		IF (@cityType = 'hf')
		BEGIN
			SELECT DISTINCT inset.ASXiInsetID,inset.InsetName,ISNULL(inset.IsHf, 0) AS IsHF,ISNULL(inset.IsUHf, 0) AS IsUHf 
			FROM dbo.config_tblASXiInset(1) as inset WHERE inset.IsHf = 1
		END
		ELSE IF (@cityType = 'uhf')
		BEGIN
			SELECT DISTINCT inset.ASXiInsetID,inset.InsetName,ISNULL(inset.IsHf, 0) AS IsHF,ISNULL(inset.IsUHf, 0) AS IsUHf
			FROM dbo.config_tblASXiInset(1) as inset WHERE INSET.IsUHf = 15
		END
	END	
	ELSE IF(@type = 'hf')
	BEGIN
		SELECT DISTINCT inset.ASXiInsetID,inset.InsetName,inset.IsHf FROM dbo.config_tblASXiInset(@configurationId) as inset WHERE inset.IsHf = 1
	END	
	ELSE IF(@type = 'uhf')
	BEGIN
		SELECT DISTINCT inset.ASXiInsetID,inset.InsetName,inset.IsUHf FROM dbo.config_tblASXiInset(@configurationId) as inset WHERE inset.IsUHf = 1
	END
END
GO