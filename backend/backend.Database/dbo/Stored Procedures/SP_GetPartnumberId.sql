SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Brinda
-- Create date: 01/31/2023
-- Description:	To get the partnumber id based on filename
-- Sample EXEC [dbo].[SP_GetPartnumberId] 'HD Briefings Config (hdbrfcfg)'
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetPartnumberId]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetPartnumberId]
END
GO

CREATE PROCEDURE [dbo].[SP_GetPartnumberId]
    
	@name NVARCHAR(255)
AS
BEGIN
    select PartNumberID from tblPartNumber where name = @name 
END
GO