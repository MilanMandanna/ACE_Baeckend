-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Returns list of all the countries for the given configuration
-- =============================================
IF OBJECT_ID('[dbo].[SP_Country_GetAll]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Country_GetAll]
END
GO

CREATE PROCEDURE [dbo].[SP_Country_GetAll]
	@configurationId int
AS
BEGIN
   
  SELECT ID AS CountryID,Description,CountryCode,ISO3166Code,RegionID
  FROM dbo.config_tblCountry(@configurationId) ORDER BY Description ASC

END

GO