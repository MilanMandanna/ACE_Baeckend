SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	This stored procedure calls individual stored procedure to import
--				Asxinfo Data
-- Sample EXEC [dbo].[SP_AsxiInfoImport] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport]
		@configid INT
AS
BEGIN
	DECLARE @ErrorMessage   nvarchar(4000), @ErrorSeverity   int, @ErrorState int, @ErrorLine  int, @ErrorNumber   int; 
	IF OBJECT_ID(N'dbo.AsxiInfotbfont', N'U') IS NOT NULL
	BEGIN TRY
		exec dbo.SP_AsxiInfoImport_font @configid
	END TRY
	BEGIN CATCH
		SELECT  
			@ErrorMessage  = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState    = ERROR_STATE(),  
			@ErrorNumber   = ERROR_NUMBER(),  
			@ErrorLine     = ERROR_LINE() 
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorNumber, @ErrorLine)
	END CATCH;	

	IF OBJECT_ID(N'dbo.AsxiInfotbfontcategory', N'U') IS NOT NULL
	BEGIN TRY
		exec dbo.SP_AsxiInfoImport_FontCategory @configid
	END TRY
	BEGIN CATCH
		SELECT  
			@ErrorMessage  = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState    = ERROR_STATE(),  
			@ErrorNumber   = ERROR_NUMBER(),  
			@ErrorLine     = ERROR_LINE() 
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorNumber, @ErrorLine)
	END CATCH;		

	IF OBJECT_ID(N'dbo.AsxiInfotbfontfamily', N'U') IS NOT NULL
	BEGIN TRY
		exec dbo.SP_AsxiInfoImport_FontFamily @configid
	END TRY
	BEGIN CATCH
		SELECT  
			@ErrorMessage  = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState    = ERROR_STATE(),  
			@ErrorNumber   = ERROR_NUMBER(),  
			@ErrorLine     = ERROR_LINE() 
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorNumber, @ErrorLine)
	END CATCH;		

	IF OBJECT_ID(N'dbo.AsxiInfotbfontmarker', N'U') IS NOT NULL
	BEGIN TRY
		exec dbo.SP_AsxiInfoImport_FontMarker @configid
	END TRY
	BEGIN CATCH
		SELECT  
			@ErrorMessage  = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState    = ERROR_STATE(),  
			@ErrorNumber   = ERROR_NUMBER(),  
			@ErrorLine     = ERROR_LINE() 
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorNumber, @ErrorLine)
	END CATCH;		
	
	IF OBJECT_ID(N'dbo.AsxiInfotbgeorefid', N'U') IS NOT NULL
	BEGIN TRY
		exec dbo.SP_AsxiInfoImport_GeoRef @configid
	END TRY
	BEGIN CATCH
		SELECT  
			@ErrorMessage  = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState    = ERROR_STATE(),  
			@ErrorNumber   = ERROR_NUMBER(),  
			@ErrorLine     = ERROR_LINE() 
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorNumber, @ErrorLine)
	END CATCH;		

	IF OBJECT_ID(N'dbo.AsxiInfotbinfospelling', N'U') IS NOT NULL
	BEGIN TRY
		exec dbo.SP_AsxiInfoImport_InfoSpelling @configid
	END TRY
	BEGIN CATCH
		SELECT  
			@ErrorMessage  = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState    = ERROR_STATE(),  
			@ErrorNumber   = ERROR_NUMBER(),  
			@ErrorLine     = ERROR_LINE() 
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorNumber, @ErrorLine)
	END CATCH;		

	IF OBJECT_ID(N'dbo.AsxiInfotblanguage', N'U') IS NOT NULL
	BEGIN TRY
		exec dbo.SP_AsxiInfoImport_Language @configid
	END TRY
	BEGIN CATCH
		SELECT  
			@ErrorMessage  = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState    = ERROR_STATE(),  
			@ErrorNumber   = ERROR_NUMBER(),  
			@ErrorLine     = ERROR_LINE() 
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorNumber, @ErrorLine)
	END CATCH;		

	IF OBJECT_ID(N'dbo.AsxiInfotbregion', N'U') IS NOT NULL
	BEGIN TRY
		exec dbo.SP_AsxiInfoImport_Region @configid
	END TRY
	BEGIN CATCH
		SELECT  
			@ErrorMessage  = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState    = ERROR_STATE(),  
			@ErrorNumber   = ERROR_NUMBER(),  
			@ErrorLine     = ERROR_LINE() 
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorNumber, @ErrorLine)
	END CATCH;		

	IF OBJECT_ID(N'dbo.AsxiInfotbcountry', N'U') IS NOT NULL
	BEGIN TRY
		exec dbo.SP_AsxiInfoImport_Country @configid
	END TRY
	BEGIN CATCH
		SELECT  
			@ErrorMessage  = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState    = ERROR_STATE(),  
			@ErrorNumber   = ERROR_NUMBER(),  
			@ErrorLine     = ERROR_LINE() 
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorNumber, @ErrorLine)
	END CATCH;		

	IF OBJECT_ID(N'dbo.AsxiInfotbairportinfo', N'U') IS NOT NULL
	BEGIN TRY
		exec dbo.SP_AsxiInfoImport_AirportInfo @configid
	END TRY
	BEGIN CATCH
		SELECT  
			@ErrorMessage  = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState    = ERROR_STATE(),  
			@ErrorNumber   = ERROR_NUMBER(),  
			@ErrorLine     = ERROR_LINE() 
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorNumber, @ErrorLine)
	END CATCH;			
	
	BEGIN
		IF OBJECT_ID(N'dbo.AsxiInfotbfont', N'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AsxiInfotbfont
		END
	
		IF OBJECT_ID(N'dbo.AsxiInfotbfontcategory', N'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AsxiInfotbfontcategory
		END
	
		IF OBJECT_ID(N'dbo.AsxiInfotbfontfamily', N'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AsxiInfotbfontfamily
		END
	
		IF OBJECT_ID(N'dbo.AsxiInfotbfontmarker', N'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AsxiInfotbfontmarker
		END
	
		IF OBJECT_ID(N'dbo.AsxiInfotbgeorefid', N'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AsxiInfotbgeorefid
		END
	
		IF OBJECT_ID(N'dbo.AsxiInfotbinfospelling', N'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AsxiInfotbinfospelling
		END
	
		IF OBJECT_ID(N'dbo.AsxiInfotblanguage', N'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AsxiInfotblanguage
		END
	
		IF OBJECT_ID(N'dbo.AsxiInfotbregion', N'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AsxiInfotbregion
		END
	
		IF OBJECT_ID(N'dbo.AsxiInfotbcountry', N'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AsxiInfotbcountry
		END
	
		IF OBJECT_ID(N'dbo.AsxiInfotbairportinfo', N'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AsxiInfotbairportinfo
		END	
		
		IF OBJECT_ID(N'dbo.AsxiInfotbgeorefidcategorytype', N'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AsxiInfotbgeorefidcategorytype
		END			
		
		IF OBJECT_ID(N'dbo.AsxiInfotbtzstrip', N'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AsxiInfotbtzstrip
		END			
	END
END