/****** Object:  StoredProcedure [dbo].[SP_Insets_Add]    Script Date: 11/22/2022 5:15:06 PM ******/
IF OBJECT_ID('[dbo].[SP_Insets_Add]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_Insets_Add]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_Insets_Add]    Script Date: 11/22/2022 5:15:06 PM ******/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[SP_Insets_Add]
	 @ConfigurationId int,
	 @MapInsetName nvarchar(50),
	 @ZoomLevel float,
	 @MapInsetsPath nvarchar(max),
	 @MapPackageType nvarchar(50),
	 @RowStart int,
	 @RowEnd int,
	 @ColStart int,
	 @ColEnd int,
	 @LatStart float,
	 @LatEnd float,
	 @LongStart float,
	 @LongEnd float,
	 @IsHf bit,
	 @Cdata nvarchar(max),
	 @userId nvarchar(max),
	 @IsUhf bit
AS
BEGIN
	BEGIN
		DECLARE @userName NVARCHAR(500), @existingInsetId INT, @newInsetID INT, @asxiInsetID INT
		SET @userName = (SELECT FirstName + ' ' + LastName FROM AspNetUsers WHERE Id = @userId)
		DECLARE @retTable TABLE (message NVARCHAR(250))
		BEGIN TRY
			BEGIN TRANSACTION
				IF EXISTS(SELECT 1 FROM tblASXiInsetMap ASXiMap 
			    INNER JOIN tblASXiInset ASXi ON ASXi.ASXiInsetID = ASXiMap.ASXiInsetID
			    WHERE ASXiMap.ConfigurationID = @configurationId AND ASXi.InsetName = @MapInsetName AND ASXi.Zoom = @ZoomLevel)
				BEGIN
					SET @existingInsetId = (SELECT ASXiMap.ASXiInsetID FROM tblASXiInsetMap ASXiMap
					INNER JOIN tblASXiInset ASXi ON ASXi.ASXiInsetID = ASXiMap.ASXiInsetID
					WHERE ASXiMap.ConfigurationID = @configurationId AND ASXi.InsetName = @MapInsetName AND ASXi.Zoom = @ZoomLevel)

					EXEC SP_ConfigManagement_HandleUpdate @configurationId, 'tblASXiInset', @existingInsetId, @newInsetID OUTPUT

					UPDATE ASXi
					SET Zoom = @ZoomLevel, Path = @MapInsetsPath, MapPackageType = @MapPackageType, RowStart = @RowStart, RowEnd = @RowEnd, ColStart = @ColStart, 
					ColEnd = @ColEnd, LatStart = @LatStart, LatEnd = @LatEnd, LongStart = @LongStart, LongEnd = @LongEnd, IsHf = @IsHf, Cdata = @Cdata, IsUHf = @IsUhf
					FROM tblASXiInset ASXi
					INNER JOIN tblASXiInsetMap ASXiMap ON ASXi.ASXiInsetID = ASXiMap.ASXiInsetID
					WHERE ASXiMap.ConfigurationID = @configurationId AND ASXi.ASXiInsetID = @newInsetID 

					UPDATE ASXiMap
					SET Action = 'Updated', LastModifiedBy = @userName
					FROM tblASXiInsetMap ASXiMap
					INNER JOIN tblASXiInset ASXi ON ASXi.ASXiInsetID = ASXiMap.ASXiInsetID
					WHERE ASXiMap.ConfigurationID = @configurationId AND ASXi.InsetName = @MapInsetName
					AND ASXi.Zoom = @ZoomLevel AND ASXiMap.ASXiInsetID = @newInsetID
				END
				ELSE
				BEGIN
					INSERT INTO [dbo].[tblASXiInset] (InsetName,Zoom,Path,MapPackageType,RowStart,RowEnd,ColStart,ColEnd,LatStart,LatEnd,LongStart,LongEnd,IsHf,Cdata,IsUHf)
					VALUES
					(@MapInsetName,@ZoomLevel,@MapInsetsPath,@MapPackageType,@RowStart,@RowEnd,@ColStart,@ColEnd,@LatStart,@LatEnd,@LongStart,@LongEnd,@IsHf,@Cdata,@IsUhf);
					
					SET @asxiInsetID = SCOPE_IDENTITY()
					
					EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblASXiInset', @asxiInsetID

					UPDATE ASXiMap
					SET LastModifiedBy = @userName
					FROM tblASXiInsetMap ASXiMap
					INNER JOIN tblASXiInset ASXi ON ASXi.ASXiInsetID = ASXiMap.ASXiInsetID
					WHERE ConfigurationID = @configurationId AND ASXiMap.ASXiInsetID = @asxiInsetID
				END
			COMMIT
			INSERT INTO @retTable(message) VALUES ('Success')
		END TRY
		BEGIN CATCH
			INSERT INTO @retTable(message) VALUES ('Failure')
		END CATCH
		SELECT * FROM @retTable
	END	
END
