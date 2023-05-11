-- =============================================
-- Author:		Sathya
-- Create date: 30/09/2022
-- Description:	Updates the country spelling
-- =============================================

IF OBJECT_ID('[dbo].[SP_Country_UpdateCountrySpelling]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Country_UpdateCountrySpelling]
END
GO
CREATE PROC SP_Country_UpdateCountrySpelling
	@configurationId INT,
	@spellingId INT,
    @languageId INT,
    @countryName NVARCHAR(MAX)
AS
BEGIN

DECLARE @updatedSpelId INT


	EXEC SP_ConfigManagement_HandleUpdate @configurationId, 'tblCountrySpelling', @spellingId,@updatedSpelId out

	DECLARE @customcountry INT ,@countryexistingvalue INT,@countryupdatedvalue INT
	SET @customcountry =2
	SET @countryexistingvalue = (SELECT CustomChangeBitMask FROM  tblCountrySpelling WHERE tblCountrySpelling.CountrySpellingID=@updatedSpelId)
	SET @countryupdatedvalue =(@countryexistingvalue | @customcountry)

    UPDATE countrySpelling 
    SET countrySpelling.CountryName =  @countryName,countrySpelling.CustomChangeBitMask = @countryupdatedvalue
    FROM 
    tblCountrySpelling AS countrySpelling 
    WHERE countrySpelling.CountrySpellingID = @updatedSpelId 

END