
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================2
-- Author:		Abhishek PM
-- Create date:13 /1/2023
-- Description:	Get the partnumber collection id
-- Sample EXEC [dbo].[SP_GetPartNumberCollection] 5037
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetPartNumberCollection]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetPartNumberCollection]
END
GO

CREATE PROCEDURE [dbo].[SP_GetPartNumberCollection]
    @outputTypeID int 
	
    
AS
BEGIN
	
    select  PartNumberCollectionID from tblOutputTypes where OutputTypeID =@outputTypeID

END
GO