SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	returns list of operators associated with aircrafts 
-- Sample EXEC [dbo].[SP_Aircraft_GetOperators] 'aircraftIds'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Aircraft_GetOperators]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Aircraft_GetOperators]
END
GO

CREATE PROCEDURE [dbo].[SP_Aircraft_GetOperators]
    @aircraftIds VARCHAR(Max)
AS
BEGIN
	SELECT dbo.Operator.* FROM dbo.Operator INNER JOIN dbo.Aircraft ON dbo.Operator.Id = dbo.Aircraft.OperatorId AND dbo.Aircraft.Id IN (@aircraftIds)
END
GO