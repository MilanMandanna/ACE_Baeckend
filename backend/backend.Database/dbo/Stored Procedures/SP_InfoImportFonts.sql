SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	This stored procedure calls individual stored procedure to import
--				fonts
-- Sample EXEC [dbo].[SP_AsxiInfoImport] 201
-- =============================================
IF OBJECT_ID('[dbo].[SP_InfoImportFonts]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_InfoImportFonts]
END
GO

CREATE PROCEDURE [dbo].[SP_InfoImportFonts]
		@configid INT
AS
BEGIN
	DECLARE @ErrorMessage   nvarchar(4000), @ErrorSeverity   int, @ErrorState int, @ErrorLine  int, @ErrorNumber   int; 
	IF OBJECT_ID(N'dbo.tblTempFonts', N'U') IS NOT NULL
	BEGIN TRY
		exec dbo.SP_Import_font @configid
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

	IF OBJECT_ID(N'dbo.tblTempFontsCategory', N'U') IS NOT NULL
	BEGIN TRY
		exec dbo.SP_Import_FontCategory @configid
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

	IF OBJECT_ID(N'dbo.tblTempFontsFamily', N'U') IS NOT NULL
	BEGIN TRY
		exec dbo.SP_Import_FontFamily @configid
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

	IF OBJECT_ID(N'dbo.tblTempFontsMarker', N'U') IS NOT NULL
	BEGIN TRY
		exec dbo.SP_Import_FontMarker @configid
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
	
END