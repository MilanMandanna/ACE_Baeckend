SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/18/2022
-- Description:	Find the aircraft by using given parameter
-- Sample EXEC [dbo].[SP_Aircraft_Find] 'id','aircraft id'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Aircraft_Find]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Aircraft_Find]
END
GO

CREATE PROCEDURE [dbo].[SP_Aircraft_Find]
	@parameterType VARCHAR(Max),
    @parameter VARCHAR(Max)
AS
BEGIN
	IF(@parameterType = 'id')
	BEGIN
        select * from dbo.aircraft where id = @parameter
    END
    ELSE IF (@parameterType = 'ids')
    BEGIN
       SELECT * FROM dbo.Aircraft WHERE Id IN  (@parameter)
    END
    ELSE IF (@parameterType = 'tailNumber')
    BEGIN
       select * from dbo.aircraft where tailnumber = @parameter
    END
    ELSE IF (@parameterType = 'all')
    BEGIN
       SELECT * FROM dbo.Aircraft WHERE IsDeleted = 0  order by Manufacturer asc
    END
END
GO