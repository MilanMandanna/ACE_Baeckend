SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 09/14/2022
-- Description:	Get all modlist data for given configuration id
-- Sample EXEC [dbo].[SP_GetModlistData] 67, 0
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetModlistData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetModlistData]
END
GO

CREATE PROCEDURE [dbo].[SP_GetModlistData]
	@configurationId INT,
	@isDirty INT = 0
AS
BEGIN
		SELECT * FROM dbo.FN_GetModListValues(@configurationId, @isDirty) AS ModListData
END
GO