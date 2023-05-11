
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Mohan Abhishek Padinarapurayil	
-- Create date: 5/24/2022
-- Description:	this will return column names based on the table name given
--Sample EXEC: [dbo].[SP_GetScopeValueForUser]
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetScopeValueForUser]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetScopeValueForUser]
END
GO
CREATE PROCEDURE [dbo].[SP_GetScopeValueForUser]		
AS
BEGIN

		SELECT Column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'UserRoleClaims'
		
END
GO
