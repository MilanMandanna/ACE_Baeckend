SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 --=============================================
 --Author: Abhishek Narasimha Prasad
 --Create date: 01/10/2022
 --Description:	Updates colors for the compass XML
 --Sample EXEC [dbo].[SP_Compass_RliXML] 35, 'get'
 --=============================================

IF OBJECT_ID('[dbo].[SP_Compass_RliXML]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_RliXML]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_RliXML]
	@configurationId INT,
	@type NVARCHAR(50),
	@xmlValue XML = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		SELECT M.Rli AS xmlData FROM cust.config_tblRLI(@configurationId) AS M 
	END
	ELSE
	BEGIN
		BEGIN TRY
			IF EXISTS (SELECT 1 FROM cust.config_tblRLI(@configurationId))
			BEGIN
				DECLARE @mappedRliId INT	
				DECLARE @updateKey INT
				SET @mappedRliId = (SELECT RLIID FROM cust.tblRliMap WHERE configurationId = @configurationId)

				IF NOT @mappedRliId IS NULL
				BEGIN
					EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblRli', @mappedRliId, @updateKey OUT
					UPDATE R SET Rli = @xmlValue FROM cust.config_tblRLI(@configurationId) AS R WHERE R.RLIID = @updateKey
				END
				SELECT 1 AS retValue
			END
			ELSE
			BEGIN
				DECLARE @compassID INT
				INSERT INTO cust.tblRli (Rli) VALUES (@xmlValue)
				SET @compassID = (SELECT MAX(RLIID) FROM cust.tblRli)
				EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblRli', @compassID
			END
			SELECT 1 AS retValue
		END TRY
		BEGIN CATCH
			SELECT 0 AS retValue
		END CATCH
	END
END

GO