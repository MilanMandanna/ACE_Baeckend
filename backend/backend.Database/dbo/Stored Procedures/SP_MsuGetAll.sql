
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Brinda
-- Create date: 6/1/2022
-- Description:	this sp will returns the number of rows based on aircraftId
-- Sample:EXEC [dbo].[SP_MsuGetAll] '65193C7A-F8BB-46A4-8EC8-E089A19EAE3B'
-- =============================================
IF OBJECT_ID('[dbo].[SP_MsuGetAll]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_MsuGetAll]
END
GO

CREATE PROCEDURE [dbo].[SP_MsuGetAll]
       @aircraftid NVARCHAR(100)
       
AS

BEGIN
		
      SELECT * FROM dbo.MsuConfigurations where tailnumber = @aircraftid          
		
END
GO

