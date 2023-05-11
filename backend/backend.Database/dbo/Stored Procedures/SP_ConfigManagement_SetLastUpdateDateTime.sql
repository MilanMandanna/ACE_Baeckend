-- =============================================
-- Author:		Sathya
-- Create date: 06/24/2022
-- Description:	Updating the last updated date time for the given config id when it is modified.
-- =============================================

GO
IF OBJECT_ID('[dbo].[SP_ConfigManagement_SetLastUpdateDateTime]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_SetLastUpdateDateTime]
END
GO
CREATE PROC SP_ConfigManagement_SetLastUpdateDateTime
@configurationId int
AS
BEGIN
	UPDATE tblConfigurations SET LastUpdateDateTime=GETDATE() WHERE ConfigurationID=@configurationId
END
GO