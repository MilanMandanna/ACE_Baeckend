
/****** Object:  StoredProcedure [dbo].[sp_ticker_getalltickerparam]    Script Date: 1/30/2022 9:28:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	get all ticker params
-- Sample EXEC [dbo].[sp_ticker_getalltickerparam]
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_getalltickerparam]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_getalltickerparam]
END
GO

CREATE PROC [dbo].[sp_ticker_getalltickerparam]
AS
BEGIN
SELECT *
                 FROM 
                (SELECT dbo.tblFeatureSet.Value as Name
                FROM dbo.tblFeatureSet
                WHERE dbo.tblFeatureSet.Name = 'CustomConfig-Ticker-ParametersList') as NameTable,
                 (SELECT dbo.tblFeatureSet.Value as DisplayName
                FROM dbo.tblFeatureSet
                WHERE dbo.tblFeatureSet.Name = 'CustomConfig-Ticker-ParametersDisplayList') as DisplayNameTable
END
GO

