
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan Abhishek
-- Create date: 08/18/2022
-- Description:	Get the default part number
-- Sample EXEC [dbo].[SP_Default_PartNumber] 7
-- =============================================

IF OBJECT_ID('[dbo].[SP_Default_PartNumber]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Default_PartNumber]
END
GO

CREATE PROCEDURE [dbo].[SP_Default_PartNumber]
	@outputTypeID int
	
    
AS
BEGIN
	DECLARE @partNumberCollectionId INT
	SET @partNumberCollectionId =(select PartNumberCollectionID from tblOutputTypes where OutputTypeID = @outputTypeID )
	select * from tblPartNumber where PartNumberCollectionID = @partNumberCollectionId
END
GO