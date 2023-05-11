
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Brinda 
-- Create date: 6/1/2022
-- Description:	return the number of rows based on id
-- Sample: EXEC [dbo].[SP_MsuFind]'ECDCACA1-9B8C-4948-9C4E-3B1BEAAE88B0'
-- =============================================
IF OBJECT_ID('[dbo].[SP_MsuFind]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_MsuFind]
END
GO

CREATE PROCEDURE [dbo].[SP_MsuFind]
        @id uniqueidentifier
		
       
AS

BEGIN
		select * from dbo.MsuConfigurations where ID = @id
		
END
GO
