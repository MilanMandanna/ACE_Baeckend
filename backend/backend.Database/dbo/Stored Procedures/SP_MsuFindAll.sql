
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Brinda 
-- Create date: 6/1/2022
-- Description: Get	all details from MsuConfigurations table
-- =============================================
IF OBJECT_ID('[dbo].[SP_MsuFindAll]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_MsuFindAll]
END
GO

CREATE PROCEDURE [dbo].[SP_MsuFindAll]
      
       
AS

BEGIN
		SELECT * FROM dbo.MsuConfigurations
               
END
GO
