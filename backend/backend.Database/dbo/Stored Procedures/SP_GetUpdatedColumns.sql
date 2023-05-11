/****** Object:  StoredProcedure [dbo].[SP_GetUpdatedColumns]    Script Date: 9/29/2022 6:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_GetUpdatedColumns]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_GetUpdatedColumns]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetUpdatedColumns]    Script Date: 9/29/2022 6:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================  
-- Author:      Logeshwaran Sivaraj  
-- Create date: 9/29/2022  
-- Description: Retrieves all the column which are updated
--				based on the KeyValue 
-- Sample EXEC [dbo].[SP_GetVersionUpdates] 2
-- =======================================================  

CREATE PROCEDURE [dbo].[SP_GetUpdatedColumns]
    @config_table VARCHAR(100),
	@schema VARCHAR(100),
	@dataColumn VARCHAR(100),
	@keyValue INT,
	@previousKeyValue INT,
	@Result NVARCHAR(MAX) OUTPUT   
AS
BEGIN
	DECLARE @sql_query NVARCHAR(MAX)
	DECLARE @tempColumnNames TABLE(id INT IDENTITY NOT NULL, columnName NVARCHAR(100))
	INSERT INTO @tempColumnNames 
	SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @schema AND TABLE_NAME = @config_table	AND COLUMN_NAME <> @dataColumn

	DECLARE @cnt INT
	DECLARE @cnt_total INT
	IF EXISTS(SELECT * FROM @tempColumnNames)
	BEGIN
		SELECT @cnt = MIN(id) , @cnt_total = MAX(id) FROM @tempColumnNames
		DECLARE @columnName NVARCHAR(100)
		SET @sql_query = 'SELECT @UpdatedColumns = CONCAT_WS(' + ''','''
		WHILE @cnt <= @cnt_total
		BEGIN
			SELECT @columnName = columnName FROM @tempColumnNames WHERE id = @cnt
			SET @sql_query = @sql_query + ',' + '(CASE WHEN MIN(ISNULL(' + @columnName + ','''')) <> MAX(ISNULL(' + @columnName + ', '''')) THEN ' + '''' + @columnName + '''' + ' END)'		
			SET @cnt = @cnt + 1
		END
		SET @sql_query = @sql_query + ')
			FROM ' + @schema + '.' + @config_table + 
			' WHERE ' + @dataColumn + ' IN (' + Cast(@previousKeyValue AS NVARCHAR) + ',' + Cast(@keyValue AS NVARCHAR) + ')'
		

		SET @Result = ''
		EXEC sys.Sp_executesql @sql_query, N'@UpdatedColumns NVARCHAR(MAX) OUT', @Result OUT
	END
END
GO


