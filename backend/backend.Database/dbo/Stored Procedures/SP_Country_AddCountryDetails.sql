SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	adds new country entry onto tblCountrySpelling
--EXEC [dbo].[SP_Country_AddCountryDetails] 107,8,1,'india'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Country_AddCountryDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Country_AddCountryDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Country_AddCountryDetails] 
	@configurationId INT,
    @countryId INT,
    @languageId INT,
    @countryName NVARCHAR(MAX)

AS
BEGIN
DECLARE @result INT
    IF EXISTS(select tblCountrySpelling.CountryName from tblCountrySpelling inner join tblCountrySpellingMap on tblCountrySpellingMap.CountrySpellingID = tblCountrySpelling.CountrySpellingID
    where tblCountrySpellingMap.ConfigurationID = @configurationId and tblCountrySpellingMap.isDeleted = 0 and tblCountrySpelling.CountryName = @countryName AND tblCountrySpelling.LanguageID = @languageId)
	BEGIN
	 SET @result = 3
	END
	ELSE
	BEGIN
		   BEGIN TRY
             INSERT INTO dbo.tblCountrySpelling(CountryID, CountryName, LanguageID, doSpellCheck, CustomChangeBitMask) 
	         VALUES(@countryId, @countryName, @languageId , 0, 1)
	         SET  @countryId = SCOPE_IDENTITY()
	         EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblCountrySpelling' , @countryId
			SET @result = 1
			END TRY
			BEGIN CATCH
				SET @result =-1
			END CATCH
	END

	SELECT @result as result

END    
GO  