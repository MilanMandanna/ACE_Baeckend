
GO

/*
1. The procedure is used to add new custom content component to tblConfigurationComponents
2. The inputs are ConfigCompPath,ConfigCompTypeID and ConfigCompName
3. execute SP_AddNewConfigurationComponent '/Customcontent/Flightdata.zip', 2, 'Flightdata.zip';
*/
IF OBJECT_ID('[dbo].[SP_AddNewConfigurationComponent]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AddNewConfigurationComponent]
END
GO

CREATE PROCEDURE [dbo].[SP_AddNewConfigurationComponent]
	 @ConfigCompPath nvarchar(500),
	 @ConfigCompTypeID int,
	 @ConfigCompName nvarchar(50)
AS
BEGIN
	BEGIN
		DECLARE @ConfigurationComponentID int
		DECLARE @retTable TABLE (id INT IDENTITY(1,1), message NVARCHAR(250))
		BEGIN TRY
			SELECT @ConfigurationComponentID = coalesce((select max(ConfigurationComponentID) + 1 from [dbo].[tblConfigurationComponents]), 1)
			BEGIN TRANSACTION
				INSERT INTO [dbo].[tblConfigurationComponents] (Path,ConfigurationComponentTypeID,Name)
				VALUES
				( @ConfigCompPath, @ConfigCompTypeID ,@ConfigCompName);
			COMMIT
		END TRY
		BEGIN CATCH
			INSERT INTO @retTable(message) VALUES ('Failure')
		END CATCH
	END	
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Adds new views if needed to custom config menu
-- Sample EXEC [dbo].[SP_AddNewConfigurationView] 'Rotating POI,Flight Info,Panorama,Flight Data,Diagnostics,Global Zoom', 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_AddNewConfigurationView]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AddNewConfigurationView]
END
GO

CREATE PROCEDURE [dbo].[SP_AddNewConfigurationView]
@configurationId INT,
@type NVARCHAR(150),
@xml XML = NULL
AS
BEGIN

	DECLARE @menuID INT, @updateKey INT
	IF (@type = 'get')
	BEGIN
		SELECT Perspective FROM cust.config_tblMenu(@configurationId)
	END
	ELSE
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM cust.config_tblMenu(@configurationId))
		BEGIN
			INSERT INTO cust.tblMenu (Perspective) VALUES (@xml)
			
			SET @menuID = (SELECT MAX(MenuId) FROM cust.tblMenu)
			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblMenu', @menuID 
		END
		ELSE
		BEGIN
			SET @menuId = (SELECT cust.tblMenuMap.MenuID FROM cust.tblMenuMap WHERE cust.tblMenuMap.ConfigurationID = @configurationId)
			EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMenu', @menuId, @updateKey out
			
			UPDATE cust.tblMenu SET Perspective = @xml WHERE MenuID = @updateKey
		END
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 03/29/2022
-- Description:	Get admin items and download details
-- Sample EXEC [dbo].[SP_Admin_GetAdminItemsAndDownloadDetails] 112, 'page', 'populations'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Admin_GetAdminItemsAndDownloadDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Admin_GetAdminItemsAndDownloadDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Admin_GetAdminItemsAndDownloadDetails]
@configurationId INT,
@type NVARCHAR(150),
@pageName NVARCHAR(250) = NULL
AS
BEGIN
	DECLARE @AdminItems TABLE (buttonNames NVARCHAR(MAX))
	DECLARE @DownloadDetails TABLE (userName NVARCHAR(500), dateUploaded DATETIME, revision INT, taskId NVARCHAR(300), configurationId INT, configurationDefinitionId INT)
	IF (@type = 'adminitem')
	BEGIN
		INSERT INTO @AdminItems SELECT FS.Value FROM tblFeatureSet FS
        INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
        INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
        WHERE FS.Name = 'Collins-Admin-ItemsList' AND C.ConfigurationID = @configurationId

		SELECT * FROM @AdminItems
	END
	
	ELSE IF (@type = 'page')
	BEGIN
		IF (@pageName = 'populations' OR @pageName = 'airports' OR @pageName = 'world guide cities')
		BEGIN
			INSERT INTO @DownloadDetails SELECT CH.CommentAddedBy, CH.DateModified, C.Version , CH.TaskID, CH.ConfigurationID, C.ConfigurationDefinitionID 
			FROM tblConfigurationHistory CH
			INNER JOIN tblConfigurations C ON C.ConfigurationID = CH.ConfigurationID 
			WHERE ContentType = @pageName AND TaskID IS NOT NULL
			AND CH.ConfigurationID IN (SELECT ConfigurationID FROM tblConfigurations WHERE ConfigurationDefinitionID IN 
									(SELECT ConfigurationDefinitionID FROM tblConfigurations WHERE ConfigurationID = @configurationId))
			ORDER BY C.Version DESC
			
		END
		ELSE
		BEGIN
			INSERT INTO @DownloadDetails
			SELECT CCM.LastModifiedBy, CCM.LastModifiedDate, C.Version, CC.ConfigurationComponentID, C.ConfigurationID, C.ConfigurationDefinitionID FROM tblConfigurationComponents CC
			INNER JOIN tblConfigurationComponentsMap CCM ON CC.ConfigurationComponentID = CCM.ConfigurationComponentID
			AND CC.ErrorLog = '' AND CC.Name = @pageName 
			AND CCM.ConfigurationID IN (SELECT ConfigurationID FROM tblConfigurations WHERE ConfigurationDefinitionID IN 
										(SELECT ConfigurationDefinitionID FROM tblConfigurations WHERE ConfigurationID = @configurationId))
			INNER JOIN tblConfigurations C ON C.ConfigurationID = CCM.ConfigurationID ORDER BY C.Version ASC
		END

		SELECT * FROM @DownloadDetails ORDER BY revision DESC
	END
END
GO
GO

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
GO

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
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/18/2022
-- Description:	returns list of products associated with aircrafts 
-- Sample EXEC [dbo].[SP_Aircraft_GetProducts] '4a2ee015-9da3-4583-aa1f-31a11006a53b'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Aircraft_GetProducts]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Aircraft_GetProducts]
END
GO

CREATE PROCEDURE [dbo].[SP_Aircraft_GetProducts]
    @aircraftId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT DISTINCT 
	CASE WHEN dbo.tblProducts.ProductID is not null THEN dbo.tblProducts.ProductID 
		WHEN dbo.tblPlatforms.PlatformID is not null THEN dbo.tblPlatforms.PlatformID 
		WHEN dbo.tblGlobals.GlobalID is not null THEN dbo.tblGlobals.GlobalID 
		END AS ProductID, 

		CASE WHEN dbo.tblProducts.ProductID is not null THEN dbo.tblProducts.Name 
		WHEN dbo.tblPlatforms.PlatformID is not null THEN dbo.tblPlatforms.Name 
	WHEN dbo.tblGlobals.GlobalID is not null THEN dbo.tblGlobals.Name 
	END AS Name, 

	CASE WHEN dbo.tblProducts.ProductID is not null THEN dbo.tblProducts.Description 
	WHEN dbo.tblPlatforms.PlatformID is not null THEN dbo.tblPlatforms.Description 
	WHEN dbo.tblGlobals.GlobalID is not null THEN dbo.tblGlobals.Description 
	END AS Description, 

	CASE WHEN dbo.tblProducts.ProductID is not null THEN dbo.tblProducts.LastModifiedBy 

	END AS LastModifiedBy,
	dbo.tblConfigurationDefinitions.ConfigurationDefinitionID AS ConfigurationDefinitionID,

	dbo.tblProducts.TopLevelPartnumber AS TopLevelPartnumber

	FROM dbo.tblAircraftConfigurationMapping 

	INNER JOIN dbo.tblConfigurationDefinitions ON dbo.tblAircraftConfigurationMapping.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionID 

	LEFT OUTER JOIN dbo.tblProductConfigurationMapping on dbo.tblProductConfigurationMapping.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionParentID 
	LEFT OUTER JOIN dbo.tblProducts on dbo.tblProducts.ProductID = dbo.tblProductConfigurationMapping.ProductID 

	LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionParentID 
	LEFT OUTER JOIN dbo.tblPlatforms on dbo.tblPlatforms.PlatformID = dbo.tblPlatformConfigurationMapping.PlatformID 

		LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID 
	LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID 

	LEFT OUTER JOIN dbo.tblConfigurationDefinitions as CD ON CD.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionParentID 

	WHERE dbo.tblAircraftConfigurationMapping.AircraftID = @aircraftId;
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 03/18/2022
-- Description:	Updates the airport data with given data
-- Sample EXEC [dbo].[SP_Airport_AddAirport] 1 ,'00S',null, 45.655556,-122.305556 ,523701 , 'Blue River'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Airport_AddAirport]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Airport_AddAirport]
END
GO

CREATE PROCEDURE [dbo].[SP_Airport_AddAirport]
	@configurationId INT,
    @fourLetID NVARCHAR(4),
    @threeLetID NVARCHAR(3) = NULL,
    @lat DECIMAL(12,9) = NULL,
    @lon DECIMAL(12,9) = NULL,
    @geoRefID INT = NULL,
    @cityName NVARCHAR(MAX) = NULL
AS
BEGIN
    DECLARE @existingAirportInfoMapCount INT
    DECLARE @existingAirportInfoId INT
    DECLARE @newAirportInfoId INT

    SET @existingAirportInfoMapCount = (SELECT COUNT(*) FROM dbo.tblAirportInfoMap INNER JOIN dbo.tblAirportInfo ON  dbo.tblAirportInfo.AirportInfoID = dbo.tblAirportInfoMap.AirportInfoID WHERE dbo.tblAirportInfoMap.ConfigurationID = @configurationId AND dbo.tblAirportInfo.FourLetId = @fourLetID AND dbo.tblAirportInfoMap.IsDeleted = 0)
    IF (@existingAirportInfoMapCount > 1)
    BEGIN        
        SELECT -1 as Result,'Airport with given 4 letter Id '+@FourLetID+' already exist' as Message
    END
    ELSE 
    BEGIN
        SET @existingAirportInfoId = (
            SELECT DISTINCT
            airportinfo.AirportInfoID
            FROM dbo.config_tblAirportInfo(@configurationId) as airportinfo
            WHERE airportinfo.FourLetId = @fourLetID
        )
        IF (@existingAirportInfoId IS NOT NULL)
        BEGIN
            EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblAirportInfo',@existingAirportInfoId
            SELECT 2 as Result,'New mapping with '+CAST(@configurationId AS varchar)+ ' and '+@FourLetID+' has been created' as Message

        END
        ELSE
        BEGIN
            INSERT INTO dbo.tblAirportInfo(FourLetID,ThreeLetID,Lat,Lon,GeoRefID,CityName,DataSourceID,CustomChangeBitMask) VALUES(@fourLetID,@threeLetID,@lat,@lon,@geoRefID,@cityName,7,1)
            SET @newAirportInfoId = (SELECT MAX(airportinfo.AirportInfoID) FROM dbo.tblAirportInfo as airportinfo)
            EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblAirportInfo',@newAirportInfoId
            SELECT 1 as Result,'New airport with IATA "'+@FourLetID+'" has been created' as Message

        END
    END
END    
GO  
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 03/21/2022
-- Description:	Get all the City Info for a given configuration id
-- Sample EXEC [dbo].[SP_Airport_GetCityInfo] 1, 
-- =============================================

IF OBJECT_ID('[dbo].[SP_Airport_GetCityInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Airport_GetCityInfo]
END
GO

CREATE PROCEDURE [dbo].[SP_Airport_GetCityInfo]
	@configurationId INT
AS
BEGIN
    SELECT distinct georef.georefid as GeoRefId,georef.Description Name,
    country.Description as Country
    FROM 
    dbo.config_tblGeoRef(@configurationId) as georef
    left outer join dbo.config_tblCountry(@configurationId) as country on georef.CountryId = country.CountryID
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 03/14/2022
-- Description:	Get all the Airport Info for a given configuration id
-- Sample EXEC [dbo].[SP_Airport_GetInfo] 1, 
-- =============================================

IF OBJECT_ID('[dbo].[SP_Airport_GetInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Airport_GetInfo]
END
GO

CREATE PROCEDURE [dbo].[SP_Airport_GetInfo]
	@configurationId INT
AS
BEGIN
    select distinct
    airportinfo.*,
    country.Description as Country
    from dbo.config_tblAirportInfo(@configurationId) as airportinfo
    left outer join dbo.config_tblGeoRef(@configurationId) as georef on airportinfo.georefid = georef.georefid
    left outer join dbo.config_tblCountry(@configurationId) as country on georef.CountryId = country.CountryID
    ORDER BY airportinfo.FourLetId ASC
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 03/14/2022
-- Description:	Get Airport IATA and ICAO names
-- Sample EXEC [dbo].[SP_Airport_GetNames] 1, 'iata'
-- Sample EXEC [dbo].[SP_Airport_GetNames] 1, 'icao'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Airport_GetNames]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Airport_GetNames]
END
GO

CREATE PROCEDURE [dbo].[SP_Airport_GetNames]
	@configurationId INT,
	@type NVARCHAR(250)
AS
BEGIN
	IF (@type = 'iata')
	BEGIN 
		SELECT 
        dbo.tblAirportInfo.ThreeLetID 
        FROM dbo.tblAirportInfo 
        INNER JOIN dbo.tblAirportInfoMap ON dbo.tblAirportInfoMap.AirportInfoID = dbo.tblAirportInfo.AirportInfoID
        WHERE dbo.tblAirportInfo.ThreeLetID IS NOT NULL AND dbo.tblAirportInfoMap.ConfigurationID = @configurationId AND dbo.tblAirportInfoMap.IsDeleted = 0
	END
    ELSE IF (@type = 'icao')
    BEGIN
       SELECT 
        dbo.tblAirportInfo.FourLetID 
        FROM dbo.tblAirportInfo 
        INNER JOIN dbo.tblAirportInfoMap ON dbo.tblAirportInfoMap.AirportInfoID = dbo.tblAirportInfo.AirportInfoID
        WHERE dbo.tblAirportInfo.FourLetID IS NOT NULL AND dbo.tblAirportInfoMap.ConfigurationID = @configurationId AND dbo.tblAirportInfoMap.IsDeleted = 0
    END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 03/18/2022
-- Description:	Updates the airport data with given data
-- Sample EXEC [dbo].[SP_Airport_UpdateAirport] 1 , 6,'00S',null, 45.655556,-122.305556 ,523701 , 'Blue River'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Airport_UpdateAirport]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Airport_UpdateAirport]
END
GO

CREATE PROCEDURE [dbo].[SP_Airport_UpdateAirport]
	@configurationId INT,
    @airportInfoID INT,
    @fourLetID NVARCHAR(4),
    @threeLetID NVARCHAR(3) = NULL,
    @lat DECIMAL(12,9) = NULL,
    @lon DECIMAL(12,9) = NULL,
    @geoRefID INT = NULL,
    @cityName NVARCHAR(MAX) = NULL,
	@modlistinfo [ModListTable] READONLY
AS
BEGIN
    DECLARE @existingAirportInfoId INT
    DECLARE @newAirportInfoId INT
	DECLARE @custom INT, @existingvalue INT , @updatedvalue INT,@geocustom INT,@existinggeovalue INT,@updatedgeorefid INT
	DECLARE @TempModListTable TABLE( Id INT,Row INT, Columns INT,Resolution INT)
	
    EXEC SP_ConfigManagement_HandleUpdate @configurationId, 'tblAirportInfo', @airportInfoID, @newAirportInfoId output
	SET @custom = 2
	SET @geocustom = 4
	SET @existingvalue = (SELECT  CustomChangeBitMask   FROM tblAirportInfo WHERE tblAirportInfo.AirportInfoID = @newAirportInfoId )
	SET @existinggeovalue = (SELECT  GeoRefID   FROM tblAirportInfo WHERE tblAirportInfo.AirportInfoID = @newAirportInfoId )
	INSERT into @TempModListTable SELECT * from @modlistinfo
	DECLARE @Id int , @Row int,@Columns int,@Resolution int
	
	WHILE (SELECT COUNT(*) FROM @TempModListTable) > 0
	BEGIN
	 SET @Id = (SELECT TOP 1 Id from @TempModListTable)
	 SET @Row = (SELECT  Row  from @TempModListTable WHERE Id =@Id)
	 SET @Columns = (SELECT  Columns  from @TempModListTable WHERE Id =@Id)
	 SET @Resolution = (SELECT  Resolution  from @TempModListTable WHERE Id =@Id)
	 
	 IF EXISTS(SELECT 1 FROM tblModList m INNER JOIN tblModListMap mm on m.ModlistId = mm.ModlistID where m.Row = @row and m.Col = @columns and m.resolution = @resolution and mm.ConfigurationID = @configurationId)
	 begin
	 update m 
	 set isdirty = 1 
	 from tblmodlist m inner join tblmodlistmap mm on m.modlistid = mm.modlistid 
	 where  m.Row = @row and m.Col = @columns and m.resolution = @resolution and mm.ConfigurationID = @configurationId
	 end

	 DELETE FROM @TempModListTable WHERE Id =@Id
	END
	

    -- logic to handle the scenario where we want to update the four letter id of an airport but there is different airport with the same for letter id. In that case return error
    SET @existingAirportInfoId = (SELECT distinct airportinfo.AirportInfoID FROM dbo.config_tblAirportInfo(@configurationId) as airportinfo WHERE airportinfo.FourLetID = @FourLetID)

    IF (@existingAirportInfoId = @newAirportInfoId OR @existingAirportInfoId IS NULL)
    BEGIN
        UPDATE airportinfo 
        SET airportinfo.FourLetID = @fourLetID, airportinfo.ThreeLetID = @threeLetID, airportinfo.Lat = @lat, airportinfo.Lon = @lon, airportinfo.GeoRefID = @geoRefID ,airportinfo.CityName =  @cityName
        FROM 
        dbo.config_tblAirportInfo(@configurationId) as airportinfo 
        WHERE airportinfo.AirportInfoID = @newAirportInfoId
        SELECT  1 as Result,'Airport data updated successfully' as Message
		SET @updatedgeorefid = (SELECT  GeoRefID   FROM tblAirportInfo WHERE tblAirportInfo.AirportInfoID = @newAirportInfoId )
    END
    ELSE 
    BEGIN
        SELECT -1 as Result,'Airport with given 4 letter Id '+@FourLetID+' already exist' as Message
    END
	IF (@existinggeovalue = @updatedgeorefid) 
	BEGIN 
	SET @updatedvalue= (@existingvalue | @custom )
	UPDATE  tblAirportInfo SET tblAirportInfo.CustomChangeBitMask = @updatedvalue WHERE  tblAirportInfo.AirportInfoID = @newAirportInfoId
	END
	ELSE
	BEGIN
	SET @updatedvalue= (@existingvalue | @geocustom )
	UPDATE  tblAirportInfo SET tblAirportInfo.CustomChangeBitMask = @updatedvalue WHERE  tblAirportInfo.AirportInfoID = @newAirportInfoId
	END
	
END    
GO  
GO

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
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Fonts from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_AirportInfo] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_AirportInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_AirportInfo]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_AirportInfo]
		@configid INT
AS
BEGIN

	DECLARE @tempNewAirportInfoCounter INT, @existingAirportInfoId INT, @newAirportInfoId INT,
	@AsxiAirportFourLetId NVARCHAR(4), @AsxiAirportThreeLetId NVARCHAR(4), @AsxiAirportGeoRefID INT, @AsxiAirportLat FLOAT, @AsxiAirportLong FLOAT;
	CREATE TABLE #tempNewAirportInfoWithIDs (AirportInfoId INT IDENTITY (1,1) NOT NULL, FourLetID NVARCHAR(4) NULL,ThreeLetID NVARCHAR(3),Lat DECIMAL (12,9) NULL,
	Lon DECIMAL(12,9) NULL,GeoRefID INT NULL)
	DECLARE @customChangeBitMask INT, @existingvalue INT, @updatedvalue INT;

	--Since there ID column for AsxiInfotbairportinfo. Created the table with one and added the records.
	INSERT INTO #tempNewAirportInfoWithIDs SELECT FourLetId,ThreeLetId,Lat,Lon,PointGeoRefId FROM AsxiInfotbairportinfo 
	
	--For new records
	SELECT TempAsxi.* INTO  #tempNewAirportInfo FROM #tempNewAirportInfoWithIDs AS TempAsxi WHERE FourLetID NOT IN 
			(SELECT T.FourLetID FROM tblAirportInfo T INNER JOIN tblAirportInfoMap TMap ON T.AirportInfoID = TMap.AirportInfoID
				WHERE TMap.ConfigurationID = @configid);
	
	--For Modified records
	SELECT TempAsxi.* INTO  #tempUpdateAirportInfo FROM #tempNewAirportInfoWithIDs AS TempAsxi WHERE TempAsxi.FourLetID IN
			(SELECT T.FourLetID FROM tblAirportInfo T INNER JOIN tblAirportInfoMap TMap ON T.AirportInfoID = TMap.AirportInfoID
				WHERE (TempAsxi.ThreeLetID != T.ThreeLetID OR
							TempAsxi.Lat != ROUND(T.Lat,6) OR
							TempAsxi.Lon != ROUND(T.Lon,6)) AND TMap.ConfigurationID = @configid);


	--Iterating to the new temp tables and adding it to the tblAirportInfo and tblAirportInfoMap
	WHILE(SELECT COUNT(*) FROM #tempNewAirportInfo) > 0
	BEGIN
		
		SET @tempNewAirportInfoCounter = (SELECT TOP 1 AirportInfoId FROM #tempNewAirportInfo)
		SET @AsxiAirportGeoRefID = (SELECT TOP 1 GeoRefID FROM #tempNewAirportInfo)	
		SET @AsxiAirportFourLetId = (SELECT TOP 1 FourLetID FROM #tempNewAirportInfo)
		SET @AsxiAirportThreeLetId = (SELECT TOP 1 ThreeLetID FROM #tempNewAirportInfo)
		SET @AsxiAirportLat = (SELECT TOP 1 Lat FROM #tempNewAirportInfo)
		SET @AsxiAirportLong = (SELECT TOP 1 Lon FROM #tempNewAirportInfo)

		DECLARE @airportinfoId INT;
		INSERT INTO tblAirportInfo(FourLetID, ThreeLetID, Lat, Lon, GeoRefID, CustomChangeBitMask)
		VALUES (@AsxiAirportFourLetId, @AsxiAirportThreeLetId, @AsxiAirportLat, @AsxiAirportLong, @AsxiAirportGeoRefID, 8) 
		SET @airportinfoId = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblAirportInfo', @airportinfoId


		DELETE FROM #tempNewAirportInfo WHERE AirportInfoId = @tempNewAirportInfoCounter
	END

	--Iterating to the new temp tables and adding it to the tblAirportInfo and tblAirportInfoMap
	WHILE(SELECT COUNT(*) FROM #tempUpdateAirportInfo) > 0
	BEGIN	

		SET @tempNewAirportInfoCounter = (SELECT TOP 1 AirportInfoId FROM #tempUpdateAirportInfo)
		SET @AsxiAirportGeoRefID = (SELECT TOP 1 GeoRefID FROM #tempUpdateAirportInfo)		
		SET @AsxiAirportFourLetId = (SELECT TOP 1 FourLetID FROM #tempUpdateAirportInfo)
		SET @AsxiAirportThreeLetId = (SELECT TOP 1 ThreeLetID FROM #tempUpdateAirportInfo)
		SET @AsxiAirportLat = (SELECT TOP 1 Lat FROM #tempUpdateAirportInfo)
		SET @AsxiAirportLong = (SELECT TOP 1 Lon FROM #tempUpdateAirportInfo)


		--Update the tblAirportInfo and its Maping Table
		SET @existingAirportInfoId = (SELECT airportinfo.AirportInfoID FROM dbo.config_tblAirportInfo(@configid) AS airportinfo 
			WHERE airportinfo.FourLetID = @AsxiAirportFourLetId)

		DECLARE @updateKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblAirportInfo', @existingAirportInfoId, @updateKey out

		SET @customChangeBitMask = 2
 	 	SET @existingvalue = (SELECT CustomChangeBitMask FROM tblAirportInfo WHERE AirportInfoID = @updateKey)
 	 	SET @updatedvalue =(@existingvalue | @customChangeBitMask)
		SET NOCOUNT OFF
		UPDATE tblAirportInfo
		SET ThreeLetID = @AsxiAirportThreeLetId, Lat = @AsxiAirportLat, Lon = @AsxiAirportLong, CustomChangeBitMask = @updatedvalue
		WHERE AirportInfoID = @updateKey

		DELETE FROM #tempUpdateAirportInfo WHERE AirportInfoId = @tempNewAirportInfoCounter
	END

	DROP TABLE #tempNewAirportInfo
	DROP TABLE #tempUpdateAirportInfo
	DROP TABLE #tempNewAirportInfoWithIDs
END



GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Fonts from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_Country] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_Country]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_Country]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_Country]
		@configid INT
AS
BEGIN
	--For new records  
	DECLARE @CurrentCountryID INT, @existingCountryId INT, @newCountryId INT, @tempCountryId INT, @tempLangID INT,@tempCountry NVARCHAR(MAX);  
	
	DECLARE @tempNewCountryWithIDs TABLE (Id INT IDENTITY (1,1) NOT NULL,CountryId INT NOT NULL, Description NVARCHAR(MAX) NOT NULL, LangTwoLetter NVARCHAR(2) NULL,LangID INT NULL); 
	DECLARE @tempNewCountry TABLE (Id INT IDENTITY (1,1) NOT NULL,CountryId INT NOT NULL, Description NVARCHAR(MAX) NOT NULL,LangID INT NULL);  
	DECLARE @tempUpdateCountry TABLE (Id INT IDENTITY (1,1) NOT NULL,CountryId INT NOT NULL, Description NVARCHAR(MAX) NOT NULL,LangID INT NULL); 
	DECLARE @dml AS NVARCHAR(MAX);  
	DECLARE @ColumnName AS NVARCHAR(MAX);  
		
	SELECT @ColumnName= ISNULL(@ColumnName + ',','')   
		+ QUOTENAME(name) from sys.columns c  
	where c.object_id = OBJECT_ID('dbo.AsxiInfotbCountry') and name LIKE '%Lang%'  
	SET @dml =   
	N'(SELECT CountryId, Description, (SELECT RIGHT( LangTwoLetter, 2 ))  
	FROM     
	(SELECT CountryId, ' +@ColumnName +'     
	
	FROM AsxiInfotbCountry) p    
	UNPIVOT    
	(Description FOR LangTwoLetter IN     
	(' + @ColumnName + ')     
	)AS unpvtAsxiInfotbCountry) '  
		
	INSERT INTO @tempNewCountryWithIDs(CountryId,Description,LangTwoLetter)  EXEC sp_executesql @dml  
	--Updating two letter codes
	UPDATE T1   
	SET T1.LangID = T2.LanguageID  
	FROM @tempNewCountryWithIDs AS T1 INNER JOIN AsxiInfotblanguage T2  
	ON T1.LangTwoLetter = t2.TwoLetterID  
	
	--For New Records
	INSERT INTO @tempNewCountry(CountryId,LangID,Description)
	SELECT TBCS.CountryId,TBCS.LangID, TBCS.Description FROM @tempNewCountryWithIDs TBCS
	WHERE CAST(TBCS.Description as nvarchar)+CAST(TBCS.LangID as nvarchar) NOT IN (SELECT CAST(FCS.CountryName as nvarchar)+CAST(FCS.LanguageId as nvarchar)
	FROM dbo.config_tblCountrySpelling(@configid) FCS)
	
	--For update Records
	INSERT INTO @tempUpdateCountry(CountryId,LangID,Description)
	SELECT TBCS.CountryId,TBCS.LangID, TBCS.Description FROM @tempNewCountryWithIDs TBCS
		WHERE CAST(TBCS.Description as nvarchar)+CAST(TBCS.LangID as nvarchar) 
			IN (SELECT CAST(FCS.CountryName as nvarchar)+CAST(FCS.LanguageId as nvarchar)
					FROM dbo.config_tblCountrySpelling(@configid) as FCS WHERE CAST(TBCS.Description as nvarchar)!= CAST(FCS.CountryName as nvarchar));
	
	

		--Iterating to the new temp tables and adding it to the tblCountrySpelling and tblCountrySpellingMap
		WHILE(SELECT COUNT(*) FROM @tempNewCountry) > 0
	BEGIN		
		SET @CurrentCountryID = (SELECT TOP 1 CountryId FROM @tempNewCountry)
		SET @tempCountryId = (SELECT TOP 1 CountryId FROM @tempNewCountry)
		SET @tempLangID = (SELECT TOP 1 LangID FROM @tempNewCountry)
		SET @tempCountry = (SELECT TOP 1 Description FROM @tempNewCountry)

		--Insert tblFont Table and and its Maping Table
		DECLARE @newtbCountryID INT;
		INSERT INTO tblCountrySpelling(CountryId,LanguageID,CountryName)
		VALUES (@tempCountryId,@tempLangID,@tempCountry) 
		SET @newtbCountryID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblCountrySpelling', @newtbCountryID

		DELETE FROM @tempNewCountry WHERE CountryId = @CurrentCountryID
	END

	--Iterating to the udate temp tables and adding it to the tblCountrySpelling and tblCountrySpellingMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateCountry) > 0
	BEGIN		
		SET @CurrentCountryID = (SELECT TOP 1 CountryId FROM @tempUpdateCountry)
		SET @tempCountryId = (SELECT TOP 1 CountryId FROM @tempUpdateCountry)
		SET @tempLangID = (SELECT TOP 1 LangID FROM @tempUpdateCountry)
		SET @tempCountry = (SELECT TOP 1 Description FROM @tempUpdateCountry)

		--Update the tblFont Table and and its Maping Table
		SET @existingCountryId = (SELECT tbCountrySpell.CountryID FROM config_tblCountrySpelling(@configid) as tbCountrySpell
		WHERE tbCountrySpell.LanguageId = @tempLangID AND tbCountrySpell.CountryId = @tempCountryId)

		DECLARE @updateSpellKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblCountrySpelling', @existingCountryId, @updateSpellKey out
		SET NOCOUNT OFF
		UPDATE tblCountrySpelling
		SET CountryName = @tempCountry
		WHERE CountryID = @updateSpellKey

		DELETE FROM @tempUpdateCountry WHERE CountryId = @CurrentCountryID
	END

END  
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Fonts from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_font] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_font]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_font]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_font]
		@configid INT
AS
BEGIN
	--For new records
	DECLARE @tempNewFontCounter INT, @existingFontId INT, @newFontId INT, @CurrentFontID INT, @tbFontID INT, @tempID INT;
	DECLARE @tbFontFontID INT, @tbFontSize INT,@tbFontDescription NVARCHAR(255), @tbFontColor NVARCHAR(8), @tbFontShadowColor NVARCHAR(8), @tbFontFontFaceId INT, @tbFontFontStyle INT;
	--CREATE TABLE @tempNewFontWithIDs (ID INT IDENTITY (1,1) NOT NULL, FontID INT NULL, Description NVARCHAR(255) NULL,Size INT NULL,Color NVARCHAR(8), ShadowColor NVARCHAR(8),FontFaceId NVARCHAR(11),FontStyle NVARCHAR(10));
	DECLARE @tempNewFont TABLE(ID INT IDENTITY (1,1) NOT NULL, FontID INT NULL, Description NVARCHAR(255) NULL,Size INT NULL,Color NVARCHAR(8), ShadowColor NVARCHAR(8),FontFaceId INT NULL,FontStyle INT NULL);
	DECLARE @tempUpdateFont TABLE (ID INT IDENTITY (1,1) NOT NULL, FontID INT NULL, Description NVARCHAR(255) NULL,Size INT NULL,Color NVARCHAR(8), ShadowColor NVARCHAR(8),FontFaceId INT NULL,FontStyle INT NULL);
 

	INSERT INTO @tempNewFont (FontID,Description,Size,Color,ShadowColor,FontFaceId,FontStyle) 
	SELECT TBF.FontId,TBF.Description, TBF.Size,TBF.Color,TBF.ShadowColor,TBF.FontFaceId, TBF.FontStyle
	FROM AsxiInfotbfont  TBF WHERE TBF.FontId NOT IN 
		(SELECT tbFont.FontID FROM config_tblFont(@configid) as tbFont)


	--For Modified records
	INSERT INTO @tempUpdateFont (FontID,Description,Size,Color,ShadowColor,FontFaceId,FontStyle) 
	SELECT TBF.FontId,TBF.Description, TBF.Size,TBF.Color,TBF.ShadowColor,TBF.FontFaceId, TBF.FontStyle
	FROM AsxiInfotbfont TBF WHERE TBF.FontId IN
			(SELECT tbFont.FontID FROM config_tblFont(@configid) as tbFont
				WHERE TBF.Description != tbFont.Description OR
							TBF.Size != tbFont.Size OR
							TBF.Color != tbFont.Color OR
							TBF.ShadowColor != tbFont.ShadowColor OR
							TBF.FontFaceId != tbFont.FontFaceId OR
							TBF.FontStyle != tbFont.FontStyle);

	--Iterating to the new temp tables and adding it to the tblFont and tblFontMap
	WHILE(SELECT COUNT(*) FROM @tempNewFont) > 0
	BEGIN
		
		SET @tempID = (SELECT TOP 1 ID FROM @tempNewFont)
		SET @tbFontID = (SELECT TOP 1 FontID FROM @tempNewFont)	
		SET @tbFontDescription = (SELECT TOP 1 Description FROM @tempNewFont)	
		SET @tbFontSize = (SELECT TOP 1 Size FROM @tempNewFont)
		SET @tbFontColor = (SELECT TOP 1 Color FROM @tempNewFont)
		SET @tbFontShadowColor = (SELECT TOP 1 ShadowColor FROM @tempNewFont)
		SET @tbFontFontFaceId = (SELECT TOP 1 FontFaceId FROM @tempNewFont)
		SET @tbFontFontStyle = (SELECT TOP 1 FontStyle FROM @tempNewFont)

		--Insert tblFont Table and and its Maping Table
		DECLARE @newtbFontID INT;
		INSERT INTO tblFont(FontID,Description,Size,Color,ShadowColor,FontFaceId,FontStyle)
		VALUES (@tbFontID,@tbFontDescription, @tbFontSize,@tbFontColor,@tbFontShadowColor,@tbFontFontFaceId,@tbFontFontStyle) 
		SET @newtbFontID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblFont', @newtbFontID

		DELETE FROM @tempNewFont WHERE ID = @tempID
	END

	--Iterating to the new temp tables and adding it to the tblFont and tblFontMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateFont) > 0
	BEGIN
		
		SET @tempID = (SELECT TOP 1 ID FROM @tempUpdateFont)	
		SET @tbFontID = (SELECT TOP 1 FontID FROM @tempUpdateFont)	
		SET @tbFontDescription = (SELECT TOP 1 Description FROM @tempUpdateFont)	
		SET @tbFontSize = (SELECT TOP 1 Size FROM @tempUpdateFont)
		SET @tbFontColor = (SELECT TOP 1 Color FROM @tempUpdateFont)
		SET @tbFontShadowColor = (SELECT TOP 1 ShadowColor FROM @tempUpdateFont)
		SET @tbFontFontFaceId = (SELECT TOP 1 FontFaceId FROM @tempUpdateFont)
		SET @tbFontFontStyle = (SELECT TOP 1 FontStyle FROM @tempUpdateFont)


		--Update the tblFont Table and and its Maping Table
		SET @existingFontId = (SELECT tbFont.ID FROM dbo.config_tblFont(@configid) AS tbFont 
		WHERE tbFont.FontID = @tbFontID)

		print @existingFontId

		DECLARE @updateFontKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblFont', @existingFontId, @updateFontKey out
		SET NOCOUNT OFF
		print @updateFontKey
		UPDATE tblFont
		SET   Size = @tbFontSize, Color = @tbFontColor, ShadowColor = @tbFontShadowColor, FontFaceId = @tbFontFontFaceId, FontStyle = @tbFontFontStyle,Description = @tbFontDescription
		WHERE ID = @updateFontKey

		DELETE FROM @tempUpdateFont WHERE ID = @tempID
	END

	DELETE @tempNewFont
	DELETE @tempUpdateFont
END





GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Fonts from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_FontCategory] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_FontCategory]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_FontCategory]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_FontCategory]
		@configid INT
AS
BEGIN
	--For new records
	DECLARE @existingFontCategoryId INT, @CurrentFontCategoryID INT;
	DECLARE @tbFontCatLangID INT,@tbFontCatMarkerID INT, @tbFontCatIMarkerID INT,@tbFontCatGeoRefIdCatTypeId INT,@tbFontCatFontID INT;
	--DECLARE  @tempNewFontCategoryWithIDs TABLE (FontCategoryId INT IDENTITY (1,1) NOT NULL, GeoRefIdCatTypeID INT NULL, LanguageID INT NULL,FontID INT NULL,MarkerID INT NULL,IMarkerID INT NULL);
	DECLARE  @tempNewFontCategory TABLE (FontCategoryId INT IDENTITY (1,1) NOT NULL, GeoRefIdCatTypeID INT NULL, LanguageID INT NULL,FontID INT NULL,MarkerID INT NULL,IMarkerID INT NULL);
	DECLARE  @tempUpdateFontCategory TABLE (FontCategoryId INT IDENTITY (1,1) NOT NULL, GeoRefIdCatTypeID INT NULL, LanguageID INT NULL,FontID INT NULL,MarkerID INT NULL,IMarkerID INT NULL);


	--For new records
	INSERT INTO  @tempNewFontCategory(GeoRefIdCatTypeID,LanguageID,FontID,MarkerID,IMarkerID) 
	SELECT TBFC.GeoRefIdCatTypeId,TBFC.LanguageId,TBFC.FontId, TBFC.MarkerId, TBFC.IMarkerId
	FROM AsxiInfotbfontcategory TBFC WHERE CAST(TBFC.GeoRefIdCatTypeId AS NVARCHAR)+CAST(TBFC.FontId AS NVARCHAR)  NOT IN 
		(SELECT CAST(tbFontCat.GeoRefIdCatTypeID AS NVARCHAR)+CAST(tbFontCat.FontID AS NVARCHAR) FROM config_tblFontCategory(@configid) as tbFontCat)
	
	--For Modified records
	INSERT INTO  @tempUpdateFontCategory(GeoRefIdCatTypeID,LanguageID,FontID,MarkerID,IMarkerID) 
	SELECT TBFC.GeoRefIdCatTypeId,TBFC.LanguageId,TBFC.FontId, TBFC.MarkerId, TBFC.IMarkerId
	FROM AsxiInfotbfontcategory TBFC WHERE CAST(TBFC.GeoRefIdCatTypeId AS NVARCHAR)+CAST(TBFC.FontId AS NVARCHAR) IN 
		(SELECT CAST(tbFontCat.GeoRefIdCatTypeID AS NVARCHAR)+CAST(tbFontCat.FontID AS NVARCHAR) FROM config_tblFontCategory(@configid) as tbFontCat 
			WHERE TBFC.LanguageID != tbFontCat.LanguageID OR
							TBFC.MarkerID != tbFontCat.MarkerID OR
							TBFC.IMarkerID != tbFontCat.IMarkerID);

	--Iterating to the new temp tables and adding it to the tblFontCategory and tblFontCategoryMap
	WHILE(SELECT COUNT(*) FROM @tempNewFontCategory) > 0
	BEGIN		
		SET @CurrentFontCategoryID = (SELECT TOP 1 FontCategoryId FROM @tempNewFontCategory)
		SET @tbFontCatGeoRefIdCatTypeId = (SELECT TOP 1 GeoRefIdCatTypeId FROM @tempNewFontCategory)
		SET @tbFontCatLangID = (SELECT TOP 1 LanguageID FROM @tempNewFontCategory)
		SET @tbFontCatFontID = (SELECT TOP 1 FontID FROM @tempNewFontCategory)
		SET @tbFontCatMarkerID = (SELECT TOP 1 MarkerID FROM @tempNewFontCategory)
		SET @tbFontCatIMarkerID = (SELECT TOP 1 IMarkerID FROM @tempNewFontCategory)

		--Insert tblFont Table and and its Maping Table
		DECLARE @newtbFontCatID INT;
		INSERT INTO tblFontCategory(GeoRefIdCatTypeID,LanguageID,FontID,MarkerID,IMarkerID)
		VALUES (@tbFontCatGeoRefIdCatTypeId,@tbFontCatLangID, @tbFontCatFontID,@tbFontCatMarkerID,@tbFontCatIMarkerID) 
		SET @newtbFontCatID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblFontCategory', @newtbFontCatID

		DELETE FROM @tempNewFontCategory WHERE FontCategoryId = @CurrentFontCategoryID
	END

	--Iterating to the new temp tables and adding it to the tblFontCategory and tblFontCategoryMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateFontCategory) > 0
	BEGIN		
		SET @CurrentFontCategoryID = (SELECT TOP 1 FontCategoryId FROM @tempUpdateFontCategory)
		SET @tbFontCatGeoRefIdCatTypeId = (SELECT TOP 1 GeoRefIdCatTypeId FROM @tempUpdateFontCategory)
		SET @tbFontCatLangID = (SELECT TOP 1 LanguageID FROM @tempUpdateFontCategory)
		SET @tbFontCatFontID = (SELECT TOP 1 FontID FROM @tempUpdateFontCategory)
		SET @tbFontCatMarkerID = (SELECT TOP 1 MarkerID FROM @tempUpdateFontCategory)
		SET @tbFontCatIMarkerID = (SELECT TOP 1 IMarkerID FROM @tempUpdateFontCategory)

		--Update the tblFont Table and and its Maping Table
		SET @existingFontCategoryId = (SELECT tbFontCat.FontCategoryID FROM config_tblFontCategory(@configid) as tbFontCat
		WHERE tbFontCat.FontID = @tbFontCatFontID AND tbFontCat.GeoRefIdCatTypeID = @tbFontCatGeoRefIdCatTypeId)

		DECLARE @updateFontCatKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblFontCategory', @existingFontCategoryId, @updateFontCatKey out
		SET NOCOUNT OFF
		UPDATE tblFontCategory
		SET LanguageID = @tbFontCatLangID, MarkerID = @tbFontCatMarkerID, IMarkerID = @tbFontCatIMarkerID
		WHERE FontCategoryID = @updateFontCatKey

		DELETE FROM @tempUpdateFontCategory WHERE FontCategoryId = @CurrentFontCategoryID
	END

	DELETE @tempNewFontCategory
	DELETE @tempUpdateFontCategory
END




GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Fonts from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_FontFamily] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_FontFamily]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_FontFamily]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_FontFamily]
		@configid INT
AS
BEGIN
	--For new records
	--DECLARE @tempNewFontFamilyCounter INT, @existingFontFamilyID INT, @newFontFamilyID INT, @CurrentFontFamilyID INT;
	DECLARE @TempId INT,@TempFontFaceID INT, @TempFaceName NVARCHAR(512), @TempFileName NVARCHAR(512),@existingFontFamilyID INT;
	DECLARE @tempNewFontFamily TABLE(ID INT IDENTITY(1,1) NOT NULL,FontFaceID INT NOT NULL, FaceName NVARCHAR(512) NULL,FileName NVARCHAR(512) NULL)
	DECLARE @tempUpdateFontFamily TABLE(ID INT IDENTITY(1,1) NOT NULL,FontFaceID INT NOT NULL, FaceName NVARCHAR(512) NULL,FileName NVARCHAR(512) NULL)

	--For New records
	INSERT INTO @tempNewFontFamily(FontFaceID, FaceName, FileName)
	SELECT TBF.FontFaceId, TBF.FaceName, TBF.FileName FROM AsxiInfotbfontfamily TBF 
	WHERE TBF.FontFaceId NOT IN (SELECT FontFamily.FontFaceId FROM config_tblFontFamily(@configid) AS FontFamily);

	--For Modified records
	INSERT INTO @tempUpdateFontFamily(FontFaceID, FaceName, FileName)
	SELECT TBF.FontFaceId, TBF.FaceName, TBF.FileName FROM AsxiInfotbfontfamily TBF 
	WHERE TBF.FontFaceId IN (SELECT FontFamily.FontFaceId FROM config_tblFontFamily(@configid) AS FontFamily 
				WHERE FontFamily.FaceName != TBF.FaceName OR FontFamily.FileName != TBF.FileName)
	

	--Iterating to the new temp tables and adding it to the tblFontFamilyID and tblFontFamilyMap
	WHILE(SELECT COUNT(*) FROM @tempNewFontFamily) > 0
	BEGIN
		
		SET @TempId = (SELECT TOP 1 ID FROM @tempNewFontFamily)
		SET @TempFontFaceID= (SELECT TOP 1 FontFaceID FROM @tempNewFontFamily)
		SET @TempFaceName= (SELECT TOP 1 FaceName FROM @tempNewFontFamily)
		SET @TempFileName= (SELECT TOP 1 FileName FROM @tempNewFontFamily)

		DECLARE @newtbFontFamilyID INT;
		INSERT INTO tblFontFamily(FontFaceID,FaceName,FileName)
		VALUES (@TempFontFaceID,@TempFaceName,@TempFileName) 
		SET @newtbFontFamilyID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblFontFamily', @newtbFontFamilyID

		DELETE FROM @tempNewFontFamily WHERE ID = @TempId
	END

	--Iterating to the new temp tables and adding it to the tblFontFamilyID and tblFontFamilyMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateFontFamily) > 0
	BEGIN
		
		SET @TempId = (SELECT TOP 1 ID FROM @tempUpdateFontFamily)
		SET @TempFontFaceID= (SELECT TOP 1 FontFaceID FROM @tempUpdateFontFamily)
		SET @TempFaceName= (SELECT TOP 1 FaceName FROM @tempUpdateFontFamily)
		SET @TempFileName= (SELECT TOP 1 FileName FROM @tempUpdateFontFamily)

		--Update the tblFontFamily Table and and its Maping Table
		SET @existingFontFamilyId = (SELECT TBFM.FontFamilyID FROM dbo.config_tblFontFamily(@configid) AS TBFM 
		WHERE TBFM.FontFaceId = @TempFontFaceID)

		DECLARE @updateFontFamilyKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblFontFamily', @existingFontFamilyId, @updateFontFamilyKey out
		SET NOCOUNT OFF
		UPDATE tblFontFamily
		SET   FaceName = @TempFaceName, FileName = @TempFileName
		WHERE FontFamilyID = @updateFontFamilyKey

		DELETE FROM @tempUpdateFontFamily WHERE ID = @TempId
	END

	DELETE @tempNewFontFamily
	DELETE @tempUpdateFontFamily
END



GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Fonts from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_FontMarker] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_FontMarker]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_FontMarker]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_FontMarker]
		@configid INT
AS
BEGIN
	--For new records
	--DECLARE @tempNewFontMarkerCounter INT, @existingFontMarkerID INT, @newFontMarkerID INT, @CurrentFontMarkerID INT;
	DECLARE @TempId INT,@TempMarkerID INT, @TempFileName NVARCHAR(512),@existingFontMarkerID INT;
	DECLARE @tempNewFontMarker TABLE(ID INT IDENTITY(1,1) NOT NULL,MarkerID INT NOT NULL,FileName NVARCHAR(512) NULL)
	DECLARE @tempUpdateFontMarker TABLE(ID INT IDENTITY(1,1) NOT NULL,MarkerID INT NOT NULL,FileName NVARCHAR(512) NULL)

	--For New records
	INSERT INTO @tempNewFontMarker(MarkerID, FileName)
	SELECT TBF.MarkerID,TBF.FileName FROM AsxiInfotbfontMarker TBF 
	WHERE TBF.MarkerID NOT IN (SELECT FontMarker.MarkerID FROM config_tblFontMarker(@configid) AS FontMarker);

	--For Modified records
	INSERT INTO @tempUpdateFontMarker(MarkerID,FileName)
	SELECT TBF.MarkerID,TBF.FileName FROM AsxiInfotbfontMarker TBF 
	WHERE TBF.MarkerID IN (SELECT FontMarker.MarkerID FROM config_tblFontMarker(@configid) AS FontMarker 
				WHERE  FontMarker.FileName != TBF.FileName)
	

	--Iterating to the new temp tables and adding it to the tblFontMarkerID and tblFontMarkerMap
	WHILE(SELECT COUNT(*) FROM @tempNewFontMarker) > 0
	BEGIN
		
		SET @TempId = (SELECT TOP 1 ID FROM @tempNewFontMarker)
		SET @TempMarkerID= (SELECT TOP 1 MarkerID FROM @tempNewFontMarker)
		SET @TempFileName= (SELECT TOP 1 FileName FROM @tempNewFontMarker)

		DECLARE @newtbFontMarkerID INT;
		INSERT INTO tblFontMarker(MarkerID,FileName)
		VALUES (@TempMarkerID,@TempFileName) 
		SET @newtbFontMarkerID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblFontMarker', @newtbFontMarkerID

		DELETE FROM @tempNewFontMarker WHERE ID = @TempId
	END

	--Iterating to the new temp tables and adding it to the tblFontMarkerID and tblFontMarkerMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateFontMarker) > 0
	BEGIN
		
		SET @TempId = (SELECT TOP 1 ID FROM @tempUpdateFontMarker)
		SET @TempMarkerID= (SELECT TOP 1 MarkerID FROM @tempUpdateFontMarker)
		SET @TempFileName= (SELECT TOP 1 FileName FROM @tempUpdateFontMarker)

		--Update the tblFontMarker Table and and its Maping Table
		SET @existingFontMarkerId = (SELECT TBFM.FontMarkerID FROM dbo.config_tblFontMarker(@configid) AS TBFM 
		WHERE TBFM.MarkerID = @TempMarkerID)

		DECLARE @updateFontMarkerKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblFontMarker', @existingFontMarkerId, @updateFontMarkerKey out
		SET NOCOUNT OFF
		UPDATE tblFontMarker
		SET FileName = @TempFileName
		WHERE FontMarkerID = @updateFontMarkerKey

		DELETE FROM @tempUpdateFontMarker WHERE ID = @TempId
	END

	DELETE @tempNewFontMarker
	DELETE @tempUpdateFontMarker
END



GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_GeoRef]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_GeoRef]
END
GO

-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/29/2022
-- Description:	It imports AsxiInfotbgeorefid data to tblGeoRef from asxinfo.sqlite3 
--               This import effect few more other tables such as tblCoverageSegment, tblSpelling and tblResolution as it all has 
--				 GeoRefID dependency.
-- Sample EXEC [dbo].[SP_AsxiInfoImport_GeoRef] 1,
-- =============================================

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_GeoRef]
		@configid INT
AS
BEGIN

	DECLARE @AsxiGeoRefID INT, @AsxiGeoRefCityName NVARCHAR(MAX), @AsxiGeoRefRegionId INT, @AsxiGeoRefCountryId INT,
	 @AsxiGeoRefCatTypeId INT, @AsxiGeoRefisRliPoi BIT, @AsxiGeoRefisInteractivePoi BIT, @AsxiGeoRefisWorldClockPoi BIT,@AsxiGeoRefClosestPOI BIT,
	 @AsxiGeoRefLat FLOAT, @AsxiGeoRefLon FLOAT, @customChangeBitMask INT, @existingvalue INT, @updatedvalue INT;
	DECLARE @dml AS NVARCHAR(MAX);
	DECLARE @ColumnName AS NVARCHAR(MAX);
	 
	DECLARE @tempNewSpelling TABLE (InfoSpellingId INT IDENTITY (1,1) NOT NULL, GeoRefID INT NULL,LangTwoLetter NVARCHAR(2) NULL,LangID INT NULL, UniCodeStr NVARCHAR(MAX));  
	DECLARE @tempSpelling TABLE (TempID INT IDENTITY (1,1) NOT NULL,LangID INT NULL, UniCodeStr NVARCHAR(MAX)); 
	
	SELECT @ColumnName= ISNULL(@ColumnName + ',','') 
       + QUOTENAME(name) from sys.columns c
		where c.object_id = OBJECT_ID('dbo.AsxiInfotbgeorefid') and name LIKE '%Lang%'
	
	--Prepare the PIVOT query using the dynamic   
	SET @dml =   
			N'(SELECT GeoRefID,(SELECT RIGHT( LangTwoLetter, 2 )), UniCodeStr  
				FROM   
				(SELECT GeoRefId, ' +@ColumnName +' 
		
			FROM AsxiInfotbgeorefid) p  
				UNPIVOT  
				(UniCodeStr FOR LangTwoLetter IN   
					(' + @ColumnName + ')  
					)AS unpvtAsxiInfotbgeorefid) '
		--Print @DynamicPivotQuery
	INSERT INTO @tempNewSpelling(GeoRefID,LangTwoLetter,UniCodeStr) EXEC sp_executesql @dml  
		--Execute the Dynamic Pivot Query
	
	
		--Updating two letter codes
		UPDATE T1   
		SET T1.LangID = T2.LanguageID  
			FROM @tempNewSpelling AS T1 INNER JOIN AsxiInfotblanguage T2  
		ON T1.LangTwoLetter = t2.TwoLetterID  

	--resolutionlistTbl has all the resolulations and their mapings
	DECLARE @resolutionlistTbl table (Zlevel INT, res FLOAT, resMap INT);
	INSERT INTO @resolutionlistTbl values (1,0,60), (2,0,120), (3,0,240), (4,0.971922,30), (5,3,0), (6,6,0),(7,15,480),(8,30,960),
		(9,60,0),(10,75,1920),(11,150,3840),(12,300,7680),(13,600,15360),(14,1620,0),(15,2025,0)	

	--For new records
	SELECT TempAsxi.* INTO  #tempNewGeoRefId FROM AsxiInfotbgeorefid AS TempAsxi WHERE TempAsxi.GeoRefId NOT IN 
			(SELECT GeoRef.GeoRefId FROM dbo.config_tblGeoRef(@configid) AS GeoRef);
	
	--For Modified records
	SELECT TempAsxi.* INTO  #tempUpdatedGeoRefId FROM AsxiInfotbgeorefid AS TempAsxi WHERE TempAsxi.GeoRefId IN 
			(SELECT GeoRef.GeoRefId FROM dbo.config_tblGeoRef(@configid) AS GeoRef
				WHERE TempAsxi.RegionId != GeoRef.RegionId OR
							TempAsxi.CountryId != GeoRef.CountryId OR
							TempAsxi.GeoRefIdCatTypeId != GeoRef.AsxiCatTypeId OR
							TempAsxi.RLIPOI != GeoRef.isRliPoi OR
							TempAsxi.IPOI != GeoRef.isInteractivePoi OR
							TempAsxi.WCPOI != GeoRef.isWorldClockPoi OR
							TempAsxi.MakkahPOI != GeoRef.isMakkahPoi OR
							TempAsxi.ClosestPOI != GeoRef.isClosestPoi);
	
	
	
	--Iterating to the new temp tables and adding it to the tblGeoRefId and tblGeoRefIdMap
	WHILE(SELECT COUNT(*) FROM #tempNewGeoRefId) > 0
	BEGIN
		
		SET @AsxiGeoRefID = (SELECT TOP 1 GeoRefID FROM #tempNewGeoRefId)	
		SET @AsxiGeoRefCityName = (SELECT TOP 1 Lang_EN FROM #tempNewGeoRefId)
		SET @AsxiGeoRefCatTypeId = (SELECT TOP 1 GeoRefIdCatTypeId FROM #tempNewGeoRefId)
		SET @AsxiGeoRefRegionId = (SELECT TOP 1 RegionId FROM #tempNewGeoRefId)
		SET @AsxiGeoRefCountryId = (SELECT TOP 1 CountryId FROM #tempNewGeoRefId)
		SET @AsxiGeoRefisRliPoi = (SELECT TOP 1 RLIPOI FROM #tempNewGeoRefId)
		SET @AsxiGeoRefisInteractivePoi= (SELECT TOP 1 IPOI FROM #tempNewGeoRefId)
		SET @AsxiGeoRefisWorldClockPoi= (SELECT TOP 1 WCPOI FROM #tempNewGeoRefId)
		SET @AsxiGeoRefClosestPOI = (SELECT TOP 1 ClosestPOI FROM #tempNewGeoRefId)
		SET @AsxiGeoRefLat = (SELECT TOP 1 Lat FROM #tempNewGeoRefId)
		SET @AsxiGeoRefLon = (SELECT TOP 1 Lon FROM #tempNewGeoRefId)
		INSERT INTO @tempSpelling(LangID,UniCodeStr) SELECT TNS.LangID,TNS.UniCodeStr FROM @tempNewSpelling AS TNS WHERE TNS.GeoRefID = @AsxiGeoRefID


		--Insert tblGeoRef Table and and its Maping Table
		DECLARE @tGeoReftblID INT;
		INSERT INTO tblGeoRef (GeoRefId, Description, AsxiCatTypeId, RegionId, CountryId, isRliPoi, isInteractivePoi, isWorldClockPoi, isMakkahPoi, isClosestPoi, CustomChangeBitMask)
		VALUES (@AsxiGeoRefID,@AsxiGeoRefCityName,@AsxiGeoRefCatTypeId,@AsxiGeoRefRegionId,@AsxiGeoRefCountryId,@AsxiGeoRefisRliPoi,
		@AsxiGeoRefisInteractivePoi,@AsxiGeoRefisInteractivePoi,@AsxiGeoRefisWorldClockPoi,@AsxiGeoRefClosestPOI, 8)
		SET @tGeoReftblID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblGeoRef', @tGeoReftblID

		--Insert tblCoverageSegment Table and and its Maping Table
		DECLARE @CoverageSegmenttblId INT;
		INSERT INTO dbo.tblCoverageSegment(GeoRefId, SegmentId, Lat1, Lon1, Lat2, Lon2, dataSourceId )
		VALUES(@AsxiGeoRefID,1,@AsxiGeoRefLat,@AsxiGeoRefLon,0, 0, 7);
		SET @CoverageSegmenttblId = SCOPE_IDENTITY()
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblCoverageSegment', @CoverageSegmenttblId

		WHILE(SELECT COUNT(*) FROM @tempSpelling) > 0
		BEGIN
			---Insert tblSpelling Table and and its Maping Table
			DECLARE @spellingLangID INT, @spellingInit INT,@spellingUniCodestr NVARCHAR(MAX),@SpellingtblId INT;	
			SET @spellingInit =(SELECT TOP 1 TempID FROM @tempSpelling)
			SET @spellingLangID =(SELECT TOP 1 LangID FROM @tempSpelling)
			SET @spellingUniCodestr =(SELECT TOP 1 UniCodeStr FROM @tempSpelling)
			
			INSERT INTO dbo.tblSpelling ( GeoRefId, LanguageId, UnicodeStr, FontId, SphereMapFontId, dataSourceId )
			VALUES(@AsxiGeoRefID,@spellingLangID,@spellingUniCodestr,1002,1015,7);
			SET @SpellingtblId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblSpelling', @SpellingtblId
			DELETE FROM @tempSpelling WHERE TempID = @spellingInit
		END
		-- Update tblAppearance Table only for English)
		--Update the Maping table List, This is used to iterate tblAppearance table for all the resolutions
		DECLARE @NumRes INT, @Init INT;	
		SELECT @NumRes= COUNT(*) FROM @resolutionlistTbl
		SET @Init =1
		WHILE @Init<= @NumRes
		BEGIN
			DECLARE @AppearancetblId INT;
			INSERT INTO dbo.tblAppearance(GeoRefId,Resolution, ResolutionMpp, Exclude, SphereMapExclude )
			VALUES(@AsxiGeoRefID,(SELECT TOP 1 res FROM @resolutionlistTbl where Zlevel =@Init),(SELECT TOP 1 resMap FROM @resolutionlistTbl where Zlevel =@Init),0,0);
			SET @AppearancetblId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblAppearance', @AppearancetblId
			SET @Init= @Init + 1
		END
		DELETE @tempSpelling
		DELETE FROM #tempNewGeoRefId WHERE GeoRefId = @AsxiGeoRefID
	END


	WHILE(SELECT COUNT(*) FROM #tempUpdatedGeoRefId) > 0
	BEGIN	

		DECLARE @existingGeoRefId INT, @existingSegmentId INT, @existingSpellingId INT, @existingAppearanceId INT

		SET @AsxiGeoRefID = (SELECT TOP 1 GeoRefID FROM #tempUpdatedGeoRefId)	
		SET @AsxiGeoRefCityName = (SELECT TOP 1 Lang_EN FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefCatTypeId = (SELECT TOP 1 GeoRefIdCatTypeId FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefRegionId = (SELECT TOP 1 RegionId FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefCountryId = (SELECT TOP 1 CountryId FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefisRliPoi = (SELECT TOP 1 RLIPOI FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefisInteractivePoi= (SELECT TOP 1 IPOI FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefisWorldClockPoi= (SELECT TOP 1 WCPOI FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefClosestPOI = (SELECT TOP 1 ClosestPOI FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefLat = (SELECT TOP 1 Lat FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefLon = (SELECT TOP 1 Lon FROM #tempUpdatedGeoRefId)
		INSERT INTO @tempSpelling(LangID,UniCodeStr) SELECT TNS.LangID,TNS.UniCodeStr FROM @tempNewSpelling AS TNS WHERE TNS.GeoRefID = @AsxiGeoRefID


		--Update the tblGeoRefId and its Maping Table
		SET @existingGeoRefId = (SELECT GeoRef.ID FROM dbo.config_tblGeoRef(@configid) AS GeoRef 
			WHERE GeoRef.ID = @AsxiGeoRefID)

		DECLARE @updateKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblGeoRef', @existingGeoRefId, @updateKey out

 	 	SET @customChangeBitMask = 2
 	 	SET @existingvalue = (SELECT CustomChangeBitMask FROM tblGeoRef WHERE ID = @updateKey)
 	 	SET @updatedvalue =(@existingvalue | @customChangeBitMask)
		SET NOCOUNT OFF
		UPDATE tblGeoRef
		SET Description = @AsxiGeoRefCityName, CatTypeId = @AsxiGeoRefCatTypeId, RegionId = @AsxiGeoRefRegionId,
		CountryId = @AsxiGeoRefCountryId, isRliPoi = @AsxiGeoRefisRliPoi, isInteractivePoi = @AsxiGeoRefisInteractivePoi,
		isWorldClockPoi = @AsxiGeoRefisWorldClockPoi, isClosestPoi = @AsxiGeoRefClosestPOI, CustomChangeBitMask = @updatedvalue
		WHERE ID = @updateKey


		--Update the tblCoverageSegment Table and and its Maping Table
		SET @existingSegmentId = (SELECT coveragesegment.ID FROM dbo.config_tblCoverageSegment(@configid) AS coveragesegment 
		WHERE coveragesegment.GeoRefID = @AsxiGeoRefID)

		DECLARE @updateSegmentKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblCoverageSegment', @existingSegmentId, @updateSegmentKey out
		SET NOCOUNT OFF
		UPDATE tblCoverageSegment
		SET  Lat1 = @AsxiGeoRefLat, Lon1 = @AsxiGeoRefLon
		WHERE ID = @updateSegmentKey

		WHILE(SELECT COUNT(*) FROM @tempSpelling) > 0
		BEGIN
		
			---Insert tblSpelling Table and and its Maping Table
			DECLARE @updateSpellingKey INT;
			SET @spellingInit =(SELECT TOP 1 TempID FROM @tempSpelling)
			SET @spellingLangID =(SELECT TOP 1 LangID FROM @tempSpelling)
			SET @spellingUniCodestr =(SELECT TOP 1 UniCodeStr FROM @tempSpelling)
			
			--Update the tblSpelling Table and and its Maping Table
			SET @existingSpellingId = (SELECT spelling.SpellingID FROM dbo.config_tblSpelling(@configid) AS spelling 
			WHERE spelling.GeoRefID = @AsxiGeoRefID AND spelling.LanguageID = 1)
			exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblSpelling', @existingSpellingId, @updateSpellingKey out
			SET NOCOUNT OFF
			UPDATE tblSpelling
			SET  UnicodeStr = @spellingUniCodestr, LanguageID = @spellingLangID
			WHERE SpellingID = @updateSpellingKey
			DELETE FROM @tempSpelling WHERE TempID = @spellingInit
		END
		-- Update tblAppearance Table only for English)
		--Update the Maping table List, This is used to iterate tblAppearance table for all the resolutions	
		DELETE @tempSpelling
		DELETE FROM #tempUpdatedGeoRefId WHERE GeoRefID = @AsxiGeoRefID
	END

	DROP TABLE #tempNewGeoRefId
	DROP TABLE #tempUpdatedGeoRefId
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Fonts from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_InfoSpelling] 9
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_InfoSpelling]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_InfoSpelling]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_InfoSpelling]
		@configid INT
AS
BEGIN
 --For new records  
 DECLARE @CurrentInfoSpellingID INT, @existingInfoSpellingId INT, @newInfoSpellingId INT, @tempInfoId INT, @tempLangID INT,@tempInfoSpelling NVARCHAR(MAX);  
 DECLARE @dml AS NVARCHAR(MAX);
 DECLARE @ColumnName AS NVARCHAR(MAX);  
 DECLARE @tempNewInfoSpellingWithIDs TABLE (InfoSpellingId INT IDENTITY (1,1) NOT NULL, InfoId INT NULL, LangTwoLetter NVARCHAR(2) NULL,LangID INT NULL, InfoItem NVARCHAR(MAX)); 
 DECLARE @tempNewInfoSpelling TABLE (InfoSpellingId INT IDENTITY (1,1) NOT NULL, InfoId INT NULL,LangID INT NULL, InfoItem NVARCHAR(MAX));  
 DECLARE @tempUpdateInfoSpelling TABLE (InfoSpellingId INT IDENTITY (1,1) NOT NULL, InfoId INT NULL,LangID INT NULL, InfoItem NVARCHAR(MAX)); 
  
 SELECT @ColumnName= ISNULL(@ColumnName + ',','') 
       + QUOTENAME(name) from sys.columns c
	where c.object_id = OBJECT_ID('dbo.AsxiInfotbinfospelling') and name LIKE '%Lang%'
  
	SET @dml = 
			N'(SELECT InfoId,(SELECT RIGHT( LangTwoLetter, 2 )), InfoItem  
	FROM   
	(SELECT InfoId, ' +@ColumnName +'
	
	FROM AsxiInfotbinfospelling) p  
	UNPIVOT  
	(InfoItem FOR LangTwoLetter IN   
		(' + @ColumnName + ')  
	)AS unpvtAsxiInfotbinfospelling)'	

	
	INSERT INTO @tempNewInfoSpellingWithIDs(InfoId,LangTwoLetter,InfoItem) EXEC sp_executesql @dml  
  
  --Updating two letter codes
 UPDATE T1   
 SET T1.LangID = T2.LanguageID  
 FROM @tempNewInfoSpellingWithIDs AS T1 INNER JOIN AsxiInfotblanguage T2  
 ON T1.LangTwoLetter = t2.TwoLetterID  

 --For New Records
 INSERT INTO @tempNewInfoSpelling(InfoId,LangID,InfoItem)
 SELECT TBIS.InfoId,TBIS.LangID, TBIS.InfoItem FROM @tempNewInfoSpellingWithIDs TBIS
 WHERE CAST(TBIS.InfoId as varchar)+'_'+CAST(TBIS.LangID as varchar) NOT IN (SELECT CAST(TBLIS.InfoId as varchar)+'_'+CAST(TBLIS.LanguageId as varchar)
 FROM config_tblInfoSpelling(@configid) TBLIS)

  --For update Records
 INSERT INTO @tempUpdateInfoSpelling(InfoId,LangID,InfoItem)
 SELECT TBIS.InfoId,TBIS.LangID, TBIS.InfoItem FROM @tempNewInfoSpellingWithIDs TBIS
	WHERE CAST(TBIS.InfoId as varchar)+'_'+CAST(TBIS.LangID as varchar) 
		IN (SELECT CAST(TBLIS.InfoId as varchar)+'_'+CAST(TBLIS.LanguageId as varchar)
				FROM config_tblInfoSpelling(@configid) as TBLIS WHERE TBIS.InfoItem != TBLIS.Spelling)

 	--Iterating to the new temp tables and adding it to the tblInfoSpelling and tblInfoSpellingMap
	WHILE(SELECT COUNT(*) FROM @tempNewInfoSpelling) > 0
	BEGIN		
		SET @CurrentInfoSpellingID = (SELECT TOP 1 InfoSpellingId FROM @tempNewInfoSpelling)
		SET @tempInfoId = (SELECT TOP 1 InfoId FROM @tempNewInfoSpelling)
		SET @tempLangID = (SELECT TOP 1 LangID FROM @tempNewInfoSpelling)
		SET @tempInfoSpelling = (SELECT TOP 1 InfoItem FROM @tempNewInfoSpelling)

		--Insert tblFont Table and and its Maping Table
		DECLARE @newtbInfoSpellingID INT;
		INSERT INTO tblInfoSpelling(InfoId,LanguageID,Spelling)
		VALUES (@tempInfoId,@tempLangID,@tempInfoSpelling) 
		SET @newtbInfoSpellingID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblInfoSpelling', @newtbInfoSpellingID

		DELETE FROM @tempNewInfoSpelling WHERE InfoSpellingId = @CurrentInfoSpellingID
	END

	--Iterating to the udate temp tables and adding it to the tblInfoSpelling and tblInfoSpellingMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateInfoSpelling) > 0
	BEGIN		
		SET @CurrentInfoSpellingID = (SELECT TOP 1 InfoSpellingId FROM @tempUpdateInfoSpelling)
		SET @tempInfoId = (SELECT TOP 1 InfoId FROM @tempUpdateInfoSpelling)
		SET @tempLangID = (SELECT TOP 1 LangID FROM @tempUpdateInfoSpelling)
		SET @tempInfoSpelling = (SELECT TOP 1 InfoItem FROM @tempUpdateInfoSpelling)

		--Update the tblFont Table and and its Maping Table
		SET @existingInfoSpellingId = (SELECT tbInfoSpell.InfoSpellingID FROM config_tblInfoSpelling(@configid) as tbInfoSpell
		WHERE tbInfoSpell.LanguageId = @tempLangID AND tbInfoSpell.InfoId = @tempInfoId)

		DECLARE @updateInfoSpellKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblInfoSpelling', @existingInfoSpellingId, @updateInfoSpellKey out
		SET NOCOUNT OFF
		UPDATE tblInfoSpelling
		SET Spelling = @tempInfoSpelling
		WHERE InfoSpellingID = @updateInfoSpellKey

		DELETE FROM @tempUpdateInfoSpelling WHERE InfoSpellingId = @CurrentInfoSpellingID
	END
 DELETE @tempNewInfoSpelling 
 DELETE @tempUpdateInfoSpelling
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Fonts from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_Language] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_Language]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_Language]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_Language]
		@configid INT
AS
BEGIN
	--For new records
	DECLARE @tempNewLanguageCounter INT, @existingLanguageId INT, @newLanguageId INT, @CurrentLanguageID INT;

	SELECT TempAsxi.* INTO  #tempNewLanguage FROM AsxiInfotblanguage as TempAsxi WHERE TempAsxi.LanguageId NOT IN
			(SELECT T.LanguageID FROM tblLanguages T INNER JOIN tblLanguagesMap TMap ON T.ID = TMap.LanguageID
				WHERE TMap.ConfigurationID = @configid);
	
	--For Modified records
	SELECT TempAsxi.* INTO  #tempUpdateLanguage FROM AsxiInfotblanguage as TempAsxi WHERE TempAsxi.LanguageId IN
			(SELECT T.LanguageID FROM tblLanguages T INNER JOIN tblLanguagesMap TMap ON T.ID = TMap.LanguageID
				WHERE (TempAsxi.Name != T.Name OR
							TempAsxi.TwoLetterID != T.[2LetterID_ASXi] OR
							TempAsxi.ThreeLetterID != T.[3LetterID_ASXi] OR
							TempAsxi.HorizontalOrder != T.HorizontalOrder OR
							TempAsxi.HorizontalScroll != T.HorizontalScroll OR
							TempAsxi.VerticalOrder != T.VerticalOrder OR
							TempAsxi.VerticalScroll != T.VerticalScroll) AND TMap.ConfigurationID = @configid);

	--Iterating to the new temp tables and adding it to the tblLanguage and tblLanguageMap
	WHILE(SELECT COUNT(*) FROM #tempNewLanguage) > 0
	BEGIN
		
		SET @CurrentLanguageID = (SELECT TOP 1 LanguageId FROM #tempNewLanguage)

		INSERT INTO tblLanguages(LanguageID,Name,[2LetterID_ASXi],[3LetterID_ASXi],HorizontalOrder,HorizontalScroll,VerticalOrder,VerticalScroll)
		SELECT @CurrentLanguageID,TN.Name,TN.TwoLetterID,TN.ThreeLetterID,TN.HorizontalOrder,TN.HorizontalScroll,TN.VerticalOrder,TN.VerticalScroll 
		FROM #tempNewLanguage TN WHERE TN.LanguageId = @CurrentLanguageID

		SET @newLanguageId = (SELECT COALESCE((SELECT Max(ID) FROM tblLanguages), 0 ) )

		INSERT INTO tblLanguagesMap(ConfigurationID,LanguageID,PreviousLanguageID,IsDeleted)
		VALUES (@configid,@newLanguageId,0, 0)

		DELETE FROM #tempNewLanguage WHERE LanguageId = @CurrentLanguageID
	END

	--Iterating to the new temp tables and adding it to the tblLanguage and tblLanguageMap
	WHILE(SELECT COUNT(*) FROM #tempUpdateLanguage) > 0
	BEGIN
		
		SET @CurrentLanguageID = (SELECT TOP 1 LanguageId FROM #tempUpdateLanguage)
		SET @existingLanguageId = (SELECT MAX(ID) FROM tblLanguages WHERE LanguageID = @CurrentLanguageID)

		INSERT INTO tblLanguages(LanguageID,Name,[2LetterID_ASXi],[3LetterID_ASXi],HorizontalOrder,HorizontalScroll,VerticalOrder,VerticalScroll)
		SELECT @CurrentLanguageID,TN.Name,TN.TwoLetterID,TN.ThreeLetterID,TN.HorizontalOrder,TN.HorizontalScroll,TN.VerticalOrder,TN.VerticalScroll 
		FROM #tempUpdateLanguage TN WHERE TN.LanguageId = @CurrentLanguageID

		SET @newLanguageId = (SELECT COALESCE((SELECT Max(ID) FROM tblLanguages), 0 ) )
		
		UPDATE tblLanguagesMap
		SET LanguageID = @newLanguageId,PreviousLanguageID = @existingLanguageId WHERE LanguageID = @existingLanguageId

		DELETE FROM #tempUpdateLanguage WHERE LanguageId = @CurrentLanguageID
	END

	DROP TABLE #tempNewLanguage
	DROP TABLE #tempUpdateLanguage
END



GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Regions from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_Region] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_Region]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_Region]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_Region]
		@configid INT
AS
BEGIN
	--For new records
	DECLARE @tempNewSpellingCounter INT,@tempUpdateSpellingCounter INT, @existingSpellingID INT, @newSpellingID INT, @CurrentRegionID INT, @CurrentLanguageID INT,@CurrentRegionName NVARCHAR (255);
	CREATE TABLE #tempNewRegionWithIDs (SpellingID INT IDENTITY (1,1) NOT NULL, RegionID INT NULL,RegionName NVARCHAR (255) NULL, LanguageID INT NULL);

	--Sqlite Database table tbRegion not have Language ID with it, So Joining AsxiInfotblanguage and tbRegion to Grab Language ID
	SELECT tempLang.*,CONCAT('Lang_',TwoLetterID) as RegionCode INTO #tempNewLang FROM AsxiInfotblanguage as tempLang
	DECLARE @dml AS NVARCHAR(MAX);
	DECLARE @ColumnName AS NVARCHAR(MAX); 

	SELECT @ColumnName= ISNULL(@ColumnName + ',','')   
       + QUOTENAME(name) from sys.columns c  
		WHERE c.object_id = OBJECT_ID('dbo.AsxiInfotbregion') and name LIKE '%Lang%'  

 --Prepare the PIVOT query using the dynamic   
	SET @dml =
	'(SELECT RT.RegionId,RT.RegionName,TNL.LanguageID FROM #tempNewLang TNL
	INNER JOIN 
	(SELECT RegionId,RegionCode,RegionName FROM AsxiInfotbregion
		UNPIVOT(RegionName FOR RegionCode IN (' + @ColumnName + ')) AS T)  RT
		ON TNL.RegionCode = RT.RegionCode)'

	INSERT INTO #tempNewRegionWithIDs  EXEC sp_executesql @dml

	--select * from #tempNewRegionWithIDs
	--For new records
	SELECT TempAsxi.* INTO  #tempNewRegion FROM #tempNewRegionWithIDs as TempAsxi WHERE CAST(TempAsxi.RegionID as nvarchar)+CAST(TempAsxi.LanguageID as nvarchar) NOT IN
			(SELECT CAST(T.RegionID as nvarchar)+CAST(T.LanguageID as nvarchar) FROM tblRegionSpelling T INNER JOIN tblRegionSpellingMap TMap ON T.SpellingID = TMap.SpellingID
				WHERE TMap.ConfigurationID = @configid);
	
	--For Modified records
	SELECT TempAsxi.* INTO  #tempUpdateRegion FROM #tempNewRegionWithIDs as TempAsxi WHERE CAST(TempAsxi.RegionID as nvarchar)+CAST(TempAsxi.LanguageID as nvarchar) IN
			(SELECT CAST(T.RegionID as nvarchar)+CAST(T.LanguageID as nvarchar) FROM tblRegionSpelling T INNER JOIN tblRegionSpellingMap TMap ON T.SpellingID = TMap.SpellingID
			WHERE (TempAsxi.RegionName != T.RegionName ) AND TMap.ConfigurationID = @configid);

	--Iterating to the new temp tables and adding it to the tblRegionSpelling and tblRegionSpellingMap
	WHILE(SELECT COUNT(*) FROM #tempNewRegion) > 0
	BEGIN

		SET @tempNewSpellingCounter = (SELECT TOP 1 SpellingID FROM #tempNewRegion)

		SET @CurrentRegionID = (SELECT TOP 1 RegionID FROM #tempNewRegion)
		SET @CurrentLanguageID = (SELECT TOP 1 LanguageID FROM #tempNewRegion)
		SET @CurrentRegionName = (SELECT TOP 1 RegionName FROM #tempNewRegion)
		
		--Insert tblRegion Table and and its Maping Table
		DECLARE @newtbSpellingID INT;
		INSERT INTO tblRegionSpelling(RegionID,RegionName,LanguageId)
		VALUES (@CurrentRegionID,@CurrentRegionName,@CurrentLanguageID) 
		SET @newtbSpellingID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblRegionSpelling', @newtbSpellingID

		DELETE FROM #tempNewRegion WHERE SpellingID = @tempNewSpellingCounter
	END

	--Iterating to the new temp tables and adding it to the tblRegionSpelling and tblRegionSpellingMap
	WHILE(SELECT COUNT(*) FROM #tempUpdateRegion) > 0
	BEGIN
		
		SET @tempUpdateSpellingCounter = (SELECT TOP 1 SpellingID FROM #tempUpdateRegion)
		SET @CurrentRegionName = (SELECT TOP 1 RegionName FROM #tempUpdateRegion)
		SET @CurrentRegionID = (SELECT TOP 1 RegionID FROM #tempUpdateRegion)
		SET @CurrentLanguageID= (SELECT TOP 1 LanguageID FROM #tempUpdateRegion)
		SET @existingSpellingID= (SELECT TRS.SpellingID FROM tblRegionSpelling TRS INNER JOIN tblRegionSpellingMap TRSM
		ON TRS.SpellingID = TRSM.SpellingID AND TRSM.ConfigurationID = @configid
		WHERE TRS.RegionID = @CurrentRegionID AND TRS.LanguageId = @CurrentLanguageID)

		DECLARE @updateSpellKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblRegionSpelling', @existingSpellingID, @updateSpellKey out
		SET NOCOUNT OFF
		UPDATE tblRegionSpelling
		SET RegionName = @CurrentRegionName
		WHERE SpellingID = @updateSpellKey

		DELETE FROM #tempUpdateRegion WHERE SpellingID = @tempUpdateSpellingCounter
	END

	DROP TABLE #tempNewRegion
	DROP TABLE #tempUpdateRegion
	DROP TABLE #tempNewRegionWithIDs
	DROP TABLE #tempNewLang
END



GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/18/2022
-- Description:	returns list of cities in the asxiinset table for given configuration id 
-- Sample EXEC [dbo].[SP_AsxiInset_GetCities] '1','all'
-- =============================================

IF OBJECT_ID('[dbo].[SP_AsxiInset_GetCities]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInset_GetCities]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInset_GetCities]
    @configurationId Int,
	@type VARCHAR(250),
	@cityType NVARCHAR(200) = ''
AS
BEGIN
	IF (@type = 'all')
	BEGIN
		IF (@cityType = 'hf')
		BEGIN
			SELECT DISTINCT inset.ASXiInsetID,inset.InsetName,ISNULL(inset.IsHf, 0) AS IsHF,ISNULL(inset.IsUHf, 0) AS IsUHf 
			FROM dbo.config_tblASXiInset(1) as inset WHERE inset.IsHf = 1
		END
		ELSE IF (@cityType = 'uhf')
		BEGIN
			SELECT DISTINCT inset.ASXiInsetID,inset.InsetName,ISNULL(inset.IsHf, 0) AS IsHF,ISNULL(inset.IsUHf, 0) AS IsUHf
			FROM dbo.config_tblASXiInset(1) as inset WHERE INSET.IsUHf = 15
		END
	END	
	ELSE IF(@type = 'hf')
	BEGIN
		SELECT DISTINCT inset.ASXiInsetID,inset.InsetName,inset.IsHf FROM dbo.config_tblASXiInset(@configurationId) as inset WHERE inset.IsHf = 1
	END	
	ELSE IF(@type = 'uhf')
	BEGIN
		SELECT DISTINCT inset.ASXiInsetID,inset.InsetName,inset.IsUHf FROM dbo.config_tblASXiInset(@configurationId) as inset WHERE inset.IsUHf = 1
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/18/2022
-- Description:	updates isHF/isUHF flag for given inset id for given configuration
-- Sample EXEC [dbo].[SP_AsxiInset_UpdateCity] '1','hf',1
-- =============================================

IF OBJECT_ID('[dbo].[SP_AsxiInset_UpdateCity]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInset_UpdateCity]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInset_UpdateCity]
    @configurationId Int,
	@type VARCHAR(MAX),
	@selected BIT,
	@ASXiInsetID INT,
	@action NVARCHAR(250)
AS
BEGIN
	IF (@action = 'insert')
	BEGIN
		INSERT INTO tblASXiInsetMap (ConfigurationID, ASXiInsetID,PreviousASXiInsetID,IsDeleted,Action)
		VALUES (@configurationId, @ASXiInsetID, 0, 0, 'adding')
	END
	ELSE IF (@action = 'delete')
	BEGIN
		UPDATE tblASXiInsetMap SET IsDeleted = 1 WHERE ASXiInsetID = @ASXiInsetID AND ConfigurationID = @configurationId
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 15/06/2022
-- Description:	marks the cancelled attribute as true for given task id
-- Sample EXEC [dbo].[SP_Build_Cancel] 'ed8032dd-ad8f-42af-9895-c941a57993dd'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Build_Cancel]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Build_Cancel]
END
GO

CREATE PROCEDURE [dbo].[SP_Build_Cancel]
	@taskId UNIQUEIDENTIFIER
	AS
BEGIN
	
	UPDATE dbo.tblTasks SET Cancelled = 1 WHERE ID = @taskId
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 15/06/2022
-- Description:	deletes the build with given id, also unlocks the configuration if required
-- Sample EXEC [dbo].[SP_Build_Delete] 'ed8032dd-ad8f-42af-9895-c941a57993dd'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Build_Delete]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Build_Delete]
END
GO

CREATE PROCEDURE [dbo].[SP_Build_Delete]
	@taskId UNIQUEIDENTIFIER
	AS
BEGIN
	
	UPDATE
	dbo.tblConfigurations
	SET Locked = 0
	WHERE dbo.tblConfigurations.ConfigurationID IN (SELECT ConfigurationID FROM dbo.tblTasks WHERE ID = @taskId)

	DELETE 
	FROM dbo.tblTasks
	WHERE ID = @taskId
	
END

GO
GO


-- =============================================
-- Author:		Prajna Hegde
-- Create date: 09/06/2022
-- Description:	Returns list of all/in progress  builds for the given user
-- EXEC dbo.SP_Build_Get '4dbed025-b15f-4760-b925-34076d13a10a','all'
-- =============================================
IF OBJECT_ID('[dbo].[SP_Build_Get]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Build_Get]
END
GO

CREATE PROCEDURE [dbo].[SP_Build_Get]
	@userId UNIQUEIDENTIFIER,
    @type VARCHAR(MAX)
AS
BEGIN

    IF (@type = 'all')
    BEGIN

        SELECT dbo.tblTasks.ID ,
        dbo.tblTaskStatus.Name as BuildStatus, 
        dbo.tblTasks.PercentageComplete ,
        case
            when  tblProducts.Name is not null then tblProducts.Name    
            when tblPlatforms.Name is not null then tblPlatforms.Name    
            when tblGlobals.Name is not null then tblGlobals.Name
            when Aircraft.Id is not null then Aircraft.TailNumber   
        end as DefinitionName,
        dbo.tblTasks.DateStarted,
        dbo.tblConfigurations.Version as ConfigurationVersion,
        dbo.tblConfigurations.ConfigurationID,
        dbo.tblConfigurations.ConfigurationDefinitionID,
		dbo.tblTaskType.Name AS TaskTypeName


        FROM (((((((((((dbo.tblTasks (nolock)

        INNER JOIN dbo.tblTaskStatus ON dbo.tblTaskStatus.ID = dbo.tblTasks.TaskStatusID )
        INNER JOIN dbo.tblTaskType ON dbo.tblTasks.TaskTypeID = dbo.tblTaskType.ID AND dbo.tblTaskType.ShouldShowInBuildDashboard = 1)
        INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationID =  dbo.tblTasks.ConfigurationID)

        LEFT OUTER JOIN tblProductConfigurationMapping on tblProductConfigurationMapping.ConfigurationDefinitionID =  dbo.tblTasks.ConfigurationDefinitionID )
        LEFT OUTER JOIN dbo.tblProducts on tblProducts.ProductID = tblProductConfigurationMapping.ProductID)   

        LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID =  dbo.tblTasks.ConfigurationDefinitionID)
        LEFT OUTER JOIN dbo.tblPlatforms on tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID)   

        LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = dbo.tblTasks.ConfigurationDefinitionID)
        LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID)   

        LEFT OUTER JOIN tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.ConfigurationDefinitionID = tblConfigurations.ConfigurationDefinitionID)
        LEFT OUTER JOIN Aircraft ON Aircraft.Id = tblAircraftConfigurationMapping.AircraftID)

        WHERE 
        dbo.tblTasks.ConfigurationDefinitionID <> 1 AND( dbo.tblTasks.StartedByUserID = @userId  
        OR dbo.tblTasks.ConfigurationID IN ( 
   
           select distinct tblConfigurations.ConfigurationID
         
           from(aspnetusers 
           inner join UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id 
           inner join UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid 
           inner join UserClaims on UserClaims.id = UserRoleClaims.claimid 
           inner join tblconfigurationdefinitions on tblconfigurationdefinitions.ConfigurationDefinitionID = UserRoleClaims.ConfigurationDefinitionID or UserRoleClaims.ConfigurationDefinitionID is null and tblconfigurationdefinitions.active = 1 
           inner join tblConfigurations on tblconfigurationdefinitions.ConfigurationDefinitionID = tblConfigurations.ConfigurationDefinitionID ) 
 
           LEFT OUTER JOIN tblProductConfigurationMapping on tblProductConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManageProductConfiguration' 

           LEFT OUTER JOIN dbo.tblProducts on tblProducts.ProductID = tblProductConfigurationMapping.ProductID 

           LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManagePlatformConfiguration' 
           LEFT OUTER JOIN dbo.tblPlatforms on tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID 

           LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'Manage Global Configuration' 
           LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID 

           where 
           UserClaims.name in ('ManagePlatformConfiguration', 'ManageProductConfiguration', 'Manage Global Configuration') 
           and aspnetusers.Id = @userId
		   ))order by dbo.tblProducts.Name, dbo.tblPlatforms.Name, dbo.Aircraft.TailNumber
 
 

    END
    ELSE
    BEGIN

        SELECT dbo.tblTasks.ID ,
        dbo.tblTaskStatus.Name as BuildStatus, 
        dbo.tblTasks.PercentageComplete ,
        case
            when  tblProducts.Name is not null then tblProducts.Name    
            when tblPlatforms.Name is not null then tblPlatforms.Name    
            when tblGlobals.Name is not null then tblGlobals.Name
            when Aircraft.Id is not null then Aircraft.TailNumber   
        end as DefinitionName,
        dbo.tblTasks.DateStarted,
        dbo.tblConfigurations.Version as ConfigurationVersion,
        dbo.tblConfigurations.ConfigurationID,
        dbo.tblConfigurations.ConfigurationDefinitionID,
		dbo.tblTaskType.Name AS TaskTypeName
        FROM (((((((((((dbo.tblTasks(nolock)

        INNER JOIN dbo.tblTaskStatus ON dbo.tblTaskStatus.ID = dbo.tblTasks.TaskStatusID AND (dbo.tblTaskStatus.Name = 'In Progress' OR dbo.tblTaskStatus.Name = 'Not Started'))
        INNER JOIN dbo.tblTaskType ON dbo.tblTasks.TaskTypeID = dbo.tblTaskType.ID AND dbo.tblTaskType.ShouldShowInBuildDashboard = 1)
        INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationID =  dbo.tblTasks.ConfigurationID)

        LEFT OUTER JOIN tblProductConfigurationMapping on tblProductConfigurationMapping.ConfigurationDefinitionID =  dbo.tblTasks.ConfigurationDefinitionID )
        LEFT OUTER JOIN dbo.tblProducts on tblProducts.ProductID = tblProductConfigurationMapping.ProductID)   

        LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID =  dbo.tblTasks.ConfigurationDefinitionID)
        LEFT OUTER JOIN dbo.tblPlatforms on tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID)   

        LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = dbo.tblTasks.ConfigurationDefinitionID)
        LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID)   

        LEFT OUTER JOIN tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.ConfigurationDefinitionID = tblConfigurations.ConfigurationDefinitionID)
        LEFT OUTER JOIN Aircraft ON Aircraft.Id = tblAircraftConfigurationMapping.AircraftID)

        WHERE 
        dbo.tblTasks.ConfigurationDefinitionID <> 1 AND(dbo.tblTasks.StartedByUserID = @userId  
        OR dbo.tblTasks.ConfigurationID IN ( 
   
           select distinct tblConfigurations.ConfigurationID
         
           from(aspnetusers 
           inner join UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id 
           inner join UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid 
           inner join UserClaims on UserClaims.id = UserRoleClaims.claimid 
           inner join tblconfigurationdefinitions on tblconfigurationdefinitions.ConfigurationDefinitionID = UserRoleClaims.ConfigurationDefinitionID or UserRoleClaims.ConfigurationDefinitionID is null and tblconfigurationdefinitions.active = 1 
           inner join tblConfigurations on tblconfigurationdefinitions.ConfigurationDefinitionID = tblConfigurations.ConfigurationDefinitionID ) 
 
           LEFT OUTER JOIN tblProductConfigurationMapping on tblProductConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManageProductConfiguration' 

           LEFT OUTER JOIN dbo.tblProducts on tblProducts.ProductID = tblProductConfigurationMapping.ProductID 

           LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManagePlatformConfiguration' 
           LEFT OUTER JOIN dbo.tblPlatforms on tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID 

           LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'Manage Global Configuration' 
           LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID 

           where 
           UserClaims.name in ('ManagePlatformConfiguration', 'ManageProductConfiguration', 'Manage Global Configuration') 
           and aspnetusers.Id = @userId
		   ))
 

    END


END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 08/25/2022
-- Description:	Get any current active import process based on the page name and configuration id
-- Sample EXEC [dbo].[SP_Build_GetActiveImportStatus] 'populations', 105
-- =============================================

IF OBJECT_ID('[dbo].[SP_Build_GetActiveImportStatus]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Build_GetActiveImportStatus]
END
GO

CREATE PROCEDURE [dbo].[SP_Build_GetActiveImportStatus]
	@pageName NVARCHAR(250),
	@configurationId INT
AS
	DECLARE @name NVARCHAR(250), @taskType UNIQUEIDENTIFIER
	DECLARE @BuildStatus TABLE(ID UNIQUEIDENTIFIER, DetailedStatus NVARCHAR(250), PercentageComplete NVARCHAR(250), DateStarted NVARCHAR(250), Version INT)

	SELECT 
	@name = CASE @pageName
			WHEN 'populations' THEN 'Import CityPopulation'
			WHEN 'airports' THEN 'Import NewAirportFromNavDB'
			WHEN 'placenames' THEN 'Import NewPlaceNames'
			WHEN 'world guide' THEN 'Import WGCities'
	END

	IF EXISTS (SELECT 1 FROM tblTasks T INNER JOIN tblConfigurations C ON T.ConfigurationID = C.ConfigurationID WHERE T.ConfigurationID = @configurationId)
	BEGIN
		INSERT INTO @BuildStatus(ID, DetailedStatus, PercentageComplete, DateStarted, Version) SELECT TOP 1 ID, DetailedStatus, PercentageComplete, FORMAT(DateStarted, 'MM/dd/yyyy') AS DateStarted, C.Version FROM tblTasks T
		INNER JOIN tblConfigurations C ON T.ConfigurationID = C.ConfigurationID
		WHERE T.ConfigurationID = @configurationId 
		AND T.TaskTypeID IN (SELECT ID FROM tblTaskType WHERE Name = @name) ORDER BY DateStarted DESC
	END

	ELSE
	BEGIN
		INSERT INTO @BuildStatus(ID, DetailedStatus, PercentageComplete, DateStarted, Version) SELECT TOP 1 T.ID, T.DetailedStatus, T.PercentageComplete, FORMAT(T.DateStarted, 'MM/dd/yyyy') AS DateStarted, C.Version FROM tblTasks T
		INNER JOIN tblConfigurations C ON T.ConfigurationID = C.ConfigurationID
		INNER JOIN tblTaskType TT ON T.TaskTypeID = TT.ID
		WHERE T.ConfigurationID  IN (SELECT ConfigurationID FROM tblConfigurations WHERE ConfigurationDefinitionID IN
		(SELECT ConfigurationDefinitionID FROM tblConfigurations WHERE ConfigurationID = @configurationId)) AND TT.Name = @name ORDER BY DateStarted DESC
	END

	SELECT * FROM @BuildStatus
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/03/2022
-- Description:	The procedure is used to get errors logs for given task
-- Sample EXEC [dbo].[SP_Build_GetErrorLog] 'ed8032dd-ad8f-42af-9895-c941a57993dd'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Build_GetErrorLog]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Build_GetErrorLog]
END
GO

CREATE PROCEDURE [dbo].[SP_Build_GetErrorLog]
	@taskId UNIQUEIDENTIFIER
	AS
BEGIN
	
	SELECT
	CASE 
		WHEN tblTasks.DetailedStatus = 'Failed due to cancellation' THEN tblTasks.DetailedStatus
		WHEN tbltasks.ErrorLog is NULL THEN 'Build failed' ELSE tbltasks.ErrorLog END
	FROM tbltasks(nolock) WHERE ID = @taskId ORDER BY DateLastUpdated DESC
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 15/06/2022
-- Description:	returns progress and task id for given list of task ids(comma seperated string)
-- Sample EXEC [dbo].[SP_Build_GetProgress] "893252a8-c80d-41ee-81fc-11c5b477d778,47285d00-1bef-449c-b890-b3d3da4dab84"
-- =============================================

IF OBJECT_ID('[dbo].[SP_Build_GetProgress]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Build_GetProgress]
END
GO

CREATE PROCEDURE [dbo].[SP_Build_GetProgress]
	@taskIds VARCHAR(MAX)
	AS
BEGIN
	
	DECLARE @temp TABLE(taskId UNIQUEIDENTIFIER)
	INSERT INTO @temp SELECT * FROM STRING_SPLIT(@taskIds, ',')

	SELECT dbo.tblTasks.ID, dbo.tbltasks.PercentageComplete, dbo.tblTasks.DetailedStatus, FORMAT(dbo.tblTasks.DateStarted, 'MM/dd/yyyy') AS DateStarted
	FROM dbo.tblTasks (nolock) WHERE dbo.tblTasks.ID IN (SELECT * FROM @temp)
	
	
	
END

GO
GO



DROP PROC IF EXISTS SP_CheckAndCreateTicker
GO
CREATE PROC SP_CheckAndCreateTicker
@configurationId INT
AS
BEGIN
DECLARE @count INT

SELECT @count=COUNT(1) from cust.tblTickerMap WHERE ConfigurationID=@configurationId

IF @count=0
BEGIN
DECLARE @tickerXML NVARCHAR(MAX)='<ticker position="bottom" speed="0" visible="true" />'
INSERT INTO cust.tblTicker(Ticker) VALUES(@tickerXML);

DECLARE @ticketId INT

SELECT @ticketId=SCOPE_IDENTITY();

EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblTicker',@ticketId
SELECT @ticketId
END
ELSE
SELECT 1
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 02/14/2022
-- Description:	Import Latest CityPopulation Data
--				Date 02/17/2022 Lakshmikanth Updated the SP to record PreviousCityPopulationID in the tables
--				Date 03/31/2022 Laksmikanth Updated the SP to update ConfigurationHistoryTable
-- Sample EXEC [dbo].[SP_CityPopulation_Import] 105, '4DBED025-B15F-4760-B925-34076D13A10A' , '23e75fe0-d2dd-4098-8a6e-e10588b2fed2'
-- =============================================

IF OBJECT_ID('[dbo].[SP_CityPopulation_Import]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_CityPopulation_Import]
END
GO

CREATE PROCEDURE [dbo].[SP_CityPopulation_Import]
	@configid INT,
	@LastModifiedBy NVARCHAR(250),
	@currentTaskID NVARCHAR(50)	

AS
BEGIN
	DECLARE @userName NVARCHAR(50),@LatestConfigHistoryID NVARCHAR(50);
	DECLARE @tempCityPopIds table (CityPopId int,cityunCodeID int);
	DECLARE @tempPreviousCityPopIds table (PrevCityPopId int,PrevCityunCodeId int);

	--Copying the PreviousCityPopulationID to @tempPreviousCityPopIds
	INSERT INTO @tempPreviousCityPopIds(PrevCityPopId,PrevCityunCodeId) 
	SELECT MAX(CityPopulationID),UnCodeID FROM tblCityPopulation GROUP BY UnCodeID

	--Updating the CityPopulation from tblTempCityPopulation
	INSERT INTO [dbo].[tblCityPopulation](GeoRefID,UnCodeID,Population,SourceDate)
	--Adding newly created CityPopulationIDs in to tempCityPopIds Table for later use
	OUTPUT Inserted.CityPopulationID ,Inserted.UnCodeID into @tempCityPopIds
	SELECT  GeoRef.GeoRefId, GeoRef.UnCodeId,TempCP.Population,CONVERT(datetime, TempCP.Year) 
	FROM dbo.tblgeoref GeoRef INNER JOIN dbo.tblTempCityPopulation TempCP 
	ON TempCP.CityCode = GeoRef.UnCodeId;

	--If tblCityPopulation doesnot have any data , set null to PreviousCityPopulationID
	INSERT INTO  @tempPreviousCityPopIds (PrevCityunCodeId) SELECT cityunCodeID
	FROM @tempCityPopIds
	WHERE (SELECT COUNT(*) FROM @tempPreviousCityPopIds) = 0;

	-- Delete the existing entries in the dbo. tblCityPopulationMap table for the configuration id to avoid duplicate inserts.
	UPDATE dbo.tblCityPopulationMap
	SET IsDeleted = 1
	WHERE dbo.tblCityPopulationMap.ConfigurationID = @configid;
	
	--Delete the existing entries in the dbo.tblTempCityPopulation once update is complete !
	DELETE [dbo].[tblTempCityPopulation]

	--Update the Mapping table
	INSERT INTO [dbo].[tblCityPopulationMap](ConfigurationID,CityPopulationID,PreviousCityPopulationID,IsDeleted)
	SELECT @configid, temp1.CityPopId,temp2.PrevCityPopId,0 FROM @tempCityPopIds temp1
	INNER JOIN @tempPreviousCityPopIds temp2 ON temp2.PrevCityunCodeId = temp1.cityunCodeID;

	--Update tblConfigurationHistory with the content
	DECLARE @comment NVARCHAR(MAX)
	SET @comment = ('Imported new population data for ' + (SELECT CT.Name FROM tblConfigurations C
				INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
				INNER JOIN tblConfigurationTypes CT ON CD.ConfigurationTypeID = CT.ConfigurationTypeID
				WHERE C.ConfigurationID = @configid) + ' configuration version V' + CONVERT(NVARCHAR(10),(SELECT C.Version FROM tblConfigurations C
				INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
				WHERE C.ConfigurationID = @configid)))

	SET @userName =   (SELECT FirstName + ' ' + LastName FROM dbo.AspNetUsers WHERE Id IN (SELECT StartedByUserID FROM tblTasks WHERE Id = @currentTaskID) );

	IF EXISTS (SELECT 1 FROM tblConfigurationHistory WHERE ContentType = 'populations' AND ConfigurationID = @configid)
	BEGIN
		UPDATE tblConfigurationHistory SET UserComments = @comment, DateModified = GETDATE(), TaskID = CONVERT(uniqueidentifier ,@currentTaskID), CommentAddedBy = @userName
		WHERE ContentType = 'populations' AND ConfigurationID = @configid
	END
	ELSE
	BEGIN
		INSERT INTO dbo.tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID,UserComments)
		VALUES(@configid,'populations',@userName,GETDATE(),CONVERT(uniqueidentifier,@currentTaskID),@comment)
	END
END
GO

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Adds new compass airplanes
-- Sample EXEC [dbo].[SP_Compass_GetAvailableAircraftAndLocation] 223, 'aircraft'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Compass_GetAvailableAircraftAndLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_GetAvailableAircraftAndLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_GetAvailableAircraftAndLocation]  
@configurationId INT,  
@type NVARCHAR(150)  
AS  
BEGIN  
 DECLARE @inputstring NVARCHAR(1000), @location NVARCHAR(500), @geoRefId NVARCHAR(500)
 DECLARE @tempTable TABLE (name NVARCHAR(500), georefID NVARCHAR(500))
 IF (@type = 'location')  
  BEGIN
	IF EXISTS(SELECT R.RLI
			FROM cust.config_tblRLI(@configurationId) as R
			WHERE R.RLI.exist('/rli/location1') = 1)
	BEGIN
		SET @location = (SELECT rli.value('(rli/location1/@name)[1]', 'varchar(max)')
					FROM cust.config_tblRLI(@configurationId) as R)

		SET @geoRefId = (SELECT rli.value('(rli/location1)[1]', 'varchar(max)')
				FROM cust.config_tblRLI(@configurationId) as R)

		INSERT INTO @tempTable VALUES (@location, @geoRefId)
	END
	ELSE
	BEGIN
		INSERT INTO @tempTable VALUES ('Closest Location', -3)
	END

	IF EXISTS(SELECT R.RLI FROM cust.config_tblRLI(@configurationId) as R

			WHERE R.RLI.exist('/rli/location2') = 1)
	BEGIN
		SET @location = (SELECT rli.value('(rli/location2/@name)[1]', 'varchar(max)')
						FROM cust.config_tblRLI(@configurationId) as R)

		SET @geoRefId = (SELECT rli.value('(rli/location2)[1]', 'varchar(max)') 				
				FROM cust.config_tblRLI(@configurationId) as R)

			INSERT INTO @tempTable VALUES (@location, @geoRefId)
	END
	ELSE
	BEGIN
		INSERT INTO @tempTable VALUES ('Closest Location', -3)
	END
	SELECT * FROM @tempTable
  END  
 ELSE IF (@type = 'aircraft')  
  BEGIN  
    SET @inputstring =(SELECT (rli.value('(rli/airplanes)[1]', 'varchar(max)')) AS Airplanes  
  						FROM cust.config_tblRLI(@configurationId) as R)  

    SELECT ty.Name,ty.[AeroPlaneTypeID] FROM  [dbo].[tblRliAeroPlaneTypes] ty INNER JOIN [dbo].[tblRliAeroPlaneTypesMap]
				tyMap on ty.[AeroPlaneTypeID] = tyMap.[AeroPlaneTypeID] WHERE [ConfigurationID]=@configurationId AND ty.Name IN (SELECT * FROM STRING_SPLIT(@inputstring, ','))
  END  
 ELSE IF (@type = 'available')  
  BEGIN  

	SET @inputstring =(SELECT (rli.value('(rli/airplanes)[1]', 'varchar(max)')) AS Airplanes  
  	FROM cust.config_tblRLI(@configurationId) as R)  


	SELECT ty.Name,ty.[AeroPlaneTypeID] FROM  [dbo].[tblRliAeroPlaneTypes] ty INNER JOIN [dbo].[tblRliAeroPlaneTypesMap]
				tyMap on ty.[AeroPlaneTypeID] = tyMap.[AeroPlaneTypeID] WHERE [ConfigurationID]=@configurationId 
				AND ty.Name NOT IN (SELECT * FROM STRING_SPLIT(@inputstring, ','))

  END  
END  
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 2/10/2022
-- Description:	Gets all the colors available in RLI xml
-- Sample EXEC [dbo].[SP_Compass_AddCompassAirplanes] 18, '1,2'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Compass_GetCompassColors]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_GetCompassColors]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_GetCompassColors]
	@configurationId int
AS
BEGIN
	SELECT rli.value('(rli/loc1/@color)[1]', 'varchar(max)') as Location_1_Color,
	rli.value('(rli/loc2/@color)[1]', 'varchar(max)') as Location_2_Color,
	rli.value('(rli/compass/@color)[1]', 'varchar(max)') as CompassColorPlaceholder,
	rli.value('(rli/north_text/@color)[1]', 'varchar(max)') as NorthTextColor,
	rli.value('(rli/north_base/@color)[1]', 'varchar(max)') as NorthBaseColor,
	rli.value('(rli/poi_text/@color)[1]', 'varchar(max)') as POIColor,
	rli.value('(rli/value_text/@color)[1]', 'varchar(max)') as ValueTextColor
	FROM cust.config_tblRLI(@configurationId) as R
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 2/10/2022
-- Description:	Gets all the colors available in RLI xml
-- Sample EXEC [dbo].[SP_Compass_GetMakkahImageTextValues] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_Compass_GetMakkahImageTextValues]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_GetMakkahImageTextValues]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_GetMakkahImageTextValues]
	@configurationId int
AS
BEGIN
	SELECT rli.value('(rli/mecca_display/@image)[1]', 'varchar(max)') as imageValue,
	rli.value('(rli/mecca_display/@text)[1]', 'varchar(max)') as textValue
	FROM cust.config_tblRLI(@configurationId) as R 
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 --=============================================
 --Author: Abhishek Narasimha Prasad
 --Create date: 01/10/2022
 --Description:	Updates colors for the compass XML
 --Sample EXEC [dbo].[SP_Compass_RliXML] 35, 'get'
 --=============================================

IF OBJECT_ID('[dbo].[SP_Compass_RliXML]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_RliXML]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_RliXML]
	@configurationId INT,
	@type NVARCHAR(50),
	@xmlValue XML = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		SELECT M.Rli AS xmlData FROM cust.config_tblRLI(@configurationId) AS M 
	END
	ELSE
	BEGIN
		BEGIN TRY
			IF EXISTS (SELECT 1 FROM cust.config_tblRLI(@configurationId))
			BEGIN
				DECLARE @mappedRliId INT	
				DECLARE @updateKey INT
				SET @mappedRliId = (SELECT RLIID FROM cust.tblRliMap WHERE configurationId = @configurationId)

				IF NOT @mappedRliId IS NULL
				BEGIN
					EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblRli', @mappedRliId, @updateKey OUT
					UPDATE R SET Rli = @xmlValue FROM cust.config_tblRLI(@configurationId) AS R WHERE R.RLIID = @updateKey
				END
				SELECT 1 AS retValue
			END
			ELSE
			BEGIN
				DECLARE @compassID INT
				INSERT INTO cust.tblRli (Rli) VALUES (@xmlValue)
				SET @compassID = (SELECT MAX(RLIID) FROM cust.tblRli)
				EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblRli', @compassID
			END
			SELECT 1 AS retValue
		END TRY
		BEGIN CATCH
			SELECT 0 AS retValue
		END CATCH
	END
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 02/11/2022
-- Description:	Update compass locations
-- Sample EXEC [dbo].[SP_Compass_UpdateCompassLocation] 1, '-3', 'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Compass_UpdateCompassLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_UpdateCompassLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_UpdateCompassLocation]
@configurationId INT,
@inputGeoRefId NVARCHAR(500),
@type NVARCHAR(150),
@xmlValue xml = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		DECLARE @cityName NVARCHAR(250), @worldClockCities XML, @location1 NVARCHAR(250), @location2 NVARCHAR(250)
		DECLARE @temp TABLE(xmlData XML, cityName NVARCHAR(250))

		SET @location1 = (SELECT WC.V.value('@name', 'nvarchar(max)') AS city
				FROM cust.config_tblRLI(@configurationId) as R
				OUTER APPLY R.Rli.nodes('rli/location1')  AS WC(V));
		SET @location2 = (SELECT WC.V.value('@name', 'nvarchar(max)') AS city
				FROM cust.config_tblRLI(@configurationId) as R
				OUTER APPLY R.Rli.nodes('rli/location2')  AS WC(V));

		IF (@location1 IS NULL AND @location2 IS NULL)
		BEGIN
			SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) GR
			WHERE GR.isRliPoi = 1 AND  GR.GeoRefId = @inputGeoRefId)
		END

		ELSE IF (@location1 IS NULL AND @location2 IS NOT NULL)
		BEGIN
			SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) GR
			WHERE GR.isRliPoi = 1 AND  GR.GeoRefId = @inputGeoRefId
			AND GR.Description NOT IN (
					SELECT WC.V.value('@name', 'nvarchar(max)') AS city
					FROM cust.config_tblRLI(@configurationId) as R
					OUTER APPLY R.Rli.nodes('rli/location2')  AS WC(V)))
		END

		ELSE IF (@location1 IS NOT NULL AND @location2 IS NULL)
		BEGIN
			SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) GR
			WHERE GR.isRliPoi = 1 AND  GR.GeoRefId = @inputGeoRefId
			AND GR.Description NOT IN (
					SELECT WC.V.value('@name', 'nvarchar(max)') AS city
					FROM cust.config_tblRLI(@configurationId) as R
					OUTER APPLY R.Rli.nodes('rli/location1')  AS WC(V)))
		END

		ELSE IF (@location1 IS NOT NULL AND @location2 IS NOT NULL)
		BEGIN
			SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) GR
			WHERE GR.isRliPoi = 1 AND  GR.GeoRefId = @inputGeoRefId
			AND GR.Description NOT IN (
					SELECT WC.V.value('@name', 'nvarchar(max)') AS city
					FROM cust.config_tblRLI(@configurationId) as R
					OUTER APPLY R.Rli.nodes('rli/location1')  AS WC(V))
			AND GR.Description NOT IN(
					SELECT WC.V.value('@name', 'nvarchar(max)') AS city
					FROM cust.config_tblRLI(@configurationId) as R
					OUTER APPLY R.Rli.nodes('rli/location2')  AS WC(V)))
		END

		IF (@cityName IS NOT NULL AND @cityName != '')
			BEGIN
				SET @worldClockCities =(SELECT R.Rli AS xmlData 
				FROM cust.config_tblRLI(@configurationId) as R)

				INSERT INTO @temp VALUES (@worldClockCities, @cityName)
			END
			ELSE IF (@inputGeoRefId = -1)
			BEGIN
				SET @worldClockCities =(SELECT R.Rli AS xmlData 
			  FROM cust.config_tblRLI(@configurationId) as R)

				INSERT INTO @temp VALUES (@worldClockCities, 'Departure')
			END
			ELSE IF (@inputGeoRefId = -2)
			BEGIN
				SET @worldClockCities =(SELECT R.Rli AS xmlData 
				FROM cust.config_tblRLI(@configurationId) as R)

				INSERT INTO @temp VALUES (@worldClockCities, 'Destination')
			END
			ELSE IF (@inputGeoRefId = -3)
			BEGIN
				SET @worldClockCities =(SELECT R.Rli AS xmlData 
         		FROM cust.config_tblRLI(@configurationId) as R)

				INSERT INTO @temp VALUES (@worldClockCities, 'Closest Location')
			END

		SELECT * FROM @temp
	END
	ELSE IF (@type = 'update')
	BEGIN
		IF EXISTS (SELECT 1 FROM cust.config_tblRLI(@configurationId))
		BEGIN
			declare @mappedRliId int	
			declare @updateKey int
			set @mappedRliId = (select RLIID from cust.tblRliMap where configurationId = @configurationId)
			if not @mappedRliId is null
			BEGIN
				exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblRli', @mappedRliId, @updateKey out
				UPDATE R
				SET Rli = @xmlValue FROM cust.config_tblRLI(@configurationId) as R WHERE R.RLIID = @updateKey
			END	
		END
		ELSE
		BEGIN
			DECLARE @rliId INT
			INSERT INTO cust.tblRli(RLI) VALUES(@xmlValue)
			SET @rliId = (SELECT MAX(RLIID) FROM cust.tblRli)

			EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblRli',@rliId
		END
		SELECT 1 AS retValue
	END
END
GO
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:
-- Example: exec dbo.SP_ConfigManagement_CheckMappingTable 1, 'tblAirportInfo'
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_CheckMappingTable]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_CheckMappingTable]
END
GO

CREATE PROCEDURE dbo.SP_ConfigManagement_CheckMappingTable
	@configurationId int,
	@dataTable nvarchar(max)
AS
BEGIN
	declare @mapTable nvarchar(max) = @dataTable + 'Map'
	declare @count int = 0

	declare @sql nvarchar(max) = 'set @count = (select count(*) from ' + @mapTable + ' where configurationid = ' + cast(@configurationId as nvarchar(max)) + ')'
	exec sys.sp_executesql @sql, N'@count int out', @count = @count out

	if @count = 0
	begin
		print(@dataTable + ' -> map data not present')

	end
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/18/2022
-- Description:	Copies a record for the purpose of maintaining configuration management in the database.
--   Some assumptions are made regarding the table structure:
--   1. single primary key in the table being copied
--   2. primary key is an integer
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_CopyRecord]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_CopyRecord]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_CopyRecord]
	@tableName varchar(max),
	@primaryKeyColumn varchar(max),
	@primaryKeyValue int,
	@newPrimaryKeyValue int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @copyColumns varchar(max)
	declare @schema varchar(max)

	-- get the schema for the table we're copying data in
	exec dbo.SP_ConfigManagement_GetTableSchema @tableName, @schema output

	-- get the list of non-primary key columns that we need to copy
	select
		@copyColumns = coalesce(@copyColumns + ',', '') + col.[name]
	from sys.tables as tab
	inner join sys.columns col
		on col.object_id = tab.object_id
	inner join sys.types y 
		on y.user_type_id = col.user_type_id
	left join sys.index_columns idx_col
		on idx_col.column_id = col.column_id and idx_col.object_id = col.object_id
	left join sys.indexes idx
		on idx.object_id = idx_col.object_id and idx.index_id = idx_col.index_id
	where 
		tab.[name] = @tableName
		and y.name != 'timestamp'
		and (idx.is_primary_key = 0 or idx.is_primary_key is null)

	-- generate a sql statement to 
	declare @sql nvarchar(max) = 'insert into ' + @schema + '.' + @tableName + ' (' + @copyColumns + ') select ' + @copyColumns + ' from ' + @schema + '.' + @tableName + ' where ' + @primaryKeyColumn + ' = ' + cast(@primaryKeyValue as varchar)
	set @sql = @sql + ';set @scopeIdentity = SCOPE_IDENTITY();'
	exec sys.sp_executesql @sql, N'@scopeIdentity int out', @scopeIdentity = @newPrimaryKeyValue out;

END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/18/2022
-- Description:	Looks up the key columns to used when connecting the two tables requested. The assumption here is that the two are linked by a single column.
--   If multiple are present then only the first one is returned.
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_FindMappingBetween]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_FindMappingBetween]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_FindMappingBetween]
	@mapTable varchar(max),
	@dataTable varchar(max),
	@mapColumn varchar(max) output,
	@dataColumn varchar(max) output,
	@mapSchema varchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	select top 1
		@mapColumn = col.[name],
		@dataColumn = data_col.[name],
		@mapSchema = schemas.[name]
	from sys.foreign_keys fk
		inner join sys.tables tab
			on tab.object_id = fk.parent_object_id
		inner join sys.tables data_table
			on data_table.object_id = fk.referenced_object_id and data_table.[name] = @dataTable
		inner join sys.foreign_key_columns fk_col
			on fk_col.constraint_object_id = fk.object_id
		inner join sys.columns col
			on col.column_id = fk_col.parent_column_id and col.object_id = fk_col.parent_object_id
		inner join sys.columns data_col
			on data_col.column_id = fk_col.referenced_column_id and data_col.object_id = fk_col.referenced_object_id
		inner join sys.schemas schemas
			on schemas.schema_id = tab.schema_id
	where tab.[name] = @mapTable
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 02/28/2022
-- Description:	Queries the database and retrieves the schema for a given table
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_GetTableSchema]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_GetTableSchema]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_GetTableSchema]
	@tableName varchar(max),
	@schema varchar(max) output
AS
BEGIN
	set nocount on

	select
		@schema = schemas.[name]
	from sys.schemas schemas
		inner join sys.tables tab on tab.schema_id = schemas.schema_id and tab.[name] = @tableName
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/18/2022
-- Description:	Handles populating the corresponding map table when a new record is inserted into a data table
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_HandleAdd]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_HandleAdd]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_HandleAdd]
	@configurationId int,
	@dataTable nvarchar(max),
	@keyValue int
AS
BEGIN
	set nocount on

	declare @mapTable nvarchar(max) = @dataTable + 'Map'
	declare @mapColumn nvarchar(max)
	declare @dataColumn nvarchar(max)
	declare @mapSchema nvarchar(max)

	exec dbo.SP_ConfigManagement_FindMappingBetween @mapTable, @dataTable, @mapColumn output, @dataColumn output, @mapSchema output

	declare @sql nvarchar(max) = 'insert into ' + @mapSchema + '.' + @dataTable + 'Map (' + @mapColumn + ', Previous' + @mapColumn + ', ConfigurationID, IsDeleted, Action) values (' + cast(@keyValue as nvarchar) + ', 0, ' + cast(@configurationId as nvarchar) + ', 0, ''adding'')'
	exec sys.sp_executesql @sql
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/18/2022
-- Description:	Updates the mapping table associated with the specified data table in order
--   to mark a record as deleted
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_HandleDelete]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_HandleDelete]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_HandleDelete]
	@configurationId int,
	@dataTable varchar(max),
	@keyValue int
AS
BEGIN
	set nocount on

	declare @mapTable varchar(max) = @dataTable + 'Map'
	declare @mapColumn varchar(max)
	declare @dataColumn varchar(max)
	declare @mapSchema varchar(max)

	exec dbo.SP_ConfigManagement_FindMappingBetween @mapTable, @dataTable, @mapColumn output, @dataColumn output, @mapSchema output

	--Update last update date time for the config

	exec SP_ConfigManagement_SetLastUpdateDateTime @configurationId

	-- flag the mapping record as deleted
	declare @sql nvarchar(max) = 'update ' + @mapSchema + '.' + @mapTable + ' set isdeleted = 1 where configurationId = ' + cast(@configurationId as nvarchar) + ' and ' + @mapColumn + ' = ' + cast(@keyValue as nvarchar)
	exec sys.sp_executesql @sql
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/17/2022
-- Description:	Used to handle record updates to records under configuration management. Updates are a bit more trickier
--   then adds or deletes. For updates, we need to create a copy of the record being updated and branch it just for the
--   configuration being updated, and then apply the updates. This procedure is responsible for detecting when a branch
--   needs to be made, copying the record, and providing the unique id of the branched record that can then be updated.
-- =============================================
IF OBJECT_ID('[dbo].[SP_ConfigManagement_HandleUpdate]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_HandleUpdate]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigManagement_HandleUpdate]
	@configurationId int,
	@dataTable varchar(max),
	@keyValue int,
	@useKeyValue int output			-- this is the output key that the calling stored procedure should use for applying the updates
AS
BEGIN
	set nocount on

	declare @mapTable varchar(max) = @dataTable + 'Map'
	declare @mapColumn varchar(max)
	declare @dataColumn varchar(max)
	declare @mapSchema varchar(max)

	exec dbo.SP_ConfigManagement_FindMappingBetween @mapTable, @dataTable, @mapColumn output, @dataColumn output, @mapSchema output

	declare @count int
	declare @sql nvarchar(max) = 'set @count = (select count(*) from ' + @mapSchema + '.' + @mapTable + ' where ' + @mapColumn + ' = ' + cast(@keyValue as nvarchar) + ')'
	exec sys.sp_executesql @sql, N'@count int out', @count = @count out

	--Update last update date time for the config
	exec SP_ConfigManagement_SetLastUpdateDateTime @configurationId
    -- record is only mapped to one configuration, which should be the current one, do nothing
    if @count <= 1
    begin
        set @useKeyValue = @keyValue
        return
    end
 
    -- create a copy of the record and update the mapping to point to it and connect the history
    declare @copyKey int
    exec dbo.SP_ConfigManagement_CopyRecord @dataTable, @dataColumn, @keyValue, @copyKey out
 
    -- update the mapping record for the configuration to point to the new record created
    set @sql = 'update ' + @mapSchema + '.' + @mapTable + ' set ' +  @mapColumn + ' = ' + cast(@copyKey as nvarchar) + ', ' + 'Previous' + @mapColumn + ' = ' + cast(@keyValue as nvarchar) + ' where configurationId = ' + cast(@configurationId as nvarchar) + ' and ' + @mapColumn + ' = ' + cast(@keyValue as nvarchar)
    exec sys.sp_executesql @sql
 
    set @useKeyValue = @copyKey
 
END

GO
GO

-- Main Goal of this SP is to keep the Parent and Child Config values to be in Sync in all Mapping tables
--1.Get the Child config Ids for input Config ID(Parent)
--2.Loop for all child config ids
--3.Get the config table names from config_tables and loop it
--4.Each table for child config id will be updated with Parent config values
--5.Repeat the process for all child config ids

--1.For the given config id, find all the child config ids and update the config values from input config id to child config id
--2.config_tables --> new table created which holds all the config tables
--	SELECT * INTO #TEMPMapTbl FROM sys.tables tab WHERE NAME LIKE'%Map'
--	SELECT SUBSTRING(NAME,1,len(NAME)-3) AS NAME INTO config_tables FROM #TEMPMapTbl;
--	select * from config_tables
--3. This process will update all the child config id map tables wiht parent config map tables

GO
IF OBJECT_ID('[dbo].[SP_ConfigManagement_MergeConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_MergeConfig]
END
GO
CREATE PROC [dbo].[SP_ConfigManagement_MergeConfig] 
@configId INT,
@childConfigId INT,
@userId NVARCHAR(200),
@taskId NVARCHAR(100)
AS
  BEGIN

drop table if exists #temp_configdefid_extract
drop table if exists #temp_child_configdefid_extract
drop table if exists #tempconfigid

CREATE TABLE #tempconfigid(configurationid INT);
-- [dbo].[SP_Configuration_GetAllChlildConfigs] returns list of child config id for given config id
--INSERT INTO #tempconfigid Exec [dbo].[SP_Configuration_GetAllChlildConfigs] @configId
INSERT INTO #tempconfigid VALUES(@childConfigId);

	DECLARE @tempTable TABLE(configurationId INT)
	INSERT INTO @tempTable SELECT * FROM #tempconfigid

      DECLARE @parent_keyValue NVARCHAR(10),
              @child_keyVal    NVARCHAR(10),
			  @userName		   NVARCHAR(100),
			  @configurationId INT
      DECLARE @config_table VARCHAR(100)
      DECLARE @sql NVARCHAR(MAX)
	  DECLARE @sql_1 NVARCHAR(MAX)

	  --select * from #tempconfigid

 DECLARE cur_tbl CURSOR  LOCAL STATIC FORWARD_ONLY READ_ONLY
 FOR
              SELECT tblName
              FROM   tblConfigTables WHERE IsUsedForMergeConfiguration = 1

            OPEN cur_tbl

            FETCH next FROM cur_tbl INTO @config_table
			--print @config_table
            WHILE @@FETCH_STATUS = 0
              BEGIN
                  --select value from parent and child config id and call the SP_ConfigManagement_HandleMerge (pass child config id)
                  DECLARE @mapTable VARCHAR(max) = @config_table + 'Map'
                  DECLARE @mapColumn VARCHAR(max)
                  DECLARE @dataColumn VARCHAR(max)
                  DECLARE @mapSchema VARCHAR(max)


                  EXEC dbo.Sp_configmanagement_findmappingbetween
                    @mapTable,
                    @config_table,
                    @mapColumn output,
                    @dataColumn output,
                    @mapSchema output

					--dECLARE @start_time DATETIME=GETDATE();
                  --Getting parent key val
                  
					DECLARE @sql_update NVARCHAR(MAX),@sql_delete NVARCHAR(MAX),@sql_insert NVARCHAR(MAX)

					--print 'running updates'
					SET  @sql_update= 'update toUpdate
							set Previous'+@mapColumn +' = toUpdate.'+@mapColumn+', 
								'+@mapColumn+' = Source.'+@mapColumn+'
							FROM '+@mapSchema + '.' + @mapTable+' (nolock) toUpdate
								inner join '+@mapSchema + '.' + @mapTable+' (nolock) Source on
									source.Previous'+@mapColumn +' = ToUpdate.'+@mapColumn+' and
									source.configurationid = '+Cast(@configId AS NVARCHAR)+' and
									toUpdate.configurationId IN( SELECT configurationid FROM #tempconfigid ) AND toUpdate.'+@mapColumn+'
									<> Source.'+@mapColumn+';';

					--PRINT @sql_update

					EXEC sys.Sp_executesql @sql_update
						-- handle deletions
						--print 'running deletions'
							SET @sql_delete= 'update toUpdate 
							set toUpdate.isDeleted = 1 
							from '+@mapSchema + '.' + @mapTable+'  (NOLOCK) toUpdate
								inner join '+@mapSchema + '.' + @mapTable+'  (NOLOCK) source on
									source.'+@mapColumn+' = toUpdate.'+@mapColumn+' and
									source.configurationId = '+Cast(@configId AS NVARCHAR)+' and
									source.isDeleted = 1 and
									toUpdate.configurationId IN( SELECT configurationid FROM #tempconfigid );';

						--print @sql_delete
						EXEC sys.Sp_executesql @sql_delete
						--		print 'running additions'
							SET @sql_insert='insert into '+@mapSchema + '.' + @mapTable+' ('+@mapColumn+', configurationid, Previous'+@mapColumn+', isdeleted) 
								select distinct '+@mapColumn+', B.configurationid, null, 0
								from '+@mapSchema + '.' + @mapTable+' (NOLOCK),#tempconfigid B 
								where '+@mapColumn+' not in (select '+@mapColumn+' from '+@mapSchema + '.' + @mapTable+' (nolock) where configurationid IN( SELECT configurationid FROM #tempconfigid)) and 
								'+@mapSchema + '.' + @mapTable+'.configurationId = '+Cast(@configId AS NVARCHAR)+' and 
								'+@mapSchema + '.' + @mapTable+'.isdeleted = 0;';
					--PRINT @sql_insert
					EXEC sys.Sp_executesql @sql_insert
                  FETCH next FROM cur_tbl INTO @config_table
              END

			  SET @userName = (SELECT FirstName + ' ' + LastName FROM AspNetUsers WHERE Id = @userId)
			  WHILE (SELECT COUNT(*) FROM @tempTable) > 0
				BEGIN
					SET @configurationId = (SELECT TOP 1 configurationId FROM @tempTable)

					DECLARE @comment NVARCHAR(MAX)
					SET @comment = ('Merging configuration data from ' + (SELECT CT.Name FROM tblConfigurations C
					INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
					INNER JOIN tblConfigurationTypes CT ON CD.ConfigurationTypeID = CT.ConfigurationTypeID
					WHERE C.ConfigurationID = @configId) + ' configuration version V' + Convert(NVARCHAR(10),(SELECT C.Version FROM tblConfigurations C
					INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
					WHERE C.ConfigurationID = @configId)) + ' to ' + (SELECT CT.Name FROM tblConfigurations C
					INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
					INNER JOIN tblConfigurationTypes CT ON CD.ConfigurationTypeID = CT.ConfigurationTypeID
					WHERE C.ConfigurationID = @configurationId) + ' configuration version V' + Convert(NVARCHAR(10),(SELECT C.Version FROM tblConfigurations C
					INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
					WHERE C.ConfigurationID = @configurationId)))

					IF EXISTS (SELECT 1 FROM tblConfigurationHistory WHERE ContentType = 'Merging Configuration' AND ConfigurationID = @configid)
					BEGIN
						UPDATE tblConfigurationHistory SET UserComments = @comment, DateModified = GETDATE(), TaskID = CONVERT(uniqueidentifier ,@taskId), CommentAddedBy = @userName
						WHERE ContentType = 'airports' AND ConfigurationID = @configid
					END
					ELSE
					BEGIN
						INSERT INTO dbo.tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID,UserComments)
						VALUES(@configid,'Merging Configuration',@userName,GETDATE(),CONVERT(uniqueidentifier,@taskId),@comment)
					END

					DELETE FROM @tempTable WHERE configurationId = @configurationId
				END
            CLOSE cur_tbl

            DEALLOCATE cur_tbl

  END

GO
GO

-- =============================================
-- Author:		Sathya
-- Create date: 06/24/2022
-- Description:	Updating the last updated date time for the given config id when it is modified.
-- =============================================

GO
IF OBJECT_ID('[dbo].[SP_ConfigManagement_SetLastUpdateDateTime]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_SetLastUpdateDateTime]
END
GO
CREATE PROC SP_ConfigManagement_SetLastUpdateDateTime
@configurationId int
AS
BEGIN
	UPDATE tblConfigurations SET LastUpdateDateTime=GETDATE() WHERE ConfigurationID=@configurationId
END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Brinda Chindamada Aiyappa
-- Create date: 08/18/2022
-- Description:	Get the default part number
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_DefaultPartNumber] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_DefaultPartNumber]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_DefaultPartNumber]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_DefaultPartNumber]
    @ConfigurationDefinitionId int 
	
    
AS
BEGIN
	
	select pa.PartNumberID,pa.Description,pa.DefaultPartNumber from tblConfigurationDefinitionPartNumber t INNER JOIN tblPartNumber pa ON t.PartNumberID = pa.PartNumberID where t.ConfigurationDefinitionID = @configurationDefinitionId
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	Returns the list of aircraft that have configuration definitions that are not associated to a fleet that are accessible to the given user for the specified operator.
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_GetAircrafts] '4dbed025-b15f-4760-b925-34076d13a10a'
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_GetAircrafts]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_GetAircrafts]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_GetAircrafts]
	@userId UNIQUEIDENTIFIER,
    @operatorId UNIQUEIDENTIFIER

AS
BEGIN
	 select 
    distinct aircraft.*, 
    tblconfigurationdefinitions.ConfigurationDefinitionID, 
    Aircraft.SerialNumber, 
    Aircraft.TailNumber,
    tblConfigurations.ConfigurationID
    from aircraft inner join tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.aircraftid = aircraft.id 
    inner join tblconfigurationdefinitions on tblConfigurationDefinitions.ConfigurationDefinitionID = tblAircraftConfigurationMapping.ConfigurationDefinitionID and tblconfigurationdefinitions.active = 1 
       inner join tblConfigurations on tblconfigurationdefinitions.ConfigurationDefinitionID=tblConfigurations.ConfigurationDefinitionID and locked!=1
    inner join operator on aircraft.operatorid=Operator.Id
       where Aircraft.OperatorId= @operatorId 

END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/12/2022
-- Description:	Get Configuration definition  information for given user
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_GetAll] '4dbed025-b15f-4760-b925-34076d13a10a'
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_GetAll]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_GetAll]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_GetAll]
	@userId uniqueidentifier
AS
BEGIN
	SELECT DISTINCT * FROM
            (select 
           
            tblconfigurationdefinitions.*,

            case when  tblProducts.Name is not null then tblProducts.Name  
            when tblPlatforms.Name is not null then tblPlatforms.Name  
            when tblGlobals.Name is not null then tblGlobals.Name  
            end as Name,  

            case when  UserClaims.name = 'ManageProductConfiguration' then 'Product'  
            when  UserClaims.name = 'ManagePlatformConfiguration' then 'Platform' 
            when UserClaims.name = 'Manage Global Configuration' then 'Global' 
            end as ConfigurationDefinitionType,

			case when  tblFeatureSet.value like 'true' then 1
            when  tblFeatureSet.value like 'false' then 0 
            end as Editable 

            from(aspnetusers 
            inner join UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id 
            inner join UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid 
            inner join UserClaims on UserClaims.id = UserRoleClaims.claimid 
            inner join tblconfigurationdefinitions on tblconfigurationdefinitions.ConfigurationDefinitionID = UserRoleClaims.ConfigurationDefinitionID or UserRoleClaims.ConfigurationDefinitionID is null and tblconfigurationdefinitions.active = 1
			INNER JOIN tblFeatureSet on tblFeatureSet.FeatureSetID = tblConfigurationDefinitions.FeatureSetID ) 
            LEFT OUTER JOIN tblProductConfigurationMapping on tblProductConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManageProductConfiguration' 

            LEFT OUTER JOIN dbo.tblProducts on tblProducts.ProductID = tblProductConfigurationMapping.ProductID 

            LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManagePlatformConfiguration' 
            LEFT OUTER JOIN dbo.tblPlatforms on tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID 

            LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'Manage Global Configuration' 
            LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID 

            where 
            UserClaims.name in ('ManagePlatformConfiguration', 'ManageProductConfiguration', 'Manage Global Configuration') and tblFeatureSet.name like '%IsEditable%'
            and aspnetusers.Id = @userId) as A WHERE A.Name is not null
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	Get all Configuration definition information for given definition type and id
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_GetDefinition] 'product', 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_GetDefinition]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_GetDefinition]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_GetDefinition]
	@definitionType VARCHAR(Max),
    @definitionId INT
AS
BEGIN
	IF(@definitionType = 'product')
	BEGIN
        SELECT Products.*,Configuration.ConfigurationDefinitionID
        FROM dbo.tblConfigurationDefinitions AS Configuration
        INNER JOIN dbo.tblProductConfigurationMapping AS Product ON Product.ConfigurationDefinitionID = Configuration.ConfigurationDefinitionID
        INNER JOIN dbo.tblProducts AS Products on Products.ProductID = Product.ProductID 
        WHERE Configuration.ConfigurationDefinitionID = @definitionId
    END
    ELSE IF (@definitionType = 'platform')
    BEGIN
       SELECT Platforms.*,  Configuration.ConfigurationDefinitionID
        FROM dbo.tblConfigurationDefinitions AS Configuration
        INNER JOIN dbo.tblPlatformConfigurationMapping AS Platform ON Platform.ConfigurationDefinitionID = Configuration.ConfigurationDefinitionID   
        INNER JOIN dbo.tblPlatforms AS Platforms on Platforms.PlatformID = Platform.PlatformID
        WHERE Configuration.ConfigurationDefinitionID =@definitionId
    END
    ELSE IF(@definitionType = 'global')
    BEGIN
        SELECT Globals.*, Configuration.ConfigurationDefinitionID 
        FROM dbo.tblConfigurationDefinitions AS Configuration 
        INNER JOIN dbo.tblGlobalConfigurationMapping AS Global ON Global.ConfigurationDefinitionID = Configuration.ConfigurationDefinitionID 
        INNER JOIN dbo.tblGlobals AS Globals on Globals.GlobalID = Global.GlobalID 
        WHERE Configuration.ConfigurationDefinitionID = @definitionId
    END
	ELSE IF (@definitionType = 'child platform')
    BEGIN
        SELECT Platforms.*, ot.PartNumberCollectionID, Configuration.ConfigurationDefinitionID 
        FROM dbo.tblConfigurationDefinitions AS Configuration 
        INNER JOIN dbo.tblPlatformConfigurationMapping AS Platform ON Platform.ConfigurationDefinitionID = Configuration.ConfigurationDefinitionID 
        INNER JOIN dbo.tblPlatforms AS Platforms on Platforms.PlatformID = Platform.PlatformID 
		INNER JOIN dbo.tblOutputTypes AS OT ON OT.OutputTypeID = Configuration.OutputTypeID
        WHERE Configuration.ConfigurationDefinitionParentID = @definitionId
    END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	Get all Configuration definition information for given definition type
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_GetDefinitions] 'products'
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_GetDefinitions]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_GetDefinitions]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_GetDefinitions]
	@definitionType VARCHAR(Max)
AS
BEGIN
	IF(@definitionType = 'products')
	BEGIN
        SELECT Configuration.*
        FROM dbo.tblConfigurationDefinitions AS Configuration 
        INNER JOIN dbo.tblProductConfigurationMapping AS Product ON Product.ConfigurationDefinitionID = Configuration.ConfigurationDefinitionID 
        INNER JOIN dbo.tblProducts AS Products on Products.ProductID = Product.ProductID;
    END
    ELSE IF (@definitionType = 'platforms')
    BEGIN
        SELECT Configuration.* 
        FROM dbo.tblConfigurationDefinitions AS Configuration 
        INNER JOIN dbo.tblPlatformConfigurationMapping AS Platform ON Platform.ConfigurationDefinitionID = Configuration.ConfigurationDefinitionID 
        INNER JOIN dbo.tblPlatforms AS Platforms on Platforms.PlatformID = Platform.PlatformID;
    END
    ELSE IF(@definitionType = 'global')
    BEGIN
        SELECT Configuration.*
        FROM dbo.tblConfigurationDefinitions AS Configuration 
        INNER JOIN dbo.tblGlobalConfigurationMapping AS Global ON Global.ConfigurationDefinitionID = Configuration.ConfigurationDefinitionID 
        INNER JOIN dbo.tblGlobals AS Globals on Globals.GlobalID = Global.GlobalID;
    END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 01/20/2023
-- Description:	Get all available installation types and outputtypes
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_GetInstallationTypesOrOutputTypes] 'installation'
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_GetInstallationTypesOrOutputTypes]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_GetInstallationTypesOrOutputTypes]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_GetInstallationTypesOrOutputTypes]
@type NVARCHAR(150)
AS
BEGIN
	IF (@type = 'installation')
	BEGIN
		SELECT * FROM InstallationTypes
	END
	ELSE IF (@type = 'outputtypes')
	BEGIN
		SELECT * FROM tblOutputTypes
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	Returns the list of operators associated with configuration definitions that the user has access to as determined by the claims associated with the given user
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_GetOperators] '4dbed025-b15f-4760-b925-34076d13a10a'
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_GetOperators]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_GetOperators]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_GetOperators]
	@userId UNIQUEIDENTIFIER,
	@configurationDefinitionID INT,
	@operatorType NVARCHAR(255)

AS
BEGIN
	IF(@operatorType = 'global')
	BEGIN
	select  

    distinct operator.*  

    from aspnetusers  
    inner join UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id  
    inner join UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid  
    inner join UserClaims on UserClaims.id = UserRoleClaims.claimid  


    inner join operator on operator.id = UserRoleClaims.operatorid or UserRoleClaims.operatorid is null  
    inner join aircraft on aircraft.operatorid = operator.id  
    inner join tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.aircraftid = aircraft.id  
    inner join tblconfigurationdefinitions on tblConfigurationDefinitions.ConfigurationDefinitionID = tblAircraftConfigurationMapping.ConfigurationDefinitionID and tblconfigurationdefinitions.active = 1  

    where  
    UserClaims.name in ('Manage Operator', 'View Operator', 'Administer Operator')  
        and  
        aspnetusers.Id =  @userId  

        UNION  

    select  
    distinct operator.*  

    from aspnetusers  
    inner join UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id  
    inner join UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid  
    inner join UserClaims on UserClaims.id = UserRoleClaims.claimid  


    inner join aircraft on aircraft.id = UserRoleClaims.aircraftid or UserRoleClaims.aircraftid is null  
    inner join tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.aircraftid = aircraft.id  
    inner join tblconfigurationdefinitions on tblConfigurationDefinitions.ConfigurationDefinitionID = tblAircraftConfigurationMapping.ConfigurationDefinitionID and tblconfigurationdefinitions.active = 1  
    inner join operator on aircraft.operatorid = operator.id  

    where  
    UserClaims.name in ('Manage Aircraft', 'Administer Aircraft')  and  aspnetusers.Id =  @userId;
	END
	ELSE IF(@operatorType ='platform')
	BEGIN
	select  

    distinct operator.*  

    from aspnetusers  
    inner join UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id  
    inner join UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid  
    inner join UserClaims on UserClaims.id = UserRoleClaims.claimid  


    inner join operator on operator.id = UserRoleClaims.operatorid or UserRoleClaims.operatorid is null  
    inner join aircraft on aircraft.operatorid = operator.id  
    inner join tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.aircraftid = aircraft.id  
    inner join tblconfigurationdefinitions on tblConfigurationDefinitions.ConfigurationDefinitionID = tblAircraftConfigurationMapping.ConfigurationDefinitionID and tblconfigurationdefinitions.active = 1  

    where  
    UserClaims.name in ('Manage Operator', 'View Operator', 'Administer Operator')  
        and  
        aspnetusers.Id =  @userId  and tblConfigurationDefinitions.ConfigurationDefinitionParentID =@configurationdefinitionID

        UNION  

    select  
    distinct operator.* 

    from aspnetusers  
    inner join UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id  
    inner join UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid  
    inner join UserClaims on UserClaims.id = UserRoleClaims.claimid  


    inner join aircraft on aircraft.id = UserRoleClaims.aircraftid or UserRoleClaims.aircraftid is null  
    inner join tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.aircraftid = aircraft.id  
    inner join tblconfigurationdefinitions on tblConfigurationDefinitions.ConfigurationDefinitionID = tblAircraftConfigurationMapping.ConfigurationDefinitionID and tblconfigurationdefinitions.active = 1  
    inner join operator on aircraft.operatorid = operator.id  

    where  
    UserClaims.name in ('Manage Aircraft', 'Administer Aircraft')  and  aspnetusers.Id =  @userId and tblConfigurationDefinitions.ConfigurationDefinitionParentID =@configurationdefinitionID
	END

END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Brinda Chindamada Aiyappa
-- Create date: 08/18/2022
-- Description:	Get the default part number
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_PartNumber] 5080,1,'ABBB'
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_PartNumber]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_PartNumber]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_PartNumber]
    @ConfigurationDefinitionId int ,
	@partNumberCollectionId int,
	@tailNumber NVARCHAR(MAX)
	
    
AS
BEGIN
	
	DECLARE @partnumbertable TABLE (PartNumberID INT, Name NVARCHAR(250), PartNumberCollectionID INT, Description NVARCHAR(500), DefaultPartNumber NVARCHAR(500))

	DECLARE @aricraftDefinitionId INT=0;

	IF LEN(@tailNumber)>0
	BEGIN
		SELECT @aricraftDefinitionId=ISNULL(AD.ConfigurationDefinitionID,0) FROM dbo.tblConfigurationDefinitions CD 
		INNER JOIN tblAircraftConfigurationMapping AD ON AD.ConfigurationDefinitionID=CD.ConfigurationDefinitionID
		INNER JOIN Aircraft AC ON AD.AircraftID=AC.Id WHERE AC.TailNumber=@tailNumber
	
		IF @aricraftDefinitionId!=0
			SET @ConfigurationDefinitionId=@aricraftDefinitionId
    END

	INSERT INTO @partnumbertable 
	SELECT tp.PartNumberID, tp.Name, tp.PartNumberCollectionID, tp.Description, tc.Value  FROM tblConfigurationDefinitionPartNumber tc 
    INNER JOIN tblPartNumber tp ON  tc.PartNumberID =tp.PartNumberID
	INNER JOIN tblOutputTypes ot ON ot.PartNumberCollectionID =tp.PartNumberCollectionID    where tc.ConfigurationDefinitionID = @ConfigurationDefinitionId AND tp.PartNumberCollectionID = @partNumberCollectionId

	INSERT INTO @partnumbertable 
	
	SELECT pa.PartNumberID, pa.Name ,pa.PartNumberCollectionID,pa.Description,pa.DefaultPartNumber from tblPartNumber pa
	INNER JOIN tblOutputTypes ot ON pa.PartNumberCollectionID = ot.PartNumberCollectionID 
	LEFT JOIN  tblConfigurationDefinitions c on c.OutputTypeID =ot.OutputTypeID
	WHERE c.ConfigurationDefinitionID =  @ConfigurationDefinitionId AND pa.PartNumberID NOT IN
	(SELECT tp.PartNumberID FROM tblConfigurationDefinitionPartNumber tc  INNER JOIN tblPartNumber tp ON  tc.PartNumberID = tp.PartNumberID 
	WHERE tc.ConfigurationDefinitionID = @ConfigurationDefinitionId AND tp.PartNumberCollectionID =@partNumberCollectionId)


	SELECT PartNumberID,PartNumberCollectionID,Description,Name,REPLACE(DefaultPartNumber,'%','0') AS DefaultPartNumber FROM @partnumbertable ORDER BY PartNumberID ASC

END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Brinda Chindamada Aiyappa
-- Create date: 08/18/2022
-- Description:	Update the partnumber based on given collection
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_UpdatePartNumber] 5080,1,'072-4599-788888','ABBB'
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_UpdatePartNumber]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_UpdatePartNumber]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_UpdatePartNumber]
    @ConfigurationDefinitionID int, 
	@PartNumberID int, 
	@Value varchar(255),
	@TailNumber NVARCHAR(255)
	
    
AS
BEGIN
	DECLARE @AircraftConfigurationDefinitionID INT;
	SET @AircraftConfigurationDefinitionID =(select ISNULL(ConfigurationDefinitionID,0) from tblAircraftConfigurationMapping ac inner join Aircraft a on ac.AircraftID = a.ID where a.TailNumber =@TailNumber)
	IF @AircraftConfigurationDefinitionID IS NULL
		BEGIN
			IF NOT EXISTS ( SELECT 1 FROM tblTempAircraftPartnumber WHERE PartNumberID = @PartNumberID AND ProductConfigurationDefinitionId= @ConfigurationDefinitionID)
			     INSERT INTO tblTempAircraftPartnumber(ProductConfigurationDefinitionId,TailNumber,PartnumberId,Value) VALUES(@ConfigurationDefinitionID,@TailNumber,@PartNumberID,@Value)
				 ELSE
				 UPDATE tblTempAircraftPartnumber SET Value = @Value WHERE  ProductConfigurationDefinitionId = @ConfigurationDefinitionID and  PartNumberID= @PartNumberID 
		END
	ELSE 
		BEGIN
		IF NOT EXISTS ( SELECT 1 FROM tblConfigurationDefinitionPartNumber WHERE ConfigurationDefinitionID = @AircraftConfigurationDefinitionID  AND PartNumberID = @PartNumberID)
			INSERT INTO tblConfigurationDefinitionPartNumber (ConfigurationDefinitionID, PartNumberID,Value) VALUES (@AircraftConfigurationDefinitionID,@PartNumberID, @Value)
			ELSE
			UPDATE tblConfigurationDefinitionPartNumber SET Value = @Value WHERE  ConfigurationDefinitionID = @AircraftConfigurationDefinitionID and  PartNumberID= @PartNumberID 
		END
	
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 2/24/2022
-- Description:	Implements logic for branching the given configuration
-- SP executes the SP_CreateBranch procedure to branch out the given configuration.
-- Sample EXEC [dbo].[SP_Configuration_LockConfiguration] 1, 'Guid of the user'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_BranchConfiguration]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_BranchConfiguration]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_BranchConfiguration]
	@configurationId INT,
    @LastModifiedBy VARCHAR(MAX)
AS
BEGIN

    DECLARE @IntoConfigurationDefinitionID INT;
    SET @IntoConfigurationDefinitionID = (SELECT  dbo.tblConfigurations.ConfigurationDefinitionID FROM dbo.tblConfigurations WHERE dbo.tblConfigurations.ConfigurationID = @configurationId);
	BEGIN TRY
		BEGIN TRANSACTION

			-- Execute SP to Creare braching of configuration.
			EXECUTE dbo.SP_CreateBranch @configurationId,@IntoConfigurationDefinitionID,@LastModifiedBy,'Branching by Locking Configuration'

		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
	END CATCH
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	Returns configuration definition info for the given configuration id
-- Sample EXEC [dbo].[SP_Configuration_DefinitionInfo] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_DefinitionInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_DefinitionInfo]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_DefinitionInfo]
	@configurationId INT
AS
BEGIN
	SELECT 
    dbo.tblConfigurations.ConfigurationDefinitionID, 

    CASE 
    WHEN dbo.tblGlobals.GlobalID is not null then dbo.tblGlobals.GlobalID 
    WHEN dbo.tblProducts.ProductID is not null then dbo.tblProducts.ProductID 
    WHEN dbo.tblPlatforms.PlatformID is not null then dbo.tblPlatforms.PlatformID 
    END as ConfigurationDefinitionTypeID, 

    CASE 
    WHEN dbo.tblGlobals.GlobalID is not null then 'Global' 
    WHEN dbo.tblProducts.ProductID is not null then 'Product' 
    WHEN dbo.tblPlatforms.PlatformID is not null then 'Platform' 
    END as ConfigurationDefinitionType 

    FROM 
    dbo.tblConfigurations 

    LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = dbo.tblConfigurations.ConfigurationDefinitionID 
    LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID 

    LEFT OUTER JOIN tblProductConfigurationMapping on tblProductConfigurationMapping.ConfigurationDefinitionID = dbo.tblConfigurations.ConfigurationDefinitionID 
    LEFT OUTER JOIN dbo.tblProducts on tblProducts.ProductID = tblProductConfigurationMapping.ProductID 

    LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID = dbo.tblConfigurations.ConfigurationDefinitionID 
    LEFT OUTER JOIN dbo.tblPlatforms on tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID 

    WHERE dbo.tblConfigurations.ConfigurationID = @configurationId;
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/18/2022
-- Description:	returns list of aircrafts that has configuration mapping
-- Sample EXEC [dbo].[SP_Configuration_GetAircrafts] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_GetAircrafts]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_GetAircrafts]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_GetAircrafts]
    @configurationId INT
AS
BEGIN
	SELECT DISTINCT * 
    FROM dbo.Aircraft 
    INNER JOIN dbo.tblAircraftConfigurationMapping ON dbo.tblAircraftConfigurationMapping.AircraftID = dbo.Aircraft.Id 
    INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationDefinitionID = dbo.tblAircraftConfigurationMapping.ConfigurationDefinitionID
    WHERE dbo.tblConfigurations.ConfigurationID = @configurationId
END
GO
GO


GO
IF OBJECT_ID('[dbo].[SP_Configuration_GetAllChlildConfigs]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_GetAllChlildConfigs]
END
GO
CREATE PROC [dbo].[SP_Configuration_GetAllChlildConfigs] @configId INT

AS

BEGIN
declare @parentDefinitionId int = (select configurationdefinitionid from tblConfigurations where configurationid = @configId);


select
--*
tblconfigurations.configurationid
from tblconfigurations
inner join tblConfigurationDefinitions
on tblconfigurations.ConfigurationDefinitionID = tblConfigurationDefinitions.ConfigurationDefinitionID
inner join (
select
max(version) as version,
configurationdefinitionid
from tblconfigurations
group by ConfigurationDefinitionID
) versions on versions.version = tblconfigurations.version and versions.ConfigurationDefinitionID = tblconfigurations.ConfigurationDefinitionID

inner join tblConfigurationTypes on tblConfigurationTypes.ConfigurationTypeID = tblConfigurationDefinitions.ConfigurationTypeID
where
tblConfigurationDefinitions.ConfigurationDefinitionParentID = @parentDefinitionId
and tblconfigurations.ConfigurationDefinitionID != @parentDefinitionId
and tblconfigurations.locked = 0;


  END

GO


GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/03/2022
-- Description:	Gets the default locking comments from tblConfigurationHistory table
-- Sample EXEC [dbo].[SP_Configuration_GetDefaultLockingComments] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_GetDefaultLockingComments]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_GetDefaultLockingComments]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_GetDefaultLockingComments]
	@configurationId INT
AS
BEGIN

SELECT
   CASE WHEN  dbo.tblConfigurationHistory.UserComments is null THEN '' ELSE dbo.tblConfigurationHistory.UserComments END 
   FROM dbo.tblConfigurationHistory
   WHERE dbo.tblConfigurationHistory.ConfigurationId = @configurationId
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	checks if a configuration exist for given configuration definition
-- Sample EXEC [dbo].[SP_Configuration_GetIfExist] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_GetIfExist]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_GetIfExist]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_GetIfExist]
	@configurationDefinitionID INT
AS
BEGIN
    SELECT dbo.tblConfigurations.ConfigurationID
    FROM dbo.tblConfigurations
    WHERE dbo.tblConfigurations.ConfigurationDefinitionID = @configurationDefinitionID
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	returns list of configurations for a given configuration definition
-- Sample EXEC [dbo].[SP_Configuration_GetVersions] 3, 'locked'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_GetVersions]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_GetVersions]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_GetVersions]
	@configurationDefinitionID INT,
    @type VARCHAR(Max)
AS
BEGIN
	IF(@type = 'all')
	BEGIN
       SELECT C.* ,p.Name as PlatFormName,ps.Name as ProductName, a.TailNumber as TailNumber
        FROM dbo.tblConfigurations C
        LEFT JOIN dbo.tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
        LEFT JOIN tblplatformconfigurationmapping pcm ON Cd.ConfigurationDefinitionID = pcm.ConfigurationDefinitionID
        LEFT JOIN tblproductconfigurationmapping prcm ON Cd.ConfigurationDefinitionID = prcm.ConfigurationDefinitionID
        LEFT JOIN tblPlatforms p ON pcm.PlatformID = p.PlatformID
        LEFT JOIN tblProducts ps ON prcm.ProductID = ps.ProductID
        left join tblAircraftConfigurationMapping acm on acm.ConfigurationDefinitionID = cd.ConfigurationDefinitionID
		 LEFT JOIN Aircraft a ON acm.AircraftID =a.Id
        WHERE C.ConfigurationDefinitionID = @configurationDefinitionID ORDER BY C.Version DESC
    END
    ELSE IF (@type = 'locked')
    BEGIN
        SELECT C.* ,p.Name as PlatFormName,ps.Name as ProductName,a.TailNumber as TailNumber
        FROM dbo.tblConfigurations C
        LEFT JOIN dbo.tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
        LEFT JOIN tblplatformconfigurationmapping pcm ON Cd.ConfigurationDefinitionID = pcm.ConfigurationDefinitionID
        LEFT JOIN tblproductconfigurationmapping prcm ON Cd.ConfigurationDefinitionID = prcm.ConfigurationDefinitionID
        LEFT JOIN tblPlatforms p ON pcm.PlatformID = p.PlatformID 
        LEFT JOIN tblProducts ps ON prcm.ProductID = ps.ProductID
        left join tblAircraftConfigurationMapping acm on acm.ConfigurationDefinitionID = cd.ConfigurationDefinitionID
		 LEFT JOIN Aircraft a ON acm.AircraftID =a.Id
        WHERE C.ConfigurationDefinitionID = @configurationDefinitionID AND C.Locked=1 ORDER BY C.Version DESC
    END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 2/24/2022
-- Description:	Implements logic for Locking the child configurations of the given config id.
-- checks if the parent configuraion definition id is set to autolock, if true then locks all child config ids corresponding to the definition id.
-- SP also returns the list of configuration ids that got locked.
-- Sample EXEC [dbo].[SP_Configuration_LockConfiguration] 1, 'lockMessage'
-- =============================================


IF OBJECT_ID('[dbo].[SP_Configuration_LockChildConfigurations]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_LockChildConfigurations]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_LockChildConfigurations]
	@configurationId INT,
    @lockMessage NVARCHAR(MAX),
	@userId NVARCHAR(200),
	@taskId NVARCHAR(100)
AS
BEGIN

    BEGIN TRANSACTION
		
		DECLARE @tempTable TABLE(configurationId INT)
		DECLARE @configId INT, @userName NVARCHAR(200), @lockingComments NVARCHAR(MAX) = ''

        -- For each child configuration, If the child is marked as AutoLock, lock the child configurations
		DROP TABLE IF EXISTS #tempconfigid
		CREATE TABLE #tempconfigid(configurationid INT);
		INSERT INTO #tempconfigid Exec [dbo].[SP_Configuration_GetAllChlildConfigs] @configurationId
        
		INSERT INTO @tempTable SELECT * FROM #tempconfigid

		-- Get user name from the userId
		SET @userName = (SELECT FirstName + ' ' + LastName FROM AspNetUsers WHERE Id = @userId)

        -- Update the configuration table for the latest configurations associated with above list of configuration Definition Id
        UPDATE tblConfig
        SET tblConfig.Locked = C.Locked, tblConfig.LockComment = C.LockComment ,tblConfig.LockDate = GETDATE()
        FROM dbo.tblConfigurations as tblConfig
        INNER JOIN 
        (
            SELECT dbo.tblConfigurations.ConfigurationDefinitionID,
            Max(dbo.tblConfigurations.Version) as Version,
            1 AS  Locked,
            @lockMessage AS LockComment 
            FROM dbo.tblConfigurations
            WHERE dbo.tblConfigurations.configurationid 
                IN (
                SELECT configurationid FROM #tempconfigid
                )
            GROUP BY  dbo.tblConfigurations.ConfigurationDefinitionID 
        ) AS C ON tblConfig.ConfigurationDefinitionID = C.ConfigurationDefinitionID
          AND tblConfig.Version = C.Version
        
		WHILE (SELECT COUNT(*) FROM @tempTable) > 0
		BEGIN
			SET @configId = (SELECT TOP 1 configurationId FROM @tempTable)

			SELECT @lockingComments = @lockingComments + CONVERT(NVARCHAR, CONVERT(date, DateModified), 3) + '-' + COALESCE(UserComments + ',','') + '  '
			FROM tblConfigurationHistory where ConfigurationID = @configId AND UserComments IS NOT NULL AND DateModified IS NOT NULL
			AND ContentType IN ('populations','airports','world guide cities','Merging Configuration')

			SET @lockMessage = @lockMessage + '  ' + Left(@lockingComments,len(@lockingComments)-1)

			INSERT INTO tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID, UserComments)
			VALUES (@configId, 'Locking Configuration', @userName, GETDATE(), @taskId, @lockMessage)

			DELETE FROM @tempTable WHERE configurationId = @configId
		END
		SELECT configurationid FROM #tempconfigid

    COMMIT
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 2/24/2022
-- Description:	Implements logic for Locking the given configuration
-- Sample EXEC [dbo].[SP_Configuration_LockConfiguration] 1, 'lockMessage'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_LockCurrentConfiguration]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_LockCurrentConfiguration]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_LockCurrentConfiguration]
	@configurationId INT,
    @lockMessage NVARCHAR(MAX),
	@userId NVARCHAR(200),
	@taskId NVARCHAR(100)
AS
BEGIN

    BEGIN TRANSACTION
		
		DECLARE @userName NVARCHAR(250), @lockingComments NVARCHAR(MAX) = ''
		
		SELECT @lockingComments = @lockingComments + CONVERT(NVARCHAR, CONVERT(date, DateModified), 3) + '-' + COALESCE(UserComments + ',','') + '  '
		FROM tblConfigurationHistory where ConfigurationID = @configurationId AND UserComments IS NOT NULL AND DateModified IS NOT NULL
		AND ContentType IN ('populations','airports','world guide cities','Merging Configuration')

		IF len(@lockingComments)>0
		BEGIN
		SET @lockMessage = @lockMessage + '  ' + Left(@lockingComments,len(@lockingComments)-1)
		END
		SET @userName = (SELECT FirstName + ' ' + LastName FROM AspNetUsers WHERE Id = @userId)
        -- Update locked value for the current configuration
        UPDATE dbo.tblConfigurations 
        SET dbo.tblConfigurations.Locked = 1, dbo.tblConfigurations.LockComment = @lockMessage , dbo.tblConfigurations.LockDate = GETDATE()
        WHERE dbo.tblConfigurations.ConfigurationID = @configurationId;

		INSERT INTO tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID, UserComments)
		VALUES (@configurationId, 'Locking Configuration', @userName, GETDATE(), @taskId, @lockMessage)

    COMMIT
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	updates the release notes for given cinfiguration and given version
-- Sample EXEC [dbo].[SP_Configuration_UpdateReleaseNotes] 1,1 'release noetes'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_UpdateReleaseNotes]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_UpdateReleaseNotes]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_UpdateReleaseNotes]
	@configurationId INT,
    @version INT,
    @releaseNotes VARCHAR(MAX)

AS
BEGIN

	DECLARE @comments NVARCHAR(MAX) = ''

	SET @comments = (SELECT ISNULL(LockComment, '') FROM tblConfigurations WHERE ConfigurationID = @configurationId AND Version = @version)

	SET @comments = @comments + ' ' + @releaseNotes

    UPDATE dbo.tblConfigurations
    SET dbo.tblConfigurations.LockComment = @comments
    WHERE dbo.tblConfigurations.ConfigurationID = @configurationId AND dbo.tblConfigurations.Version = @version
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	Utility SP to get the max of configuration and configuration defiition
-- Sample EXEC [dbo].[SP_Configuration_Utility] 'configuration'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_Utility]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_Utility]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_Utility]
	@type VARCHAR(Max)
AS
BEGIN
	IF(@type = 'configuration')
	BEGIN
        SELECT MAX(ConfigurationID) FROM dbo.tblConfigurations;
    END
    ELSE IF (@type = 'configuration definition')
    BEGIN
       SELECT MAX(ConfigurationDefinitionID) FROM dbo.tblConfigurationDefinitions;
    END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author Abhishek Narasimha Prasad
-- Create date: 02/03/2022
-- Description:	Updates Autolock or Autodeploy columns in Configdefinition table
-- Sample EXEC [dbo].[SP_Config_UpdateAutoLockorAutoDeploy] 18, 1, 'AutoLock'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Config_UpdateAutoLockorAutoDeploy]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Config_UpdateAutoLockorAutoDeploy]
END
GO

CREATE PROCEDURE [dbo].[SP_Config_UpdateAutoLockorAutoDeploy]
	@configurationDefinitionId INT,
	@autoLock INT,
	@autoDeploy INT,
	@autoMerge INT

AS
BEGIN
	UPDATE dbo.tblConfigurationDefinitions
	SET AutoLock = @autoLock, AutoDeploy = @autoDeploy, AutoMerge = @autoMerge
	WHERE ConfigurationDefinitionID = @configurationDefinitionId
END
GO

GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
IF OBJECT_ID('[dbo].[SP_CopyConfigurationDefinition]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_CopyConfigurationDefinition]
END
GO

CREATE PROCEDURE [dbo].[SP_CopyConfigurationDefinition]
	@sourceConfigurationDefinitionId int = 0,
	@destinationConfigurationDefinitionId int = 0,
	@description nvarchar(max) = ''
AS
BEGIN
	set nocount on;

	declare @configurationId int;
	set @configurationId = (select max(configurationid) from tblconfigurations where ConfigurationDefinitionID = @sourceConfigurationDefinitionId);

	execute sp_createbranch @configurationId, @destinationConfigurationDefinitionId, 'Script', @description

END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	adds new country entry to tblCountry and returns the country id
-- =============================================

IF OBJECT_ID('[dbo].[SP_Country_Add]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Country_Add]
END
GO

CREATE PROCEDURE [dbo].[SP_Country_Add]
	@configurationId INT,
    @description NVARCHAR(MAX),
    @regionId INT
AS
BEGIN


    DECLARE @countryId INT;
    INSERT INTO dbo.tblCountry (Description,RegionID,CustomChangeBitMask) VALUES(@description,@regionId,1)
    SET @countryId = SCOPE_IDENTITY();
	update dbo.tblCountry set countryid=@countryId where ID=@countryId;
    EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblCountry', @countryId
    SELECT @countryId as countryId

END    
GO  
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	adds new country entry onto tblCountrySpelling
--EXEC [dbo].[SP_Country_AddCountryDetails] 107,8,1,'india'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Country_AddCountryDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Country_AddCountryDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Country_AddCountryDetails] 
	@configurationId INT,
    @countryId INT,
    @languageId INT,
    @countryName NVARCHAR(MAX)

AS
BEGIN
DECLARE @result INT
    IF EXISTS(select tblCountrySpelling.CountryName from tblCountrySpelling inner join tblCountrySpellingMap on tblCountrySpellingMap.CountrySpellingID = tblCountrySpelling.CountrySpellingID
    where tblCountrySpellingMap.ConfigurationID = @configurationId and tblCountrySpellingMap.isDeleted = 0 and tblCountrySpelling.CountryName = @countryName AND tblCountrySpelling.LanguageID = @languageId)
	BEGIN
	 SET @result = 3
	END
	ELSE
	BEGIN
		   BEGIN TRY
             INSERT INTO dbo.tblCountrySpelling(CountryID, CountryName, LanguageID, doSpellCheck, CustomChangeBitMask) 
	         VALUES(@countryId, @countryName, @languageId , 0, 1)
	         SET  @countryId = SCOPE_IDENTITY()
	         EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblCountrySpelling' , @countryId
			SET @result = 1
			END TRY
			BEGIN CATCH
				SET @result =-1
			END CATCH
	END

	SELECT @result as result

END    
GO  
GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Returns list of all the countries for the given configuration
-- =============================================
IF OBJECT_ID('[dbo].[SP_Country_GetAll]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Country_GetAll]
END
GO

CREATE PROCEDURE [dbo].[SP_Country_GetAll]
	@configurationId int
AS
BEGIN
   
  SELECT ID AS CountryID,Description,CountryCode,ISO3166Code,RegionID
  FROM dbo.config_tblCountry(@configurationId) ORDER BY Description ASC

END

GO
GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Returns Details of the country as name of the country in all the selected languages
-- =============================================
IF OBJECT_ID('[dbo].[SP_Country_GetDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Country_GetDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Country_GetDetails]
	@configurationId int,
    @countryId int
AS
BEGIN
   
   CREATE TABLE #tmpSelectedLanguages
(	[RowNum] int not null,
    [ID] int NOT NULL ,
	[LanguageID] int NOT NULL,	
	[Name] nvarchar(100) NULL,	
	[NativeName] nvarchar(100) NULL,
	[Description] nvarchar(255) NULL,
	[ISLatinScript] bit NULL,
	[Tier] smallint NULL,	
	[2LetterID_4xxx] nvarchar(50) NULL,	
	[3LetterID_4xxx] nvarchar(50) NULL,	
	[2LetterID_ASXi] nvarchar(50) NULL,	
	[3LetterID_ASXi] nvarchar(50) NULL,
	[HorizontalOrder] smallint NULL DEFAULT 0,
	[HorizontalScroll] smallint NULL DEFAULT 0,	
	[VerticalOrder] smallint NULL DEFAULT 0,
	[VerticalScroll] smallint NULL DEFAULT 0
);
    INSERT INTO #tmpSelectedLanguages EXEC cust.SP_Global_GetSelectedLanguages @configurationId

    SELECT countrySpelling.CountryID,
	country.Description,
	country.RegionID,
	countrySpelling.CountrySpellingID,
	countrySpelling.LanguageID,
	Name as Language,
	countrySpelling.CountryName

    FROM dbo.config_tblCountrySpelling(@configurationId) as countrySpelling
    inner join #tmpSelectedLanguages ON #tmpSelectedLanguages.LanguageID = countrySpelling.LanguageID
	inner join dbo.config_tblCountry(@configurationId) as country ON country.CountryID = countrySpelling.CountryID
    WHERE countrySpelling.CountryID = country.CountryID and country.ID=@countryId ORDER BY #tmpSelectedLanguages.RowNum ASC

    DROP TABLE #tmpSelectedLanguages
END

GO
GO

-- =============================================
-- Author:		Sathya
-- Create date: 30/09/2022
-- Description:	Updates the country spelling
-- =============================================

IF OBJECT_ID('[dbo].[SP_Country_UpdateCountrySpelling]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Country_UpdateCountrySpelling]
END
GO
CREATE PROC SP_Country_UpdateCountrySpelling
	@configurationId INT,
	@spellingId INT,
    @languageId INT,
    @countryName NVARCHAR(MAX)
AS
BEGIN

DECLARE @updatedSpelId INT


	EXEC SP_ConfigManagement_HandleUpdate @configurationId, 'tblCountrySpelling', @spellingId,@updatedSpelId out

	DECLARE @customcountry INT ,@countryexistingvalue INT,@countryupdatedvalue INT
	SET @customcountry =2
	SET @countryexistingvalue = (SELECT CustomChangeBitMask FROM  tblCountrySpelling WHERE tblCountrySpelling.CountrySpellingID=@updatedSpelId)
	SET @countryupdatedvalue =(@countryexistingvalue | @customcountry)

    UPDATE countrySpelling 
    SET countrySpelling.CountryName =  @countryName,countrySpelling.CustomChangeBitMask = @countryupdatedvalue
    FROM 
    tblCountrySpelling AS countrySpelling 
    WHERE countrySpelling.CountrySpellingID = @updatedSpelId 

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Updates Contry name of the given language, for the given country of the given configuration. Also updates the country description and region id.
-- =============================================

IF OBJECT_ID('[dbo].[SP_Country_UpdateDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Country_UpdateDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Country_UpdateDetails]
	@configurationId INT,
    @countryId INT,
    @description NVARCHAR(MAX),
    @regionId INT
AS
BEGIN
	DECLARE @custom INT, @existingvalue INT,@updatedvalue INT,@updatedcountryId INT
	EXEC SP_ConfigManagement_HandleUpdate @configurationId, 'tblCountry', @countryId,@updatedcountryId out
	SET @custom =2
	SET @existingvalue = (SELECT CustomChangeBitMask FROM tblCountry WHERE tblCountry.CountryID = @updatedcountryId)
	SET @updatedvalue =(@existingvalue | @custom)
	
    UPDATE country
    SET country.Description = @description,
    country.RegionID = @regionId, country.CustomChangeBitMask =@updatedvalue
    FROM dbo.config_tblCountry(@configurationId) AS country
    WHERE country.ID = @updatedcountryId

	
END    
GO  
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Updated By:		Prajna Hegde
-- Update date: 02/02/2022
-- Description:	Added tblASXiInsetMap and tblMapInsetsMap to the list of Configurable Tables. 
				-- Also added DROP PROC block so that it overwrites the existing procedure
-- EXEC [dbo].[SP_CreateBranch] 107,5066,''
-- =============================================

IF OBJECT_ID('[dbo].[SP_CreateBranch]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_CreateBranch]
END
GO

CREATE PROCEDURE [dbo].[SP_CreateBranch] 
	-- Add the parameters for the stored procedure here
	@FromConfigurationID int,
	@IntoConfigurationDefinitionID int,
	@LastModifiedBy nvarchar(100),
	@Description nvarchar(max) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from 
	-- interfering with SELECT statements.
	BEGIN TRY
		BEGIN TRANSACTION CreateConfiguration
		SET NOCOUNT ON;

		 -- report an error if we are create a new version for the same configuration definition and the version we are branching from is not locked

		 declare @fromConfigurationDefinitionId int = (select configurationdefinitionid from tblconfigurations where configurationid = @FromConfigurationID)
		 if (select count(1) from tblconfigurations where configurationdefinitionid = @fromConfigurationDefinitionId ) =1		
		 begin
			 set @FromConfigurationID  =(select max(configurationid) from tblconfigurations where configurationdefinitionid IN
			 (select ConfigurationDefinitionParentID from tblConfigurationDefinitions where configurationdefinitionid = @fromConfigurationDefinitionId) and locked = 1)
		 end
		


		declare @version as int = (select max(version) + 1 from tblconfigurations where configurationdefinitionid = @intoconfigurationdefinitionid);
		if @version is null begin set @version = 1 end

		-- get the next configuration id
		declare @NewConfigurationID as int = (Select max(ConfigurationID) + 1 from  [dbo].[tblConfigurations]);

		-- Create a new configuration
		insert into [dbo].[tblConfigurations]
			([ConfigurationID], [ConfigurationDefinitionID], [Version], [Locked], Description) values
			(@NewConfigurationID, @IntoConfigurationDefinitionID, @version, 0, @Description);

		declare @ParentConfigurationID as int = null
		--set @parentconfigurationid = null
		if exists (select max(configurationid) from tblconfigurations where configurationdefinitionid = @IntoConfigurationDefinitionID)
		begin
			set @ParentConfigurationID = (select max(configurationid) from tblconfigurations where configurationdefinitionid = @IntoConfigurationDefinitionID);
		end

		declare tables cursor for (select tblName from tblConfigTables);
		declare @tableName nvarchar(max) = ''

		open tables

		fetch next from tables into @tableName
		while @@fetch_status = 0
		begin

			print @tableName

			declare @mapTableName nvarchar(max) = @tableName + 'Map'
			declare @sql nvarchar(max) = ''
			declare @count int = 0
			declare @schema nvarchar(max) = ''
			declare @mapColumn nvarchar(max) = ''
			declare @dataColumn nvarchar(max) = ''

			exec dbo.SP_ConfigManagement_FindMappingBetween @mapTablename, @tableName, @mapColumn out, @dataColumn out, @schema out

			--set @sql = formatmessage('delete from %s.%s where configurationid > 1', @schema, @mapTableName);
			--exec sys.sp_executesql @sql
			declare @subSelect nvarchar(max) = ''
			set @subSelect = formatmessage('select %d, %s, Previous%s, IsDeleted, ''%s'' from %s.%s where isDeleted = 0 and ConfigurationId = %d', @NewConfigurationID, @mapColumn, @mapColumn, @LastModifiedBy, @schema, @mapTableName, @FromConfigurationID)
			set @sql = formatmessage('insert into %s.%s (ConfigurationID, %s, Previous%s, IsDeleted, LastModifiedBy) %s;', @schema, @mapTableName, @mapColumn, @mapColumn, @subSelect)

			print @sql
			exec sys.sp_executesql @sql

			fetch next from tables into @tableName
		end

		close tables
		deallocate tables

		Select ConfigurationId, 'New configuration has been created successfully.' as [Message] from dbo.tblConfigurations where ConfigurationId = @NewConfigurationID;

		COMMIT TRANSACTION CreateConfiguration
	END TRY

	BEGIN CATCH
		close tables
		deallocate tables
		ROLLBACK TRANSACTION CreateConfiguration
	END CATCH
END

GO
GO

IF OBJECT_ID('[dbo].[SP_CreateConfigurationDefinition]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_CreateConfigurationDefinition]
END
GO

CREATE PROCEDURE [dbo].[SP_CreateConfigurationDefinition]
	@ParentConfigurationDefinitionID int,
	@NewConfigurationDefinitionID int,
	@ConfigurationTypeID int = 1,
	@OutputTypeID int = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
	INSERT INTO tblConfigurationDefinitions (ConfigurationDefinitionID, ConfigurationDefinitionParentID, ConfigurationTypeID, OutputTypeID, Active, AutoLock, AutoDeploy)
	SELECT @NewConfigurationDefinitionID, ConfigurationDefinitionID, @ConfigurationTypeID, @OutputTypeID, 1, 1, 1 FROM tblConfigurationDefinitions WHERE tblConfigurationDefinitions.ConfigurationDefinitionID = @ParentConfigurationDefinitionID;


END

GO
GO

IF OBJECT_ID('[dbo].[SP_CreateTask]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_CreateTask]
END
GO

CREATE   PROCEDURE [dbo].[SP_CreateTask] 	
	 @TaskTypeId  uniqueidentifier,	
	 @UserId  uniqueidentifier,
	 @TaskStatusId  int,
	 @DetailedStatus  nvarchar(500),
	 @AzureBuildId int
AS
BEGIN
	DECLARE
		@LASTID   uniqueidentifier
		DECLARE @ReturnValue int
	BEGIN
		BEGIN TRANSACTION
			SET @LASTID = NEWID();
			SET @ReturnValue = 1;

		INSERT INTO [dbo].[tblTasks] (ID, TaskTypeID,StartedByUserID,TaskStatusID
			   ,DateStarted,DateLastUpdated,PercentageComplete,DetailedStatus
			   ,AzureBuildID)
		 VALUES
			   (@LASTID, @TaskTypeId, @UserId ,@TaskStatusId, GETDATE()
			   , GETDATE(),0.2,@DetailedStatus,@AzureBuildId)	;
		 

		select tblTasks.ID, tblTasks.TaskStatusID, tblTasks.DetailedStatus from tblTasks where tblTasks.ID = @LASTID;		
		COMMIT	
	END		
END

GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan Abhishek
-- Create date: 08/18/2022
-- Description:	Get the default part number
-- Sample EXEC [dbo].[SP_Default_PartNumber] 7
-- =============================================

IF OBJECT_ID('[dbo].[SP_Default_PartNumber]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Default_PartNumber]
END
GO

CREATE PROCEDURE [dbo].[SP_Default_PartNumber]
	@outputTypeID int
	
    
AS
BEGIN
	DECLARE @partNumberCollectionId INT
	SET @partNumberCollectionId =(select PartNumberCollectionID from tblOutputTypes where OutputTypeID = @outputTypeID )
	select * from tblPartNumber where PartNumberCollectionID = @partNumberCollectionId
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 2/03/2022
-- Description:	Get Features details from FeatureSet table
-- Sample EXEC [dbo].[SP_Feature_GetFeatures] , 'all'
-- Sample EXEC [dbo].[SP_Feature_GetFeatures] , 'featureName'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Feature_GetFeatures]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Feature_GetFeatures]
END
GO

CREATE PROCEDURE [dbo].[SP_Feature_GetFeatures]
	@configurationId INT,
	@featureName NVARCHAR(250)
AS
BEGIN
	IF (@featureName = 'all')
	BEGIN 
		SELECT dbo.tblFeatureSet.Name, 
         dbo.tblFeatureSet.Value
        FROM dbo.tblFeatureSet INNER JOIN dbo.tblConfigurationDefinitions ON dbo.tblFeatureSet.FeatureSetID = dbo.tblConfigurationDefinitions.FeatureSetID 
        INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionID
         AND dbo.tblConfigurations.ConfigurationID = @configurationId 
	END
    ELSE IF (@featureName != 'all')
    BEGIN
       SELECT dbo.tblFeatureSet.Name, 
         dbo.tblFeatureSet.Value
        FROM dbo.tblFeatureSet INNER JOIN dbo.tblConfigurationDefinitions ON dbo.tblFeatureSet.FeatureSetID = dbo.tblConfigurationDefinitions.FeatureSetID 
        INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionID
        AND dbo.tblConfigurations.ConfigurationID = @configurationId
        WHERE dbo.tblFeatureSet.Name = @featureName
    END
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa,Brinda Chindamada
-- Create date: 5/22/2022
-- Description:	update scriptdef table based on condition configurationId and strxml
-- Sample: EXEC [dbo].[SP_FlightInfo]1,'ENGLISH'
-- =============================================
IF OBJECT_ID('[dbo].[SP_FlightInfo]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_FlightInfo]
END

GO

CREATE PROCEDURE [dbo].[SP_FlightInfo]
                        @configurationId INT,
                         @strXml NVARCHAR(Max)
                       

AS

BEGIN  
            DECLARE @sql NVARCHAR(Max)

			DECLARE @xmlTag NVARCHAR(MAX),@count INT=0;

			SELECT @count=COUNT(1) FROM cust.tblScriptDefs SD
           INNER JOIN cust.tblScriptDefsMap SDM ON SD.ScriptDefID = SDM.ScriptDefID
           CROSS APPLY SD.ScriptDefs.nodes('/script_defs/infopages') Nodes(item)
            where SDM.ConfigurationID = @configurationId
			DECLARE @params NVARCHAR(4000) = '@configurationId Int'
			IF @count =0
				BEGIN
					set @xmlTag='<infopages>'+@strXML+'</infopages>';

					SET @sql=('UPDATE [cust].[tblScriptDefs] 
				SET ScriptDefs.modify(''insert ' + @xmlTag +'  as first into (/script_defs)[1]'') 
				FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID 
				WHERE ConfigurationID =  @configurationId ')
				EXEC sys.Sp_executesql @sql ,@params,@configurationId = @configurationId 

				END
			ELSE
				BEGIN
				
				SET @sql=('UPDATE [cust].[tblScriptDefs] 
				SET ScriptDefs.modify(''insert ' + @strXml +'  as last into (/script_defs/infopages)[1]'') 
				FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID 
				WHERE ConfigurationID =  @configurationId ')
				EXEC sys.Sp_executesql @sql ,@params,@configurationId = @configurationId 
				END
END

GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa,Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	This will update the scriptdef table with configurationId,infoname and infoitems
-- Sample: EXEC [dbo].[SP_FlightInfoViewUpdateParameters] 67 ,'Info Page 1_3D','eAltitude,eGroundSpeed,eHeading,eLatitude,eLocalTimeAtPresentPosition,eOutsideAirTemperature,eHeadwindTailwind'
-- =============================================
IF OBJECT_ID('[dbo].[SP_FlightInfoViewUpdateParameters]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_FlightInfoViewUpdateParameters]

END

GO

CREATE PROCEDURE [dbo].[SP_FlightInfoViewUpdateParameters]
                        @configurationId INT,
                        @infoName NVARCHAR(Max),
                        @infoItems NVARCHAR(Max)

AS

BEGIN        
         DECLARE @sql NVARCHAR(Max),@ScriptDefID Int,@updateKey Int
		 DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
		  SET @ScriptDefID = (SELECT cust.tblScriptDefsMap.ScriptDefID FROM cust.tblScriptDefsMap WHERE cust.tblScriptDefsMap.configurationId = @configurationId)
		  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@ScriptDefID,@updateKey out
         SET @sql=('UPDATE [cust].[tblScriptDefs]
             SET ScriptDefs.modify(''replace value of (/script_defs/infopages/infopage [@name=  "'+ @infoName +'"]/@infoitems)[1] 
             with  "'+ @infoItems + '" '')
             FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID 
             where  ConfigurationID = @configurationId AND b.ScriptDefID = @updateKey ')
		 EXEC sys.Sp_executesql @sql ,@params,@configurationId = @configurationId,@updateKey=@updateKey 
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get available flightinfo parameters
-- Sample EXEC [dbo].[SP_FlightInfo_GetAvailableFlightInfoParameters] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_FlightInfo_GetAvailableFlightInfoParameters]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_FlightInfo_GetAvailableFlightInfoParameters]
END
GO

CREATE PROCEDURE [dbo].[SP_FlightInfo_GetAvailableFlightInfoParameters]
@ConfigurationId INT 
AS
BEGIN
	DECLARE @temp TABLE(infoParamDisplay NVARCHAR(500), infoParamName NVARCHAR(500))
	DECLARE @infoParamDisplay NVARCHAR(500), @infoParamName NVARCHAR(500)

	SET @infoParamName = (SELECT FS.Value FROM tblFeatureSet FS
                    INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
                    INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
                    WHERE FS.Name = 'FlightInfo-ParametersList' AND C.ConfigurationID = @configurationId)

	SET @infoParamDisplay = (SELECT FS.Value FROM tblFeatureSet FS
                    INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
                    INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
                    WHERE FS.Name = 'FlightInfo-ParametersDisplayList' AND C.ConfigurationID = @configurationId)

	INSERT INTO @temp(infoParamDisplay, infoParamName) VALUES (@infoParamDisplay, @infoParamName)

	SELECT * FROM @temp
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get and Update flightinfo parameters names
-- Sample EXEC [dbo].[SP_FlightInfo_GetFlightInfoParameters] 1, 'get', xmldata
-- =============================================

IF OBJECT_ID('[dbo].[SP_FlightInfo_GetFlightInfoParameters]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_FlightInfo_GetFlightInfoParameters]
END
GO

CREATE PROCEDURE [dbo].[SP_FlightInfo_GetFlightInfoParameters]
@ConfigurationId INT,
@pageName NVARCHAR(20),
@type NVARCHAR(150),
@xmlData XML = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		DECLARE @temp TABLE(xmldisplayName NVARCHAR(MAX), infoParamDisplay NVARCHAR(MAX), infoParamName NVARCHAR(MAX), xmlData XML)
		DECLARE @name NVARCHAR(MAX), @infoParamDisplay NVARCHAR(MAX), @infoParamName NVARCHAR(MAX), @xml XML

		SET @name = '';
		IF (@pageName = 'flightinfo')
		BEGIN
			SELECT @name = @name + ISNULL(Nodes.item.value('(./text())[1]', 'varchar(max)'), '') + ','
			FROM cust.config_tblWebmain(@configurationId) as M
			CROSS APPLY M.InfoItems.nodes('//infoitem') AS Nodes(item)
			WHERE Nodes.item.value('(./@default_flight_info)[1]', 'varchar(max)') = 'true'
		END
		ELSE IF (@pageName = 'broadcast')
		BEGIN
			SELECT @name = @name + ISNULL(Nodes.item.value('(./text())[1]', 'varchar(max)'), '') + ','
			FROM cust.config_tblWebmain(@configurationId) as M
			CROSS APPLY M.InfoItems.nodes('//infoitem') AS Nodes(item)
			WHERE Nodes.item.value('(./@broadcast)[1]', 'varchar(max)') = 'true'
		END
		ELSE IF (@pageName = 'yourflight')
		BEGIN
			SELECT @name = @name + ISNULL(Nodes.item.value('(./text())[1]', 'varchar(max)'), '') + ','
			FROM cust.config_tblWebmain(@configurationId) as M
			CROSS APPLY M.InfoItems.nodes('//infoitem') AS Nodes(item)
			WHERE Nodes.item.value('(./@yourflight)[1]', 'varchar(max)') = 'true'
		END
		SET @infoParamName = (SELECT FS.Value FROM tblFeatureSet FS
						INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
						INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
						WHERE FS.Name = 'FlightInfo-ParametersList' AND C.ConfigurationID = @ConfigurationId)

		SET @infoParamDisplay = (SELECT FS.Value FROM tblFeatureSet FS
						INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
						INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
						WHERE FS.Name = 'FlightInfo-ParametersDisplayList' AND C.ConfigurationID = @configurationId)

		SET @xml = (SELECT InfoItems FROM cust.config_tblWebmain(@configurationId))

		INSERT INTO @temp(xmldisplayName, infoParamDisplay, infoParamName, xmlData) VALUES (@name, @infoParamDisplay, @infoParamName, @xml)

		SELECT * FROM @temp
	END
	ELSE IF(@type = 'update')
	BEGIN
		BEGIN TRY
		IF (@xmlData IS NOT NULL)
		BEGIN
			DECLARE @mappedWebMainID INT, @updateKey INT
			SET @mappedWebMainID = (SELECT WebMainID FROM cust.tblWebMainMap WHERE configurationId = @configurationId)
			IF NOT @mappedWebMainID IS NULL
       		BEGIN	
				exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWebmain', @mappedWebMainID, @updateKey out

				UPDATE WM
				SET InfoItems = @xmlData FROM cust.config_tblWebmain(@configurationId) AS WM WHERE WM.WebMainID = @updateKey
			END
			ELSE
			BEGIN
				DECLARE @webmainId INT
				INSERT INTO cust.tblWebMain (infoItems) VALUES (@xmlData)
				SET @webmainId = (SELECT MAX(WebMainID) FROM cust.tblWebMain)
				EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblWebmain', @webmainId
			END
			SELECT 1 AS retValue
		END
		ELSE
		BEGIN
			SELECT 0 AS retValue
		END
		END TRY
		BEGIN CATCH
		SELECT 0 AS retValue
		END CATCH
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get and update the xml data for the Flightinfo
-- Sample EXEC [dbo].[SP_FlightInfo_MoveFlightInfoLocation] 18, 'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_FlightInfo_MoveFlightInfoLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_FlightInfo_MoveFlightInfoLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_FlightInfo_MoveFlightInfoLocation]
@configurationId INT,
@type NVARCHAR(150),
@xmlData XML = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		SELECT InfoItems FROM cust.config_tblWebmain(@configurationId) as WM
	END
	ELSE IF (@type = 'update' AND @xmlData IS NOT NULL)
	BEGIN
		BEGIN TRY
			declare @mappedWebMainID int	
			declare @updateKey int
			set @mappedWebMainID = (select WebMainID from cust.tblWebMainMap where configurationId = @configurationId)
			if not @mappedWebMainID is null
       		BEGIN	
			   
			   	exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWebmain', @mappedWebMainID, @updateKey out
				UPDATE WM
				SET InfoItems = @xmlData FROM cust.config_tblWebmain(@configurationId) as WM WHERE WM.WebMainID = @updateKey
			END
			SELECT 1 AS retValue
		END TRY
		BEGIN CATCH
			SELECT 0 AS retValue
		END CATCH
	END
	ELSE
	BEGIN
		SELECT 0 AS retValue
	END
END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date:  5/24/2022
-- Description:	This SP will return the rows from DownloadPreferenceAssignment table based on tail number and downloadPreferenceId
-- Sample: EXEC [dbo].[SP_GetAircraftDownloadPreferenceId] 'xyz_deleted_637012045649249189','C41ADFC5-CB74-41B7-A271-E0F7F0BC51C7'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetAircraftDownloadPreferenceId]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetAircraftDownloadPreferenceId]
END
GO

CREATE PROCEDURE [dbo].[SP_GetAircraftDownloadPreferenceId]
        @tailNumber NVARCHAR(100),
		@downloadPreferenceId  uniqueidentifier
       
AS

BEGIN

               SELECT dbo.DownloadPreferenceAssignment.* FROM dbo.DownloadPreferenceAssignment 
               INNER JOIN dbo.Aircraft ON dbo.DownloadPreferenceAssignment.AircraftId = dbo.Aircraft.Id 
               WHERE dbo.Aircraft.TailNumber = @tailNumber AND dbo.DownloadPreferenceAssignment.DownloadPreferenceId = @downloadPreferenceId
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date:  5/24/2022
-- Description:	This SP will return DownloadPreferenceAssignment based on tailnumber and assestType
-- Sample: EXEC [dbo].[SP_GetAircraftDownloadPreferences]'xyz_deleted_637012045649249189',1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetAircraftDownloadPreferences]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetAircraftDownloadPreferences]
END
GO

CREATE PROCEDURE [dbo].[SP_GetAircraftDownloadPreferences]
		@tailNumber NVARCHAR(300),
        @assetType INT
AS

BEGIN

               SELECT dbo.DownloadPreferenceAssignment.* FROM dbo.DownloadPreferenceAssignment 
               INNER JOIN dbo.Aircraft ON dbo.DownloadPreferenceAssignment.AircraftId = dbo.Aircraft.Id 
               INNER JOIN dbo.DownloadPreference on dbo.DownloadPreferenceAssignment.DownloadPreferenceID = dbo.DownloadPreference.Id 
               WHERE dbo.Aircraft.TailNumber = @tailNumber AND dbo.DownloadPreference.AssetType = @assetType
END
GO


GO

/****** Object:  StoredProcedure [dbo].[SP_getAirportConflicts]    Script Date: 10/27/2022 5:15:06 PM ******/
IF OBJECT_ID('[dbo].[SP_getAirportConflicts]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_getAirportConflicts]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_getAirportConflicts]    Script Date: 10/27/2022 5:15:06 PM ******/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROC [dbo].[SP_getAirportConflicts]
@taskId UNIQUEIDENTIFIER
AS
BEGIN

 DROP TABLE IF EXISTS #TEMP_AIRPORT_PARENT
  DROP TABLE IF EXISTS #TEMP_AIRPORT_CHILD
    DROP TABLE IF EXISTS #TEMP

CREATE TABLE #TEMP_AIRPORT_PARENT(ID INT,MergeChoice INT, SelectedKey INT,AirportId int,GeoRefId int,Description varchar(MAX),FourLetID NVARCHAR(8),ThreeLetID NVARCHAR(6),Lat decimal(9),Lon decimal(9),City NVARCHAR(MAX));
CREATE TABLE #TEMP_AIRPORT_CHILD(ID INT,MergeChoice INT, SelectedKey INT,AirportId int,GeoRefId int,Description varchar(MAX),FourLetID NVARCHAR(8),ThreeLetID NVARCHAR(6),Lat decimal(9),Lon decimal(9),City NVARCHAR(MAX));
 
SELECT ID,ChildKey,ParentKey,TableName,SelectedKey,MergeChoice INTO #TEMP FROM tblMergeDetails where MergeChoice NOT IN(1,3) AND TableName IN('tblAirportInfo') AND TaskId = @taskId;
 
DECLARE @TableName varchar(50),@ParentKey INT,@ChildKey INT,@MergeChoice INT,@SelectedKey INT,@ID INT
 
DECLARE cur_tbl CURSOR 
 FOR
              SELECT ID,ChildKey,ParentKey,TableName,MergeChoice,SelectedKey
              FROM   #TEMP
 
                      OPEN cur_tbl
 
            FETCH next FROM cur_tbl INTO @ID,@ChildKey,@ParentKey,@TableName,@MergeChoice,@SelectedKey
                    --print @config_table
            WHILE @@FETCH_STATUS = 0
              BEGIN
                              
                                 insert into #TEMP_AIRPORT_PARENT(ID,MergeChoice,SelectedKey,AirportId,FourLetID,ThreeLetID,Lat,Lon,City,Description) 
                                 
									SELECT @ID,@MergeChoice,@SelectedKey,airPort.AirportInfoID, airPort.FourLetID,airPort.ThreeLetID,airPort.Lat,airPort.Lon, airPort.CityName, geo.Description
									FROM tblAirportInfo airPort 
                                 INNER JOIN tblGeoRef geo on geo.GeoRefId=airPort.GeoRefId 
                                 WHERE AirportInfoID in(@ParentKey);
 
                                 insert into #TEMP_AIRPORT_CHILD(ID,MergeChoice,SelectedKey,AirportId,FourLetID,ThreeLetID,Lat,Lon,City,Description) 
                                 
									SELECT @ID,@MergeChoice,@SelectedKey,airPort.AirportInfoID,airPort.FourLetID,airPort.ThreeLetID,airPort.Lat,airPort.Lon, airPort.CityName, geo.Description
									FROM tblAirportInfo airPort 
                                 INNER JOIN tblGeoRef geo on geo.GeoRefId=airPort.GeoRefId 
                                 WHERE AirportInfoID in(@ChildKey);
 
                           FETCH next FROM cur_tbl INTO @ID,@ChildKey,@ParentKey,@TableName,@MergeChoice,@SelectedKey
                      END
 CLOSE cur_tbl

            DEALLOCATE cur_tbl
--compare 2 tables and display the values

DECLARE @TEMP_RESULT TABLE(ID INT,  [Key] NVARCHAR(MAX), Parent_value NVARCHAR(MAX), Child_value NVARCHAR(MAX))
INSERT INTO @TEMP_RESULT
Select ID, [key], Parent_Value = max( case when Src=1 then Value end), Child_Value = max( case when Src=2 then Value end)
From ( Select Src=1, ID, B.*
         From #TEMP_AIRPORT_PARENT A
         Cross Apply (Select [Key], Value From OpenJson((Select A.ID,ISNULL(A.FourLetID, '') AS FourLetID,ISNULL(A.ThreeLetID, '') AS ThreeLetID,A.Lat,A.Lon,A.City For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
               B
        Union All
        Select Src=2, ID, B.*
         From #TEMP_AIRPORT_CHILD A
         Cross Apply (Select [Key], Value From OpenJson((Select A.ID,ISNULL(A.FourLetID, '') AS FourLetID,ISNULL(A.ThreeLetID, '') AS ThreeLetID,A.Lat,A.Lon,A.City For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
               B
      ) A
Group By ID, [key]
Having max(case when Src=1 then Value end) <> max(case when Src=2 then Value end)
Order By ID, [key]
--SELECT * FROM @TEMP_RESULT 
 
SELECT t.ID, C.AirportId AS ContentID, 'Airport' AS ContentType, c.Description AS Description, t.[Key] AS DisplayName, t.Parent_value AS ParentValue, t.Child_value AS ChildValue, 
 CASE WHEN m.SelectedKey = m.ParentKey THEN t.Parent_value  WHEN m.SelectedKey = m.ChildKey THEN t.Child_Value ELSE NULL END AS SelectedValue  
 FROM @TEMP_RESULT t, tblMergeDetails m, #TEMP_AIRPORT_CHILD c WHERE t.ID = m.ID AND t.ID = c.ID 

END
GO

GO

/****** Object:  StoredProcedure [dbo].[SP_GetAirportUpdates]    Script Date: 11/02/2022 5:15:06 PM ******/
IF OBJECT_ID('[dbo].[SP_GetAirportUpdates]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_GetAirportUpdates]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetAirportUpdates]    Script Date: 11/02/2022 5:15:06 PM ******/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROC [dbo].[SP_GetAirportUpdates]
	@tableXml XML
AS
BEGIN

	DROP TABLE IF EXISTS #TEMP_AIRPORT_PARENT
	DROP TABLE IF EXISTS #TEMP_AIRPORT_CHILD
    DROP TABLE IF EXISTS #TEMP

	CREATE TABLE #TEMP_AIRPORT_PARENT(ID INT, AirportId int,GeoRefId int,Description varchar(MAX),FourLetID NVARCHAR(8),ThreeLetID NVARCHAR(6),Lat decimal(9),Lon decimal(9),City NVARCHAR(MAX), Action NVARCHAR(10));
	CREATE TABLE #TEMP_AIRPORT_CHILD(ID INT, AirportId int,GeoRefId int,Description varchar(MAX),FourLetID NVARCHAR(8),ThreeLetID NVARCHAR(6),Lat decimal(9),Lon decimal(9),City NVARCHAR(MAX), Action NVARCHAR(10));
 
	CREATE TABLE #TEMP (ID INT IDENTITY, TableName NVARCHAR(100), CurrentKey INT, PreviousKey INT, Action NVARCHAR(10))
	INSERT INTO #TEMP 
	SELECT Tbl.Col.value('@TableName', 'NVARCHAR(100)') AS TableName,  Tbl.Col.value('@CurrentKey', 'INT') AS CurrentKey,  
       Tbl.Col.value('@PreviousKey', 'INT') AS PreviousKey, Tbl.Col.value('@Action', 'NVARCHAR(10)') AS Action 
	FROM   @tableXml.nodes('//row') Tbl(Col) WHERE Tbl.Col.value('@TableName', 'NVARCHAR(100)') IN('tblAirportInfo');
  
	DECLARE @ID INT, @TableName VARCHAR(50),@ParentKey INT,@ChildKey INT, @Action NVARCHAR(10)

	DECLARE cur_tbl CURSOR 
	FOR
	SELECT ID,TableName,PreviousKey,CurrentKey,Action
	FROM   #TEMP WHERE Action = 'Update'
	
	OPEN cur_tbl
	FETCH next FROM cur_tbl INTO @ID,@TableName ,@ParentKey ,@ChildKey, @Action 
	WHILE @@FETCH_STATUS = 0
	BEGIN
                              
		INSERT INTO #TEMP_AIRPORT_PARENT(ID,AirportId,FourLetID,ThreeLetID,Lat,Lon,City,Description,Action)                                 
		SELECT @ID, airPort.AirportInfoID, airPort.FourLetID,airPort.ThreeLetID,airPort.Lat,airPort.Lon, airPort.CityName, geo.Description,@Action
		FROM tblAirportInfo airPort 
		INNER JOIN tblGeoRef geo on geo.GeoRefId=airPort.GeoRefId 
		WHERE AirportInfoID in(@ParentKey);
 
		INSERT INTO #TEMP_AIRPORT_CHILD(ID,AirportId,FourLetID,ThreeLetID,Lat,Lon,City,Description,Action)                                  
		SELECT @ID, airPort.AirportInfoID,airPort.FourLetID,airPort.ThreeLetID,airPort.Lat,airPort.Lon, airPort.CityName, geo.Description,@Action
		FROM tblAirportInfo airPort 
		INNER JOIN tblGeoRef geo on geo.GeoRefId=airPort.GeoRefId 
		WHERE AirportInfoID in(@ChildKey);
 
		FETCH NEXT FROM cur_tbl INTO @ID, @TableName, @ParentKey, @ChildKey, @Action
	END 
	CLOSE cur_tbl
	DEALLOCATE cur_tbl
	--compare 2 tables and display the values
	--SELECT * FROM #TEMP_AIRPORT_PARENT
	--SELECT * FROM #TEMP_AIRPORT_CHILD
	DECLARE @TEMP_RESULT TABLE(ID INT, [Key] NVARCHAR(MAX), Parent_value NVARCHAR(MAX), Child_value NVARCHAR(MAX), Action NVARCHAR(10))
	INSERT INTO @TEMP_RESULT
	SELECT ID, [key], Parent_Value = MAX( CASE WHEN Src=1 THEN Value END), Child_Value = MAX( CASE WHEN Src=2 THEN Value END), Action
	FROM ( SELECT Src=1, ID, Action, B.*
			 FROM #TEMP_AIRPORT_PARENT A
			 CROSS APPLY (SELECT [Key], Value FROM OPENJSON((SELECT A.ID, ISNULL(A.FourLetID, '') AS FourLetID,ISNULL(A.ThreeLetID, '') AS ThreeLetID,A.Lat,A.Lon,A.City FOR JSON PATH,WITHOUT_ARRAY_WRAPPER,INCLUDE_NULL_VALUES))) 
				   B
			UNION ALL
			SELECT Src=2, ID, Action, B.*
			 FROM #TEMP_AIRPORT_CHILD A
			 CROSS APPLY (SELECT [Key], Value FROM OPENJSON((SELECT A.ID, ISNULL(A.FourLetID, '') AS FourLetID,ISNULL(A.ThreeLetID, '') AS ThreeLetID,A.Lat,A.Lon,A.City FOR JSON PATH,WITHOUT_ARRAY_WRAPPER,INCLUDE_NULL_VALUES))) 
				   B
		  ) A
	GROUP BY ID, [key], Action
	HAVING MAX(CASE WHEN Src=1 THEN Value END) <> MAX(CASE WHEN Src=2 THEN Value END)
	ORDER BY ID, [key]
	--SELECT * FROM @TEMP_RESULT 
 
	SELECT C.AirportId AS ContentID, 'Airport' AS ContentType, c.Description AS Name, t.[Key] AS Field, 
	t.Parent_value AS PreviousValue, t.Child_value AS CurrentValue, t.Action
	FROM @TEMP_RESULT t, #TEMP_AIRPORT_CHILD c WHERE  t.ID = c.ID 
	UNION
	SELECT t.CurrentKey AS ContentID, 'Airport' AS ContentType, g.Description AS Name, NULL, NULL, NULL, t.Action
	FROM #TEMP t, tblAirportInfo a, tblGeoRef g WHERE t.CurrentKey = a.AirportInfoID AND a.GeoRefID = g.GeoRefId AND t.Action IN ('Insert', 'Delete')
END
GO

GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetAllCountrySpellings]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetAllCountrySpellings]
END
GO
CREATE PROC sp_GetAllCountrySpellings
@configurationId INT,
@languageCodes NVARCHAR(MAX)
AS
BEGIN

DECLARE @sql NVARCHAR(MAX)
SET @sql = 'select
	*
from 
(
	select 
		CountryID, 
		tblLanguages.[2LetterID_ASXi] AS Code, 
		CountryName 
	from dbo.tblCountrySpelling 
		inner join tblCountrySpellingMap as csmap on csmap.CountrySpellingID = tblCountrySpelling.CountrySpellingID
		inner join tblLanguages on tblLanguages.LanguageID = dbo.tblCountrySpelling.LanguageID 
		inner join tblLanguagesMap as lmap on lmap.LanguageID = tblLanguages.ID
	where
		csmap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ' and csmap.isDeleted=0
		and lmap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ' and lmap.isDeleted=0
) as sourcetable 
pivot(max(countryname) for Code in (' + @languageCodes + ')) as pivottable 
order by countryid;'

EXEC (@sql)

END

GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada
-- Create date: 5/24/2022
-- Description:	Returns number of rows from DownloadPreference table based on assetType
-- Sample: EXEC [dbo].[SP_GetAllDownloadPreference] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetAllDownloadPreference]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetAllDownloadPreference]
END
GO

CREATE PROCEDURE [dbo].[SP_GetAllDownloadPreference]
        @assetType INT
       
AS

BEGIN

       SELECT * FROM dbo.DownloadPreference WHERE dbo.DownloadPreference.AssetType = @assetType
END
GO


GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 01/25/2023
-- Description:	To get values from feature set table. If configuration def Id is 1 then get all distinct values, if not get values for specific configuration def id
-- Sample EXEC [dbo].[SP_GetAllFeatureSet] 5050
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetAllFeatureSet]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetAllFeatureSet]
END
GO

CREATE PROCEDURE [dbo].[SP_GetAllFeatureSet]
    @configurationDefinitionId INT
AS
BEGIN
	DECLARE @featureSetId INT
	DECLARE @temptable TABLE(ID INT IDENTity(1,1), NAME NVARCHAR(500))
	DECLARE @featuresetValue TABLE(ID INT IDENTITY(1,1), featureSetName NVARCHAR(500), value NVARCHAR(MAX), selectedValue BIT, featureSetId INT,
				inputtype NVARCHAR(50), uniqueList NVARCHAR(MAX))
	DECLARE @distinctFeaturesetValue TABLE(ID INT IDENTITY(1,1), distinctFeatureSetName NVARCHAR(500), value NVARCHAR(MAX), selectedValue BIT,
											featureSetId INT, inputtype NVARCHAR(50))
	CREATE TABLE #selectedValueList (ID INT IDENTITY(1,1), val NVARCHAR(500))
	CREATE TABLE #uniqueValueList (ID INT IDENTITY(1,1), val NVARCHAR(500))
	DECLARE @tempFeatureSet TABLE(ID INT IDENTITY(1,1), featureSetId INT, Name NVARCHAR(500), Value NVARCHAR(MAX), keyFeatureSetID INT)
	DECLARE @finalList TABLE(ID INT IDENTITY(1,1), Name NVARCHAR(500))
	DECLARE @id INT, @inputtype NVARCHAR(500), @value NVARCHAR(MAX), @name NVARCHAR(MAX), @uniqueValue NVARCHAR(MAX), @selected NVARCHAR(MAX),
	@featureId INT, @CommaSeparatedString NVARCHAR(MAX), @keyId INT

	CREATE TABLE #keyList (ID INT IDENTITY(1,1), val NVARCHAR(500))
	CREATE TABLE #valueList (ID INT IDENTITY(1,1), val NVARCHAR(500))
	DECLARE @keys NVARCHAR(MAX), @values NVARCHAR(MAX)
	CREATE TABLE #selectedKeyList (ID INT IDENTITY(1,1), val NVARCHAR(500))
	CREATE TABLE #uniquekeyList (ID INT IDENTITY(1,1), val NVARCHAR(500))
    DECLARE @uniqueList AS TABLE (val NVARCHAR(500))
    DECLARE @selectedList AS TABLE (val NVARCHAR(500))
	DECLARE @selectedKeys NVARCHAR(MAX), @uniqueKeys NVARCHAR(MAX)
	SET @featureSetId = (SELECT FeatureSetID FROM tblConfigurationDefinitions WHERE ConfigurationDefinitionID = @configurationDefinitionId)
	--Global featurset
	IF (@configurationDefinitionId = 1 OR @featureSetId IS NULL)
	BEGIN

		INSERT INTO @temptable SELECT DISTINCT Name FROM tblFeatureSet WHERE IsConfigurable = 1
		WHILE (SELECT COUNT(*) FROM @temptable) > 0
		BEGIN
			SET @id = (SELECT TOP 1 id FROM @temptable)
			SET @name = (SELECT name FROM @temptable WHERE id = @id)
			SET @value = (SELECT value FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1)
			SET @inputtype = (SELECT Name FROM tblFeatureSetInputType WHERE InputTypeID = (SELECT InputTypeID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1))
			SET @keyId = (SELECT KeyFeatureSetID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1)
			--Dropdown with keyvalue pair
			IF (@inputtype = 'dropdown' AND @keyId IS NOT NULL)
			BEGIN
				SET @keys = (SELECT VALUE FROM tblFeatureSet WHERE ID = @keyId)
				SET @values = @value

				INSERT INTO #keyList SELECT * FROM STRING_SPLIT(@keys, ',')
				INSERT INTO #valueList SELECT * FROM STRING_SPLIT(@values, ',')

				INSERT INTO @finalList 
				SELECT LTRIM(RTRIM(xml.val)) + '|' + LTRIM(RTRIM(display.val)) AS keyValue FROM #keyList xml INNER JOIN #valueList display ON xml.ID = display.ID

				SELECT @CommaSeparatedString = COALESCE(@CommaSeparatedString + ',', '') + (LTRIM(RTRIM(Name))) FROM @finalList
				
				INSERT INTO @distinctFeaturesetValue (distinctFeatureSetName, value, selectedValue, featureSetId, inputtype) VALUES (@name, @CommaSeparatedString, 0, 1, @inputtype)

				TRUNCATE TABLE #keyList
				TRUNCATE TABLE #valueList
				DELETE FROM @finalList
			END
			--Other InputTypes
			ELSE
			BEGIN
				INSERT INTO @distinctFeaturesetValue (distinctFeatureSetName, value, selectedValue, featureSetId, inputtype) VALUES (@name, @value, 0, 1, @inputtype)
			END
			DELETE FROM @temptable WHERE id = @id
		END
		SELECT * FROM @distinctFeaturesetValue ORDER BY distinctFeatureSetName ASC
	END
	--Product level selected featureset
	ELSE
	BEGIN
		INSERT INTO @temptable SELECT DISTINCT Name FROM tblFeatureSet WHERE FeatureSetID = @featureSetId AND IsConfigurable = 1
		
		WHILE (SELECT COUNT(*) FROM @temptable) > 0
		BEGIN
			SET @id = (SELECT TOP 1 id FROM @temptable)
			SET @name = (SELECT name FROM @temptable WHERE id = @id)
			SET @value = (SELECT value FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = @featureSetId)
			SET @inputtype = (SELECT Name FROM tblFeatureSetInputType WHERE InputTypeID = (SELECT InputTypeID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = @featureSetId))
			SET @keyId = (SELECT KeyFeatureSetID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = @featureSetId)

			IF (@inputtype = 'dropdown')
			BEGIN
				--Dropdown with keyvalue pair
				IF (@keyId IS NOT NULL)
				BEGIN
					SET @CommaSeparatedString = NULL
					INSERT INTO @tempFeatureSet SELECT FeatureSetID, Name, value, KeyFeatureSetID FROM tblFeatureSet WHERE Name = @name
					SET @selected = (SELECT VALUE FROM tblFeatureSet WHERE Name = @name AND FeatureSetID = @featureSetId)
					SET @selectedKeys = (SELECT VALUE FROM tblFeatureSet WHERE ID = @keyId)

					WHILE (SELECT COUNT (*) FROM @tempFeatureSet) > 0
					BEGIN
						SET @featureId = (SELECT TOP 1 ID FROM @tempFeatureSet)
						SET @uniqueValue = (SELECT Value FROM @tempFeatureSet WHERE ID = @featureId)
						SET @keyId = (SELECT keyFeatureSetID FROM @tempFeatureSet WHERE ID = @featureId)
						SET @uniqueKeys = (SELECT value FROM tblFeatureSet WHERE ID = @keyId)

						INSERT INTO #selectedValueList SELECT * FROM STRING_SPLIT(@selected, ',')
						INSERT INTO #selectedKeyList SELECT * FROM STRING_SPLIT(@selectedKeys, ',')

						INSERT INTO #uniqueValueList SELECT * FROM STRING_SPLIT(@uniqueValue, ',')
						INSERT INTO #uniquekeyList SELECT * FROM STRING_SPLIT(@uniqueKeys, ',')

                        INSERT INTO @selectedList 
					    SELECT LTRIM(RTRIM(xml.val)) + '|' + LTRIM(RTRIM(display.val)) AS keyValue FROM #selectedKeyList xml INNER JOIN #selectedValueList display ON xml.ID = display.ID

                        INSERT INTO @uniqueList 
					    SELECT LTRIM(RTRIM(xml.val)) + '|' + LTRIM(RTRIM(display.val)) AS keyValue FROM #uniquekeyList xml INNER JOIN #uniqueValueList display ON xml.ID = display.ID

						DELETE FROM @tempFeatureSet WHERE ID = @featureId
					END
					--To Bind UniqueList field with key|value pair
                    DELETE FROM @finalList
					INSERT INTO @finalList 
					SELECT DISTINCT LTRIM(RTRIM(val)) FROM @uniqueList  WHERE val NOT IN (SELECT DISTINCT LTRIM(RTRIM(val)) FROM @selectedList)

					SELECT @CommaSeparatedString = COALESCE(@CommaSeparatedString + ',', '') + (LTRIM(RTRIM(Name))) FROM @finalList

					--To Bind Value Field with key|value pair
					SET @keys = (SELECT VALUE FROM tblFeatureSet WHERE ID = @keyId)
					SET @values = @value

					TRUNCATE TABLE #keyList
					TRUNCATE TABLE #valueList
					INSERT INTO #keyList SELECT * FROM STRING_SPLIT(@selectedKeys, ',')
					INSERT INTO #valueList SELECT * FROM STRING_SPLIT(@values, ',')

					DELETE FROM @finalList
					INSERT INTO @finalList 
					SELECT LTRIM(RTRIM(xml.val)) + '|' + LTRIM(RTRIM(display.val)) AS keyValue FROM #keyList xml INNER JOIN #valueList display ON xml.ID = display.ID
					SET @value = NULL
					SELECT @value = COALESCE(@value + ',', '') + (LTRIM(RTRIM(Name))) FROM @finalList

					INSERT INTO @featuresetValue (featureSetName, value, selectedValue, featureSetId, inputtype, uniqueList) 
					VALUES (@name, @value, 1, @featureSetId, @inputtype, @CommaSeparatedString)

					TRUNCATE TABLE #selectedKeyList
					TRUNCATE TABLE #uniqueKeyList
					TRUNCATE TABLE #selectedValueList
					TRUNCATE TABLE #uniqueValueList
					TRUNCATE TABLE #keyList
					TRUNCATE TABLE #valueList
					DELETE FROM @finalList
				END
				--Dropdown without keyvalue pair
				ELSE
				BEGIN
					SET @CommaSeparatedString = NULL
					INSERT INTO @tempFeatureSet SELECT FeatureSetID, Name, value, KeyFeatureSetID FROM tblFeatureSet WHERE Name = @name
					SET @selected = NULL
                    SET @selected = (SELECT VALUE FROM tblFeatureSet WHERE Name = @name AND FeatureSetID = @featureSetId)
					WHILE (SELECT COUNT (*) FROM @tempFeatureSet) > 0
					BEGIN
						SET @featureId = (SELECT TOP 1 ID FROM @tempFeatureSet)
						SET @uniqueValue = (SELECT Value FROM @tempFeatureSet WHERE ID = @featureId)

						INSERT INTO #selectedValueList SELECT * FROM STRING_SPLIT(@selected, ',')
						INSERT INTO #uniqueValueList SELECT * FROM STRING_SPLIT(@uniqueValue, ',')

						DELETE FROM @tempFeatureSet WHERE ID = @featureId
					END
                    DELETE FROM @finalList
					INSERT INTO @finalList SELECT DISTINCT LTRIM(RTRIM(VAL)) FROM #uniqueValueList  WHERE val NOT IN (SELECT DISTINCT LTRIM(RTRIM(val)) FROM #selectedValueList)
					SELECT @CommaSeparatedString = COALESCE(@CommaSeparatedString + ',', '') + (LTRIM(RTRIM(Name))) FROM @finalList

					INSERT INTO @featuresetValue (featureSetName, value, selectedValue, featureSetId, inputtype, uniqueList) 
					VALUES (@name, @selected, 1, @featureSetId, @inputtype, @CommaSeparatedString)

					TRUNCATE TABLE #selectedValueList
					TRUNCATE TABLE #uniqueValueList
					TRUNCATE TABLE #keyList
					TRUNCATE TABLE #valueList
					DELETE FROM @finalList
				END
			END
			--Other InputTypes
			ELSE
			BEGIN
				INSERT INTO @featuresetValue (featureSetName, value, selectedValue, featureSetId, inputtype) VALUES (@name, @value, 1, @featureSetId, @inputtype)
			END

			DELETE FROM @temptable WHERE id = @id
		END
		--All Available featureset
		INSERT INTO @temptable SELECT DISTINCT Name FROM tblFeatureSet WHERE IsConfigurable = 1 AND NAME NOT IN (SELECT Name FROM tblFeatureSet WHERE FeatureSetID = @featureSetId)

		WHILE (SELECT COUNT(*) FROM @temptable) > 0
		BEGIN
			SET @id = (SELECT TOP 1 id FROM @temptable)
			SET @name = (SELECT name FROM @temptable WHERE id = @id)
			SET @value = (SELECT value FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1)
			SET @inputtype = (SELECT Name FROM tblFeatureSetInputType WHERE InputTypeID = (SELECT InputTypeID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1))
			SET @keyId = (SELECT KeyFeatureSetID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1)
			--Dropdown with keyvalue pair
			IF (@inputtype = 'dropdown' AND @keyId IS NOT NULL)
			BEGIN
				SET @keys = (SELECT VALUE FROM tblFeatureSet WHERE ID = @keyId)
				SET @values = @value

				INSERT INTO #keyList SELECT * FROM STRING_SPLIT(@keys, ',')
				INSERT INTO #valueList SELECT * FROM STRING_SPLIT(@values, ',')

				INSERT INTO @finalList 
				SELECT LTRIM(RTRIM(xml.val)) + '|' + LTRIM(RTRIM(display.val)) AS keyValue FROM #keyList xml INNER JOIN #valueList display ON xml.ID = display.ID
				SET @CommaSeparatedString = NULL
				SELECT @CommaSeparatedString = COALESCE(@CommaSeparatedString + ',', '') + (LTRIM(RTRIM(Name))) FROM @finalList
				
				INSERT INTO @distinctFeaturesetValue (distinctFeatureSetName, value, selectedValue, featureSetId, inputtype) VALUES (@name, @CommaSeparatedString, 0, 1, @inputtype)

				TRUNCATE TABLE #keyList
				TRUNCATE TABLE #valueList
				DELETE FROM @finalList
			END
			--Other InputTypes
			ELSE
			BEGIN
				INSERT INTO @distinctFeaturesetValue (distinctFeatureSetName, value, selectedValue, featureSetId, inputtype) VALUES (@name, @value, 0, 1, @inputtype)
			END

			DELETE FROM @temptable WHERE id = @id
		END
		
		DROP TABLE IF EXISTS #selectedKeyList
		DROP TABLE IF EXISTS #uniqueKeyList
		DROP TABLE IF EXISTS #selectedValueList
		DROP TABLE IF EXISTS #uniqueValueList
		DROP TABLE IF EXISTS #keyList
		DROP TABLE IF EXISTS #valueList
		SELECT * FROM @distinctFeaturesetValue ORDER BY distinctFeatureSetName ASC
		SELECT * FROM @featuresetValue ORDER BY featureSetName ASC
		
	END
END
GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetAS4000CountrySpellings]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetAS4000CountrySpellings]
END
GO
CREATE PROC sp_GetAS4000CountrySpellings
@configurationId INT
AS
BEGIN

select 
	tblCountry.CountryID, 
	CountryCode,
    CountryName, 
	LanguageId
from dbo.tblCountrySpelling 
	inner join tblcountryspellingmap on tblcountryspellingmap.CountrySpellingID = dbo.tblCountrySpelling.CountrySpellingID
	RIGHT JOIN dbo.tblCountry ON dbo.tblCountrySpelling.CountryId = dbo.tblCountry.CountryId
	inner join dbo.tblCountryMap on dbo.tblCountryMap.CountryID = dbo.tblCountry.CountryID
where
	tblCountrySpellingMap.ConfigurationID = @configurationId and tblCountrySpellingMap.IsDeleted=0
	and tblCountryMap.ConfigurationID = @configurationId and tblCountryMap.IsDeleted=0

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetAS4000CoverageSegments]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetAS4000CoverageSegments]
END
GO
CREATE PROC sp_GetAS4000CoverageSegments
@configurationId INT
AS
BEGIN

SELECT 
	tblCoverageSegment.GeoRefId,
	tblCoverageSegment.SegmentID,
	Lat1,
	Lon1,
	Lat2,
	Lon2
from dbo.tblCoverageSegment 
	inner join tblCoverageSegmentMap csmap on csmap.CoverageSegmentID = tblCoverageSegment.ID
	inner join tblgeoRef on tblGeoRef.GeoRefId = tblCoverageSegment.GeoRefID
	inner join tblGeoRefMap as grmap on grmap.GeoRefID = tblgeoref.id
WHERE 
	tblCoverageSegment.georefid < 510000 
	and tblCoverageSegment.georefid NOT BETWEEN 20000 AND 20162 
	and tblCoverageSegment.georefid NOT BETWEEN 20200 AND 25189 
	and tblCoverageSegment.georefid NOT BETWEEN 200172 AND 200239 
	AND tblCoverageSegment.georefid NOT BETWEEN 250001 AND 250017 
	AND tblCoverageSegment.georefid NOT BETWEEN 300000 AND 307840
	and csmap.configurationId = @configurationId and csmap.IsDeleted=0
	and grmap.ConfigurationID = @configurationId and grmap.IsDeleted=0
order by tblCoverageSegment.GeoRefID

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetASXI3dCountryData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetASXI3dCountryData]
END
GO
CREATE PROC sp_GetASXI3dCountryData
@configurationId INT,
@languages VARCHAR(MAX)
AS
BEGIN
DECLARE @sql NVARCHAR(MAX)
SET @sql='select 
	*
from (
    select 
		tblcountry.CountryID,
		tblcountry.CustomChangeBitMask as CustomChangeBit,
		tblCountrySpelling.CountryName,
		tblLanguages.[2LetterID_ASXi] as code
    from tblcountry
		inner join tblCountrySpelling on tblcountry.CountryID = tblcountryspelling.CountryID
		inner join tblLanguages on tblLanguages.LanguageID = tblCountrySpelling.LanguageID
		inner join tblcountrymap as cmap on cmap.CountryID = tblcountry.CountryID
		inner join tblCountrySpellingMap as csmap on csmap.CountrySpellingID = tblCountrySpelling.CountrySpellingID
		inner join tbllanguagesmap as lmap on lmap.languageid = tbllanguages.id
    where
		cmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and cmap.IsDeleted=0 and
		csmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and csmap.IsDeleted=0 and
		lmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and lmap.IsDeleted=0
) as sourcetable
pivot(
    max(CountryName)
    for code in ('+@languages+')
) as pivottable
order by CountryID'

EXECUTE sp_executesql @sql;

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetASXI3dCoverageSegments]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetASXI3dCoverageSegments]
END
GO
CREATE PROC sp_GetASXI3dCoverageSegments
@configurationId INT
AS
BEGIN

select 
	tblCoverageSegment.GeoRefID,
	SegmentID,
	Lat1,
	Lon1,
	Lat2,
	Lon2,
	tblCoverageSegment.CustomChangeBitMask as CustomChangeBit
from tblCoverageSegment
    inner join tblgeoref on tblgeoref.GeoRefId = tblCoverageSegment.GeoRefID
	inner join tblCoverageSegmentMap as csmap on csmap.CoverageSegmentID = tblCoverageSegment.ID
	inner join tblgeorefmap as grmap on grmap.GeoRefID = tblgeoref.id
where
	tblgeoref.georefid not between 200172 and 200239 and
	tblgeoref.georefid not between 300000 and 307840 and
	csmap.ConfigurationID = @configurationId and csmap.IsDeleted=0 and
	grmap.ConfigurationID = @configurationId and grmap.IsDeleted=0 and
	tblCoverageSegment.GeoRefID in (
	  select georefid
	  from tblcoveragesegment
		inner join tblcoveragesegmentmap as cvgmap on cvgmap.CoverageSegmentID = tblcoveragesegment.ID
	  where 
		cvgmap.ConfigurationID = @configurationId and cvgmap.IsDeleted=0 
		and tblcoveragesegment.segmentid = 1
	)
order by georefid

END

GO
GO

/****** Object:  StoredProcedure [dbo].[SP_GetASXiInsets]    Script Date: 9/19/2022 6:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_GetASXiInsets]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_GetASXiInsets]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetASXiInsets]    Script Date: 9/19/2022 6:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================  
-- Author:      Logeshwaran Sivaraj  
-- Create date: 9/19/2022  
-- Description: Retrieves all the Insets data 
--				based on the ConfigurationId  
-- Sample EXEC [dbo].[SP_GetASXiInsets] 12
-- =============================================  

CREATE PROCEDURE [dbo].[SP_GetASXiInsets]
    @ConfigurationId int 
	   
AS
BEGIN
    SELECT DISTINCT
    asxiInfo.*
    FROM dbo.config_tblASXiInset(@configurationId) AS asxiInfo
	ORDER BY asxiInfo.Zoom DESC
END
GO



GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan Abhishek Padinarapurayil
-- Create date: 5/26/2022
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetBuildTasks]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetBuildTasks]
END
GO
CREATE PROCEDURE [dbo].[SP_GetBuildTasks]
			@userId  uniqueidentifier	
AS
BEGIN
		SELECT dbo.tblTasks.ID ,
        dbo.tblTaskStatus.Name as BuildStatus, 
        dbo.tblTasks.PercentageComplete ,
        case when  tblProducts.Name is not null then tblProducts.Name    
        when tblPlatforms.Name is not null then tblPlatforms.Name    
        when tblGlobals.Name is not null then tblGlobals.Name    
        end as DefiniationName,
        dbo.tblConfigurations.Version as ConfigurationVersion,
        dbo.tblConfigurations.ConfigurationID 
		FROM ((((((((dbo.tblTasks
        INNER JOIN dbo.tblTaskStatus ON dbo.tblTaskStatus.ID = dbo.tblTasks.TaskStatusID)
        INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationID =  dbo.tblTasks.ConfigurationID)
        LEFT OUTER JOIN tblProductConfigurationMapping ON tblProductConfigurationMapping.ConfigurationDefinitionID =  dbo.tblTasks.ConfigurationDefinitionID )
        LEFT OUTER JOIN dbo.tblProducts ON tblProducts.ProductID = tblProductConfigurationMapping.ProductID)   
        LEFT OUTER JOIN tblPlatformConfigurationMapping ON tblPlatformConfigurationMapping.ConfigurationDefinitionID =  dbo.tblTasks.ConfigurationDefinitionID)
        LEFT OUTER JOIN dbo.tblPlatforms ON tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID)   
        LEFT OUTER JOIN tblGlobalConfigurationMapping ON tblGlobalConfigurationMapping.ConfigurationDefinitionID = dbo.tblTasks.ConfigurationDefinitionID)
        LEFT OUTER JOIN dbo.tblGlobals ON tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID)   
        WHERE dbo.tblTasks.StartedByUserID = @userId OR (dbo.tblTasks.ConfigurationID IN ( 
        select distinct tblConfigurations.ConfigurationID 
           from(aspnetusers 
           INNER JOIN UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id 
           INNER JOIN UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid 
           INNER JOIN UserClaims on UserClaims.id = UserRoleClaims.claimid 
           INNER JOIN tblconfigurationdefinitions on tblconfigurationdefinitions.ConfigurationDefinitionID = UserRoleClaims.ConfigurationDefinitionID or UserRoleClaims.ConfigurationDefinitionID is null and tblconfigurationdefinitions.active = 1 
           INNER JOIN tblConfigurations on tblconfigurationdefinitions.ConfigurationDefinitionID = tblConfigurations.ConfigurationDefinitionID ) 
           LEFT OUTER JOIN tblProductConfigurationMapping on tblProductConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManageProductConfiguration' 
           LEFT OUTER JOIN dbo.tblProducts on tblProducts.ProductID = tblProductConfigurationMapping.ProductID 
           LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManagePlatformConfiguration' 
           LEFT OUTER JOIN dbo.tblPlatforms on tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID 
           LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'Manage Global Configuration' 
           LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID 
           where 
           UserClaims.name in ('ManagePlatformConfiguration', 'ManageProductConfiguration', 'Manage Global Configuration') 
           and aspnetusers.Id = @userId) )
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date: 5/24/2022
-- Description:	This SP will return id,AssetType,Title based on given name
-- Sample: EXEC [dbo].[SP_GetByNameForDownloadPreference] 'Episode'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetByNameForDownloadPreference]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetByNameForDownloadPreference]
END
GO

CREATE PROCEDURE [dbo].[SP_GetByNameForDownloadPreference]
        @name NVARCHAR(100)
       
AS

BEGIN

      SELECT * FROM dbo.DownloadPreference WHERE dbo.DownloadPreference.Name = @name
END
GO


GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetCESHTSECoverageSegments]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetCESHTSECoverageSegments]
END
GO
CREATE PROC sp_GetCESHTSECoverageSegments
@configurationId INT
AS
BEGIN

select
	tblCoverageSegment.GeoRefId,
	SegmentId,
	Lat1,
	Lon1,
	Lat2,
	Lon2
from tblCoverageSegment
	inner join tblCoverageSegmentMap as csmap on csmap.CoverageSegmentID = tblCoverageSegment.ID
	inner join tblgeoref on tblgeoref.GeoRefId = tblCoverageSegment.GeoRefID
	inner join tblgeorefmap as grmap on grmap.GeoRefId = tblgeoref.id
where
	tblgeoref.georefid NOT BETWEEN 20200 AND 25189 and 
	tblgeoref.georefid NOT BETWEEN 200172 AND 200239 and
	tblgeoref.georefid NOT BETWEEN 300000 AND 307840 and
	tblgeoref.georefid NOT BETWEEN 310000 AND 414100 and
	csmap.ConfigurationID = @configurationId and csmap.IsDeleted=0 and
	grmap.ConfigurationID = @configurationId and grmap.IsDeleted=0
order by tblCoverageSegment.georefid, segmentid

END

GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Mohan Abhishek Padinarapurayil		
-- Create date: 5/24/2022
-- Description:	This query returns the number of count from UserRoleClaims table based on the claimID and roleID
--Sample EXEC :SP_GetClaimsCountByRoleId 'D3CC19CD-F347-4FAE-A03C-31EA39478282','C9F1DD7A-C408-47F3-9DF1-4395B4C903B6'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetClaimsCountByRoleId]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetClaimsCountByRoleId]
END
GO
CREATE PROCEDURE [dbo].[SP_GetClaimsCountByRoleId]
			@roleId uniqueidentifier,
			@claimId uniqueidentifier
			
AS
BEGIN
		
		SELECT count(*) FROM dbo.UserRoleClaims WHERE RoleID = @roleId AND ClaimID = @claimId
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan Abhishek Padniarapurayil
-- Create date: 28/5/2022
-- Description:	this will select the userRoleClaims from UserRoleclaims table based on the userID that is passed
--Sample EXEC:[dbo].[SP_GetClaimsforuser_Aircraftconfig] '4DBED025-B15F-4760-B925-34076D13A10A'

-- =============================================
IF OBJECT_ID('[dbo].[SP_GetClaimsforuser_Aircraftconfig]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetClaimsforuser_Aircraftconfig]
END
GO
CREATE PROCEDURE [dbo].[SP_GetClaimsforuser_Aircraftconfig]
			@userId  uniqueidentifier	
AS
BEGIN

		SELECT dbo.UserRoleClaims.* FROM dbo.UserRoleClaims
        INNER JOIN dbo.UserRoleAssignments on UserRoleClaims.RoleID = dbo.UserRoleAssignments.RoleID
        inner join tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.aircraftid = dbo.UserRoleClaims.AircraftID
        inner join tblconfigurationdefinitions on tblConfigurationDefinitions.ConfigurationDefinitionID = tblAircraftConfigurationMapping.ConfigurationDefinitionID 
        and tblconfigurationdefinitions.active = 1 AND dbo.UserRoleAssignments.UserID = @userId
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan,Abhishek Padniarapurayil
-- Create date: 5/24/2022
--Description :this query returns multiple colums from dbo.UserRoles based on RoleID given
--Sample EXEC: exec [dbo].[SP_GetClaims_RoleId] '383D4F04-8F3A-408B-BF52-05EFF3674BDB'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetClaims_RoleId]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetClaims_RoleId]
END
GO
CREATE PROCEDURE [dbo].[SP_GetClaims_RoleId]
			@roleId  uniqueidentifier
			
AS
BEGIN
		
		SELECT dbo.UserClaims.ID, dbo.UserClaims.Name, dbo.UserClaims.Description, dbo.UserClaims.ScopeType FROM dbo.UserRoles INNER JOIN dbo.UserRoleClaims ON dbo.UserRoles.ID = dbo.UserRoleClaims.RoleID INNER JOIN dbo.UserClaims ON dbo.UserRoleClaims.ClaimID = dbo.UserClaims.ID WHERE dbo.UserRoles.ID = @roleId
		
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Mohan Abhishek Padinarapuaryil
-- Create date: <29/5/2022>
-- Description:	this query returns only the distinct value based on userId
--Sample EXEC:exec [dbo].[SP_GetClaims_UserId] 'EE35E2A0-0ED7-4575-AA95-12B0000E7AC5'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetClaims_UserId]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetClaims_UserId]
END
GO
CREATE PROCEDURE [dbo].[SP_GetClaims_UserId]
			@userId  uniqueidentifier
			
AS
BEGIN
		
		SELECT DISTINCT dbo.UserClaims.ID, dbo.UserClaims.Name, dbo.UserClaims.Description, dbo.UserClaims.ScopeType FROM (dbo.UserRoleAssignments INNER JOIN dbo.UserRoleClaims ON dbo.UserRoleAssignments.RoleID = dbo.UserRoleClaims.RoleID) INNER JOIN dbo.UserClaims ON dbo.UserRoleClaims.ClaimID = dbo.UserClaims.ID WHERE dbo.UserRoleAssignments.UserID = @userId
END
GO
GO


-- =============================================
-- Author:		Sathya
-- Create date: 7/27/2022
-- Description:	Returns all componenent types and its config path for a given config id
-- =============================================
GO
IF OBJECT_ID('[dbo].[SP_getConfigComponentsArtifacts]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_getConfigComponentsArtifacts]
END
GO

CREATE PROC [dbo].[SP_getConfigComponentsArtifacts]  
@configurationId INT  
AS  
BEGIN  
SELECT ConfigurationComponentID,Path,ConfigurationComponentTypeID,Name FROM [dbo].[config_tblConfigurationComponents](@configurationId)  
END
GO
GO

-- =============================================
-- Author:		Sathya
-- Create date: 06/24/2022
-- Description:	Returns list of child config for given config id if queued for locking and its not modified since last x hrs and not cancelled.
-- =============================================
GO
IF OBJECT_ID('[dbo].[SP_getConfigIdsToBeLocked]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_getConfigIdsToBeLocked]
END
GO
CREATE PROC SP_getConfigIdsToBeLocked  
@timeInterval INT,  
@taskTypeId UNIQUEIDENTIFIER  
AS  
BEGIN  
  SET @timeInterval=@timeInterval*-1  
  
  SELECT ID,TaskDataJSON,task.ConfigurationID,task.ConfigurationDefinitionID,StartedByUserID FROM tblTasks(nolock) task INNER JOIN tblConfigurations(nolock) config ON  
  config.ConfigurationID= task.ConfigurationID WHERE TaskTypeID=@taskTypeId AND TaskStatusID     
  IN(SELECT id  FROM tblTaskStatus WHERE name='Not Started') AND  (config.LastUpdateDateTime IS NULL OR config.LastUpdateDateTime<DATEADD(MINUTE, @timeInterval, GETDATE()))
  AND task.Cancelled=0
  
END  

GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/24/2022
-- Description:	This SP will return ConnectivityTypes from InstallationTypes table based on given condition and installationTypeID 
-- Sample:  EXEC [dbo].[SP_GetConnectivityTypes] '23825E21-652E-482E-8AB0-870FD67BA94B'
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetConnectivityTypes]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetConnectivityTypes]
END
GO

CREATE PROCEDURE [dbo].[SP_GetConnectivityTypes]
        @installationtypeID uniqueidentifier
       
AS

BEGIN

              Select Aircraft.ConnectivityTypes from  dbo.InstallationTypes InstallType 
              INNER JOIN dbo.tblPlatforms on  dbo.tblPlatforms.InstallationTypeID = InstallType.ID 
               INNER JOIN dbo.tblPlatformConfigurationMapping on dbo.tblPlatformConfigurationMapping.PlatformID = tblPlatforms.PlatformID 
               INNER JOIN dbo.tblConfigurationDefinitions  on tblConfigurationDefinitions.ConfigurationDefinitionID = tblPlatformConfigurationMapping.ConfigurationDefinitionID 
               INNER JOIN dbo.tblAircraftConfigurationMapping on dbo.tblAircraftConfigurationMapping.ConfigurationDefinitionID = tblConfigurationDefinitions.ConfigurationDefinitionID 
               INNER JOIN dbo.Aircraft on dbo.Aircraft.Id = tblAircraftConfigurationMapping.AircraftID INNER JOIN dbo.DownloadPreferenceAssignment 
               ON dbo.DownloadPreferenceAssignment.AircraftId = dbo.Aircraft.Id 
               INNER JOIN dbo.DownloadPreference on dbo.DownloadPreference.Id = dbo.DownloadPreferenceAssignment.DownloadPreferenceID 
               where InstallType.ID =  @installationtypeID
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		< Mohan ,Abhishek Padinarapurayil>
-- Create date: 28/6/2022
-- Description: this query count the number of records from UserRoleAssignments based on the userID and RoleID given
--Sample EXEC: SP_GetCountbyuser_RoleId '3CD9AEB9-564F-41A4-AC03-00EF897F29F7','3A638B85-7F31-4E6A-BFA1-40C6003AC404'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetCountbyuser_RoleId]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetCountbyuser_RoleId]
END
GO
CREATE PROCEDURE [dbo].[SP_GetCountbyuser_RoleId]
			@userId  uniqueidentifier,
			@roleId  uniqueidentifier
			
AS
BEGIN
		
		 SELECT COUNT(*) FROM dbo.UserRoleAssignments WHERE dbo.UserRoleAssignments.UserID = @userId AND dbo.UserRoleAssignments.RoleID = @roleId
		
END
GO
GO

/****** Object:  StoredProcedure [dbo].[SP_getCountryConflicts]    Script Date: 9/29/2022 6:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_getCountryConflicts]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_getCountryConflicts]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_getCountryConflicts]    Script Date: 9/29/2022 6:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_getCountryConflicts]
@taskId UNIQUEIDENTIFIER
AS
BEGIN

 DROP TABLE IF EXISTS #TEMP_COUNTRY_PARENT
  DROP TABLE IF EXISTS #TEMP_COUNTRY_CHILD
    DROP TABLE IF EXISTS #TEMP

CREATE TABLE #TEMP_COUNTRY_PARENT(ID INT,MergeChoice INT, SelectedKey INT,CountryId INT,CountrySpellingId INT,Translation NVARCHAR(MAX),Description NVARCHAR(MAX),regionId int,Region nvarchar(max),LanguageId int,LanguageName varchar(100));
CREATE TABLE #TEMP_COUNTRY_CHILD(ID INT,MergeChoice INT, SelectedKey INT,CountryId INT,CountrySpellingId INT,Translation NVARCHAR(MAX),Description NVARCHAR(MAX),regionId int,Region nvarchar(max),LanguageId int,LanguageName varchar(100));
 
SELECT ID,ChildKey,ParentKey,TableName,SelectedKey,MergeChoice INTO #TEMP FROM tblMergeDetails where MergeChoice NOT in(3,1) AND TableName IN('tblCountry','tblCountrySpelling') AND TaskId = @taskId;
 
DECLARE @TableName varchar(50),@ParentKey INT,@ChildKey INT,@MergeChoice INT,@SelectedKey INT,@ID INT
 
DECLARE cur_tbl CURSOR 
 FOR
              SELECT ID,ChildKey,ParentKey,TableName,MergeChoice,SelectedKey
              FROM   #TEMP
 
                      OPEN cur_tbl
 
            FETCH next FROM cur_tbl INTO @ID,@ChildKey,@ParentKey,@TableName,@MergeChoice,@SelectedKey
                    --print @config_table
            WHILE @@FETCH_STATUS = 0
              BEGIN
 
                                 IF @TableName='tblCountry'
                                 begin
                                 insert into #TEMP_COUNTRY_PARENT(ID,MergeChoice,SelectedKey,CountryId,Description,Region) 
                                 SELECT @ID,@MergeChoice,@SelectedKey,CountryID,Description,RegionName FROM tblCountry ctry 
                                 INNER JOIN tblRegionSpelling spel on ctry.RegionID=spel.RegionID and spel.LanguageId=1
                                 WHERE ID in(@ParentKey);
 
                                 insert into #TEMP_COUNTRY_CHILD(ID,MergeChoice,SelectedKey,CountryId,Description,Region) 
                                 SELECT @ID,@MergeChoice,@SelectedKey,CountryID,Description,RegionName FROM tblCountry ctry 
                                 INNER JOIN tblRegionSpelling spel on ctry.RegionID=spel.RegionID and spel.LanguageId=1
                                 WHERE ID in(@ChildKey);
 
                                 end
                                 IF @TableName='tblCountrySpelling'
                                 begin
                                 insert into #TEMP_COUNTRY_PARENT(ID,MergeChoice,SelectedKey,CountryId,Description,Translation,LanguageName)
                                 SELECT @ID,@MergeChoice,@SelectedKey,ctry.CountryID,ctry.Description,CountryName, lang.Name FROM tblCountrySpelling spel 
                                 INNER JOIN tblCountry ctry ON ctry.CountryID=spel.CountryID
								 INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID WHERE CountrySpellingID in(@ParentKey);
 
                                 insert into #TEMP_COUNTRY_CHILD(ID,MergeChoice,SelectedKey,CountryId,Description,Translation,LanguageName)
                                 SELECT @ID,@MergeChoice,@SelectedKey,ctry.CountryID,ctry.Description,CountryName, lang.Name FROM tblCountrySpelling spel 
                                 INNER JOIN tblCountry ctry ON ctry.CountryID=spel.CountryID
								 INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID WHERE CountrySpellingID in(@ChildKey);
 
                                 end
                           FETCH next FROM cur_tbl INTO @ID,@ChildKey,@ParentKey,@TableName,@MergeChoice,@SelectedKey
                      END
 
 CLOSE cur_tbl

            DEALLOCATE cur_tbl

--compare 2 tables and display the values
--select * from  #TEMP_COUNTRY_PARENT
--select * from  #TEMP_COUNTRY_CHILD
DECLARE @TEMP_RESULT TABLE(ID INT, CountryID INT, LanguageName NVARCHAR(MAX), [Key] NVARCHAR(MAX), Parent_value NVARCHAR(MAX), Child_value NVARCHAR(MAX))
INSERT INTO @TEMP_RESULT
 Select ID, CountryId,LanguageName, [key], Parent_Value = max( case when Src=1 then Value end), Child_Value = max( case when Src=2 then Value end)
 From ( Select Src=1, ID, CountryId,LanguageName, B.*
         From #TEMP_COUNTRY_PARENT A
         Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
		 B
        Union All
        Select Src=2, ID, CountryId, LanguageName, B.*
         From #TEMP_COUNTRY_CHILD A
         Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
		 B
      ) A
 Group By ID, CountryId,LanguageName, [key]
 Having max(case when Src=1 then Value end) <> max(case when Src=2 then Value end)
 Order By ID, [key]

-- SELECT * FROM #TEMP_RESULT

SELECT t.ID, t.CountryID AS ContentID, 'Country' AS ContentType, c.Description AS Description, 
 CASE WHEN t.[Key] = 'Translation' THEN t.[key] + '(' + t.LanguageName + ')' ELSE t.[key] END AS DisplayName, 
 t.Parent_value AS ParentValue, t.Child_value AS ChildValue, 
 CASE WHEN m.SelectedKey = m.ParentKey THEN t.Parent_value  WHEN m.SelectedKey = m.ChildKey THEN t.Child_Value ELSE NULL END AS SelectedValue 
 FROM @TEMP_RESULT t, tblMergeDetails m, tblCountry c WHERE t.ID = m.ID AND t.CountryID = c.ID

END

GO

/****** Object:  StoredProcedure [dbo].[SP_GetCountryUpdates]    Script Date: 10/31/2022 6:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_GetCountryUpdates]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_GetCountryUpdates]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetCountryUpdates]    Script Date: 10/31/2022 6:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_GetCountryUpdates]
	@tableXml XML
AS
BEGIN

	DROP TABLE IF EXISTS #TEMP_COUNTRY_PARENT
	DROP TABLE IF EXISTS #TEMP_COUNTRY_CHILD
	DROP TABLE IF EXISTS #TEMP

	CREATE TABLE #TEMP_COUNTRY_PARENT(ID INT, CountryId INT,CountrySpellingId INT,Translation NVARCHAR(MAX),Description NVARCHAR(MAX),regionId int,Region nvarchar(max),LanguageId int,LanguageName varchar(100),Action NVARCHAR(10));
	CREATE TABLE #TEMP_COUNTRY_CHILD(ID INT, CountryId INT,CountrySpellingId INT,Translation NVARCHAR(MAX),Description NVARCHAR(MAX),regionId int,Region nvarchar(max),LanguageId int,LanguageName varchar(100),Action NVARCHAR(10));
	
	CREATE TABLE #TEMP (ID INT IDENTITY, TableName NVARCHAR(100), CurrentKey INT, PreviousKey INT, Action NVARCHAR(10))
	INSERT INTO #TEMP 
	SELECT Tbl.Col.value('@TableName', 'NVARCHAR(100)') AS TableName,  Tbl.Col.value('@CurrentKey', 'INT') AS CurrentKey,  
       Tbl.Col.value('@PreviousKey', 'INT') AS PreviousKey, Tbl.Col.value('@Action', 'NVARCHAR(10)') AS Action 
	FROM   @tableXml.nodes('//row') Tbl(Col) WHERE Tbl.Col.value('@TableName', 'NVARCHAR(100)') IN ('tblCountry','tblCountrySpelling')
	
	DECLARE @ID INT, @TableName VARCHAR(50),@ParentKey INT,@ChildKey INT, @Action NVARCHAR(10)
 
	DECLARE cur_tbl CURSOR 
	FOR
	SELECT ID,TableName,PreviousKey,CurrentKey,Action
	FROM   #TEMP WHERE Action = 'Update'
 
	OPEN cur_tbl 
	FETCH next FROM cur_tbl INTO @ID, @TableName ,@ParentKey ,@ChildKey, @Action 
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		IF @TableName='tblCountry'
		BEGIN
			INSERT INTO #TEMP_COUNTRY_PARENT(ID,CountryId,Description,Region,Action) 
			SELECT @ID,CountryID,Description,RegionName,@Action FROM tblCountry ctry 
			INNER JOIN tblRegionSpelling spel on ctry.RegionID=spel.RegionID and spel.LanguageId=1
			WHERE ID in(@ParentKey);
 
			INSERT INTO #TEMP_COUNTRY_CHILD(ID,CountryId,Description,Region,Action) 
			SELECT @ID,CountryID,Description,RegionName, @Action FROM tblCountry ctry 
			INNER JOIN tblRegionSpelling spel on ctry.RegionID=spel.RegionID and spel.LanguageId=1
			WHERE ID in(@ChildKey);
		END
		IF @TableName='tblCountrySpelling'
		BEGIN
			INSERT INTO #TEMP_COUNTRY_PARENT(ID,CountryId,Description,Translation,LanguageName,Action)
			SELECT @ID,ctry.CountryID,ctry.Description,CountryName, lang.Name, @Action FROM tblCountrySpelling spel 
			INNER JOIN tblCountry ctry ON ctry.CountryID=spel.CountryID
			INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID WHERE CountrySpellingID in(@ParentKey);
 
			INSERT INTO #TEMP_COUNTRY_CHILD(ID,CountryId,Description,Translation,LanguageName,Action)
			SELECT @ID,ctry.CountryID,ctry.Description,CountryName, lang.Name, @Action FROM tblCountrySpelling spel 
			INNER JOIN tblCountry ctry ON ctry.CountryID=spel.CountryID
			INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID WHERE CountrySpellingID in(@ChildKey);
		END
		FETCH NEXT FROM cur_tbl INTO @ID,@TableName, @ParentKey, @ChildKey, @Action
	END 
	CLOSE cur_tbl
	DEALLOCATE cur_tbl

	--compare 2 tables and display the values
	--select * from  #TEMP_COUNTRY_PARENT
	--select * from  #TEMP_COUNTRY_CHILD
	DECLARE @TEMP_RESULT TABLE(ID INT, CountryID INT, LanguageName NVARCHAR(MAX), [Key] NVARCHAR(MAX) NULL, Parent_value NVARCHAR(MAX) NULL, Child_value NVARCHAR(MAX) NULL, Action NVARCHAR(10))
	INSERT INTO @TEMP_RESULT
	 Select ID, CountryId, LanguageName, [key], Parent_Value = max( case when Src=1 then Value end), Child_Value = max( case when Src=2 then Value end), Action
	 From ( Select Src=1, ID, CountryId, LanguageName, Action, B.*
			 From #TEMP_COUNTRY_PARENT A
			 Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
			 B
			Union All
			Select Src=2, ID, CountryId, LanguageName, Action, B.*
			 From #TEMP_COUNTRY_CHILD A
			 Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
			 B
		  ) A
	 Group By ID, CountryId, LanguageName, [key], Action
	 Having max(case when Src=1 then Value end) <> max(case when Src=2 then Value end)
	 Order By ID, [key]

	-- SELECT * FROM #TEMP_RESULT

	SELECT t.CountryID AS ContentID, 'Country' AS ContentType, c.Description AS Name, 
	CASE WHEN t.[Key] = 'Translation' THEN t.[key] + '(' + t.LanguageName + ')' ELSE t.[key] END AS Field, 
	t.Parent_value AS PreviousValue, t.Child_value AS CurrentValue, Action 
	FROM @TEMP_RESULT t, tblCountry c WHERE t.CountryID = c.ID
	UNION
	SELECT t.CurrentKey AS ContentID, 'Country' AS ContentType, c.Description AS Name, NULL, NULL, NULL, t.Action
	FROM #TEMP t, tblCountry c WHERE t.CurrentKey = c.ID AND t.Action IN ('Insert', 'Delete') 
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 09/14/2022
-- Description:	Get data to build modlist JSON file
-- Sample EXEC [dbo].[SP_GetDataForModListJson] '1499,2956,1496,2953', 67, 'all'
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetDataForModListJson]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetDataForModListJson]
END
GO

CREATE PROCEDURE [dbo].[SP_GetDataForModListJson]
	@geoRefId NVARCHAR(MAX),
	@configurationId INT,
	@type NVARCHAR(50)
AS
BEGIN
	IF (@type = 'all')
	BEGIN
		SELECT GeoRef.GeoRefId, CoverageSegment.Lat1, CoverageSegment.Lon1, GeoRef.isInteractivePoi, GeoRef.AsxiCatTypeId, GeoRef.Description 
		FROM dbo.config_tblGeoRef(@configurationId) AS GeoRef
		OUTER APPLY dbo.config_tblCoverageSegment(@configurationId) AS CoverageSegment
		WHERE GeoRef.CustomChangeBitMask = 1 AND GeoRef.GeoRefId = CoverageSegment.GeoRefID

	END
	ELSE
	BEGIN
		SELECT GeoRef.GeoRefId, CoverageSegment.Lat1, CoverageSegment.Lon1, GeoRef.isInteractivePoi, GeoRef.AsxiCatTypeId, GeoRef.Description 
		FROM dbo.config_tblGeoRef(@configurationId) AS GeoRef
		OUTER APPLY dbo.config_tblCoverageSegment(@configurationId) AS CoverageSegment
		WHERE GeoRef.GeoRefId IN (SELECT * FROM STRING_SPLIT(@geoRefId, ',')) AND GeoRef.GeoRefId = CoverageSegment.GeoRefID
	END
END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date: 5/24/2022
-- Description:	This query returns DownloadPreference from InstallationTypes table based on given condition and installationtypeID
-- Sample: EXEC [dbo].[SP_GetDownloadPreferencesOfType] '23825E21-652E-482E-8AB0-870FD67BA94B'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetDownloadPreferencesOfType]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetDownloadPreferencesOfType]
END
GO

CREATE PROCEDURE [dbo].[SP_GetDownloadPreferencesOfType]
        @installationtypeID uniqueidentifier
       
AS

BEGIN

               Select DownloadPreference.* from  dbo.InstallationTypes InstallType 
               INNER JOIN dbo.tblPlatforms on  dbo.tblPlatforms.InstallationTypeID = InstallType.ID 
               INNER JOIN dbo.tblPlatformConfigurationMapping on dbo.tblPlatformConfigurationMapping.PlatformID = tblPlatforms.PlatformID 
               INNER JOIN dbo.tblConfigurationDefinitions  on tblConfigurationDefinitions.ConfigurationDefinitionID = tblPlatformConfigurationMapping.ConfigurationDefinitionID 
               INNER JOIN dbo.tblAircraftConfigurationMapping on dbo.tblAircraftConfigurationMapping.ConfigurationDefinitionID = tblConfigurationDefinitions.ConfigurationDefinitionID 
               INNER JOIN dbo.Aircraft on dbo.Aircraft.Id = tblAircraftConfigurationMapping.AircraftID INNER JOIN dbo.DownloadPreferenceAssignment 
               ON dbo.DownloadPreferenceAssignment.AircraftId = dbo.Aircraft.Id 
                INNER JOIN dbo.DownloadPreference on dbo.DownloadPreference.Id = dbo.DownloadPreferenceAssignment.DownloadPreferenceID 
                where InstallType.ID =  @installationtypeID
END
GO



GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 5/24/2022
-- Description:	Procedure to retrieve the download URL
-- Sample EXEC [dbo].[SP_GetDownloadURL] 18, 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetDownloadURL]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetDownloadURL]
END
GO

CREATE PROCEDURE [dbo].[SP_GetDownloadURL]
	@configurationId INT,
	@taskId NVARCHAR(500)
AS
BEGIN
	SELECT Path AS downloadURL FROM tblConfigurationComponents CC
	INNER JOIN tblConfigurationComponentsMap CCM
	ON CC.[ConfigurationComponentID ] = CCM.ConfigurationComponentID AND CCM.ConfigurationID = @configurationId AND CC.[ConfigurationComponentID ] = @taskId
END
GO
GO

GO
-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000AirportInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000AirportInfo]
END
GO
CREATE PROC sp_GetExportAS4000AirportInfo
@configurationId INT
AS
BEGIN

select
	FourLetId,
	ThreeLetId,
	Lat,
	Lon,
	GeoRefId as PointGeoRefId,
	null as Include,
	null as ACARS,
	null as DispDest
from tblAirportInfo
	inner join tblAirportInfoMap on tblAirportInfoMap.AirportInfoID = tblAirportInfo.AirportInfoID
where
	tblAirportInfoMap.ConfigurationID = @configurationId and tblAirportInfoMap.isDeleted=0

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000Appearance]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000Appearance]
END
GO
CREATE PROC sp_GetExportAS4000Appearance
@configurationId INT
AS 
BEGIN

select
	tblAppearance.GeoRefId,
	Resolution,
	tblGeoRef.Priority as Priority,
	tblGeoRef.MarkerId as MarkerId,
	Exclude,
	tblGeoRef.isInteractivePoi as POI,
	tblGeoRef.AtlasMarkerId as AtlasMarkerId,
	SphereMapExclude,
	null as SphereMapPNMeshId
from tblAppearance
	inner join tblgeoref on tblgeoref.GeoRefId = tblAppearance.GeoRefID
	inner join tblAppearanceMap as apmap on apmap.AppearanceID = tblAppearance.AppearanceID
	inner join tblgeorefmap as grmap on grmap.GeoRefID = tblgeoref.ID
where
	tblAppearance.georefid NOT BETWEEN 20000 AND 20162
	AND tblAppearance.georefid NOT BETWEEN 20200 AND 25189
	AND tblAppearance.georefid NOT BETWEEN 200172 AND 200239
	AND tblAppearance.georefid NOT BETWEEN 250001 AND 250017
	and tblAppearance.georefid < 510000
	and resolution not in (0, 3,6, 60, 1620)
	and apmap.ConfigurationID = @configurationId and apmap.isDeleted=0
	and grmap.ConfigurationID = @configurationId and grmap.isDeleted=0
order by georefid, resolution

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000AppearanceResolution6]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000AppearanceResolution6]
END
GO
CREATE PROC sp_GetExportAS4000AppearanceResolution6
@configurationId INT
AS 
BEGIN
select
	tblAppearance.GeoRefId,
	Resolution,
	tblGeoRef.Priority as Priority,
	tblGeoRef.MarkerId as MarkerId,
	Exclude,
	tblGeoRef.isInteractivePoi as POI,
	tblGeoRef.AtlasMarkerId as AtlasMarkerId,
	SphereMapExclude,
	null as SphereMapPNMeshId
from tblAppearance
	inner join tblgeoref on tblgeoref.GeoRefId = tblAppearance.GeoRefID
	inner join tblAppearanceMap as apmap on apmap.AppearanceID = tblAppearance.AppearanceID
	inner join tblgeorefmap as grmap on grmap.GeoRefID = tblgeoref.ID
where
	tblAppearance.georefid between 300000 and 307840
	and tblAppearance.resolution = 6
	and apmap.ConfigurationID = @configurationId and apmap.isDeleted=0
	and grmap.ConfigurationID = @configurationId and grmap.isDeleted=0
order by georefid, resolution
END

GO
GO

GO

-- =============================================
-- Author:		Lakshmikanth
-- Create date: 18-Jul-2022
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetExportAS4000FourLetter]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetExportAS4000FourLetter]
END
GO
CREATE PROC SP_GetExportAS4000FourLetter
@configurationId INT
AS
BEGIN

select distinct
    airportinfo.*,
    '' as Country
    from tblairportinfo as airportinfo
    inner join tblairportinfomap map on map.airportinfoid = airportinfo.airportinfoid and map.configurationid = @configurationId
    ORDER BY airportinfo.FourLetId ASC
END

GO
GO

GO
-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000GeoRefIds]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000GeoRefIds]
END
GO
CREATE PROC sp_GetExportAS4000GeoRefIds
@configurationId INT
AS
BEGIN
select 
	null as '4xx POI',
	tblGeoRef.GeoRefId,
	Description as Name,
	isCapitalCountry as 'country capital',
	isTerrainOcean as 'Ocean Floor',
	PnType,
	isCapitalState as 'State Capitals',
	case
		when CatTypeId is null then 1
		else CatTypeId
	end as GeoRefIdCatTypeId,
	Display,
	KeepNew
from tblgeoref
	inner join tblgeorefmap as grmap on grmap.GeoRefID = tblGeoRef.ID
where
	tblgeoref.georefid NOT BETWEEN 20000 AND 20162
	AND tblgeoref.georefid NOT BETWEEN 20200 AND 25189
	AND tblgeoref.georefid NOT BETWEEN 200172 AND 200239
	AND tblgeoref.georefid NOT BETWEEN 250001 AND 250017
	and grmap.ConfigurationID = @configurationId and grmap.isDeleted=0
END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000GeoRefIdsArea]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000GeoRefIdsArea]
END
GO
CREATE PROC sp_GetExportAS4000GeoRefIdsArea
@configurationId INT
AS
BEGIN

SELECT 
	georefid,
	Area
from tblArea
	inner join tblAreaMap as amap on amap.AreaID = tblArea.AreaID
where
	amap.ConfigurationID = @configurationId and amap.IsDeleted=0

END

GO
GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000GeoRefIdsElevation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000GeoRefIdsElevation]
END
GO
CREATE PROC sp_GetExportAS4000GeoRefIdsElevation
@configurationId INT
AS
BEGIN

SELECT
	georefid,
	Elevation 
from tblElevation
	inner join tblElevationMap as emap on emap.ElevationID = tblElevation.ID
where
	emap.ConfigurationID = @configurationId and emap.IsDeleted=0

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- Description:	Returns geo ref id for not us
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000GeoRefIdsPnameTriviaNonUS]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000GeoRefIdsPnameTriviaNonUS]
END
GO
CREATE PROC sp_GetExportAS4000GeoRefIdsPnameTriviaNonUS
@configurationId INT
AS
BEGIN

SELECT DISTINCT
  Gr.GeoRefId, 
  (Sp.UnicodeStr + ', ' + tblcountryspelling.CountryName) as Name, 
  Gr.CountryId, 
  null as StateCode, 
  Area, 
  Elevation, 
  Population
FROM tblGeoRef AS Gr
  inner join tblgeorefmap on tblgeorefmap.georefid = gr.id
  inner join tblspelling as sp on sp.georefid = gr.georefid
  inner join tblspellingmap on tblspellingmap.spellingid = sp.spellingid
  inner join tblcountryspelling on tblcountryspelling.CountryID = gr.countryid
  inner join tblcountryspellingmap as csmap on csmap.CountrySpellingID = tblCountrySpelling.CountrySpellingID
  left join tblArea on tblArea.GeoRefID = Gr.GeoRefID
  left join tblAreaMap as amap on amap.AreaID = tblArea.AreaID
  left join tblElevation on tblElevation.GeoRefID = Gr.GeoRefId
  left join tblElevationMap as emap on emap.ElevationID = tblElevation.ID
  left join tblCityPopulation on tblCityPopulation.GeoRefID = gr.GeoRefId
  left join tblCityPopulationMap as cmap on cmap.CityPopulationID = tblCityPopulation.CityPopulationID
WHERE 
  tblgeorefmap.configurationid = @configurationId   and tblgeorefmap.isDeleted=0
  and tblspellingmap.configurationid = @configurationId and tblspellingmap.IsDeleted=0
  and csmap.configurationid = @configurationId and csmap.IsDeleted=0
  and Gr.GeoRefId IN (SELECT GeoRefId FROM tblGeoRef WHERE GeoRefId < 100000) 
  AND Sp.LanguageId = 1 
  AND Gr.CountryId != 251 
  AND Gr.PnType = 1
  and tblcountryspelling.LanguageID = 1
  and ((amap.ConfigurationID = @configurationId and amap.IsDeleted=0) or amap.ConfigurationID is null)
  and ((emap.ConfigurationID = @configurationId and emap.IsDeleted=0)or emap.ConfigurationID is null )
  and ((cmap.ConfigurationID = @configurationId and cmap.IsDeleted=0) or cmap.ConfigurationID is null )
order by gr.GeoRefId

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- Description:	Returns Geo ref ids for configurationId
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000GeoRefIdsPnameTriviaUS]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000GeoRefIdsPnameTriviaUS]
END
GO
CREATE PROC sp_GetExportAS4000GeoRefIdsPnameTriviaUS
@configurationId INT
AS
BEGIN

SELECT DISTINCT
  Gr.GeoRefId, 
  (Sp.UnicodeStr + ', ' + Us.StateName) as Name, 
  Gr.CountryId, 
  convert(nvarchar,Gr.StateId) as StateCode, 
  tblArea.Area as Area, 
  tblElevation.Elevation as Elevation, 
  tblCityPopulation.Population as Population 
FROM tblGeoRef AS Gr
  inner join tblgeorefmap on tblgeorefmap.georefid = gr.id
  inner join tblspelling as sp on sp.georefid = gr.georefid
  inner join tblspellingmap on tblspellingmap.spellingid = sp.spellingid
  inner join tblusstates as us on us.stateid = gr.stateid
  left join tblArea on tblArea.GeoRefID = Gr.GeoRefID
  left join tblAreaMap as amap on amap.AreaID = tblArea.AreaID
  left join tblElevation on tblElevation.GeoRefID = Gr.GeoRefId
  left join tblElevationMap as emap on emap.ElevationID = tblElevation.ID
  left join tblCityPopulation on tblCityPopulation.GeoRefID = gr.GeoRefId
  left join tblCityPopulationMap as cmap on cmap.CityPopulationID = tblCityPopulation.CityPopulationID
WHERE 
  tblgeorefmap.configurationid = @configurationId   and tblgeorefmap.isDeleted=0
  and tblspellingmap.configurationid = @configurationId and tblspellingmap.isDeleted=0
  and Gr.GeoRefId IN (SELECT GeoRefId FROM tblGeoRef WHERE GeoRefId < 100000 AND GeoRefId NOT BETWEEN 20000 AND 20162 AND GeoRefId NOT BETWEEN 20200 AND 25189) 
  AND Sp.LanguageId = 1 
  AND Gr.CountryId = 251 
  AND Gr.PnType = 1 
  and ((amap.ConfigurationID = @configurationId and amap.IsDeleted=0) or amap.ConfigurationID is null)
  and ((emap.ConfigurationID = @configurationId and emap.IsDeleted=0)or emap.ConfigurationID is null )
  and ((cmap.ConfigurationID = @configurationId and cmap.IsDeleted=0) or cmap.ConfigurationID is null )
order by gr.GeoRefId

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000GeoRefIdsPopulation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000GeoRefIdsPopulation]
END
GO
CREATE PROC sp_GetExportAS4000GeoRefIdsPopulation
@configurationId INT
AS
BEGIN

SELECT 
	georefid,
	Population 
from tblCityPopulation
	inner join tblCityPopulationMap as cpmap on cpmap.CityPopulationID = tblCityPopulation.CityPopulationID
where
	cpmap.ConfigurationID = @configurationId and cpmap.IsDeleted=0

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000Languages]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000Languages]
END
GO
CREATE PROC sp_GetExportAS4000Languages
@configurationId INT
AS 
BEGIN

select
	tblLanguages.LanguageID,
	Name,
	tblLanguages.[2LetterID_4xxx] as '2LetterID',
	tblLanguages.[3LetterID_4xxx] as '3LetterID',
	HorizontalOrder,
	HorizontalScroll,
	VerticalOrder,
	VerticalScroll,
	case 
		when tblLanguages.LanguageID = 1 then 'ENGLISH'
		else 'METRIC'
	end as UnitType,
	case
		when tblLanguages.LanguageID = 1 then 'HOUR12'
		else 'HOUR24'
	end as TimeType
from tblLanguages
	inner join tblLanguagesMap as lmap on lmap.LanguageID = tblLanguages.ID
where
	lmap.ConfigurationID = @configurationId and lmap.IsDeleted=0
order by tblLanguages.LanguageID

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- Description:	Returns spelling for AS4000
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000Spellings]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000Spellings]
END
GO
CREATE PROC sp_GetExportAS4000Spellings
@configurationId INT
AS
BEGIN

SELECT 
	tblspelling.GeoRefID, 
	languageid as Language, 
	FontID,
	SequenceID,
	UnicodeStr, 
	SphereMapFontID, 
	POISpelling, 
	tblgeoref.PoiPanelStatsAppearance as POIGroup 
from dbo.tblSpelling 
	inner join tblspellingmap as smap on smap.SpellingID = tblSpelling.SpellingID
	inner join tblgeoref on tblgeoref.georefid = dbo.tblspelling.georefid
	inner join tblgeorefmap as grmap on grmap.GeoRefId = tblgeoref.ID
WHERE 
	smap.ConfigurationID = @configurationId and smap.IsDeleted=0
	and grmap.ConfigurationID = @configurationId and grmap.IsDeleted=0
and tblspelling.georefid in 
(
	select tblgeoref.georefid
	from dbo.tblGeoRef 
		inner join tblgeorefmap on tblgeorefmap.GeoRefID = tblgeoref.id
	where tblgeoref.georefid < 510000 
		AND tblgeoref.georefid NOT BETWEEN 20000 AND 20162 
		AND tblgeoref.georefid NOT BETWEEN 20200 AND 25189 
		AND tblgeoref.georefid NOT BETWEEN 200172 AND 200239 
		AND tblgeoref.georefid NOT BETWEEN 250001 AND 250017
		and tblgeorefmap.configurationid = @configurationId and tblgeorefmap.IsDeleted=0
)

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXI3dAirportInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXI3dAirportInfo]
END
GO
CREATE PROC sp_GetExportASXI3dAirportInfo
@configurationId INT
AS
BEGIN
select
	FourLetID as FourLetId,
	ThreeLetID as ThreeLetId,
	Lat,
	Lon, 
	tblAirportInfo.GeoRefID as PointGeoRefId,
	null as AirportGeoRefId,
	0 as CustomChangeBit
from tblairportinfo
    inner join tblgeoref on tblgeoref.georefid = tblairportinfo.georefid
	inner join tblairportinfomap as apmap on apmap.AirportInfoID = tblairportinfo.AirportInfoID
    inner join tblgeorefmap as grmap on grmap.GeoRefID = tblgeoref.id
where
    tblgeoref.georefid not between 200172 and 200239 and
	tblgeoref.georefid not between 300000 and 307840 and
	apmap.ConfigurationID = @configurationId and apmap.isDeleted=0 and
	grmap.ConfigurationID = @configurationId and grmap.isDeleted=0
order by tblairportinfo.FourLetID
END

GO 
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXI3dAppearance]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXI3dAppearance]
END
GO
CREATE PROC sp_GetExportASXI3dAppearance
@configurationId INT
AS 
BEGIN

select
  tblAppearance.georefid as GeoRefId,
  tblappearance.ResolutionMpp as Resolution,
  tblgeoref.AsxiPriority as Priority,
  case 
	when tblappearance.exclude != 0 then 1
	else 0
  end as Exclude,
  tblappearance.CustomChangeBitMask as CustomChangeBit
from tblappearance
  inner join tblgeoref on tblgeoref.georefid = tblappearance.georefid
  inner join tblCoverageSegment as cvg on cvg.GeoRefID = tblgeoref.georefid
  inner join tblAppearanceMap as amap on amap.AppearanceID = tblAppearance.AppearanceID
  inner join tblGeoRefMap as grmap on grmap.GeoRefID = tblgeoref.id
  inner join tblCoverageSegmentMap as cvgmap on cvgmap.CoverageSegmentID = cvg.ID
where
	tblappearance.georefid not between 200172 and 200239 and
	tblappearance.georefid not between 300000 and 307840 and
	tblappearance.ResolutionMpp in (15, 30, 60, 120, 240, 480, 960, 1920, 3840, 7680, 15360) and
	cvg.SegmentID = 1 and
	amap.ConfigurationID = @configurationId and amap.isDeleted=0 and
	grmap.ConfigurationID = @configurationId and grmap.isDeleted=0 and
	cvgmap.ConfigurationID = @configurationId and cvgmap.isDeleted=0 
order by tblAppearance.georefid

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXI3dGeoRefIdCategoryType]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXI3dGeoRefIdCategoryType]
END
GO
CREATE PROC sp_GetExportASXI3dGeoRefIdCategoryType
AS
BEGIN

select 
	GeoRefCategoryTypeID_ASXIAndroid as GeoRefIdCatTypeId,
	Description
from tblCategoryType
where
	GeoRefCategoryTypeID_ASXIAndroid is not null
order by GeoRefCategoryTypeID_ASXIAndroid

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXI3dGeoRefIds]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXI3dGeoRefIds]
END
GO
CREATE PROC sp_GetExportASXI3dGeoRefIds
@configurationId INT,
@languages VARCHAR(MAX)
AS
BEGIN
DECLARE @sql NVARCHAR(MAX)
SET @sql='select 
		*
from (
	select 
		tblgeoref.georefid,
		tblgeoref.description,
		tblgeoref.AsxiCatTypeId as GeoRefIdCatTypeId,
		tblgeoref.regionid,
		tblgeoref.countryid,
		tblgeoref.MapStatsAppearance as LayerDisplay,
		tblgeoref.isInteractiveSearch as ISearch,
		tblgeoref.isrlipoi as RLIPOI,
		tblgeoref.isInteractivePoi as IPOI,
		tblgeoref.isWorldClockPoi as WCPOI,
		tblgeoref.isClosestPoi as ClosestPOI,
		tblgeoref.ismakkahpoi as MakkahPOI,
		tblgeoref.customchangebitmask as CustomChangeBit,
		tblcoveragesegment.lat1 as Lat,
		tblcoveragesegment.lon1 as Lon,
		tbllanguages.[2LetterID_ASXi] as code, 
		tblspelling.unicodestr as spelling,
		elevation.elevation as elevation,
		population.Population as population,
		tblgeoref.Priority as Priority
	from tblgeoref
		inner join tblgeorefmap on tblgeorefmap.georefid = tblgeoref.id
		inner join tblspelling on tblspelling.georefid = tblgeoref.georefid
		inner join tblspellingmap on tblspellingmap.spellingid = tblspelling.spellingid
		inner join tbllanguages on tbllanguages.languageid = tblspelling.languageid
		inner join tbllanguagesmap on tbllanguagesmap.languageid = tbllanguages.id
		inner join tblcoveragesegment on tblcoveragesegment.GeoRefID = tblgeoref.georefid
		inner join tblCoverageSegmentMap on tblCoverageSegmentMap.CoverageSegmentID = tblCoverageSegment.id
		left join (
			select tblelevation.* from tblelevation inner join tblelevationmap on tblelevationmap.elevationid = tblelevation.id
			where tblelevationmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tblelevationmap.IsDeleted=0
		) as elevation on elevation.georefid = tblgeoref.georefid
		left join (
			select tblcitypopulation.* from tblCityPopulation inner join tblCityPopulationMap on tblCityPopulationMap.CityPopulationID = tblCityPopulation.CityPopulationID
			where tblCityPopulationMap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tblCityPopulationMap.IsDeleted=0
		) as population on population.GeoRefID = tblgeoref.GeoRefId
	where tblgeorefmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and
		tblgeoref.georefid not between 200172 and 200239 and
		tblgeoref.georefid not between 300000 and 307840 and
		tblspellingmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tblspellingmap.isDeleted=0 and
		tbllanguagesmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tbllanguagesmap.IsDeleted=0 and
		tblcoveragesegmentmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tblcoveragesegmentmap.IsDeleted=0 and
		tblcoveragesegment.SegmentID = 1
) as sourcetable
pivot(
    max(spelling)
    for code in ('+@languages+')
) as pivottable
order by georefid'

EXECUTE sp_executesql @sql;


END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXI3dGeoRefIdsFiltered]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXI3dGeoRefIdsFiltered]
END
GO
CREATE PROC sp_GetExportASXI3dGeoRefIdsFiltered
@configurationId INT,
@languages VARCHAR(MAX),
@geoRefIds VARCHAR(MAX)
AS
BEGIN
DECLARE @sql NVARCHAR(MAX)

SELECT * INTO #TEMPAEROPLANETYPES FROM STRING_SPLIT(@geoRefIds, ',')

SET @sql='select 
		*
from (
	select 
		tblgeoref.georefid,
		tblgeoref.description,
		tblgeoref.AsxiCatTypeId as GeoRefIdCatTypeId,
		tblgeoref.regionid,
		tblgeoref.countryid,
		tblgeoref.MapStatsAppearance as LayerDisplay,
		tblgeoref.isInteractiveSearch as ISearch,
		tblgeoref.isrlipoi as RLIPOI,
		tblgeoref.isInteractivePoi as IPOI,
		tblgeoref.isWorldClockPoi as WCPOI,
		tblgeoref.isClosestPoi as ClosestPOI,
		tblgeoref.ismakkahpoi as MakkahPOI,
		tblgeoref.customchangebitmask as CustomChangeBit,
		tblcoveragesegment.lat1 as Lat,
		tblcoveragesegment.lon1 as Lon,
		tbllanguages.[2LetterID_ASXi] as code, 
		tblspelling.unicodestr as spelling,
		elevation.elevation as elevation,
		population.Population as population,
		tblgeoref.Priority as Priority
	from tblgeoref
		inner join tblgeorefmap on tblgeorefmap.georefid = tblgeoref.id
		inner join tblspelling on tblspelling.georefid = tblgeoref.georefid
		inner join tblspellingmap on tblspellingmap.spellingid = tblspelling.spellingid
		inner join tbllanguages on tbllanguages.languageid = tblspelling.languageid
		inner join tbllanguagesmap on tbllanguagesmap.languageid = tbllanguages.id
		inner join tblcoveragesegment on tblcoveragesegment.GeoRefID = tblgeoref.georefid
		inner join tblCoverageSegmentMap on tblCoverageSegmentMap.CoverageSegmentID = tblCoverageSegment.id
		left join (
			select tblelevation.* from tblelevation inner join tblelevationmap on tblelevationmap.elevationid = tblelevation.id
			where tblelevationmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tblelevationmap.IsDeleted=0
		) as elevation on elevation.georefid = tblgeoref.georefid
		left join (
			select tblcitypopulation.* from tblCityPopulation inner join tblCityPopulationMap on tblCityPopulationMap.CityPopulationID = tblCityPopulation.CityPopulationID
			where tblCityPopulationMap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tblCityPopulationMap.IsDeleted=0
		) as population on population.GeoRefID = tblgeoref.GeoRefId
	where tblgeorefmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tblgeoref.georefid IN(SELECT VALUE FROM #TEMPAEROPLANETYPES) AND
		tblgeoref.georefid not between 200172 and 200239 and
		tblgeoref.georefid not between 300000 and 307840 and
		tblspellingmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tblspellingmap.isDeleted=0 and
		tbllanguagesmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tbllanguagesmap.IsDeleted=0 and
		tblcoveragesegmentmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tblcoveragesegmentmap.IsDeleted=0 and
		tblcoveragesegment.SegmentID = 1
) as sourcetable
pivot(
    max(spelling)
    for code in ('+@languages+')
) as pivottable
order by georefid'
PRINT @sql
EXECUTE sp_executesql @sql;


END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXI3dGeoRefIdTbTzStrip]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXI3dGeoRefIdTbTzStrip]
END
GO
CREATE PROC sp_GetExportASXI3dGeoRefIdTbTzStrip
@configurationId INT
AS
BEGIN

select 
	tblgeoref.GeoRefId,
	tbltimezonestrip.IdVer2 as TimeZoneStrip
from tblTimeZoneStrip
	inner join tblgeoref on tblgeoref.TZStripId = tblTimeZoneStrip.TZStripID
	inner join tblgeorefmap as grmap on grmap.GeoRefID = tblgeoref.id
	inner join tblTimeZoneStripMap as tzsmap on tzsmap.TimeZoneStripID = tblTimeZoneStrip.ID
where
	tblgeoref.georefid not between 200172 and 200239 and
	tblgeoref.georefid not between 300000 and 307840 and
	grmap.ConfigurationID = @configurationId and grmap.IsDeleted=0 and
	tzsmap.ConfigurationID = @configurationId and tzsmap.isDeleted=0
order by georefid

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXi3DLanguages]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXi3DLanguages]
END
GO
CREATE PROC sp_GetExportASXi3DLanguages
@configurationId INT
AS 
BEGIN

select 
	tblLanguages.LanguageID,
	tblLanguages.Name,
	tblLanguages.[2LetterID_ASXi] as TwoLetterID,
	tblLanguages.[3LetterID_ASXi] as ThreeLetterID,
	HorizontalOrder,
	HorizontalScroll,
	VerticalOrder,
	VerticalScroll
from tbllanguages
	inner join tbllanguagesmap as lmap on lmap.languageid = tbllanguages.ID
where
	lmap.ConfigurationID = @configurationId and lmap.IsDeleted=0
order by tbllanguages.languageid

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- Description:	Returns region spelling for configurationId
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXI3dRegionSpelling]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXI3dRegionSpelling]
END
GO

CREATE PROC sp_GetExportASXI3dRegionSpelling
@configurationId INT,
@languages VARCHAR(MAX)
AS
BEGIN
DECLARE @sql NVARCHAR(MAX)
SET @sql='select 
	*
from (
    select 
		RegionID,
		tblRegionSpelling.CustomChangeBitMask as CustomChangeBit,
		RegionName,
		tblLanguages.[2LetterID_ASXi] as code
    from tblRegionSpelling 
		inner join tblLanguages on tblLanguages.LanguageID = tblRegionSpelling.LanguageId
		inner join tblRegionSpellingMap as rsmap on rsmap.SpellingID = tblRegionSpelling.SpellingID
		inner join tbllanguagesmap as lmap on lmap.languageid = tbllanguages.id
    where
		rsmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and rsmap.isDeleted=0 and
		lmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and lmap.isDeleted=0
) as sourcetable
pivot(
    max(RegionName)
    for code in ('+@languages+')
) as pivottable
order by RegionID'

EXECUTE sp_executesql @sql;


END
GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXInfoAppearance]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXInfoAppearance]
END
GO
CREATE PROC sp_GetExportASXInfoAppearance
@configurationId INT
AS
BEGIN

select
	*
from(
    select 
		tblgeoref.georefid,
		tblappearance.ResolutionMpp as resolution,
		cast(tblAppearance.exclude as int) as exclude
    from tblgeoref
		inner join tblappearance on tblappearance.georefid = tblgeoref.georefid
		inner join tblgeorefmap on tblgeorefmap.georefid = tblgeoref.id
		inner join tblappearancemap on tblappearancemap.appearanceid = tblappearance.appearanceid
    where 
		tblgeorefmap.configurationid = @configurationId and tblgeorefmap.IsDeleted=0 and
		tblappearancemap.configurationid = @configurationId and tblappearancemap.isDeleted=0
) as sourcetable
pivot(
    max(exclude)
    for resolution in ([15360], [7680], [3840], [1920], [960], [480], [240], [120], [60], [30], [15])
) as pivottable
order by georefid

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXInfoGeoRefSpellings]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXInfoGeoRefSpellings]
END
GO
CREATE PROC sp_GetExportASXInfoGeoRefSpellings
@configurationId INT,
@languageCodes NVARCHAR(MAX)
AS
BEGIN

DECLARE @sql NVARCHAR(MAX)
SET @sql = 'select 
	* 
from (
    select 
		tblgeoref.*, 
		tbllanguages.[2LetterID_ASXi] as code, 
		tblspelling.unicodestr as spelling,
		tblcitypopulation.population,
		tblelevation.elevation
    from tblgeoref
		inner join tblgeorefmap on tblgeorefmap.georefid = tblgeoref.id
		inner join tblspelling on tblspelling.georefid = tblgeoref.georefid
		inner join tblspellingmap on tblspellingmap.spellingid = tblspelling.spellingid
		inner join tbllanguages on tbllanguages.languageid = tblspelling.languageid
		inner join tbllanguagesmap on tbllanguagesmap.languageid = tbllanguages.id
		left join tblelevation on tblelevation.georefid = tblgeoref.georefid
		left join tblelevationmap on tblelevationmap.elevationid = tblelevation.id
		left join tblcitypopulation on tblcitypopulation.georefid = tblgeoref.georefid
		left join tblcitypopulationmap on tblcitypopulationmap.citypopulationid = tblcitypopulation.citypopulationid
    where tblgeorefmap.configurationid = ' + CAST(@configurationId AS NVARCHAR) +' and tblgeorefmap.isDeleted=0 and
		tblspellingmap.configurationid = ' + CAST(@configurationId AS NVARCHAR) +' and tblspellingmap.isDeleted=0 and
		tbllanguagesmap.configurationid = ' + CAST(@configurationId AS NVARCHAR) +' and tbllanguagesmap.isDeleted=0 and
		((tblelevationmap.configurationid = ' + CAST(@configurationId AS NVARCHAR) +' and tblelevationmap.isDeleted=0) or tblelevationmap.configurationid is null) and
		((tblcitypopulationmap.configurationid = ' + CAST(@configurationId AS NVARCHAR) +' and tblcitypopulationmap.isDeleted=0) or tblcitypopulationmap.configurationid is null)
) as sourcetable
pivot(
    max(spelling)
    for code in (' + @languageCodes + ')
) as pivottable
order by georefid'

EXEC (@sql)

END

GO
GO

GO
-- =============================================
-- Author:		<Sathya>
-- Create date: <19-05-2022>
-- Description:	 Retrieves the latitude and longitude information for each georef record. Suitable for export
--                    into the asxinfo database
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXInfoLatLon]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXInfoLatLon]
END
GO
CREATE PROC sp_GetExportASXInfoLatLon
@configurationId INT
AS
BEGIN
select 
	tblgeoref.georefid,
    tblcoveragesegment.lat1 as lat,
    tblcoveragesegment.lon1 as lon
from tblgeoref
    inner join tblgeorefmap on tblgeorefmap.georefid = tblgeoref.id
    inner join tblCoverageSegment on tblCoverageSegment.georefid = tblgeoref.georefid
    inner join tblcoveragesegmentmap on tblcoveragesegmentmap.CoverageSegmentID = tblcoveragesegment.id
where tblgeorefmap.configurationid = @configurationId
    and tblcoveragesegmentmap.configurationid = @configurationId and tblcoveragesegmentmap.isDeleted=0
    and tblcoveragesegment.segmentid = 1 and tblGeoRefMap.IsDeleted=0
order by tblgeoref.georefid
END
GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXInfoTimezoneStrips]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXInfoTimezoneStrips]
END
GO
CREATE PROC sp_GetExportASXInfoTimezoneStrips
@configurationId INT
AS
BEGIN
select
	tblgeoref.georefid,
	tblgeoref.tzstripid as tzstripid
from tblgeoref
	inner join tbltimezonestrip on tbltimezonestrip.tzstripid = tblgeoref.tzstripid
	inner join tblgeorefmap on tblgeorefmap.georefid = tblgeoref.id
	inner join tbltimezonestripmap on tbltimezonestripmap.timezonestripid = tbltimezonestrip.tzstripid
where
	tblgeorefmap.configurationid = @configurationId and tblgeorefmap.isDeleted=0
	and tbltimezonestripmap.configurationid = @configurationId and tbltimezonestripmap.isDeleted=0
order by tblgeoref.georefid
END

GO
GO

GO 

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportCESHTSEAirportInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportCESHTSEAirportInfo]
END
GO
CREATE PROC sp_GetExportCESHTSEAirportInfo
@configurationId INT
AS 
BEGIN

select
	FourLetId,
	case
		when ThreeLetId is null then 'ZZZ'
		else ThreeLetId
	end as ThreeLetId,
	Lat,
	Lon,
	GeoRefID as PointGeoRefId,
	null as ACARS
from tblAirportInfo
	inner join tblAirportInfoMap as apmap on apmap.AirportInfoID = tblAirportInfo.AirportInfoID
where
	apmap.ConfigurationID = @configurationId and apmap.IsDeleted=0
order by FourLetID

END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportCESHTSEAppearance]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportCESHTSEAppearance]
END
GO
CREATE PROC sp_GetExportCESHTSEAppearance
@configurationId INT
AS
BEGIN

select
	tblAppearance.GeoRefId,
	Resolution,
	tblAppearance.Priority,
	abs(exclude) as Exclude,
	abs(spheremapexclude) as SphereMapExclude
from tblAppearance
	inner join tblAppearanceMap as apmap on apmap.AppearanceID = tblAppearance.AppearanceID
	inner join tblgeoref on tblgeoref.GeoRefId = tblAppearance.GeoRefID
	inner join tblgeorefmap as grmap on grmap.GeoRefId = tblgeoref.id
where
	tblgeoref.georefid NOT BETWEEN 20200 AND 25189 and 
	tblgeoref.georefid NOT BETWEEN 200172 AND 200239 and
	tblgeoref.georefid NOT BETWEEN 300000 AND 307840 and
	tblgeoref.georefid NOT BETWEEN 310000 AND 414100 and
	resolution in (15, 30, 75, 150, 300, 600, 1620) and
	apmap.ConfigurationID = @configurationId and apmap.IsDeleted=0 and
	grmap.ConfigurationID = @configurationId and grmap.IsDeleted=0
order by georefid, resolution

END
GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportCESHTSEGeoRefIds]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportCESHTSEGeoRefIds]
END
GO
CREATE PROC sp_GetExportCESHTSEGeoRefIds
@configurationId INT
AS 
BEGIN

select
	tblgeoref.GeoRefId,
	Description as Name,
	PnType as PnGeoType,
	RliAppearance as POIType,
	CatTypeId as GeoRefIdCatTypeId
from tblgeoref
	inner join tblgeorefmap as grmap on grmap.GeoRefID = tblgeoref.ID
where
	tblgeoref.georefid NOT BETWEEN 20200 AND 25189 and 
	tblgeoref.georefid NOT BETWEEN 200172 AND 200239 and
	tblgeoref.georefid NOT BETWEEN 300000 AND 307840 and
	tblgeoref.georefid NOT BETWEEN 310000 AND 414100 and
	grmap.ConfigurationID = @configurationId AND grmap.isDeleted=0
order by tblgeoref.GeoRefId

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportCESHTSESpellings]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportCESHTSESpellings]
END
GO
CREATE PROC sp_GetExportCESHTSESpellings
@configurationId INT
AS
BEGIN

select 
	GeoRefId,
	en as Lang_EN,
	fr as Lang_FR,
	de as Lang_DE,
	es as Lang_ES,
	nl as Lang_NL,
	it as Lang_IT,
	el as Lang_EL,
	ja as Lang_JA,
	zh as Lang_ZH,
	ko as Lang_KO,
	id as Lang_ID,
	ar as Lang_AR,
	tr as Lang_TR,
	ms as Lang_MS,
	fi as Lang_FI,
	hi as Lang_HI,
	ru as Lang_RU,
	pt as Lang_PT,
	th as Lang_TH,
	ro as Lang_RO,
	sr as Lang_SR,
	sv as Lang_SV,
	hu as Lang_HU,
	he as Lang_HE,
	pl as Lang_PL,
	hk as Lang_HK,
	sm as Lang_SM,
	[to] as Lang_TO,
	cs as Lang_CS,
	da as Lang_DA,
	kk as Lang_KK,
	[is] as Lang_IS,
	vi as Lang_VI,
	di as Lang_DI,
	lk as Lang_LK
from (
    select 
		tblspelling.GeoRefID,
		tblspelling.UnicodeStr,
		tblLanguages.[2LetterID_ASXi] as code
    from tblspelling
		inner join tblLanguages on tblLanguages.LanguageID = tblspelling.LanguageID
		inner join tblSpellingMap as smap on smap.SpellingID = tblspelling.SpellingID
		inner join tbllanguagesmap as lmap on lmap.languageid = tbllanguages.id
    where
		georefid NOT BETWEEN 20200 AND 25189 and
		georefid NOT BETWEEN 200172 AND 200239 and
		georefid NOT BETWEEN 300000 AND 307840 and
		georefid NOT BETWEEN 310000 AND 414100 and
		smap.ConfigurationID = @configurationId and smap.IsDeleted=0 and
		lmap.ConfigurationID = @configurationId and lmap.IsDeleted=0
) as sourcetable
pivot(
    max(UnicodeStr)
    for code in ([en], [fr], [de], [es], [nl], [it], [el], [ja], [zh], [ko], [id], [ar], [tr], [ms], [fi], 
		[hi], [ru], [pt], [th], [ro], [sr], [sv], [hu], [he], [pl], [hk], [vi], [sm], [to], [cs], [da], [is], [kk], [di], [tk],
		[uz], [bn], [mn], [bo], [az], [ep], [sp], [no], [lk]
	)
) as pivottable
order by GeoRefId

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportCESHTSESpellingsTrivia]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportCESHTSESpellingsTrivia]
END
GO
CREATE PROC sp_GetExportCESHTSESpellingsTrivia
@configurationId INT,
@languages NVARCHAR(MAX)

AS
BEGIN
DECLARE @sql NVARCHAR(MAX)
SET @sql ='select 
	*
from (
    select 
		tblspelling.GeoRefID,
		edata.Elevation,
		pdata.Population,
		tblspelling.UnicodeStr,
		tblLanguages.[2LetterID_ASXi] as code
    from tblspelling
		inner join tblgeoref on tblgeoref.georefid = tblspelling.georefid
		inner join tblLanguages on tblLanguages.LanguageID = tblspelling.LanguageID
		inner join tblgeorefmap as grmap on grmap.GeoRefID = tblgeoref.id
		inner join tblSpellingMap as smap on smap.SpellingID = tblspelling.SpellingID
		inner join tbllanguagesmap as lmap on lmap.languageid = tbllanguages.id
		left join (
			select GeoRefId, Population from tblCityPopulation inner join tblCityPopulationMap on tblCityPopulationMap.CityPopulationID = tblCityPopulation.CityPopulationID
			where tblCityPopulationMap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and tblCityPopulationMap.IsDeleted=0
		) pdata on pdata.GeoRefID = tblSpelling.GeoRefID
		left join (
			select georefid, elevation from tblElevation inner join tblElevationMap on tblElevationMap.ElevationID = tblElevation.Elevation
			where tblElevationMap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and tblElevationMap.IsDeleted=0
		) edata on edata.GeoRefID = tblSpelling.GeoRefID

    where
		tblgeoref.georefid NOT BETWEEN 20200 AND 25189 and
		tblgeoref.pntype = 1 and
		tblgeoref.georefid < 100000 and
		grmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and grmap.IsDeleted=0 and
		smap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and smap.IsDeleted=0 and
		lmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and lmap.IsDeleted=0
) as sourcetable
pivot(
    max(UnicodeStr)
    for code in ('+@languages+')
) as pivottable
order by GeoRefId'

EXECUTE sp_executesql @sql;

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- Description:	Returns spelling of Destination for configurationId
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportDataAS4000DestinationSpelling]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportDataAS4000DestinationSpelling]
END
GO
CREATE PROC sp_GetExportDataAS4000DestinationSpelling
@configurationId INT
AS
BEGIN

SELECT 
	tblAirportInfo.FourLetId, 
	tblSpelling.languageid as LangId, 
	substring(tblSpelling.unicodestr, 1, 50) as DestinationSpelling, 
	1002 as CabinWXMapFontID, 
	10308 as FontId
from tblAirportInfo 
	inner join tblairportinfomap as apmap on apmap.AirportInfoID = tblAirportInfo.AirportInfoID
	INNER JOIN tblSpelling ON tblAirportInfo.georefid = tblSpelling.georefid
	inner join tblspellingmap as spmap on spmap.SpellingID = tblspelling.SpellingID
WHERE 
	tblSpelling.unicodestr is not null
	and apmap.ConfigurationID = @configurationId and apmap.IsDeleted=0
	and spmap.ConfigurationID = @configurationId and spmap.IsDeleted=0
order by fourletid

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontCategoryForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontCategoryForConfig]
END
GO
CREATE PROC sp_GetExportFontCategoryForConfig
@configurationId INT
AS
BEGIN

select
	GeoRefIdCatTypeId,
	LanguageId,
	FontId,
	MarkerId,
	Resolution,
	SphereFontId,
	AtlasMarkerId,
	SphereMarkerId
from tblFontCategory
	inner join tblFontCategoryMap on tblFontCategoryMap.FontCategoryID = tblFontCategory.FontCategoryID
where
	tblFontCategoryMap.ConfigurationID = @configurationId

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontCategoryForConfigPAC3D]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontCategoryForConfigPAC3D]
END
GO
CREATE PROC sp_GetExportFontCategoryForConfigPAC3D
@configurationId INT
AS
BEGIN

select
	GeoRefIdCatTypeId,
	LanguageId,
	FontId,
	MarkerId,
	IMarkerId
from tblFontCategory
	inner join tblFontCategoryMap on tblFontCategoryMap.FontCategoryID = tblFontCategory.FontCategoryID
where
	tblFontCategoryMap.ConfigurationID = @configurationId

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontDefaultCategoryForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontDefaultCategoryForConfig]
END
GO
CREATE PROC sp_GetExportFontDefaultCategoryForConfig
@configurationId INT
AS
BEGIN

select
	GeoRefIdCatTypeId,
	FontId,
	MarkerId,
	Resolution,
	SphereFontId,
	AtlasMarkerId,
	SphereMarkerId
from tblFontDefaultCategory
	inner join tblFontDefaultCategoryMap on tblFontDefaultCategoryMap.FontDefaultCategoryID = tblFontDefaultCategory.FontDefaultCategoryID
where
	tblFontDefaultCategoryMap.ConfigurationID = @configurationId

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontDefaultCategoryForConfigPAC3D]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontDefaultCategoryForConfigPAC3D]
END
GO
CREATE PROC sp_GetExportFontDefaultCategoryForConfigPAC3D
@configurationId INT
AS
BEGIN

select
	GeoRefIdCatTypeId,
	FontId,
	MarkerId,
	Resolution,
	SphereFontId,
	AtlasMarkerId,
	SphereMarkerId
from tblFontDefaultCategory
	inner join tblFontDefaultCategoryMap on tblFontDefaultCategoryMap.FontDefaultCategoryID = tblFontDefaultCategory.FontDefaultCategoryID
where
	tblFontDefaultCategoryMap.ConfigurationID = @configurationId

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontFamilyForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontFamilyForConfig]
END
GO
CREATE PROC sp_GetExportFontFamilyForConfig
@configurationId INT
AS
BEGIN

select
	FontFaceId,
	FaceName AS Name
from tblFontFamily
	inner join tblFontFamilyMap on tblFontFamilyMap.FontFamilyID = tblFontFamily.FontFamilyId
where
	tblFontFamilyMap.ConfigurationID = @configurationId

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontFamilyForConfigPAC3D]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontFamilyForConfigPAC3D]
END
GO
CREATE PROC sp_GetExportFontFamilyForConfigPAC3D
@configurationId INT
AS
BEGIN

select
	FontFaceId,
	FaceName,
	FileName
from tblFontFamily
	inner join tblFontFamilyMap on tblFontFamilyMap.FontFamilyID = tblFontFamily.FontFamilyId
where
	tblFontFamilyMap.ConfigurationID = @configurationId

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontForConfig]
END
GO
CREATE PROC sp_GetExportFontForConfig
@configurationId INT
AS
BEGIN

select distinct
	tblFont.FontId,
	Description,
	Size,
	Color,ShadowColor,
	FontFaceId,
	FontStyle,
	PxSize,TextEffectId
from tblFont
	inner join tblFontMap on tblFontMap.FontID = tblFont.ID
where
	tblFontMap.ConfigurationID = @configurationId and tblFontMap.IsDeleted=0

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontForConfigPAC3D]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontForConfigPAC3D]
END
GO
CREATE PROC sp_GetExportFontForConfigPAC3D
@configurationId INT
AS
BEGIN

select
	tblFont.FontId,
	Description,
	Size,
	Color,ShadowColor,
	FontFaceId,
	FontStyle
from tblFont
	inner join tblFontMap on tblFontMap.FontID = tblFont.ID
where
	tblFontMap.ConfigurationID = @configurationId

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontMarkerForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontMarkerForConfig]
END
GO
CREATE PROC sp_GetExportFontMarkerForConfig
@configurationId INT
AS
BEGIN

select
	MarkerId,
	Filename
from tblFontMarker
	inner join tblFontMarkerMap on tblFontMarkerMap.FontMarkerID = tblFontMarker.FontMarkerID
where
	tblFontMarkerMap.ConfigurationID = @configurationId

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontMarkerForConfigPAC3D]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontMarkerForConfigPAC3D]
END
GO
CREATE PROC sp_GetExportFontMarkerForConfigPAC3D
@configurationId INT
AS
BEGIN

select
	MarkerId,
	Filename
from tblFontMarker
	inner join tblFontMarkerMap on tblFontMarkerMap.FontMarkerID = tblFontMarker.FontMarkerID
where
	tblFontMarkerMap.ConfigurationID = @configurationId

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontTextEffectForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontTextEffectForConfig]
END
GO
CREATE PROC sp_GetExportFontTextEffectForConfig
@configurationId INT
AS
BEGIN

select
	tblFontTextEffect.FontTextEffectID AS TextEffectId,
	Name
from tblFontTextEffect
	inner join tblFontTextEffectMap on tblFontTextEffectMap.FontTextEffectID = tblFontTextEffect.FontTextEffectID
where
	tblFontTextEffectMap.ConfigurationID = @configurationId

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontTextEffectForConfigPAC3D]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontTextEffectForConfigPAC3D]
END
GO
CREATE PROC sp_GetExportFontTextEffectForConfigPAC3D
@configurationId INT
AS
BEGIN

select
	Name
from tblFontTextEffect
	inner join tblFontTextEffectMap on tblFontTextEffectMap.FontTextEffectID = tblFontTextEffect.FontTextEffectID
where
	tblFontTextEffectMap.ConfigurationID = @configurationId

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportScreenSizeForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportScreenSizeForConfig]
END
GO
CREATE PROC sp_GetExportScreenSizeForConfig 
@configurationId INT
AS
BEGIN

select 
	tblScreenSize.ScreenSizeID as id,
	Description as description
from tblScreenSize
	inner join tblScreenSizeMap on tblScreenSizeMap.ScreenSizeID = tblScreenSize.ScreenSizeID
where
	tblScreenSizeMap.ConfigurationID = @configurationId

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 21-Dec-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportSpellings]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportSpellings]
END
GO
CREATE PROC sp_GetExportSpellings
@configurationId INT,
@languages NVARCHAR(MAX)
AS
BEGIN

DECLARE @sql nvarchar(max)

set @sql = 'select 
	*
from (
    select 
		tblspelling.GeoRefID,
		tblspelling.UnicodeStr,
		tblLanguages.[2LetterID_ASXi] as code
    from tblspelling
		inner join tblLanguages on tblLanguages.LanguageID = tblspelling.LanguageID
		inner join tblSpellingMap as smap on smap.SpellingID = tblspelling.SpellingID
		inner join tbllanguagesmap as lmap on lmap.languageid = tbllanguages.id
    where
		georefid NOT BETWEEN 20200 AND 25189 and
		georefid NOT BETWEEN 200172 AND 200239 and
		georefid NOT BETWEEN 300000 AND 307840 and
		georefid NOT BETWEEN 310000 AND 414100 and
		smap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and smap.IsDeleted=0 and
		lmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and lmap.IsDeleted=0
) as sourcetable
pivot(
    max(UnicodeStr)
    for code in ('+@languages+')
) as pivottable
order by GeoRefId'

EXECUTE sp_executesql @sql;


END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportThalesAirportInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportThalesAirportInfo]
END
GO
CREATE PROC sp_GetExportThalesAirportInfo
@configurationId INT
AS
BEGIN

select
	FourLetId,
	ThreeLetId,
	Lat,
	Lon,
	GeoRefID as PointGeoRefId,
	null as ACARS
from tblAirportInfo
	inner join tblAirportInfoMap as apmap on apmap.AirportInfoID = tblAirportInfo.AirportInfoID
where
	apmap.ConfigurationID = @configurationId and apmap.isDeleted=0
order by FourLetID

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportThalesPNameTriva]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportThalesPNameTriva]
END
GO
CREATE PROC sp_GetExportThalesPNameTriva
@configurationId INT
AS
BEGIN

select 
	GeoRefId,
	Elevation,
	Population,
	en as Lang_EN
from (
	select 
		tblspelling.GeoRefID,
		Elevation,
		Population,
		tblspelling.UnicodeStr,
		tblLanguages.[2LetterID_ASXi] as code
	from tblspelling
		inner join tblgeoref on tblgeoref.georefid = tblspelling.georefid
		inner join tblLanguages on tblLanguages.LanguageID = tblspelling.LanguageID
		inner join tblgeorefmap as grmap on grmap.GeoRefID = tblgeoref.id
		inner join tblSpellingMap as smap on smap.SpellingID = tblspelling.SpellingID
		inner join tbllanguagesmap as lmap on lmap.languageid = tbllanguages.id
		left join (
			select tblelevation.* from tblelevation inner join tblelevationmap on tblelevationmap.elevationid = tblelevation.id
			where tblelevationmap.configurationid = @configurationid and tblelevationmap.IsDeleted=0
		) as elevation on elevation.georefid = tblgeoref.georefid
		left join (
			select tblcitypopulation.* from tblCityPopulation inner join tblCityPopulationMap on tblCityPopulationMap.CityPopulationID = tblCityPopulation.CityPopulationID
			where tblCityPopulationMap.configurationid = @configurationid and tblCityPopulationMap.IsDeleted=0
		) as population on population.GeoRefID = tblgeoref.GeoRefId
	where
		tblgeoref.pntype = 1 and
		tblgeoref.georefid < 100000 and
		tblgeoref.georefid NOT BETWEEN 20200 AND 25189 and
		grmap.ConfigurationID = @configurationId and grmap.IsDeleted=0 and
		smap.ConfigurationID = @configurationId and smap.IsDeleted=0 and
		lmap.ConfigurationID = @configurationId and lmap.IsDeleted=0
) as sourcetable
pivot(
    max(UnicodeStr)
    for code in ([en])
) as pivottable
order by GeoRefId

END

GO
GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- Description:	Returns spelling for configurationId
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportThalesSpellings]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportThalesSpellings]
END
GO
CREATE PROC sp_GetExportThalesSpellings
@configurationId INT
AS
BEGIN

select 
	GeoRefId,
	en as Lang_EN,
	fr as Lang_FR,
	de as Lang_DE,
	es as Lang_ES,
	nl as Lang_NL,
	it as Lang_IT,
	el as Lang_EL,
	ja as Lang_JA,
	zh as Lang_ZH,
	ko as Lang_KO,
	id as Lang_ID,
	ar as Lang_AR,
	tr as Lang_TR,
	ms as Lang_MS,
	fi as Lang_FI,
	hi as Lang_HI,
	ru as Lang_RU,
	pt as Lang_PT,
	th as Lang_TH,
	ro as Lang_RO,
	sr as Lang_SR,
	sv as Lang_SV,
	hu as Lang_HU,
	he as Lang_HE,
	pl as Lang_PL,
	hk as Lang_HK,
	sm as Lang_SM,
	[to] as Lang_TO,
	cs as Lang_CS,
	da as Lang_DA,
	[is] as Lang_IS,
	vi as Lang_VI,
	di as Lang_DI,
	lk as Lang_LK
from (
    select 
		tblspelling.GeoRefID,
		tblspelling.UnicodeStr,
		tblLanguages.[2LetterID_ASXi] as code
    from tblspelling
		inner join tblLanguages on tblLanguages.LanguageID = tblspelling.LanguageID
		inner join tblSpellingMap as smap on smap.SpellingID = tblspelling.SpellingID
		inner join tbllanguagesmap as lmap on lmap.languageid = tbllanguages.id
    where
		georefid NOT BETWEEN 20200 AND 25189 and
		georefid NOT BETWEEN 200172 AND 200239 and 
		georefid NOT BETWEEN 300000 AND 307840 and
		georefid NOT BETWEEN 310000 AND 414100 and
		smap.ConfigurationID = @configurationId and smap.isDeleted=0 and
		lmap.ConfigurationID = @configurationId and lmap.isDeleted=0
) as sourcetable
pivot(
    max(UnicodeStr)
    for code in ([en], [fr], [de], [es], [nl], [it], [el], [ja], [zh], [ko], [id], [ar], [tr], [ms], [fi], 
		[hi], [ru], [pt], [th], [ro], [sr], [sv], [hu], [he], [pl], [hk], [vi], [sm], [to], [cs], [da], [is], [kk], [di], [tk],
		[uz], [bn], [mn], [bo], [az], [ep], [sp], [no], [lk]
	)
) as pivottable
order by GeoRefId

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportWGCitiesForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportWGCitiesForConfig]
END
GO
CREATE PROC sp_GetExportWGCitiesForConfig
@configurationId INT
AS
BEGIN

select 
	city_id,
	georefid
from tblwgwcities
	inner join tblwgwcitiesMap on tblwgwcitiesMap.CityID = tblwgwcities.city_id
where
	tblwgwcitiesMap.ConfigurationID = @configurationId
order by city_id

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportWGContentForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportWGContentForConfig]
END
GO
CREATE PROC sp_GetExportWGContentForConfig
@configurationId INT
AS
BEGIN

select
	tblWgContent.WGContentId,
	GeoRefId,
	TypeId,
	ImageId,
	TExtId
from tblWGContent
	inner join tblWGContentMap on tblWGContentMap.WGContentID = tblwgcontent.WGContentID
where
	tblWGContentMap.ConfigurationID = @configurationId

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportWGImageForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportWGImageForConfig]
END
GO
CREATE PROC sp_GetExportWGImageForConfig
@configurationId INT
AS
BEGIN

select
  -1 as ImageId,
  null as Filename
union
select
	tblwgImage.ImageId,
	Filename
from tblwgimage
	inner join tblwgimagemap on tblwgimagemap.ImageID = tblwgimage.ImageID
where
	tblwgimagemap.ConfigurationID = @configurationId

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportWGTextForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportWGTextForConfig]
END
GO
CREATE PROC sp_GetExportWGTextForConfig
@configurationId INT
AS
BEGIN

select 
	[TextID],
	[Text_EN],
	[Text_FR],
	[Text_DE],
	[Text_ES],
	[Text_NL],
	[Text_IT],
	[Text_EL],
	[Text_JA],
	[Text_ZH],
	[Text_KO],
	[Text_ID],
	[Text_AR],
	[Text_TR],
	[Text_MS],
	[Text_FI],
	[Text_HI],
	[Text_RU],
	[Text_PT],
	[Text_TH],
	[Text_RO],
	[Text_SR],
	[Text_SV],
	[Text_HU],
	[Text_HE],
	[Text_PL],
	[Text_HK],
	[Text_SM],
	[Text_TO],
	[Text_CS],
	[Text_DA],
	[Text_IS],
	[Text_VI]
from tblwgtext
	inner join tblwgtextmap on tblwgtextmap.WGtextID = tblwgtext.WGtextID
where
	tblwgtextmap.ConfigurationID = @configurationId
order by textid

END

GO
GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportWGTypeForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportWGTypeForConfig]
END
GO
CREATE PROC sp_GetExportWGTypeForConfig
@configurationId INT
AS
BEGIN

select 
	TypeId,
	Description,
	Layout,
	ImageWidth,
	ImageHeight
from tblwgtype
	inner join tblWGTypeMap on tblwgtypemap.WGTypeID = tblwgtype.WGTypeID
where
	tblwgtypemap.ConfigurationID = @configurationId
order by TypeId

END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 06/13/2022
-- Description:	Procedure to get the file ID from tasks table based on configuration ID and tasktype ID
-- Sample EXEC [dbo].[SP_GetFileIDFromTaskID] '67','755DC050-137C-4BFB-BE7C-8BB0F1441224'
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetFileIDFromTaskID]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetFileIDFromTaskID]
END
GO

CREATE PROCEDURE [dbo].[SP_GetFileIDFromTaskID]
	@configurationId INT,
	@taskId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT TOP 1 ID FROM tblTasks WHERE TaskTypeID = @taskId AND ConfigurationID = @configurationId ORDER BY DateStarted DESC
END
GO


GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 08/25/2022
-- Description:	Procedure to get errors when a file upload fails.
-- Sample EXEC [dbo].[SP_GetFileUploadErrorLogs] 1,'populations'
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetFileUploadErrorLogs]', 'P') IS NOT NULL
	BEGIN
		DROP PROC [dbo].[SP_GetFileUploadErrorLogs]
	END
GO

CREATE PROCEDURE [dbo].[SP_GetFileUploadErrorLogs]  
	@configurationId INT,  
	@pageName NVARCHAR(500)  
AS  
BEGIN

	DECLARE @name NVARCHAR(250), @taskType UNIQUEIDENTIFIER
	
	IF (@pageName = 'populations' OR @pageName = 'airports' OR @pageName = 'world guide cities')
		BEGIN
			SELECT
				@name = CASE @pageName
				WHEN 'populations' THEN 'Import CityPopulation'
				WHEN 'airports' THEN 'Import NewAirportFromNavDB'
				WHEN 'placenames' THEN 'Import NewPlaceNames'
				WHEN 'world guide' THEN 'Import WGCities'
			END
			SELECT TOP 1 errorlog FROM tbltasks WHERE ConfigurationID = @configurationId
			AND TaskTypeID IN (SELECT ID FROM tblTaskType WHERE Name = @name) ORDER BY DateStarted DESC
		END
	ELSE
		BEGIN
			SELECT TOP 1 CC.ErrorLog FROM tblConfigurationComponents CC
			INNER JOIN tblConfigurationComponentsMap CCM ON CC.ConfigurationComponentTypeID = CCM.ConfigurationComponentID AND CCM.ConfigurationID = @configurationId
		END
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:			Aiyappa, Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	 this SP returns name based on configurationid
-- Sample: EXEC [dbo].[SP_GetFlightInfoView] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetFlightInfoView]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetFlightInfoView]
END
GO

CREATE PROCEDURE [dbo].[SP_GetFlightInfoView]
        @configurationId INT
       
AS

BEGIN

            SELECT ISNULL(Nodes.item.value('(./@name)[1]','varchar(max)'),'') AS name
             FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID
              CROSS APPLY b.ScriptDefs.nodes('/script_defs/infopages/infopage') Nodes(item) 
            WHERE ConfigurationID  = @configurationId 
END
GO



GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa,Brinda Chindamada
-- Create date:  5/25/2022
-- Description: get the scripttype based on configurationId and viewname
-- Sample: EXEC [dbo].[SP_GetFlightInfoViewParam] 1,'Info Page 2_3D'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetFlightInfoViewParam]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_GetFlightInfoViewParam]

END

GO

CREATE PROCEDURE [dbo].[SP_GetFlightInfoViewParam]
                        @configurationId INT,
						@viewName VARCHAR(Max)
                      
                       

AS

BEGIN
        DECLARE @sql NVARCHAR(Max)
		 DECLARE @params NVARCHAR(4000) = '@configurationId Int'
        SET @sql='SELECT ISNULL(Nodes.item.value(''(/script_defs/infopages/infopage[@name="' + @viewName + '"]/@infoitems)[1]'',''varchar(max)''),'''')
            AS scriptType 
            FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID 
            CROSS APPLY b.ScriptDefs.nodes(''/script_defs'') Nodes(item) WHERE ConfigurationID =  @configurationId '
			 EXEC sys.Sp_executesql @sql ,@params,@configurationId = @configurationId
END

GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date:  5/25/2022
-- Description:	This will return the info parameters 
-- Sample: EXEC [dbo].[SP_GetFlightInfoViewParameters] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetFlightInfoViewParameters]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetFlightInfoViewParameters]
END
GO

CREATE PROCEDURE [dbo].[SP_GetFlightInfoViewParameters]
       @configurationId INT
       
AS

BEGIN
     
           SELECT DISTINCT Nodes.item.value('(.)[1]', 'VARCHAR(MAX)') as info_params
            FROM cust.tblWebMain CROSS APPLY InfoItems.nodes('/infoitems/infoitem') Nodes(item)
			INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.ConfigurationID = tblWebMainMap.ConfigurationID 
             WHERE tblWebMainMap.ConfigurationID = @configurationId
END
GO

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Brinda
-- Create date: 2/22/2023
-- Description:	To get the font info for languages
-- EXEC [dbo].[SP_GetFontInfoForLangugaeId] 1,1,0
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetFontInfoForLangugaeId]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetFontInfoForLangugaeId]
END
GO

CREATE PROCEDURE [dbo].[SP_GetFontInfoForLangugaeId]
    @languageId INT,
	@geoRefCatTypeId INT,
	@resolution INT
	
AS
BEGIN
        SELECT distinct tblfont.fontId,MarkerID,FaceName,Size,Color,ShadowColor,FontStyle FROM tblfontcategory INNER JOIN tblfont ON tblfontcategory.FontId = tblfont.FontId
        INNER JOIN tblfontfamily ON tblfont.FontFaceId=tblfontfamily.FontFaceId WHERE GeoRefIdCatTypeId=@geoRefCatTypeId AND
        Resolution=@resolution AND LanguageId=@languageId
END
GO


GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	Get the font based on configurationID
-- Sample: EXEC [dbo].[SP_GetFonts] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetFonts]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetFonts]
END
GO

CREATE PROCEDURE [dbo].[SP_GetFonts]
        @configurationId INT
       
AS

BEGIN

                    SELECT DISTINCT tblFontFiles.*
                    ,
                    CASE WHEN dbo.tblFontFileSelectionMap.FontFileSelectionID IS NOT NULL THEN 1 ELSE 0 
                    END AS IsSelected 
                    FROM dbo.tblFontFiles INNER JOIN dbo.tblFontFilesMap ON dbo.tblFontFiles.FontFileID = dbo.tblFontFilesMap.FontFileID 
                    LEFT OUTER JOIN dbo.tblFontFileSelection ON dbo.tblFontFileSelection.FontFileID = dbo.tblFontFilesMap.FontFileID 
                    LEFT OUTER JOIN dbo.tblFontFileSelectionMap ON dbo.tblFontFileSelectionMap.FontFileSelectionID = dbo.tblFontFileSelection.FontFileSelectionID 
                    AND dbo.tblFontFileSelectionMap.ConfigurationID = dbo.tblFontFilesMap.ConfigurationID
                    WHERE dbo.tblFontFilesMap.ConfigurationID = @configurationId
END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Aiyappa, Brinda Chindamada
-- Create date:  5/25/2022
-- Description:	This SP will return FontFileSelectionId based on FontFileID
-- Sample: EXEC [dbo].[SP_GetFontSelectionIdForFont] 2
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetFontSelectionIdForFont]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetFontSelectionIdForFont]
END
GO

CREATE PROCEDURE [dbo].[SP_GetFontSelectionIdForFont]
        @fontFileId INT
       
AS

BEGIN

       SELECT dbo.tblFontFileSelection.* FROM dbo.tblFontFileSelection  WHERE dbo.tblFontFileSelection.FontFileID =  @fontFileId
END
GO


GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	This SP will give the number of column name based on configurationID from table fontfileselectionMap
-- Sample: EXEC [dbo].[SP_GetFontSelectionMappingCount] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetFontSelectionMappingCount]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetFontSelectionMappingCount]
END
GO

CREATE PROCEDURE [dbo].[SP_GetFontSelectionMappingCount]
        @configurationId INT
       
AS

BEGIN

       select count(*) from dbo.tblFontFileSelectionMap WHERE dbo.tblFontFileSelectionMap.ConfigurationID =  @configurationId
END
GO


GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	Get the forced languages based on configurationId and scriptId
-- Sample: EXEC [dbo].[SP_GetForcedLanguages] 36,4
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetForcedLanguages]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetForcedLanguages]
END
GO

CREATE PROCEDURE [dbo].[SP_GetForcedLanguages]
        @configurationId INT,
        @scriptId  INT
AS

BEGIN

               SELECT ISNULL(Nodes.item.value('(./@forced_langs)[1]','varchar(max)'),'') AS forced_lang 
               FROM cust.tblScriptDefs b INNER JOIN [cust].tblScriptDefsMap c on c.ScriptDefID=b.ScriptDefID 
               CROSS APPLY b.ScriptDefs.nodes('/script_defs/script') Nodes(item) WHERE ISNULL(Nodes.item.value('(./@id)[1]','int'),'')= @scriptId AND ConfigurationID=@configurationId
END
GO


GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan,Abhishek Padinarapurayil
-- Create date: 5/09/2022
-- Description:	this will fetch the landsat value
--EXEC [dbo].[SP_GetLandSatValue] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetLandSatValue]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetLandSatValue]
END
GO
CREATE PROCEDURE [dbo].[sp_GetLandSatValue]
			@configurationId INT
					
AS
BEGIN
	IF EXISTS (select 1 from cust.tblmaps MP INNER JOIN cust.tblmapsmap mm on MP.mapid = mm.mapid WHERE MM.CONFIGURATIONID = @configurationId)
	BEGIN
		SELECT ISNULL((MAP.V.value('(map_package)[1]', 'nvarchar(50)')), 'temnaturalvue') AS LandSat
		FROM cust.tblmaps MP INNER JOIN cust.tblmapsmap mm on MP.mapid = mm.mapid
		OUTER APPLY MP.mapitems.nodes('maps') AS MAP(V)
		WHERE MM.CONFIGURATIONID = @configurationId
	END
	ELSE
	BEGIN
		Select 'temnaturalvue' as LandSat
	END
END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	get the language list and default language
-- Sample: EXEC [dbo].[SP_GetLanguagesOverride] 110
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetLanguagesOverride]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetLanguagesOverride]
END
GO

CREATE PROCEDURE [dbo].[SP_GetLanguagesOverride]
              @configurationId INT
     
       
AS

BEGIN

	  SELECT Global.value('(/global/language_set)[1]', 'varchar(max)') AS lang_list,
                        ISNULL(Nodes.item.value('(./@default)[1]','varchar(max)'),'') AS default_lang 
                        FROM cust.tblGlobal b 
                        CROSS APPLY b.Global.nodes('/global/language_set') Nodes(item) 
						INNER JOIN cust.tblGlobalMap c ON c.CustomID = b.CustomID 
                        WHERE c.ConfigurationID = @configurationId

END
GO


GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetLatestConfiguration]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetLatestConfiguration]
END
GO
CREATE PROC sp_GetLatestConfiguration 
@configurationDefinitionId INT
AS
BEGIN

select 
  tblConfigurations.*
from tblConfigurations
where configurationid = (
  select
    max(configurationid)
  from tblConfigurations
  where
    ConfigurationDefinitionID = @configurationDefinitionId
)

END

GO
GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- Description:	Returns config mapped records
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetMappedConfigurationRecords]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetMappedConfigurationRecords]
END
GO

CREATE PROCEDURE [dbo].[SP_GetMappedConfigurationRecords]
	@ConfigurationID int,
	@DataTable nvarchar(100),
	@primaryColumn nvarchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @theSql nvarchar(1000)
	DECLARE @mappingTable varchar(250)
	 SET @mappingTable = @DataTable + 'Map'
	   SET @theSql = 'SELECT DataTable.* '
	   SET @theSql = @theSql + 'FROM ' + @DataTable + ' AS DataTable '
	IF (@DataTable = 'dbo.tblwgimage')
	BEGIN
		 SET @theSql = @theSql + 'INNER JOIN ' + @DataTable + 'Map AS Mapping ON DataTable.' + @primaryColumn + ' = Mapping.Image' + @primaryColumn + ' '
	END
	ELSE
	BEGIN
	   SET @theSql = @theSql + 'INNER JOIN ' + @DataTable + 'Map AS Mapping ON DataTable.' + @primaryColumn + ' = Mapping.' + @primaryColumn + ' '
	END
	SET @theSql = @theSql + 'WHERE Mapping.ConfigurationID = ' + CAST(@ConfigurationID as nvarchar) +' AND Mapping.isDeleted=0'

	EXECUTE dbo.sp_executesql @theSql
END

GO
GO


DROP PROCEDURE IF EXISTS [dbo].[SP_GetMenus_UserId]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_GetMenus_UserId]
			@userId UNIQUEIDENTIFIER
			
AS
BEGIN
		--DECLARE @userId UNIQUEIDENTIFIER
		--SELECT @userId = Id FROM AspNetUsers WHERE UserName = @userName
		DROP TABLE IF EXISTS #TEMP_CLAIMS
		CREATE TABLE #TEMP_CLAIMS (ClaimID UNIQUEIDENTIFIER, Name NVARCHAR(max), Description NVARCHAR(max), Scope NVARCHAR(MAX))
		INSERT INTO #TEMP_CLAIMS EXEC SP_GetClaims_UserId @userId
		
		SELECT DISTINCT dbo.tblUserMenus.*, dbo.tblMenuClaims.AccessLevel FROM dbo.tblUserMenus 
		INNER JOIN dbo.tblMenuClaims ON dbo.tblUserMenus.MenuId = dbo.tblMenuClaims.MenuID 
		WHERE dbo.tblMenuClaims.ClaimID IN (SELECT ClaimID FROM #TEMP_CLAIMS)
END
GO



GO

DROP PROC IF EXISTS [dbo].[SP_GetMergeConfigurationTaskData]  
  GO
CREATE PROCEDURE [dbo].[SP_GetMergeConfigurationTaskData]  
 @configurationId INT  
AS  
BEGIN  
 SELECT task.ID,Name,TaskStatusID FROM tblTasks task INNER JOIN tblTaskType tType ON task.TaskTypeID=tType.ID  WHERE ConfigurationID = @configurationId AND  
 tType.Name in('ui merge configuration','PerformDataMerge') ORDER BY DateLastUpdated DESC

END  

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 09/14/2022
-- Description:	Get all modlist data for given configuration id
-- Sample EXEC [dbo].[SP_GetModlistData] 67, 0
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetModlistData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetModlistData]
END
GO

CREATE PROCEDURE [dbo].[SP_GetModlistData]
	@configurationId INT,
	@isDirty INT = 0
AS
BEGIN
		SELECT * FROM dbo.FN_GetModListValues(@configurationId, @isDirty) AS ModListData
END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================2
-- Author:		Abhishek PM
-- Create date:13 /1/2023
-- Description:	Get the partnumber collection id
-- Sample EXEC [dbo].[SP_GetPartNumberCollection] 5037
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetPartNumberCollection]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetPartNumberCollection]
END
GO

CREATE PROCEDURE [dbo].[SP_GetPartNumberCollection]
    @outputTypeID int 
	
    
AS
BEGIN
	
    select  PartNumberCollectionID from tblOutputTypes where OutputTypeID =@outputTypeID

END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================2
-- Author:		Abhishek PM
-- Create date:13 /1/2023
-- Description:	Get the partnumber collection id
-- Sample EXEC [dbo].[SP_GetPartNumberCollectionId] 5080
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetPartNumberCollectionId]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetPartNumberCollectionId]
END
GO

CREATE PROCEDURE [dbo].[SP_GetPartNumberCollectionId]
    @ConfigurationDefinitionId int 
	
    
AS
BEGIN
	DECLARE @configurationDefinitionParentID INT
    Set @configurationDefinitionParentID = (select configurationDefinitionParentID from tblConfigurationDefinitions where configurationDefinitionID = @configurationDefinitionID)
    select Distinct pn.PartNumberCollectionID from tblPartNumber as pn  inner join tblOutputTypes  
	as ot on pn.PartNumberCollectionID =ot.PartNumberCollectionID  inner join  tblConfigurationDefinitions as tc
	on  tc.OutputTypeID = ot.OutputTypeID where tc.ConfigurationDefinitionID = @configurationDefinitionParentID

END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Brinda
-- Create date: 01/31/2023
-- Description:	To get the partnumber id based on filename
-- Sample EXEC [dbo].[SP_GetPartnumberId] 'HD Briefings Config (hdbrfcfg)'
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetPartnumberId]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetPartnumberId]
END
GO

CREATE PROCEDURE [dbo].[SP_GetPartnumberId]
    
	@name NVARCHAR(255)
AS
BEGIN
    select PartNumberID from tblPartNumber where name = @name 
END
GO
GO

IF OBJECT_ID('[dbo].[SP_GetPendingTasks]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetPendingTasks]
END
GO

CREATE PROCEDURE [dbo].[SP_GetPendingTasks] 	
	 @ID  uniqueidentifier,	
	 @IDType nvarchar	 
AS
BEGIN
	DECLARE
		@sql   nvarchar(max)
		DECLARE @ReturnValue int
	BEGIN
	 
	 IF UPPER(@IDType) = 'USER'
		 BEGIN
			SELECT tblTasks.ID, tblTasks.TaskStatusID, tblTasks.DetailedStatus FROM dbo.tblTasks WHERE 
			StartedByUserID = @ID 
			and TaskStatusID NOT IN (Select ID from dbo.tblTaskStatus where [Name] in ('Complete'));		
		 END
	 --ELSE IF UPPER(@IDType) = 'AIRCRAFT'
		--BEGIN
		--	SELECT *  FROM dbo.tblTasks INNER JOIN [tblTaskData ] 			
		--	WHERE 
		--	StartedByUserID = @ID 
		--	and TaskStatusID NOT IN (Select ID from dbo.tblTaskStatus where [Name] in ('Complete'));
		--END
	END	
END

GO
GO

/****** Object:  StoredProcedure [dbo].[SP_getPlaceNameConflicts]    Script Date: 9/29/2022 6:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_getPlaceNameConflicts]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_getPlaceNameConflicts]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_getPlaceNameConflicts]    Script Date: 9/29/2022 6:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_getPlaceNameConflicts]
@taskId UNIQUEIDENTIFIER
AS
BEGIN

 DROP TABLE IF EXISTS #TEMP_PLACENAME_PARENT
  DROP TABLE IF EXISTS #TEMP_PLACENAME_CHILD
    DROP TABLE IF EXISTS #TEMP

CREATE TABLE #TEMP_PLACENAME_PARENT(ID INT,MergeChoice INT, SelectedKey INT,GeoRefId INT, Description nvarchar(max), CountryId INT,Country NVARCHAR(MAX), RegionId INT, Region nvarchar(max), CatTypeId INT, Category nvarchar(max), SpellingId INT, Translation nvarchar(max),LanguageId INT, LanguageName nvarchar(max), Lat1 decimal, Lat2 decimal, Lon1 decimal, Lon2 decimal, Resolution decimal, Exclude bit, Priority INT);
CREATE TABLE #TEMP_PLACENAME_CHILD(ID INT,MergeChoice INT, SelectedKey INT,GeoRefId INT, Description nvarchar(max), CountryId INT,Country NVARCHAR(MAX), RegionId INT,Region nvarchar(max),CatTypeId INT, Category nvarchar(max), SpellingId INT, Translation nvarchar(max), LanguageId INT, LanguageName nvarchar(max), Lat1 decimal, Lat2 decimal, Lon1 decimal, Lon2 decimal, Resolution decimal, Exclude bit, Priority INT);
 
SELECT ID,ChildKey,ParentKey,TableName,SelectedKey,MergeChoice INTO #TEMP FROM tblMergeDetails where MergeChoice NOT IN(1,3) AND TableName IN('tblGeoRef', 'tblCoverageSegment', 'tblSpelling', 'tblAppearance') AND TaskId = @taskId;
 
DECLARE @TableName varchar(50),@ParentKey INT,@ChildKey INT,@MergeChoice INT,@SelectedKey INT,@ID INT
 
DECLARE cur_tbl CURSOR 
 FOR
              SELECT ID,ChildKey,ParentKey,TableName,MergeChoice,SelectedKey
              FROM   #TEMP
 
                      OPEN cur_tbl
 
            FETCH next FROM cur_tbl INTO @ID,@ChildKey,@ParentKey,@TableName,@MergeChoice,@SelectedKey
                    --print @config_table
            WHILE @@FETCH_STATUS = 0
              BEGIN

                                 IF @TableName='tblGeoRef'
                                 BEGIN
									 INSERT INTO #TEMP_PLACENAME_PARENT(ID,MergeChoice,SelectedKey, GeoRefId, Description, Country, Region, Category) 
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId,geo.Description, ctry.Description, RegionName, cat.Description 
									 FROM tblGeoRef geo 
									 INNER JOIN tblCountry ctry on geo.CountryId = ctry.CountryID
									 INNER JOIN tblRegionSpelling spel on geo.RegionID=spel.RegionID and spel.LanguageId=1
									 INNER JOIN tblCategoryType cat on geo.AsxiCatTypeId = cat.CategoryTypeID
									 WHERE geo.ID in(@ParentKey);
 
									 INSERT INTO #TEMP_PLACENAME_CHILD(ID,MergeChoice,SelectedKey, GeoRefId, Description, Country, Region, Category) 
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId, geo.Description, ctry.Description, RegionName, cat.Description 
									 FROM tblGeoRef geo 
									 INNER JOIN tblCountry ctry on geo.CountryId = ctry.CountryID
									 INNER JOIN tblRegionSpelling spel on geo.RegionID=spel.RegionID and spel.LanguageId=1
									 INNER JOIN tblCategoryType cat on geo.AsxiCatTypeId = cat.CategoryTypeID
									 WHERE geo.ID in(@ChildKey);
                                 END

                                 IF @TableName='tblSpelling'
                                 BEGIN
									 INSERT INTO #TEMP_PLACENAME_PARENT(ID,MergeChoice,SelectedKey,GeoRefId,Description,Translation, LanguageName)
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId,geo.Description,spel.UnicodeStr,lang.Name 
									 FROM tblSpelling spel 
									 INNER JOIN tblGeoRef geo ON geo.GeoRefId=spel.GeoRefID 
									 INNER JOIN tblLanguages lang ON spel.LanguageID = lang.LanguageID
									 WHERE spel.SpellingID in(@ParentKey);
 
									 INSERT INTO #TEMP_PLACENAME_CHILD(ID,MergeChoice,SelectedKey,GeoRefId,Description,Translation, LanguageName)
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId,geo.Description,spel.UnicodeStr,lang.Name 
									 FROM tblSpelling spel 
									 INNER JOIN tblGeoRef geo ON geo.GeoRefId=spel.GeoRefID 
									 INNER JOIN tblLanguages lang ON spel.LanguageID = lang.LanguageID 
									 WHERE spel.SpellingID in(@ChildKey);
                                 END

								 IF @TableName = 'tblCoverageSegment'
								 BEGIN
									INSERT INTO #TEMP_PLACENAME_PARENT(ID,MergeChoice,SelectedKey,GeoRefId,Description,Lat1,Lat2,Lon1,Lon2)
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId,geo.Description,seg.Lat1,seg.Lat2,seg.Lon1,seg.Lon2 
									 FROM tblCoverageSegment seg 
									 INNER JOIN tblGeoRef geo ON geo.GeoRefId=seg.GeoRefID 
									 WHERE seg.ID in(@ParentKey);
 
									 INSERT INTO #TEMP_PLACENAME_CHILD(ID,MergeChoice,SelectedKey,GeoRefId,Description,Lat1,Lat2,Lon1,Lon2)
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId,geo.Description,seg.Lat1,seg.Lat2,seg.Lon1,seg.Lon2  
									 FROM tblCoverageSegment seg 
									 INNER JOIN tblGeoRef geo ON geo.GeoRefId=seg.GeoRefID 
									 WHERE seg.ID in(@ChildKey);
								 END

								 IF @TableName = 'tblAppearance'
								 BEGIN
									INSERT INTO #TEMP_PLACENAME_PARENT(ID,MergeChoice,SelectedKey,GeoRefId,Description,Resolution,Exclude,Priority)
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId,geo.Description,appear.Resolution,appear.Exclude,appear.Priority
									 FROM tblAppearance appear 
									 INNER JOIN tblGeoRef geo ON geo.GeoRefId=appear.GeoRefID 
									 WHERE appear.AppearanceID in(@ParentKey);
 
									 INSERT INTO #TEMP_PLACENAME_CHILD(ID,MergeChoice,SelectedKey,GeoRefId,Description,Resolution,Exclude,Priority)
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId,geo.Description,appear.Resolution,appear.Exclude,appear.Priority  
									 FROM tblAppearance appear
									 INNER JOIN tblGeoRef geo ON geo.GeoRefId=appear.GeoRefID 
									 WHERE appear.AppearanceID in(@ChildKey);
								 END
                           FETCH next FROM cur_tbl INTO @ID,@ChildKey,@ParentKey,@TableName,@MergeChoice,@SelectedKey
                      END
 
 CLOSE cur_tbl

            DEALLOCATE cur_tbl
--compare 2 tables and display the values
--select * from  #TEMP_PLACENAME_PARENT
--select * from  #TEMP_PLACENAME_CHILD
DECLARE @TEMP_RESULT TABLE(ID INT, GeoRefID INT, LanguageName NVARCHAR(MAX), [Key] NVARCHAR(MAX), Parent_value NVARCHAR(MAX), Child_value NVARCHAR(MAX))
INSERT INTO @TEMP_RESULT
 Select ID, GeoRefId, LanguageName, [key], Parent_Value = max( case when Src=1 then Value end), Child_Value = max( case when Src=2 then Value end)
 From ( Select Src=1, ID, GeoRefId, LanguageName, B.*
         From #TEMP_PLACENAME_PARENT A
         Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
		 B
        Union All
        Select Src=2, ID, GeoRefId, LanguageName, B.*
         From #TEMP_PLACENAME_CHILD A
         Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
		 B
      ) A
 Group By ID, GeoRefId, LanguageName, [key]
 Having max(case when Src=1 then Value end) <> max(case when Src=2 then Value end)
 Order By ID, [key]

-- SELECT * FROM #TEMP_RESULT

SELECT t.ID, t.GeoRefID AS ContentID, 'PlaceName' AS ContentType, g.Description AS Description, 
 CASE WHEN t.[Key] = 'Translation' THEN t.[key] + '(' + t.LanguageName + ')' ELSE t.[key] END AS DisplayName, 
 t.Parent_value AS ParentValue, t.Child_value AS ChildValue, 
 CASE WHEN m.SelectedKey = m.ParentKey THEN t.Parent_value  WHEN m.SelectedKey = m.ChildKey THEN t.Child_Value ELSE NULL END AS SelectedValue  
 FROM @TEMP_RESULT t, tblMergeDetails m, tblGeoRef g WHERE t.ID = m.ID AND t.GeoRefID = g.ID

END

GO

/****** Object:  StoredProcedure [dbo].[SP_getPlaceNameUpdates]    Script Date: 11/03/2022 12:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_getPlaceNameUpdates]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_getPlaceNameUpdates]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_getPlaceNameUpdates]    Script Date: 11/03/2022 12:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_getPlaceNameUpdates]
	@tableXml XML
AS
BEGIN

	DROP TABLE IF EXISTS #TEMP_PLACENAME_PARENT
	DROP TABLE IF EXISTS #TEMP_PLACENAME_CHILD
    DROP TABLE IF EXISTS #TEMP

	CREATE TABLE #TEMP_PLACENAME_PARENT(ID INT,GeoRefId INT, Description nvarchar(max), CountryId INT,Country NVARCHAR(MAX), RegionId INT, Region nvarchar(max), CatTypeId INT, Category nvarchar(max), SpellingId INT, Translation nvarchar(max),LanguageId INT, LanguageName nvarchar(max), Lat1 decimal, Lat2 decimal, Lon1 decimal, Lon2 decimal, Resolution decimal, Exclude bit, Priority INT, Action NVARCHAR(10));
	CREATE TABLE #TEMP_PLACENAME_CHILD(ID INT,GeoRefId INT, Description nvarchar(max), CountryId INT,Country NVARCHAR(MAX), RegionId INT,Region nvarchar(max),CatTypeId INT, Category nvarchar(max), SpellingId INT, Translation nvarchar(max), LanguageId INT, LanguageName nvarchar(max), Lat1 decimal, Lat2 decimal, Lon1 decimal, Lon2 decimal, Resolution decimal, Exclude bit, Priority INT, Action NVARCHAR(10));
 
	CREATE TABLE #TEMP (ID INT IDENTITY, TableName NVARCHAR(100), CurrentKey INT, PreviousKey INT, Action NVARCHAR(10))
	INSERT INTO #TEMP 
	SELECT Tbl.Col.value('@TableName', 'NVARCHAR(100)') AS TableName,  Tbl.Col.value('@CurrentKey', 'INT') AS CurrentKey,  
       Tbl.Col.value('@PreviousKey', 'INT') AS PreviousKey, Tbl.Col.value('@Action', 'NVARCHAR(10)') AS Action 
	FROM   @tableXml.nodes('//row') Tbl(Col) WHERE Tbl.Col.value('@TableName', 'NVARCHAR(100)') IN ('tblGeoRef', 'tblCoverageSegment', 'tblSpelling', 'tblAppearance');
 
	DECLARE @ID INT, @TableName VARCHAR(50),@ParentKey INT,@ChildKey INT, @Action NVARCHAR(10)

	DECLARE cur_tbl CURSOR 
	FOR
	SELECT ID,TableName,PreviousKey,CurrentKey,Action
	FROM   #TEMP WHERE Action = 'Update'
	
	OPEN cur_tbl
	FETCH next FROM cur_tbl INTO @ID,@TableName ,@ParentKey ,@ChildKey, @Action 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @TableName='tblGeoRef'
		BEGIN
			INSERT INTO #TEMP_PLACENAME_PARENT(ID, GeoRefId, Description, Country, Region, Category,Action) 
			SELECT @ID,geo.GeoRefId,geo.Description, ctry.Description, RegionName, cat.Description, @Action 
			FROM tblGeoRef geo 
			INNER JOIN tblCountry ctry on geo.CountryId = ctry.CountryID
			INNER JOIN tblRegionSpelling spel on geo.RegionID=spel.RegionID and spel.LanguageId=1
			INNER JOIN tblCategoryType cat on geo.AsxiCatTypeId = cat.CategoryTypeID
			WHERE geo.ID in(@ParentKey);
 
			INSERT INTO #TEMP_PLACENAME_CHILD(ID, GeoRefId, Description, Country, Region, Category,Action) 
			SELECT @ID,geo.GeoRefId, geo.Description, ctry.Description, RegionName, cat.Description, @Action 
			FROM tblGeoRef geo 
			INNER JOIN tblCountry ctry on geo.CountryId = ctry.CountryID
			INNER JOIN tblRegionSpelling spel on geo.RegionID=spel.RegionID and spel.LanguageId=1
			INNER JOIN tblCategoryType cat on geo.AsxiCatTypeId = cat.CategoryTypeID
			WHERE geo.ID in(@ChildKey);
		END

		IF @TableName='tblSpelling'
		BEGIN
			INSERT INTO #TEMP_PLACENAME_PARENT(ID,GeoRefId,Description,Translation, LanguageName,Action)
			SELECT @ID,geo.GeoRefId,geo.Description,spel.UnicodeStr,lang.Name, @Action 
			FROM tblSpelling spel 
			INNER JOIN tblGeoRef geo ON geo.GeoRefId=spel.GeoRefID 
			INNER JOIN tblLanguages lang ON spel.LanguageID = lang.LanguageID
			WHERE spel.SpellingID in(@ParentKey);
 
			INSERT INTO #TEMP_PLACENAME_CHILD(ID,GeoRefId,Description,Translation, LanguageName,Action)
			SELECT @ID,geo.GeoRefId,geo.Description,spel.UnicodeStr,lang.Name, @Action 
			FROM tblSpelling spel 
			INNER JOIN tblGeoRef geo ON geo.GeoRefId=spel.GeoRefID 
			INNER JOIN tblLanguages lang ON spel.LanguageID = lang.LanguageID 
			WHERE spel.SpellingID in(@ChildKey);
		END

		IF @TableName = 'tblCoverageSegment'
		BEGIN
		INSERT INTO #TEMP_PLACENAME_PARENT(ID,GeoRefId,Description,Lat1,Lat2,Lon1,Lon2,Action)
			SELECT @ID,geo.GeoRefId,geo.Description,seg.Lat1,seg.Lat2,seg.Lon1,seg.Lon2, @Action 
			FROM tblCoverageSegment seg 
			INNER JOIN tblGeoRef geo ON geo.GeoRefId=seg.GeoRefID 
			WHERE seg.ID in(@ParentKey);
 
			INSERT INTO #TEMP_PLACENAME_CHILD(ID,GeoRefId,Description,Lat1,Lat2,Lon1,Lon2,Action)
			SELECT @ID,geo.GeoRefId,geo.Description,seg.Lat1,seg.Lat2,seg.Lon1,seg.Lon2, @Action  
			FROM tblCoverageSegment seg 
			INNER JOIN tblGeoRef geo ON geo.GeoRefId=seg.GeoRefID 
			WHERE seg.ID in(@ChildKey);
		END

		IF @TableName = 'tblAppearance'
		BEGIN
		INSERT INTO #TEMP_PLACENAME_PARENT(ID,GeoRefId,Description,Resolution,Exclude,Priority,Action)
			SELECT @ID,geo.GeoRefId,geo.Description,appear.Resolution,appear.Exclude,appear.Priority, @Action
			FROM tblAppearance appear 
			INNER JOIN tblGeoRef geo ON geo.GeoRefId=appear.GeoRefID 
			WHERE appear.AppearanceID in(@ParentKey);
 
			INSERT INTO #TEMP_PLACENAME_CHILD(ID,GeoRefId,Description,Resolution,Exclude,Priority,Action)
			SELECT @ID,geo.GeoRefId,geo.Description,appear.Resolution,appear.Exclude,appear.Priority, @Action  
			FROM tblAppearance appear
			INNER JOIN tblGeoRef geo ON geo.GeoRefId=appear.GeoRefID 
			WHERE appear.AppearanceID in(@ChildKey);
		END
	FETCH NEXT FROM cur_tbl INTO @ID, @TableName, @ParentKey, @ChildKey, @Action
	END 
	CLOSE cur_tbl
	DEALLOCATE cur_tbl
	--compare 2 tables and display the values
	--select * from  #TEMP_PLACENAME_PARENT
	--select * from  #TEMP_PLACENAME_CHILD
	DECLARE @TEMP_RESULT TABLE(ID INT, GeoRefID INT, LanguageName NVARCHAR(MAX), [Key] NVARCHAR(MAX), Parent_value NVARCHAR(MAX), Child_value NVARCHAR(MAX), Action NVARCHAR(10))
	INSERT INTO @TEMP_RESULT
	 Select ID, GeoRefId, LanguageName, [key], Parent_Value = max( case when Src=1 then Value end), Child_Value = max( case when Src=2 then Value end), Action
	 From ( Select Src=1, ID, GeoRefId, LanguageName, Action, B.*
			 From #TEMP_PLACENAME_PARENT A
			 Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
			 B
			Union All
			Select Src=2, ID, GeoRefId, LanguageName, Action, B.*
			 From #TEMP_PLACENAME_CHILD A
			 Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
			 B
		  ) A
	 Group By ID, GeoRefId, LanguageName, [key], Action
	 Having max(case when Src=1 then Value end) <> max(case when Src=2 then Value end)
	 Order By ID, [key]

	-- SELECT * FROM #TEMP_RESULT

	SELECT t.GeoRefID AS ContentID, 'PlaceName' AS ContentType, g.Description AS Name,
	CASE WHEN t.[Key] = 'Translation' THEN t.[key] + '(' + t.LanguageName + ')' ELSE t.[key] END AS Field, 
	t.Parent_value AS PreviousValue, t.Child_value AS CurrentValue , Action
	FROM @TEMP_RESULT t, tblGeoRef g WHERE t.GeoRefID = g.ID
	UNION
	SELECT t.CurrentKey AS ContentID, 'PlaceName' AS ContentType, g.Description AS Name, NULL, NULL, NULL, t.Action
	FROM #TEMP t, tblGeoRef g WHERE t.CurrentKey = g.ID AND t.Action IN ('Insert', 'Delete') 
END

GO

GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetProductExport]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetProductExport]
END
GO
CREATE PROC sp_GetProductExport
@configurationId INT
AS
BEGIN

select 
  tblTasks.*,
  tblTaskType.Name
from tblTasks
  inner join tblTaskType on tblTaskType.ID = tblTasks.TaskTypeID
  inner join tblTaskStatus on tblTaskStatus.Id = tblTasks.TaskStatusID
where
  configurationId = @configurationID
  and tblTaskType.Name in ('Export Product Database - Thales', 'Export Product Database - PAC3D', 'Export Product Database - AS4XXX', 'Export Product Database - CESHTSE'
  ,'Venue Next','Venue Hybrid')
  and tblTaskStatus.Name not in ('Failed')

END

GO
GO

/****** Object:  StoredProcedure [dbo].[SP_getRegionConflicts]    Script Date: 9/29/2022 6:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_getRegionConflicts]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_getRegionConflicts]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_getRegionConflicts]    Script Date: 9/29/2022 6:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_getRegionConflicts]
@taskId UNIQUEIDENTIFIER
AS
BEGIN
 
  DROP TABLE IF EXISTS #TEMP_REGION_PARENT
  DROP TABLE IF EXISTS #TEMP_REGION_CHILD
    DROP TABLE IF EXISTS #TEMP

CREATE TABLE #TEMP_REGION_PARENT(ID INT,MergeChoice INT, SelectedKey INT,RegionId int,RegionSpellingId INT,Translation NVARCHAR(MAX),LanguageId int,LanguageName varchar(100));
CREATE TABLE #TEMP_REGION_CHILD(ID INT,MergeChoice INT, SelectedKey INT,RegionId int, RegionSpellingId INT,Translation NVARCHAR(MAX),LanguageId int,LanguageName varchar(100));
 
SELECT ID,ChildKey,ParentKey,TableName,SelectedKey,MergeChoice INTO #TEMP FROM tblMergeDetails where MergeChoice NOT IN(1,3) AND TableName IN('tblRegionSpelling') AND TaskId = @taskId;
 
DECLARE @TableName varchar(50),@ParentKey INT,@ChildKey INT,@MergeChoice INT,@SelectedKey INT,@ID INT
 
DECLARE cur_tbl CURSOR 
 FOR
              SELECT ID,ChildKey,ParentKey,TableName,MergeChoice,SelectedKey
              FROM   #TEMP
 
                      OPEN cur_tbl
 
            FETCH next FROM cur_tbl INTO @ID,@ChildKey,@ParentKey,@TableName,@MergeChoice,@SelectedKey
                    --print @config_table
            WHILE @@FETCH_STATUS = 0
              BEGIN
                              
                                 insert into #TEMP_REGION_PARENT(ID,MergeChoice,SelectedKey,regionId,Translation,LanguageName) 
                                 
                                                      SELECT @ID,@MergeChoice,@SelectedKey,spel.RegionID, RegionName,lang.Name FROM tblRegionSpelling spel 
                                 INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID 
                                 WHERE spel.SpellingID in(@ParentKey);
 
                                 insert into #TEMP_REGION_CHILD(ID,MergeChoice,SelectedKey,regionId,Translation,LanguageName)  
                                 
                                                      SELECT @ID,@MergeChoice,@SelectedKey,spel.RegionID,RegionName,lang.Name FROM tblRegionSpelling spel 
                                 INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID 
                                 WHERE spel.SpellingID in(@ChildKey);
 
                           FETCH next FROM cur_tbl INTO @ID,@ChildKey,@ParentKey,@TableName,@MergeChoice,@SelectedKey
                      END
 
 CLOSE cur_tbl

            DEALLOCATE cur_tbl
--compare 2 tables and display the values

DECLARE @TEMP_RESULT TABLE(ID INT, RegionID INT, LanguageName NVARCHAR(MAX), [Key] NVARCHAR(MAX), Parent_value NVARCHAR(MAX), Child_value NVARCHAR(MAX))
INSERT INTO @TEMP_RESULT
Select ID, RegionID, LanguageName, [key], Parent_Value = max( case when Src=1 then Value end), Child_Value = max( case when Src=2 then Value end)
From ( Select Src=1, ID, RegionID, LanguageName, B.*
         From #TEMP_REGION_PARENT A
         Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
               B
        Union All
        Select Src=2, ID, RegionID, LanguageName,B.*
         From #TEMP_REGION_CHILD A
         Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
               B
      ) A
Group By ID, RegionID, LanguageName, [key]
Having max(case when Src=1 then Value end) <> max(case when Src=2 then Value end)
Order By ID, [key]
 
--SELECT * FROM @TEMP_RESULT
 
SELECT t.ID, t.RegionID AS ContentID, 'Region' AS ContentType, r.RegionName AS Description, 
 CASE WHEN t.[Key] = 'Translation' THEN t.[key] + '(' + t.LanguageName + ')' ELSE t.[key] END AS DisplayName,
 t.Parent_value AS ParentValue, t.Child_value AS ChildValue, 
 CASE WHEN m.SelectedKey = m.ParentKey THEN t.Parent_value  WHEN m.SelectedKey = m.ChildKey THEN t.Child_Value ELSE NULL END AS SelectedValue 
 FROM @TEMP_RESULT t, tblMergeDetails m, tblRegionSpelling r WHERE t.ID = m.ID AND t.RegionID = r.RegionID AND r.LanguageId = 1 AND r.RegionName <> t.Parent_value
 
END

GO

/****** Object:  StoredProcedure [dbo].[SP_GetRegionUpdates]    Script Date: 11/02/2022 6:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_GetRegionUpdates]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_GetRegionUpdates]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetRegionUpdates]    Script Date: 11/02/2022 6:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_GetRegionUpdates]
	@tableXml XML
AS
BEGIN
 
	DROP TABLE IF EXISTS #TEMP_REGION_PARENT
	DROP TABLE IF EXISTS #TEMP_REGION_CHILD
    DROP TABLE IF EXISTS #TEMP

	CREATE TABLE #TEMP_REGION_PARENT(ID INT, RegionId INT,RegionSpellingId INT,Translation NVARCHAR(MAX),LanguageId int,LanguageName varchar(100),Action NVARCHAR(10));
	CREATE TABLE #TEMP_REGION_CHILD(ID INT, RegionId INT, RegionSpellingId INT,Translation NVARCHAR(MAX),LanguageId int,LanguageName varchar(100),Action NVARCHAR(10));
 
	CREATE TABLE #TEMP (ID INT IDENTITY, TableName NVARCHAR(100), CurrentKey INT, PreviousKey INT, Action NVARCHAR(10))
	INSERT INTO #TEMP 
	SELECT Tbl.Col.value('@TableName', 'NVARCHAR(100)') AS TableName,  Tbl.Col.value('@CurrentKey', 'INT') AS CurrentKey,  
       Tbl.Col.value('@PreviousKey', 'INT') AS PreviousKey, Tbl.Col.value('@Action', 'NVARCHAR(10)') AS Action 
	FROM   @tableXml.nodes('//row') Tbl(Col) WHERE Tbl.Col.value('@TableName', 'NVARCHAR(100)') IN ('tblRegionSpelling');
 
	DECLARE @ID INT, @TableName VARCHAR(50),@ParentKey INT,@ChildKey INT, @Action NVARCHAR(10)

	DECLARE cur_tbl CURSOR 
	FOR
	SELECT ID,TableName,PreviousKey,CurrentKey,Action
	FROM   #TEMP WHERE Action = 'Update'
	
	OPEN cur_tbl
	FETCH next FROM cur_tbl INTO @ID, @TableName ,@ParentKey ,@ChildKey, @Action 
	WHILE @@FETCH_STATUS = 0
	BEGIN                              
		INSERT INTO #TEMP_REGION_PARENT(ID, RegionId,Translation,LanguageName,Action) 
        SELECT @ID, spel.RegionID, RegionName,lang.Name,@Action FROM tblRegionSpelling spel 
		INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID 
		WHERE spel.SpellingID in(@ParentKey);
 
		INSERT INTO #TEMP_REGION_CHILD(ID, RegionId,Translation,LanguageName,Action)  
        SELECT @ID, spel.RegionID,RegionName,lang.Name,@Action FROM tblRegionSpelling spel 
		INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID 
		WHERE spel.SpellingID in(@ChildKey);
		
		FETCH NEXT FROM cur_tbl INTO @ID,@TableName, @ParentKey, @ChildKey, @Action
	END 
	CLOSE cur_tbl
	DEALLOCATE cur_tbl
	--compare 2 tables and display the values

	DECLARE @TEMP_RESULT TABLE(ID INT, RegionID INT, LanguageName NVARCHAR(MAX), [Key] NVARCHAR(MAX), Parent_value NVARCHAR(MAX), Child_value NVARCHAR(MAX), Action NVARCHAR(10))
	INSERT INTO @TEMP_RESULT
	SELECT ID, RegionID, LanguageName, [key], Parent_Value = max( case when Src=1 then Value end), Child_Value = max( case when Src=2 then Value end), Action
	FROM ( SELECT Src=1, ID, RegionID, LanguageName, Action, B.*
			 FROM #TEMP_REGION_PARENT A
			 CROSS APPLY (SELECT [Key], Value FROM OPENJSON((SELECT A.* For JSON PATH,WITHOUT_ARRAY_WRAPPER,INCLUDE_NULL_VALUES))) 
				   B
			UNION ALL
			SELECT Src=2, ID, RegionID, LanguageName, Action, B.*
			 FROM #TEMP_REGION_CHILD A
			 CROSS APPLY (SELECT [Key], Value FROM OPENJSON((SELECT A.* FOR JSON PATH,WITHOUT_ARRAY_WRAPPER,INCLUDE_NULL_VALUES))) 
				   B
		  ) A
	GROUP BY ID, RegionID, LanguageName, [key], Action
	HAVING MAX(CASE WHEN Src=1 THEN Value END) <> MAX(CASE WHEN Src=2 THEN Value END)
	ORDER BY ID, [key]
 
	--SELECT * FROM @TEMP_RESULT
 
	SELECT t.RegionID AS ContentID, 'Region' AS ContentType, r.RegionName AS Name, 
	CASE WHEN t.[Key] = 'Translation' THEN t.[key] + '(' + t.LanguageName + ')' ELSE t.[key] END AS Field,
	t.Parent_value AS PreviousValue, t.Child_value AS CurrentValue , t.Action
	FROM @TEMP_RESULT t, tblRegionSpelling r WHERE t.RegionID = r.RegionID AND r.LanguageId = 1 AND r.RegionName <> t.Parent_value
	UNION
	SELECT t.CurrentKey AS ContentID, 'Region' AS ContentType, r.RegionName AS Name, NULL, NULL, NULL, t.Action
	FROM #TEMP t, tblRegionSpelling r WHERE t.CurrentKey = r.RegionID AND r.LanguageId = 1 AND t.Action IN ('Insert', 'Delete')
END

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan,Abhishek Padinarapurayil
-- Create date: 5/24/2022
-- SAMPLE:[dbo].[SP_GetRoleClaim_Mapuser] '1A374C06-6B00-4853-86B1-7551534D6130','410D1BAA-B6E6-44EA-A230-D80E869905A1','DC0D5974-1E1B-4EDF-B4AB-3C82F8D3B143'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetRoleClaim_Mapuser]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetRoleClaim_Mapuser]
END
GO
CREATE PROCEDURE [dbo].[SP_GetRoleClaim_Mapuser]
			@roleId uniqueidentifier,
			@userId uniqueidentifier,
			@claimId uniqueidentifier
			
AS
BEGIN
		SELECT COUNT(*) FROM dbo.UserRoleAssignments INNER JOIN dbo.UserRoleClaims ON dbo.UserRoleAssignments.RoleID = dbo.UserRoleClaims.RoleID WHERE dbo.UserRoleAssignments.UserID = @userId AND dbo.UserRoleClaims.RoleID = @roleId AND dbo.UserRoleClaims.ClaimID = @claimId
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Mohan Abhishek Padinarapurayil
-- Create date: 5/24/2022
-- Description:	This query will return the roles based on userID
--Sample EXEC: SP_GetRolesByUserId '410D1BAA-B6E6-44EA-A230-D80E869905A1'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetRolesByUserId]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetRolesByUserId]
END
GO
CREATE PROCEDURE [dbo].[SP_GetRolesByUserId]
			@userId uniqueidentifier
			
AS
BEGIN
		
		SELECT * FROM dbo.UserRoles INNER JOIN dbo.UserRoleAssignments ON dbo.UserRoles.ID = dbo.UserRoleAssignments.RoleID WHERE dbo.UserRoleAssignments.UserID = @userId
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Mohan Abhishek Padinarapurayil	
-- Create date: 5/24/2022
-- Description:	this will return column names based on the table name given
--Sample EXEC: [dbo].[SP_GetScopeValueForUser]
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetScopeValueForUser]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetScopeValueForUser]
END
GO
CREATE PROCEDURE [dbo].[SP_GetScopeValueForUser]		
AS
BEGIN

		SELECT Column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'UserRoleClaims'
		
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan Abhishek Padinarapurayil
-- Create date: 5/25/2022
-- Description:	This will select the scoptype that is sent as a parameter  based on the userId and ClaimID
--Sample EXEC: EXEC SP_GetScopeValueForUserinput '4dbed025-b15f-4760-b925-34076d13a10a', '65faa542-665b-41ff-8cda-b2fa05b41176'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetScopeValueForUserinput]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_GetScopeValueForUserinput]
END
GO
CREATE PROCEDURE [dbo].[SP_GetScopeValueForUserinput]
   @userId uniqueidentifier,
   @claimId uniqueidentifier

AS
BEGIN
  SELECT dbo.UserRoleClaims.OperatorID FROM dbo.UserRoleClaims
         INNER JOIN dbo.UserRoleAssignments on UserRoleClaims.RoleID = dbo.UserRoleAssignments.RoleID
         AND dbo.UserRoleClaims.ClaimID =@claimId AND dbo.UserRoleAssignments.UserID =@userId 

END

GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan Abhishek Padinarapurayil
-- Create date: 5/25/2022
--description : This query will return the particular UserRoleClaimID that is passed as a parameter based on the roleId and ClaimID
--Sample EXEC:   EXEC [dbo].[SP_Getscopevalue_Claims] 'D3CC19CD-F347-4FAE-A03C-31EA39478282','7C08EC0E-1916-4C61-B386-FB817FF4A8AE','AircraftID'
-- =============================================
IF OBJECT_ID('[dbo].[SP_Getscopevalue_Claims]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_Getscopevalue_Claims]
END
GO
CREATE PROCEDURE [dbo].[SP_Getscopevalue_Claims]
			@roleId  uniqueidentifier,
			@claimId uniqueidentifier,
			@param NVARCHAR(300)
			
AS
BEGIN
		DECLARE @sql NVARCHAR(MAX)
		IF(@param ='AircraftID')
		BEGIN
		SELECT dbo.UserRoleClaims.AircraftID FROM dbo.UserRoleClaims 
        left join dbo.UserClaims on UserClaims.ID = dbo.UserRoleClaims.ClaimID  
        WHERE dbo.UserRoleClaims.RoleID =@roleId AND dbo.UserRoleClaims.ClaimID =@claimId
		END
		ELSE IF(@param ='OperatorID')
		BEGIN
		SELECT dbo.UserRoleClaims.OperatorID FROM dbo.UserRoleClaims 
        left join dbo.UserClaims on UserClaims.ID = dbo.UserRoleClaims.ClaimID  
        WHERE dbo.UserRoleClaims.RoleID =@roleId AND dbo.UserRoleClaims.ClaimID =@claimId
		END
		ELSE IF(@param ='ConfigurationDefinitionID')
		BEGIN
		SELECT dbo.UserRoleClaims.ConfigurationDefinitionID FROM dbo.UserRoleClaims 
        left join dbo.UserClaims on UserClaims.ID = dbo.UserRoleClaims.ClaimID  
        WHERE dbo.UserRoleClaims.RoleID =@roleId AND dbo.UserRoleClaims.ClaimID =@claimId
		END
		ELSE IF(@param ='UserRoleID')
		BEGIN
		SELECT dbo.UserRoleClaims.UserRoleID FROM dbo.UserRoleClaims 
        left join dbo.UserClaims on UserClaims.ID = dbo.UserRoleClaims.ClaimID  
        WHERE dbo.UserRoleClaims.RoleID =@roleId AND dbo.UserRoleClaims.ClaimID =@claimId
		END
END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Brinda
-- Create date:6/1/2022
-- Description:	this will return xmlitem based on condition from cust.tblScriptdefs
-- Sample: EXEC [dbo].[SP_GetScriptItems] 1,1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetScriptItems]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetScriptItems]
END
GO

CREATE PROCEDURE [dbo].[SP_GetScriptItems]
        @ConfigurationID INT,
		@scriptId  INT
       
AS

BEGIN
                             select item.query('.') AS xmlItem
                             FROM cust.tblScriptDefs b INNER JOIN [cust].tblScriptDefsMap c on c.ScriptDefID=b.ScriptDefID 
                             CROSS APPLY b.ScriptDefs.nodes('/script_defs/script') test(item)
                              WHERE ConfigurationID=@ConfigurationID 
                             and ISNULL(item.value('(./@id)[1]','varchar(max)'),'')=@scriptId
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Brinda	
-- Create date: 6/1/2022
-- Description:	get the scripttype based on configurationId and scrriptid
-- Sample: EXEC [dbo].[SP_GetScriptItemsByScript] 36,4
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetScriptItemsByScript]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetScriptItemsByScript]
END
GO

CREATE PROCEDURE [dbo].[SP_GetScriptItemsByScript]
        @configurationId INT,
		@scriptId INT
       
AS

BEGIN

           select ISNULL(Nodes.item.value('(./@type)[1]','varchar(max)'),'') AS scriptType
            FROM cust.tblScriptDefs b INNER JOIN [cust].tblScriptDefsMap c on c.ScriptDefID=b.ScriptDefID 
            CROSS APPLY b.ScriptDefs.nodes('/script_defs/script/item') Nodes(item) WHERE ConfigurationID=@configurationId 
            AND ISNULL(Nodes.item.value('(../@id)[1]','varchar(max)'),'')=@scriptId
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	get the name and display name from table getscriptitemtypes
-- Sample: EXEC [dbo].[SP_GetScriptItemTypes] 112
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetScriptItemTypes]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetScriptItemTypes]
END
GO

CREATE PROCEDURE [dbo].[SP_GetScriptItemTypes]
       
       @configurationID INT
AS

BEGIN

	 DECLARE @featuresetID INT
	   SET @featuresetID =( SELECT DISTINCT dbo.tblFeatureSet.FeatureSetID 
         FROM dbo.tblFeatureSet INNER JOIN dbo.tblConfigurationDefinitions ON dbo.tblFeatureSet.FeatureSetID = dbo.tblConfigurationDefinitions.FeatureSetID 
         INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionID
         AND dbo.tblConfigurations.ConfigurationID = @configurationId)

       SELECT *  
               FROM   
             (SELECT dbo.tblFeatureSet.Value as Name  
               FROM dbo.tblFeatureSet  
               WHERE dbo.tblFeatureSet.Name = 'CustomConfig-OverheadAutoplay-ScriptList'  AND dbo.tblFeatureSet.FeatureSetID = @featuresetID) as Nametable ,
                (SELECT dbo.tblFeatureSet.Value as DisplayName  
               FROM dbo.tblFeatureSet  
               WHERE dbo.tblFeatureSet.Name = 'CustomConfig-OverheadAutoplay-ScriptDisplayList'  AND dbo.tblFeatureSet.FeatureSetID = @featuresetID) as DisplayNameTable
END
GO



GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Aiyappa, Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	get the script based on configurationId
-- Sample: EXEC [dbo].[SP_GetScripts] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetScripts]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetScripts]
END
GO

CREATE PROCEDURE [dbo].[SP_GetScripts]
        @configurationId INT
       
AS

BEGIN

                  SELECT ISNULL(Nodes.item.value('(./@name)[1]','varchar(max)'),'') AS name ,
                  ISNULL(Nodes.item.value('(./@id)[1]','int'),'') AS id 
                  FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID
                  CROSS APPLY b.ScriptDefs.nodes('/script_defs/script') Nodes(item) WHERE ConfigurationID  = @configurationId
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa,Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	returns the row based on combined string
-- Sample: EXEC [dbo].[SP_GetSelectLangOverride] 67,2
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetSelectLangOverride]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_GetSelectLangOverride]

END

GO

CREATE PROCEDURE [dbo].[SP_GetSelectLangOverride]
                        @configurationId Int,
						@scriptId Int
                      
                       

AS

BEGIN

	     SELECT ISNULL(Nodes.item.value('(./@forced_langs)[1]','varchar(max)'),'') AS forced_lang
          FROM cust.tblScriptDefs b INNER JOIN [cust].tblScriptDefsMap c on c.ScriptDefID=b.ScriptDefID
          CROSS APPLY b.ScriptDefs.nodes('/script_defs/script') Nodes(item) WHERE ISNULL(Nodes.item.value('(./@id)[1]','int'),'')= @scriptId AND ConfigurationID=@configurationId
			
END

GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa,Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	returns the row based on combined string
-- Sample: EXEC [dbo].[SP_GetSelectLangOverrideCombinedString] 'English,French,Spanish,Simp_chinese'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetSelectLangOverrideCombinedString]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_GetSelectLangOverrideCombinedString]

END

GO

CREATE PROCEDURE [dbo].[SP_GetSelectLangOverrideCombinedString]
                       @combindedString NVARCHAR(250)
                      
                       

AS

BEGIN
               SELECT LOWER(dbo.tblLanguages.Name),[2LetterID_4xxx] FROM dbo.tblLanguages
               WHERE LOWER(dbo.tblLanguages.Name) IN(SELECT Item
               FROM dbo.SplitString(@combindedString, ',') )
			
END

GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Abhishek Mohan
-- Create date: 3/31/2023
-- Description:	get Task Details
--Sample: EXEC [dbo].[SP_GetTask_Status] 1,'en'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetTask_Status]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetTask_Status]
END
GO

CREATE PROCEDURE [dbo].[SP_GetTask_Status]
        @TaskTypeID NVARCHAR(Max),
		@userId NVARCHAR(Max)
		
       
AS

BEGIN
    select * from tblTasks where StartedByUserID =@userId and TaskTypeID =@TaskTypeID and TaskStatusID IN(1,2)
END
GO


GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================2
-- Author:		Abhishek PM
-- Create date:13 /1/2023
-- Description:	Get the partnumber collection id
-- Sample EXEC [dbo].[SP_GetToplevelPartNumber] 5037
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetToplevelPartNumber]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetToplevelPartNumber]
END
GO

CREATE PROCEDURE [dbo].[SP_GetToplevelPartNumber]
    @configurationDefnitionID int 
	
    
AS
BEGIN
	
    SELECT Products.TopLevelPartnumber from dbo.tblProducts AS Products 
        INNER JOIN dbo.tblProductConfigurationMapping AS Product 
        ON  Products.ProductID = Product.ProductID Where Product.ConfigurationDefinitionID = @configurationDefnitionID

END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Aiyappa, Brinda Chindamada		
-- Create date: 5/25/2022
-- Description:	This sp will return name,condition,type based on configurationid
-- Sample: EXEC [dbo].[SP_GetTriggers] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetTriggers]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetTriggers]
END
GO

CREATE PROCEDURE [dbo].[SP_GetTriggers]
        @configurationId INT
       
AS

BEGIN
        SELECT DISTINCT
                isnull(Nodes.TriggerItem.value('(./@name)[1]', 'varchar(max)'),'') as Name,
                isnull(Nodes.TriggerItem.value('(./@condition)[1]', 'varchar(max)'),'') as Condition,
                isnull(Nodes.TriggerItem.value('(./@id)[1]', 'varchar(max)'),'') as Id,
                isnull(Nodes.TriggerItem.value('(./@type)[1]', 'varchar(max)'),'') as Type,
                isnull(Nodes.TriggerItem.value('(./@default)[1]', 'varchar(max)'),'false') as IsDefault
                FROM cust.tblTrigger as T
                cross apply T.TriggerDefs.nodes('/trigger_defs/trigger') as Nodes(TriggerItem)
                INNER JOIN cust.tblTriggerMap ON cust.tblTriggerMap.TriggerID = T.TriggerID 
                AND cust.tblTriggerMap.ConfigurationID = @configurationId
       
END
GO



GO

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



GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Mohan
-- Create date: 05/17/2022
-- Description:	checks if an update is available
-- Sample EXEC [dbo].[SP_GetUpdatesAvailable] 1,1
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetUpdatesAvailable]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetUpdatesAvailable]
END
GO

CREATE PROCEDURE [dbo].[SP_GetUpdatesAvailable]
	@configurationDefinitionID INT,
	@configurationId INT
AS
BEGIN
	DECLARE @version INT
	DECLARE @returnTable TABLE(updatesAvailable BIT, updateType NVARCHAR(250))

	DECLARE @parentVersion INT
	DECLARE @ChildVersion INT,@parentDefId INT,@parentConfigurationId INT

	SELECT @parentDefId=ConfigurationDefinitionParentID FROM tblConfigurationDefinitions WHERE ConfigurationDefinitionID=@configurationDefinitionID AND ConfigurationDefinitionParentID>0 AND ConfigurationDefinitionParentID!=ConfigurationDefinitionID

	SELECT @parentConfigurationId = MAX(ConfigurationID) FROM tblconfigurations WHERE ConfigurationDefinitionID = @parentDefId AND Locked = 1

	SELECT @parentVersion=(CASE WHEN MAX(C.version)>ISNULL(CD.UpdatedUpToVersion, 0) THEN MAX(version) ELSE ISNULL(CD.UpdatedUpToVersion, 0) END) 
	FROM tblConfigurations C INNER JOIN tblConfigurationDefinitions CD ON c.ConfigurationDefinitionID=cd.ConfigurationDefinitionID
	WHERE cd.ConfigurationDefinitionID=@parentDefId AND c.Locked=1 GROUP BY c.ConfigurationDefinitionID,CD.UpdatedUpToVersion

	SELECT @ChildVersion= ISNULL(CD.UpdatedUpToVersion, 0)  
	FROM tblConfigurations C INNER JOIN tblConfigurationDefinitions CD ON c.ConfigurationDefinitionID=cd.ConfigurationDefinitionID
	WHERE cd.ConfigurationDefinitionID=@configurationDefinitionID AND c.Locked=1 GROUP BY c.ConfigurationDefinitionID,CD.UpdatedUpToVersion

	DECLARE @mergeDate DATETIME
	IF @parentVersion > @ChildVersion --Either Updates Available or Pending
	BEGIN
		--Either PopulateMergeDetails or Perform Data Merge is in progress
		IF EXISTS (SELECT 1 FROM tblTasks WHERE configurationId = @configurationId AND TaskTypeID IN (SELECT ID FROM tblTaskType WHERE Name in('UI Merge Configuration','PerformDataMerge'))
		AND TaskStatusID IN (1,2)) 
		BEGIN
			INSERT INTO @returnTable VALUES(1, 'Updates Pending')
		END
		--Once PopulateMergeDetails is completed, Check Perform Data Merge status based on PopulateMergeDetails date and parent configurationId
		ELSE IF EXISTS (SELECT 1 FROM tblTasks WHERE ConfigurationID = @configurationId AND TaskTypeID IN (SELECT ID FROM tblTaskType WHERE Name = 'UI Merge Configuration') AND TaskStatusID = 4 AND TaskDataJSON LIKE '%' + CAST(@parentConfigurationId AS NVARCHAR) + '%')
		BEGIN
			SET @mergeDate = (SELECT TOP 1 DateStarted FROM tblTasks WHERE ConfigurationID = @configurationId AND TaskTypeID IN (SELECT ID FROM tblTaskType WHERE Name = 'UI Merge Configuration') AND TaskStatusID = 4
									AND TaskDataJSON LIKE '%' + CAST(@parentConfigurationId AS NVARCHAR) + '%' ORDER BY DateLastUpdated DESC)
			--Either Perform Data Merge is in progress or not initiated 
			IF NOT EXISTS (SELECT 1 FROM tblTasks WHERE ConfigurationID = @configurationId AND TaskTypeID IN (SELECT ID FROM tblTaskType WHERE Name = 'PerformDataMerge') AND DateStarted > @mergeDate AND TaskStatusID = 4)
			BEGIN
				INSERT INTO @returnTable VALUES(1, 'Updates Pending')
			END
			--Perform Data Merge also got completed
			ELSE
			BEGIN
				INSERT INTO @returnTable VALUES(1, 'Updates Available')
			END
		END
		--Populate Merge Details task itself not initiated
		ELSE
		BEGIN
			INSERT INTO @returnTable VALUES(1, 'Updates Available')
		END
	END
	--No Updates Available
	ELSE
	BEGIN
		INSERT INTO @returnTable VALUES(0, 'Updates Available')
	END
    SELECT * FROM @returnTable
	END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Mohan Abhishek Padinarapurayil
-- Create date: 5/24/2022
-- Description:	this query selects the number of rows from aspNetUsers based on the condition and roleID
--Sample EXEC: exec [dbo].[SP_GetUserByRoleId] '512661BD-A474-4BE5-942A-401FEAE04A65'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetUserByRoleId]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetUserByRoleId]
END
GO
CREATE PROCEDURE [dbo].[SP_GetUserByRoleId]
			@roleId uniqueidentifier
			
AS
BEGIN
		
		SELECT * FROM dbo.AspNetUsers INNER JOIN dbo.UserRoleAssignments ON dbo.AspNetUsers.Id = dbo.UserRoleAssignments.UserID WHERE dbo.UserRoleAssignments.RoleID = @roleId
		
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan,Abhishek Padinarapurayil
-- Create date: 5/24/2022
-- Description:	return number of rows based on the ObjectFieldname  and based on given objectID ,manageclaimID and ViewClaimID
--Sample EXEC:exec [dbo].[SP_Getuserby_Object] '71E1A0FD-091A-441C-AA29-21F811951AD3','7C08EC0E-1916-4C61-B386-FB817FF4A8AE','7C08EC0E-1916-4C61-B386-FB817FF4A8AE','AircraftID'
-- =============================================
IF OBJECT_ID('[dbo].[SP_Getuserby_Object]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_Getuserby_Object]
END
GO
CREATE PROCEDURE [dbo].[SP_Getuserby_Object]
			@objectID  uniqueidentifier,
			@manageClaimId uniqueidentifier,
			@viewClaimId uniqueidentifier,
			 @objectIDFieldName NVARCHAR(300)
AS
BEGIN
		DECLARE @sql NVARCHAR(MAX)
		DECLARE @params NVARCHAR(4000) = '@manageClaimId VARCHAR(255), @viewClaimId VARCHAR(255),@objectID VARCHAR(255)'
		SET  @sql =' SELECT DISTINCT dbo.AspNetUsers.ID, dbo.AspNetUsers.DateCreated ,dbo.AspNetUsers.DateModified, dbo.AspNetUsers.Fax, dbo.AspNetUsers.FirstName,    dbo.AspNetUsers.IsDeleted, dbo.AspNetUsers.IsPasswordChangeRequired, dbo.AspNetUsers.IsRememberMe, dbo.AspNetUsers.IsSubscribedForNewsLetter, dbo.AspNetUsers.IsSystemuser, dbo.AspNetUsers.LastName, dbo.AspNetUsers.Company, dbo.AspNetUsers.LastResetDate, dbo.AspNetUsers.ModifiedBy, dbo.AspNetUsers.ResetToken, dbo.AspNetUsers.ResetTokenExpirationTime, dbo.AspNetUsers.SelectedOperatorId, dbo.AspNetUsers.Email, dbo.AspNetUsers.EmailConfirmed, dbo.AspNetUsers.PasswordHash, dbo.AspNetUsers.SecurityStamp, dbo.AspNetUsers.PhoneNumber,dbo.AspNetUsers.PhoneNumberConfirmed, dbo.AspNetUsers.TwoFactorEnabled, dbo.AspNetUsers.LockoutEndDateUtc, dbo.AspNetUsers.LockoutEnabled, dbo.AspNetUsers.AccessFailedCount, dbo.AspNetUsers.UserName FROM (dbo.AspNetUsers INNER JOIN dbo.UserRoleAssignments ON dbo.AspNetUsers.Id = dbo.UserRoleAssignments.UserID) 
              INNER JOIN dbo.UserRoleClaims ON dbo.UserRoleAssignments.RoleID = dbo.UserRoleClaims.RoleID  
               WHERE (dbo.UserRoleClaims.ClaimID = @manageClaimId  OR dbo.UserRoleClaims.ClaimID =@viewClaimId )
               AND (dbo.UserRoleClaims.'+ @objectIDFieldName + ' =@objectID OR dbo.UserRoleClaims.' + @objectIDFieldName + ' IS NULL) AND (dbo.AspNetUsers.IsDeleted = 0)'
        --print @sql
        EXEC sys.Sp_executesql @sql ,@params,@manageClaimId = @manageClaimId,@viewClaimId = @viewClaimId,@objectID=@objectID

END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Mohan Abhishek Padinarapurayil		
-- Create date: 5/24/2022
-- Description:	this query returns all the userroleclaims from the UserRoleClaims table based on the RoleID and ClamID given
--Sample EXEC:SP_GetUserRoleClaims 'D3CC19CD-F347-4FAE-A03C-31EA39478282','7C08EC0E-1916-4C61-B386-FB817FF4A8AE'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetUserRoleClaims]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetUserRoleClaims]
END
GO
CREATE PROCEDURE [dbo].[SP_GetUserRoleClaims]
			@roleId uniqueidentifier,
			@claimId uniqueidentifier
			
AS
BEGIN
		
		SELECT dbo.UserRoleClaims.*, dbo.UserClaims.Name FROM dbo.UserRoleClaims 
        left join dbo.UserClaims on UserClaims.ID = dbo.UserRoleClaims.ClaimID 
        WHERE dbo.UserRoleClaims.RoleID = @roleId AND dbo.UserRoleClaims.ClaimID = @claimId
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan,Abhishek Padinarapurayil
-- Create date: 5/27/2022
-- Description:	this query will return total number of count from dbo.UserRoleAssignments table based on the RoleID,UserId ,and ClaimId given
--Sample EXEC:EXEC [dbo].[SP_GetUserRoleClaimsby_RoleclaimId] '5A99A6B6-B8A3-45D1-A6DF-FB6DA8F51EDE','68B6EEE4-9439-4FA2-ABF4-C597E63CA983','DC0D5974-1E1B-4EDF-B4AB-3C82F8D3B143'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetUserRoleClaimsby_RoleclaimId]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetUserRoleClaimsby_RoleclaimId]
END
GO
CREATE PROCEDURE [dbo].[SP_GetUserRoleClaimsby_RoleclaimId]
			@roleId  uniqueidentifier,
			@userId uniqueidentifier,
			@claimId uniqueidentifier
AS
BEGIN
		SELECT COUNT(*) FROM dbo.UserRoleAssignments INNER JOIN dbo.UserRoleClaims ON dbo.UserRoleAssignments.RoleID = dbo.UserRoleClaims.RoleID WHERE dbo.UserRoleAssignments.UserID = @userId AND dbo.UserRoleClaims.RoleID = @roleId AND dbo.UserRoleClaims.ClaimID = @claimId
		
END
GO
GO


-- =============================================
-- Author:		Sathya
-- Create date: 14/07/2022
-- Description:	Returns url for timezone and venue next scripts url
-- =============================================
GO
IF OBJECT_ID('[dbo].[SP_getVenueNextArtifacts]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_getVenueNextArtifacts]
END

GO
CREATE PROC SP_getVenueNextArtifacts
@configurationId INT
AS
BEGIN
SELECT ConfigurationComponentID,Path,ConfigurationComponentTypeID,Name FROM [dbo].[config_tblConfigurationComponents](@configurationId) WHERE ConfigurationComponentTypeID IN(4,10)
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetVersionUpdates]    Script Date: 9/29/2022 6:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_GetVersionUpdates]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_GetVersionUpdates]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetVersionUpdates]    Script Date: 9/29/2022 6:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================  
-- Author:      Logeshwaran Sivaraj  
-- Create date: 9/29/2022  
-- Description: Retrieves all the data which are updated
--				based on the ConfigurationId  
-- Sample EXEC [dbo].[SP_GetVersionUpdates] 2
-- =======================================================  

CREATE PROCEDURE [dbo].[SP_GetVersionUpdates]
    @ConfigurationId int 
	   
AS
BEGIN

	DECLARE @configurationDefinitionID INT 
	DECLARE @currentConfigurationID INT = @ConfigurationId
	DECLARE @previousConfigurationID INT
	SELECT @ConfigurationDefinitionId = ConfigurationDefinitionID FROM tblConfigurations WHERE ConfigurationID = @currentConfigurationID
	DECLARE @currentVersion INT
	SELECT @currentVersion = Version FROM tblConfigurations WHERE ConfigurationID = @currentConfigurationID
	SELECT @previousConfigurationID = ConfigurationID FROM tblConfigurations WHERE Version = @currentVersion - 1 AND ConfigurationDefinitionID = @configurationDefinitionID
	--Compare with previous version configuration
	IF @previousConfigurationID IS NOT NULL
	BEGIN	
		DECLARE @sql_query NVARCHAR(MAX)
		DECLARE @tempConfigTables TABLE(id INT IDENTITY NOT NULL, tableName NVARCHAR(100))
		INSERT INTO @tempConfigTables SELECT tblName FROM tblConfigTables WHERE IsUsedForMergeConfiguration = 1
		DECLARE @cnt INT
		DECLARE @cnt_total INT
		SELECT @cnt = MIN(id) , @cnt_total = MAX(id) FROM @tempConfigTables
		DECLARE @config_table VARCHAR(100), @sqlUpdateStatement NVARCHAR(MAX), @sqlDeleteStatement NVARCHAR(MAX), @sqlInsertStatement NVARCHAR(MAX)
		DECLARE @mapTable VARCHAR(MAX), @mapColumn VARCHAR(100), @dataColumn VARCHAR(100), @mapSchema VARCHAR(100)
		DROP TABLE IF EXISTS #tempUpdates
		CREATE TABLE #tempUpdates(TableName NVARCHAR(100), CurrentKey INT, PreviousKey INT, Action NVARCHAR(100));
		WHILE @cnt <= @cnt_total
		BEGIN
			SELECT @config_table = tableName FROM @tempConfigTables WHERE id = @cnt
			SET @mapTable = @config_table + 'Map'
			EXEC dbo.Sp_configmanagement_findmappingbetween @mapTable, @config_table, @mapColumn output, @dataColumn output, @mapSchema output
		
			-- Inserting data when current configuration data is changed
			SET @sqlUpdateStatement = 'INSERT INTO #tempUpdates (TableName, CurrentKey, PreviousKey, Action)
					SELECT ''' + @config_table + ''',' + 'source.' + @mapColumn + ',' + 
					'destination.' + @mapColumn + ', ''Update'' FROM
					' + @mapSchema + '.' + @mapTable + '(NOLOCK) destination INNER JOIN ' + @mapSchema + '.' + @mapTable + '(NOLOCK) source ON 
					source.Previous' + @mapColumn + ' = destination.'+ @mapColumn +' AND source.configurationid = '''+
					CAST(@currentConfigurationID AS NVARCHAR) +''' AND destination.configurationId =''' + CAST(@previousConfigurationID AS NVARCHAR) + '''
					AND destination.' + @mapColumn + ' <> source.'+ @mapColumn +';';

			EXEC (@sqlUpdateStatement)

			-- Inserting data when current configuration data is deleted
			SET @sqlDeleteStatement = 'INSERT INTO #tempUpdates (TableName, CurrentKey, PreviousKey, Action)
					SELECT ''' + @config_table + ''',' + 'source.' + @mapColumn + ',' + 'destination.'+ @mapColumn + ',
					''Delete'' FROM  '+ @mapSchema + '.' + @mapTable +'  (NOLOCK) destination INNER JOIN '+ @mapSchema + '.' + @mapTable +'
					(NOLOCK) source ON source.' + @mapColumn + ' = destination.' + @mapColumn + ' AND source.configurationId = ''' + 
					Cast(@currentConfigurationID AS NVARCHAR) + ''' AND source.isDeleted = 1 AND 
					destination.configurationId IN(''' + Cast(@previousConfigurationID AS NVARCHAR) + ''');';

			EXEC (@sqlDeleteStatement)

			-- Inserting data when new data is added to current configuration
			SET @sqlInsertStatement = 'INSERT INTO #tempUpdates (TableName, CurrentKey, PreviousKey, Action)
					SELECT ''' + @config_table + ''',' + @mapColumn + ',' + 'NULL, ''Insert'' FROM ' + @mapSchema + '.' + @mapTable +  
					' (NOLOCK) WHERE ConfigurationID = ' + Cast(@currentConfigurationID AS NVARCHAR) + ' AND '+ 'Previous' + @mapColumn + ' = 0 AND IsDeleted = 0
					EXCEPT
					SELECT ''' + @config_table + ''',' + @mapColumn + ',' + 'NULL, ''Insert'' FROM ' + @mapSchema + '.' + @mapTable +  
					' (NOLOCK) WHERE ConfigurationID = ' + Cast(@previousConfigurationID AS NVARCHAR) + ' AND '+ 'Previous' + @mapColumn + ' = 0 AND IsDeleted = 0'

			EXEC (@sqlInsertStatement)
			SET @cnt = @cnt + 1
		END

		DECLARE @tableXML XML 
		SET @tableXML = (SELECT * FROM #tempUpdates FOR XML RAW);
		--SELECT @tableXML
		DROP TABLE IF EXISTS #TEMP_RESULT
		CREATE TABLE #TEMP_RESULT (ContentID INT, ContentType NVARCHAR(max), Name NVARCHAR(max), Field NVARCHAR(MAX), PreviousValue NVARCHAR(MAX), CurrentValue NVARCHAR(MAX), Action NVARCHAR(MAX))
		INSERT INTO #TEMP_RESULT
		EXEC SP_GetCountryUpdates @tableXML
		INSERT INTO #TEMP_RESULT
		EXEC SP_GetRegionUpdates @tableXML
		INSERT INTO #TEMP_RESULT
		EXEC SP_GetAirportUpdates @tableXML
		INSERT INTO #TEMP_RESULT
		EXEC SP_GetPlaceNameUpdates @tableXML
		SELECT * FROM #TEMP_RESULT ORDER BY ContentType ASC, Action DESC
		--Return Release Notes(Locking Comments)
		SELECT ISNULL(LockComment, '') AS ReleaseNotes FROM tblConfigurations WHERE ConfigurationID = @ConfigurationId
	END
END
GO



GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Brinda 
-- Create date: 5/6/22
-- Description:	Updates the row based on configurationId and language
-- Sample: EXEC [dbo].[SP_Globalconfig_Respo] 1,'ENGLISH'
-- =============================================
IF OBJECT_ID('[dbo].[SP_Globalconfig_Respo]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_Globalconfig_Respo]
END
GO

CREATE PROCEDURE [dbo].[SP_Globalconfig_Respo]
        @ConfigurationID INT,
		@languageSetToUpdate VARCHAR(Max)
       
AS

BEGIN
		DECLARE @sql NVARCHAR(Max),@CustomID Int,@updateKey Int
		DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
		EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblGlobal',@CustomID,@updateKey out
        SET @sql='UPDATE cust.tblGlobal SET  
                 Global.modify(''replace value of (/global/language_set/text())[1] with "' +@languageSetToUpdate+'" '')
                WHERE cust.tblGlobal.CustomID IN 
                (SELECT distinct cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap WHERE cust.tblGlobalMap.ConfigurationID = @configurationId )'
	    EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey
END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	This query will update cust.tblGlobal based on configurationId and language code
-- Sample: EXEC [dbo].[SP_GlobalRemoveLanguage] 1,'EN'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GlobalRemoveLanguage]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GlobalRemoveLanguage]
END
GO

CREATE PROCEDURE [dbo].[SP_GlobalRemoveLanguage]
        @configurationId INT,
		@languageCode NVARCHAR(Max)
       
AS

BEGIN
       DECLARE @sql NVARCHAR(Max),@CustomID Int,@updateKey Int
	    DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
        SET @CustomID = (SELECT  cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap WHERE cust.tblGlobalMap.ConfigurationID = @configurationId)
	   EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblGlobal',@CustomID,@updateKey out
	   print @updateKey
       SET @sql= ('UPDATE cust.tblGlobal 
                SET Global.modify(''delete (/global/' +@languageCode+')[1]'') 
                WHERE cust.tblGlobal.CustomID = @updateKey')
	   EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey
END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada
-- Create date: 5/24/2022
-- Description:	Get the languages based on configurationId
-- Sample:EXEC [dbo].[SP_global_AddLanguages] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_AddLanguages]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_AddLanguages]
END
GO

CREATE PROCEDURE [dbo].[SP_global_AddLanguages]
        @configurationId INT
       
AS

BEGIN

                SELECT Global.value('(global/language_set)[1]', 'varchar(max)')
                FROM 
                cust.tblGlobal INNER JOIN cust.tblGlobalMap ON cust.tblGlobalMap.CustomID = cust.tblGlobal.CustomID 
                WHERE cust.tblGlobalMap.ConfigurationID = @configurationId 
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date: 5/24/2022
-- Description:	Get language based on language code and configurationID
-- Sample: [dbo].[SP_global_AddLanguagesCode] 'SP',112
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_AddLanguagesCode]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_AddLanguagesCode]
END
GO

CREATE PROCEDURE [dbo].[SP_global_AddLanguagesCode]
        @languageCode NVARCHAR(100),
		@configurationId Int
       
AS

BEGIN
  
 IF NOT EXISTS(SELECT 1 FROM  dbo.tblLanguages INNER JOIN dbo.tblLanguagesMap ON dbo.tblLanguagesMap.LanguageID = dbo.tblLanguages.ID  WHERE dbo.tblLanguages.[2LetterID_ASXi] = @languageCode 
 AND dbo.tblLanguagesMap.ConfigurationID = @configurationId )
 BEGIN
       DECLARE @LanguageID INT
       SET @LanguageID =(SELECT ID   from dbo.tblLanguages  WHERE dbo.tblLanguages.[2LetterID_ASXi] = @languageCode)
	   INSERT INTO dbo.tblLanguagesMap(ConfigurationID,LanguageID,Action)values(@configurationId,@LanguageID,'adding')
	   SELECT  LOWER(dbo.tblLanguages.Name) as languages FROM dbo.tblLanguages 
       INNER JOIN dbo.tblLanguagesMap ON dbo.tblLanguagesMap.LanguageID = dbo.tblLanguages.ID 
       WHERE dbo.tblLanguages.[2LetterID_ASXi] = @languageCode AND dbo.tblLanguagesMap.ConfigurationID = @configurationId
 END
 ELSE
 BEGIN
                SELECT  LOWER(dbo.tblLanguages.Name) as languages FROM dbo.tblLanguages 
                INNER JOIN dbo.tblLanguagesMap ON dbo.tblLanguagesMap.LanguageID = dbo.tblLanguages.ID 
                WHERE dbo.tblLanguages.[2LetterID_ASXi] = @languageCode AND dbo.tblLanguagesMap.ConfigurationID = @configurationId
				END
END
GO


GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa,Brinda Chindamada
-- Create date: 5/27/2022
-- Description:	updates table global based on language and configid
-- Sample: EXEC  [dbo].[SP_global_AddLanguagesCodeIsnullOrWhiteSpace] 1,'ENGLISH'
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_AddLanguagesCodeIsnullOrWhiteSpace]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_AddLanguagesCodeIsnullOrWhiteSpace]
END
GO

CREATE PROCEDURE [dbo].[SP_global_AddLanguagesCodeIsnullOrWhiteSpace]
	    @configurationId INT,
        @languageSetToUpdate NVARCHAR(Max)
		
       
AS

BEGIN 
            DECLARE @sql NVARCHAR(Max),@CustomID Int,@updateKey Int, @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
		  SELECT  @CustomID=ISNULL(cust.tblGlobalMap.CustomID,0) FROM cust.tblGlobalMap WHERE cust.tblGlobalMap.ConfigurationID = @configurationId 
		    
			IF @CustomID!=0
			BEGIN
				EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblGlobal',@CustomID,@updateKey out
		     
			   SET @sql=('UPDATE cust.tblGlobal SET 
					Global.modify(''replace value of (/global/language_set/text())[1] with " '+ @languageSetToUpdate +'" '') 
					WHERE cust.tblGlobal.CustomID IN 
					(SELECT distinct cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap WHERE cust.tblGlobalMap.ConfigurationID = @configurationId  AND CustomID = @updateKey )') 
				 EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey 
			 END
			 ELSE
			 BEGIN
				 DECLARE @langXML NVARCHAR(MAX)='<global><language_set default="'+@languageSetToUpdate+'">'+@languageSetToUpdate+'</language_set>
									  </global>'
				INSERT INTO cust.tblGlobal (Global) VALUES(@langXML);
				DECLARE @latestCustomId int=(SELECT SCOPE_IDENTITY());
				print @latestCustomId
				EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId ,'tblGlobal',@latestCustomId
			END
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	Get languages based on configurationId
-- Sample: EXEC [dbo].[SP_global_GetAllLanguages] 
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_GetAllLanguages]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_GetAllLanguages]
END
GO

CREATE PROCEDURE [dbo].[SP_global_GetAllLanguages]
       
AS

BEGIN    
		select distinct ID,LanguageID,Name,NativeName,Description,(ISNULL(ISLatinScript, 0)) AS ISLatinScript,Tier,[2LetterID_4xxx],[3LetterID_4xxx],[2LetterID_ASXi],
		[3LetterID_ASXi],HorizontalOrder,HorizontalScroll,VerticalOrder,VerticalScroll
		from tblLanguages 
	
END
GO


GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Returns List of languaged selected for the given configuration
-- =============================================
IF OBJECT_ID('[cust].[SP_Global_GetSelectedLanguages]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Global_GetSelectedLanguages]
END
GO

CREATE PROCEDURE [cust].[SP_Global_GetSelectedLanguages]
	@configurationId int
AS
BEGIN
    SELECT 
    A.RowNum,
    Lang.ID, Lang.LanguageID, Lang.Name, Lang.NativeName, Lang.Description, ISNULL(Lang.ISLatinScript, 0) AS ISLatinScript, Lang.Tier, Lang.[2LetterID_4xxx],
	Lang.[3LetterID_4xxx], Lang.[2LetterID_ASXi], Lang.[3LetterID_ASXi], Lang.HorizontalOrder, Lang.HorizontalScroll, Lang.VerticalOrder, Lang.VerticalScroll
    FROM
    (
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as RowNum, value
    FROM STRING_SPLIT(
        (
        SELECT             
    UPPER(Global.value('(global/language_set)[1]', 'varchar(max)')) as language 
    FROM cust.tblGlobal INNER JOIN cust.tblGlobalMap ON cust.tblGlobalMap.CustomID = cust.tblGlobal.CustomID WHERE cust.tblGlobalMap.ConfigurationID = @configurationId
    )
    ,',')
    ) as A 
    INNER JOIN dbo.tblLanguages as Lang ON A.value LIKE CONCAT('%', 'E', UPPER(Lang.Name), '%')
    INNER JOIN dbo.tblLanguagesMap ON Lang.ID = dbo.tblLanguagesMap.LanguageID
    WHERE  dbo.tblLanguagesMap.ConfigurationID = @configurationId AND dbo.tblLanguagesMap.IsDeleted = 0
    ORDER BY A.RowNum
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date:  5/25/2022
-- Description:	This Sp will returns the value based on name,configId and language prefix
-- Sample: EXEC [dbo].[SP_global_GetSelectLanguage] 'ENGLISH',1,'EN'
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_GetSelectLanguage]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_GetSelectLanguage]
END
GO

CREATE PROCEDURE [dbo].[SP_global_GetSelectLanguage]
        @name NVARCHAR(100),
		@configurationId  INT,
		@langprefix NVARCHAR(100) 
       
AS

BEGIN
		
       DECLARE @sql NVARCHAR(Max), @params NVARCHAR(4000) = '@inputName VARCHAR(255),@configurationId Int' 
     SET @sql =N'SELECT CASE WHEN UPPER(Global.value(''(global/language_set/@default)[1]'', ''varchar(max)'')) = @inputName THEN 1 ELSE 0
       END AS IsDefault, 
	   ISNULL(Global.value(''(' + @langprefix + '/@clock)[1]'', ''varchar(max)''),''eHour24'') as Clock, 
       ISNULL(Global.value(''(' + @langprefix + '/@decimal)[1]'' , ''varchar(max)''),''os'') as Decimal, 
       ISNULL(Global.value(''(' + @langprefix + '/@grouping)[1]'', ''varchar(max)''),''os'') as Grouping, 
       ISNULL(Global.value(''(' + @langprefix + '/@interactive_clock)[1]'', ''varchar(max)''),''eHour24'') as InteractiveClock,
       ISNULL(Global.value(''(' + @langprefix + '/@interactive_units)[1]'', ''varchar(max)''),''eMetric'') as InteractiveUnits,
       ISNULL(Global.value(''(' + @langprefix + '/@units)[1]'', ''varchar(max)''),''eMetric'') as Units 
       FROM cust.tblGlobal 
       INNER JOIN cust.tblGlobalMap ON cust.tblGlobalMap.CustomID = cust.tblGlobal.CustomID 
       WHERE cust.tblGlobalMap.ConfigurationID =  @configurationId '
	   
	   EXEC SP_EXECUTESQL @sql ,@params,@inputName = @name,@configurationId = @configurationId
		
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	updates global table based on language and configuration id
--Sample: EXEC [dbo].[SP_global_SetDefaultLanguage] 1,'ENGLISH'
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_SetDefaultLanguage]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_SetDefaultLanguage]
END
GO

CREATE PROCEDURE [dbo].[SP_global_SetDefaultLanguage]
        @configurationId INT,
		@language NVARCHAR(100)
       
AS

BEGIN

    DECLARE @sql NVARCHAR(Max),@CustomID Int,@updateKey Int
	DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
	SELECT @CustomID = CustomID FROM cust.tblGlobalMap WHERE ConfigurationID = @configurationId
	EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblGlobal',@CustomID,@updateKey out
    SET @sql=('UPDATE cust.tblGlobal  
                SET  Global.modify(''replace value of (/global/language_set/@default)[1] with "'+ @language +'" '') 
                WHERE cust.tblGlobal.CustomID IN 
                (SELECT distinct cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap 
                WHERE cust.tblGlobalMap.ConfigurationID =@configurationId  AND CustomID = @updateKey)')
				
	 EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey
       
END
GO


GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	Get the language based on congigurationId
-- Sample: EXEC [dbo].[SP_global_UpdateLanguage] 67
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_UpdateLanguage]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_UpdateLanguage]
END
GO

CREATE PROCEDURE [dbo].[SP_global_UpdateLanguage]
        @configurationId INT
       
AS

BEGIN

                    SELECT Lang.ID, Lang.LanguageID, Lang.Name, Lang.NativeName, Lang.Description, ISNULL(Lang.ISLatinScript, 0) AS ISLatinScript, Lang.Tier, 
					Lang.[2LetterID_4xxx],Lang.[3LetterID_4xxx], Lang.[2LetterID_ASXi], Lang.[3LetterID_ASXi],Lang.HorizontalOrder, 
					Lang.HorizontalScroll, Lang.VerticalOrder, Lang.VerticalScroll
                    FROM
                    (
                    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as RowNum, value
                    FROM STRING_SPLIT(
                        (
                        SELECT             
                    UPPER(Global.value('(global/language_set)[1]', 'varchar(max)')) as language 
                    FROM cust.tblGlobal INNER JOIN cust.tblGlobalMap ON cust.tblGlobalMap.CustomID = cust.tblGlobal.CustomID WHERE cust.tblGlobalMap.ConfigurationID = @configurationId
                    )
                    ,',')
                    ) as A 
                    INNER JOIN dbo.tblLanguages as Lang ON A.value LIKE CONCAT('%', 'E', UPPER(Lang.Name), '%')
                    INNER JOIN dbo.tblLanguagesMap ON Lang.ID = dbo.tblLanguagesMap.LanguageID
                    WHERE  dbo.tblLanguagesMap.ConfigurationID = @configurationId
                    ORDER BY A.RowNum
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	updates global table
--Sample: EXEC [dbo].[SP_global_UpdateLanguageSetElements] 1,'en'
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_UpdateLanguageSetElements]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_UpdateLanguageSetElements]
END
GO

CREATE PROCEDURE [dbo].[SP_global_UpdateLanguageSetElements]
        @configurationId INT,
		@languageCode NVARCHAR(Max)
		
       
AS

BEGIN
         DECLARE @sql NVARCHAR(Max),@CustomID Int,@updateKey Int
		 DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
		
		  SET @CustomID = (SELECT  cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap WHERE cust.tblGlobalMap.ConfigurationID = @configurationId )
		  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblGlobal',@CustomID,@updateKey out
         SET @sql=('UPDATE cust.tblGlobal 
                SET Global.modify(''insert <'+ @languageCode +'  clock= "eHour24" decimal= "os" grouping= "os" interactive_clock= "eHour24" interactive_units= "eMetric" units= "eMetric"/> 
                into (/global)[1]'') 
                WHERE cust.tblGlobal.CustomID = @updateKey')
	      EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey
END
GO


GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa,Brinda,Chindamada
-- Create date: 26/5/2022
-- Description:	Update the  language based on conditions
-- Sample: EXEC [dbo].[SP_global_UpdateLanguageSetElementsAttributes] 67,'fr','units','eMetric'
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_UpdateLanguageSetElementsAttributes]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_global_UpdateLanguageSetElementsAttributes]

END

GO
CREATE PROCEDURE [dbo].[SP_global_UpdateLanguageSetElementsAttributes]
                        @configurationId INT,
						 @languagePrefix NVARCHAR(Max),
						 @name NVARCHAR( Max),
						 @value NVARCHAR (Max)
                       

AS

BEGIN        
         DECLARE @sql NVARCHAR(Max),@updateKey Int,@CustomID INT
		  DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
		 SET @CustomID=(SELECT distinct cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap  WHERE cust.tblGlobalMap.ConfigurationID = @configurationId)
		  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblGlobal',@CustomID,@updateKey out
         SET @sql=('UPDATE cust.tblGlobal 
                 SET Global.modify(''replace value of ('+ @languagePrefix +'/@'+ @name + ')[1] with "'+ @value+'"'') 
                  WHERE cust.tblGlobal.CustomID = @updateKey') 

				  print @sql
		 EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey
		 
END

GO

GO

IF OBJECT_ID('[dbo].[sp_image_management_DeleteImage]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_DeleteImage]
END
GO

CREATE PROC sp_image_management_DeleteImage
@imageId  INT,
@configurationId INT
AS 
BEGIN
	EXEC [SP_ConfigManagement_HandleDelete] @configurationId, 'tblImage', @imageId
END
GO
GO

IF OBJECT_ID('[dbo].[sp_image_management_GetConfigImages]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_GetConfigImages]
END
GO

CREATE PROC sp_image_management_GetConfigImages
@configurationId  INT,
@type INT
AS 
BEGIN
SELECT img.ImageId,img.ImageName,img.IsSelected,img.OriginalImagePath FROM dbo.config_tblImage(@configurationId) as img where img.ImageTypeId=@type
END

GO
GO


IF OBJECT_ID('[dbo].[sp_image_management_GetImageCount]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_GetImageCount]
END
GO

CREATE PROC sp_image_management_GetImageCount
@configurationId INT
AS 
BEGIN

SELECT id,ImageType,count(B.ImageId) as imageCount FROM tblImageType A inner JOIN dbo.config_tblImage(@configurationId) as B
                     ON A.ID=B.ImageTypeId 
                     GROUP BY A.ID,ImageType
END

GO
GO


IF OBJECT_ID('[dbo].[sp_image_management_GetImageDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_GetImageDetails]
END
GO
CREATE PROC sp_image_management_GetImageDetails
@ImageId  INT,
@configurationId INT
AS 
BEGIN
SELECT img.ImageName,img.OriginalImagePath FROM dbo.config_tblImage(@configurationId) as img WHERE img.ImageId=@ImageId
END

GO
GO

IF OBJECT_ID('[dbo].[sp_image_management_GetResolutions]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_GetResolutions]
END
GO

CREATE PROC sp_image_management_GetResolutions
AS 
BEGIN
SELECT ID,resolution FROM tblImageres
END

GO
GO

IF OBJECT_ID('[dbo].[sp_image_management_GetResolutionText]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_GetResolutionText]
END
GO

CREATE PROC sp_image_management_GetResolutionText
@resolutionId INT

AS 
BEGIN
	IF (@resolutionId = -1)
		SELECT resolution FROM tblImageres WHERE IsDefault=1
	ELSE 
		SELECT resolution FROM tblImageres WHERE ID=@resolutionId
END
GO
GO

IF OBJECT_ID('[dbo].[sp_image_management_InsertImages]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_InsertImages]
END
GO

CREATE PROC sp_image_management_InsertImages
@configurationId INT,
@ImageId  INT,
@type INT,
@imageURL NVARCHAR(500),
@imageName NVARCHAR(500),
@guidFileName NVARCHAR(100)
AS 
BEGIN
INSERT INTO tblImage VALUES(@imageId,@imageName,@imageURL,@type,0,@guidFileName);
EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblImage', @imageId
END

GO
GO

IF OBJECT_ID('[dbo].[sp_image_management_InsertResolutionSpecImage]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_InsertResolutionSpecImage]
END
GO
CREATE PROC sp_image_management_InsertResolutionSpecImage
@configurationId INT,
@ImageId  INT,
@resolutionId INT,
@imageURL NVARCHAR(500)
AS 
BEGIN
INSERT INTO tblImageResSpec VALUES(@configurationId,@imageId,@resolutionId,@imageURL)
END

GO
GO

IF OBJECT_ID('[dbo].[sp_image_management_PreviewImages]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_PreviewImages]
END
GO

CREATE PROC sp_image_management_PreviewImages
@configurationId INT,
@imageId INT
AS 
BEGIN

SELECT ResolutionId,ImagePath,res.IsDefault,res.resolution,res.Description FROM tblImageResSpec map RIGHT JOIN tblImageres res 
                        ON map.resolutionId=res.ID WHERE ImageId=@imageId AND ConfigurationID=@configurationId

END

GO
GO

IF OBJECT_ID('[dbo].[sp_image_management_RenameFile]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_RenameFile]
END
GO

CREATE PROC sp_image_management_RenameFile
@imageId INT,
@type INT,
@fileName NVARCHAR(500)
AS 
BEGIN

UPDATE tblImage SET ImageName=@fileName WHERE ImageId=@imageId AND ImageTypeId=@type
END
GO
GO


IF OBJECT_ID('[dbo].[sp_image_management_ReSetConfigImage]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_ReSetConfigImage]
END
GO

CREATE PROC sp_image_management_ReSetConfigImage
@configurationId INT,
@type INT
AS 
BEGIN

    UPDATE img
    SET img.IsSelected = 0
    FROM 
    dbo.config_tblImage(@configurationId) as img
    WHERE img.imageTypeId = @type and img.IsSelected = 1

END

GO
GO



IF OBJECT_ID('[dbo].[sp_image_management_SetConfigImage]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_SetConfigImage]
END
GO

CREATE PROC sp_image_management_SetConfigImage
@configurationId INT,
@type INT,
@imageId INT
AS 
BEGIN

    UPDATE img
    SET img.IsSelected = 1
    FROM 
    dbo.config_tblImage(@configurationId) as img
    WHERE img.imageTypeId = @type and img.ImageId = @imageId

END

GO
GO

IF OBJECT_ID('[dbo].[sp_image_management_UpdateResolutionSpecImage]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_image_management_UpdateResolutionSpecImage]
END
GO

CREATE PROC sp_image_management_UpdateResolutionSpecImage
@configurationId INT,
@imageId INT,
@imageURL NVARCHAR(500),
@resolutionId INT
AS 
BEGIN

UPDATE tblImageResSpec SET ImagePath=@imageURL WHERE ConfigurationID=@configurationId AND ImageId=@imageId AND ResolutionId=@resolutionId

END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek pm 
-- Create date: 10/4/2023
-- Description:	Import Fonts from csv
-- Sample EXEC [dbo].[SP_Import_font] 201
-- =============================================
IF OBJECT_ID('[dbo].[SP_Import_font]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Import_font]
END
GO

CREATE PROCEDURE [SP_Import_font]
		@configid INT
AS
BEGIN
	BEGIN TRY
	--For new records
	DECLARE @tempNewFontCounter INT, @existingFontId INT, @newFontId INT, @CurrentFontID INT, @tbFontID INT, @tempID INT;
	DECLARE @tbFontFontID INT, @tbFontSize INT,@tbFontDescription NVARCHAR(255), @tbFontColor NVARCHAR(8), @tbFontShadowColor NVARCHAR(8), @tbFontFontFaceId INT, @tbFontFontStyle INT;
	--CREATE TABLE @tempNewFontWithIDs (ID INT IDENTITY (1,1) NOT NULL, FontID INT NULL, Description NVARCHAR(255) NULL,Size INT NULL,Color NVARCHAR(8), ShadowColor NVARCHAR(8),FontFaceId NVARCHAR(11),FontStyle NVARCHAR(10));
	DECLARE @tempNewFont TABLE(ID INT IDENTITY (1,1) NOT NULL, FontID INT NULL, Description NVARCHAR(255) NULL,Size INT NULL,Color NVARCHAR(8), ShadowColor NVARCHAR(8),FontFaceId INT NULL,FontStyle INT NULL);
	DECLARE @tempUpdateFont TABLE (ID INT IDENTITY (1,1) NOT NULL, FontID INT NULL, Description NVARCHAR(255) NULL,Size INT NULL,Color NVARCHAR(8), ShadowColor NVARCHAR(8),FontFaceId INT NULL,FontStyle INT NULL);
 

	INSERT INTO @tempNewFont (FontID,Description,Size,Color,ShadowColor,FontFaceId,FontStyle) 
	SELECT TBF.FontId,TBF.Description, TBF.Size,TBF.Color,TBF.ShadowColor,TBF.FontFaceId, TBF.FontStyle
	FROM tblTempFonts  TBF WHERE TBF.FontId NOT IN 
		(SELECT tbFont.FontID FROM config_tblFont(@configid) as tbFont)


	--For Modified records
	INSERT INTO @tempUpdateFont (FontID,Description,Size,Color,ShadowColor,FontFaceId,FontStyle) 
	SELECT TBF.FontId,TBF.Description, TBF.Size,TBF.Color,TBF.ShadowColor,TBF.FontFaceId, TBF.FontStyle
	FROM tblTempFonts TBF WHERE TBF.FontId IN
			(SELECT tbFont.FontID FROM config_tblFont(@configid) as tbFont
				WHERE TBF.Description != tbFont.Description OR
							TBF.Size != tbFont.Size OR
							TBF.Color != tbFont.Color OR
							TBF.ShadowColor != tbFont.ShadowColor OR
							TBF.FontFaceId != tbFont.FontFaceId OR
							TBF.FontStyle != tbFont.FontStyle);

	--Iterating to the new temp tables and adding it to the tblFont and tblFontMap
	WHILE(SELECT COUNT(*) FROM @tempNewFont) > 0
	BEGIN
		
		SET @tempID = (SELECT TOP 1 ID FROM @tempNewFont)
		SET @tbFontID = (SELECT TOP 1 FontID FROM @tempNewFont)	
		SET @tbFontDescription = (SELECT TOP 1 Description FROM @tempNewFont)	
		SET @tbFontSize = (SELECT TOP 1 Size FROM @tempNewFont)
		SET @tbFontColor = (SELECT TOP 1 Color FROM @tempNewFont)
		SET @tbFontShadowColor = (SELECT TOP 1 ShadowColor FROM @tempNewFont)
		SET @tbFontFontFaceId = (SELECT TOP 1 FontFaceId FROM @tempNewFont)
		SET @tbFontFontStyle = (SELECT TOP 1 FontStyle FROM @tempNewFont)

		--Insert tblFont Table and and its Maping Table
		DECLARE @newtbFontID INT;
		INSERT INTO tblFont(FontID,Description,Size,Color,ShadowColor,FontFaceId,FontStyle)
		VALUES (@tbFontID,@tbFontDescription, @tbFontSize,@tbFontColor,@tbFontShadowColor,@tbFontFontFaceId,@tbFontFontStyle) 
		SET @newtbFontID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblFont', @newtbFontID

		DELETE FROM @tempNewFont WHERE ID = @tempID
	END

	select * from @tempUpdateFont

	--Iterating to the new temp tables and adding it to the tblFont and tblFontMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateFont) > 0
	BEGIN
		
		SET @tempID = (SELECT TOP 1 ID FROM @tempUpdateFont)	
		SET @tbFontID = (SELECT TOP 1 FontID FROM @tempUpdateFont)	
		SET @tbFontDescription = (SELECT TOP 1 Description FROM @tempUpdateFont)	
		SET @tbFontSize = (SELECT TOP 1 Size FROM @tempUpdateFont)
		SET @tbFontColor = (SELECT TOP 1 Color FROM @tempUpdateFont)
		SET @tbFontShadowColor = (SELECT TOP 1 ShadowColor FROM @tempUpdateFont)
		SET @tbFontFontFaceId = (SELECT TOP 1 FontFaceId FROM @tempUpdateFont)
		SET @tbFontFontStyle = (SELECT TOP 1 FontStyle FROM @tempUpdateFont)


		--Update the tblFont Table and and its Maping Table
		SET @existingFontId = (SELECT tbFont.ID FROM dbo.config_tblFont(@configid) AS tbFont 
		WHERE tbFont.FontID = @tbFontID)

		SELECT tbFont.ID FROM dbo.config_tblFont(@configid) AS tbFont 
		WHERE tbFont.FontID = @tbFontID
		print'existingFontId'
		print @existingFontId
		DECLARE @updateFontKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblFont', @existingFontId, @updateFontKey out
		SET NOCOUNT OFF
		print'updateFontKey'
		print @updateFontKey
		UPDATE tblFont
		SET   Size = @tbFontSize,Description = @tbFontDescription, Color = @tbFontColor, ShadowColor = @tbFontShadowColor, FontFaceId = @tbFontFontFaceId, FontStyle = @tbFontFontStyle
		WHERE ID = @updateFontKey

		DELETE FROM @tempUpdateFont WHERE ID = @tempID
	END

	DELETE @tempNewFont
	DELETE @tempUpdateFont
	END TRY
	BEGIN CATCH
	 SELECT  
        ERROR_NUMBER() AS ErrorNumber  
        ,ERROR_SEVERITY() AS ErrorSeverity  
        ,ERROR_STATE() AS ErrorState  
        ,ERROR_PROCEDURE() AS ErrorProcedure  
        ,ERROR_LINE() AS ErrorLine  
        ,ERROR_MESSAGE() AS ErrorMessage;  
	END CATCH
END





GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek
-- Create date: 06/24/2022
-- Description:	Import Fonts from csv file
-- Sample EXEC [dbo].[SP_Import_FontCategory] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_Import_FontCategory]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Import_FontCategory]
END
GO

CREATE PROCEDURE [dbo].[SP_Import_FontCategory]
		@configid INT
AS
BEGIN
	--For new records
	DECLARE @existingFontCategoryId INT, @CurrentFontCategoryID INT;
	DECLARE @tbFontCatLangID INT,@tbFontCatMarkerID INT, @tbFontCatIMarkerID INT,@tbFontCatGeoRefIdCatTypeId INT,@tbFontCatFontID INT;
	--DECLARE  @tempNewFontCategoryWithIDs TABLE (FontCategoryId INT IDENTITY (1,1) NOT NULL, GeoRefIdCatTypeID INT NULL, LanguageID INT NULL,FontID INT NULL,MarkerID INT NULL,IMarkerID INT NULL);
	DECLARE  @tempNewFontCategory TABLE (FontCategoryId INT IDENTITY (1,1) NOT NULL, GeoRefIdCatTypeID INT NULL, LanguageID INT NULL,FontID INT NULL,MarkerID INT NULL,IMarkerID INT NULL);
	DECLARE  @tempUpdateFontCategory TABLE (FontCategoryId INT IDENTITY (1,1) NOT NULL, GeoRefIdCatTypeID INT NULL, LanguageID INT NULL,FontID INT NULL,MarkerID INT NULL,IMarkerID INT NULL);


	--For new records
	INSERT INTO  @tempNewFontCategory(GeoRefIdCatTypeID,LanguageID,FontID,MarkerID,IMarkerID) 
	SELECT TBFC.GeoRefIdCatTypeId,TBFC.LanguageId,TBFC.FontId, TBFC.MarkerId, TBFC.IMarkerId
	FROM tblTempFontsCategory TBFC WHERE CAST(TBFC.GeoRefIdCatTypeId AS NVARCHAR)+CAST(TBFC.FontId AS NVARCHAR)  NOT IN 
		(SELECT CAST(tbFontCat.GeoRefIdCatTypeID AS NVARCHAR)+CAST(tbFontCat.FontID AS NVARCHAR) FROM config_tblFontCategory(@configid) as tbFontCat)
	
	--For Modified records
	INSERT INTO  @tempUpdateFontCategory(GeoRefIdCatTypeID,LanguageID,FontID,MarkerID,IMarkerID) 
	SELECT TBFC.GeoRefIdCatTypeId,TBFC.LanguageId,TBFC.FontId, TBFC.MarkerId, TBFC.IMarkerId
	FROM tblTempFontsCategory TBFC WHERE CAST(TBFC.GeoRefIdCatTypeId AS NVARCHAR)+CAST(TBFC.FontId AS NVARCHAR) IN 
		(SELECT CAST(tbFontCat.GeoRefIdCatTypeID AS NVARCHAR)+CAST(tbFontCat.FontID AS NVARCHAR) FROM config_tblFontCategory(@configid) as tbFontCat 
			WHERE TBFC.LanguageID != tbFontCat.LanguageID OR
							TBFC.MarkerID != tbFontCat.MarkerID OR
							TBFC.IMarkerID != tbFontCat.IMarkerID);

	--Iterating to the new temp tables and adding it to the tblFontCategory and tblFontCategoryMap
	WHILE(SELECT COUNT(*) FROM @tempNewFontCategory) > 0
	BEGIN		
		SET @CurrentFontCategoryID = (SELECT TOP 1 FontCategoryId FROM @tempNewFontCategory)
		SET @tbFontCatGeoRefIdCatTypeId = (SELECT TOP 1 GeoRefIdCatTypeId FROM @tempNewFontCategory)
		SET @tbFontCatLangID = (SELECT TOP 1 LanguageID FROM @tempNewFontCategory)
		SET @tbFontCatFontID = (SELECT TOP 1 FontID FROM @tempNewFontCategory)
		SET @tbFontCatMarkerID = (SELECT TOP 1 MarkerID FROM @tempNewFontCategory)
		SET @tbFontCatIMarkerID = (SELECT TOP 1 IMarkerID FROM @tempNewFontCategory)

		--Insert tblFont Table and and its Maping Table
		DECLARE @newtbFontCatID INT;
		INSERT INTO tblFontCategory(GeoRefIdCatTypeID,LanguageID,FontID,MarkerID,IMarkerID)
		VALUES (@tbFontCatGeoRefIdCatTypeId,@tbFontCatLangID, @tbFontCatFontID,@tbFontCatMarkerID,@tbFontCatIMarkerID) 
		SET @newtbFontCatID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblFontCategory', @newtbFontCatID

		DELETE FROM @tempNewFontCategory WHERE FontCategoryId = @CurrentFontCategoryID
	END

	--Iterating to the new temp tables and adding it to the tblFontCategory and tblFontCategoryMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateFontCategory) > 0
	BEGIN		
		SET @CurrentFontCategoryID = (SELECT TOP 1 FontCategoryId FROM @tempUpdateFontCategory)
		SET @tbFontCatGeoRefIdCatTypeId = (SELECT TOP 1 GeoRefIdCatTypeId FROM @tempUpdateFontCategory)
		SET @tbFontCatLangID = (SELECT TOP 1 LanguageID FROM @tempUpdateFontCategory)
		SET @tbFontCatFontID = (SELECT TOP 1 FontID FROM @tempUpdateFontCategory)
		SET @tbFontCatMarkerID = (SELECT TOP 1 MarkerID FROM @tempUpdateFontCategory)
		SET @tbFontCatIMarkerID = (SELECT TOP 1 IMarkerID FROM @tempUpdateFontCategory)

		--Update the tblFont Table and and its Maping Table
		SET @existingFontCategoryId = (SELECT tbFontCat.FontCategoryID FROM config_tblFontCategory(@configid) as tbFontCat
		WHERE tbFontCat.FontID = @tbFontCatFontID AND tbFontCat.GeoRefIdCatTypeID = @tbFontCatGeoRefIdCatTypeId)

		DECLARE @updateFontCatKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblFontCategory', @existingFontCategoryId, @updateFontCatKey out
		SET NOCOUNT OFF
		UPDATE tblFontCategory
		SET LanguageID = @tbFontCatLangID, MarkerID = @tbFontCatMarkerID, IMarkerID = @tbFontCatIMarkerID
		WHERE FontCategoryID = @updateFontCatKey

		DELETE FROM @tempUpdateFontCategory WHERE FontCategoryId = @CurrentFontCategoryID
	END

	DELETE @tempNewFontCategory
	DELETE @tempUpdateFontCategory
END




GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek
-- Create date: 04/11/2023
-- Description:	Import Fontfamily from csv
-- Sample EXEC [dbo].[SP_Import_FontFamily] 201
-- =============================================
IF OBJECT_ID('[dbo].[SP_Import_FontFamily]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Import_FontFamily]
END
GO

CREATE PROCEDURE [dbo].[SP_Import_FontFamily]
		@configid INT
AS
BEGIN
	--For new records
	--DECLARE @tempNewFontFamilyCounter INT, @existingFontFamilyID INT, @newFontFamilyID INT, @CurrentFontFamilyID INT;
	DECLARE @TempId INT,@TempFontFaceID INT, @TempFaceName NVARCHAR(512), @TempFileName NVARCHAR(512),@existingFontFamilyID INT;
	DECLARE @tempNewFontFamily TABLE(ID INT IDENTITY(1,1) NOT NULL,FontFaceID INT NOT NULL, FaceName NVARCHAR(512) NULL,FileName NVARCHAR(512) NULL)
	DECLARE @tempUpdateFontFamily TABLE(ID INT IDENTITY(1,1) NOT NULL,FontFaceID INT NOT NULL, FaceName NVARCHAR(512) NULL,FileName NVARCHAR(512) NULL)

	--For New records
	INSERT INTO @tempNewFontFamily(FontFaceID, FaceName, FileName)
	SELECT TBF.FontFaceId, TBF.FaceName, TBF.FileName FROM tblTempFontsFamily TBF 
	WHERE TBF.FontFaceId NOT IN (SELECT FontFamily.FontFaceId FROM config_tblFontFamily(@configid) AS FontFamily);

	--For Modified records
	INSERT INTO @tempUpdateFontFamily(FontFaceID, FaceName, FileName)
	SELECT TBF.FontFaceId, TBF.FaceName, TBF.FileName FROM tblTempFontsFamily TBF 
	WHERE TBF.FontFaceId IN (SELECT FontFamily.FontFaceId FROM config_tblFontFamily(@configid) AS FontFamily 
				WHERE FontFamily.FaceName != TBF.FaceName OR FontFamily.FileName != TBF.FileName)
	

	--Iterating to the new temp tables and adding it to the tblFontFamilyID and tblFontFamilyMap
	WHILE(SELECT COUNT(*) FROM @tempNewFontFamily) > 0
	BEGIN
		
		SET @TempId = (SELECT TOP 1 ID FROM @tempNewFontFamily)
		SET @TempFontFaceID= (SELECT TOP 1 FontFaceID FROM @tempNewFontFamily)
		SET @TempFaceName= (SELECT TOP 1 FaceName FROM @tempNewFontFamily)
		SET @TempFileName= (SELECT TOP 1 FileName FROM @tempNewFontFamily)

		DECLARE @newtbFontFamilyID INT;
		INSERT INTO tblFontFamily(FontFaceID,FaceName,FileName)
		VALUES (@TempFontFaceID,@TempFaceName,@TempFileName) 
		SET @newtbFontFamilyID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblFontFamily', @newtbFontFamilyID

		DELETE FROM @tempNewFontFamily WHERE ID = @TempId
	END

	--Iterating to the new temp tables and adding it to the tblFontFamilyID and tblFontFamilyMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateFontFamily) > 0
	BEGIN
		
		SET @TempId = (SELECT TOP 1 ID FROM @tempUpdateFontFamily)
		SET @TempFontFaceID= (SELECT TOP 1 FontFaceID FROM @tempUpdateFontFamily)
		SET @TempFaceName= (SELECT TOP 1 FaceName FROM @tempUpdateFontFamily)
		SET @TempFileName= (SELECT TOP 1 FileName FROM @tempUpdateFontFamily)

		--Update the tblFontFamily Table and and its Maping Table
		SET @existingFontFamilyId = (SELECT TBFM.FontFamilyID FROM dbo.config_tblFontFamily(@configid) AS TBFM 
		WHERE TBFM.FontFaceId = @TempFontFaceID)

		DECLARE @updateFontFamilyKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblFontFamily', @existingFontFamilyId, @updateFontFamilyKey out
		SET NOCOUNT OFF
		UPDATE tblFontFamily
		SET   FaceName = @TempFaceName, FileName = @TempFileName
		WHERE FontFamilyID = @updateFontFamilyKey

		DELETE FROM @tempUpdateFontFamily WHERE ID = @TempId
	END

	DELETE @tempNewFontFamily
	DELETE @tempUpdateFontFamily
END



GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek
-- Create date: 06/24/2022
-- Description:	Import Fonts from csv
-- Sample EXEC [dbo].[SP_Import_FontMarker] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_Import_FontMarker]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Import_FontMarker]
END
GO

CREATE PROCEDURE [dbo].[SP_Import_FontMarker]
		@configid INT
AS
BEGIN
	--For new records
	--DECLARE @tempNewFontMarkerCounter INT, @existingFontMarkerID INT, @newFontMarkerID INT, @CurrentFontMarkerID INT;
	DECLARE @TempId INT,@TempMarkerID INT, @TempFileName NVARCHAR(512),@existingFontMarkerID INT;
	DECLARE @tempNewFontMarker TABLE(ID INT IDENTITY(1,1) NOT NULL,MarkerID INT NOT NULL,FileName NVARCHAR(512) NULL)
	DECLARE @tempUpdateFontMarker TABLE(ID INT IDENTITY(1,1) NOT NULL,MarkerID INT NOT NULL,FileName NVARCHAR(512) NULL)

	--For New records
	INSERT INTO @tempNewFontMarker(MarkerID, FileName)
	SELECT TBF.MarkerID,TBF.FileName FROM tblTempFontsMarker TBF 
	WHERE TBF.MarkerID NOT IN (SELECT FontMarker.MarkerID FROM config_tblFontMarker(@configid) AS FontMarker);

	--For Modified records
	INSERT INTO @tempUpdateFontMarker(MarkerID,FileName)
	SELECT TBF.MarkerID,TBF.FileName FROM tblTempFontsMarker TBF 
	WHERE TBF.MarkerID IN (SELECT FontMarker.MarkerID FROM config_tblFontMarker(@configid) AS FontMarker 
				WHERE  FontMarker.FileName != TBF.FileName)
	

	--Iterating to the new temp tables and adding it to the tblFontMarkerID and tblFontMarkerMap
	WHILE(SELECT COUNT(*) FROM @tempNewFontMarker) > 0
	BEGIN
		
		SET @TempId = (SELECT TOP 1 ID FROM @tempNewFontMarker)
		SET @TempMarkerID= (SELECT TOP 1 MarkerID FROM @tempNewFontMarker)
		SET @TempFileName= (SELECT TOP 1 FileName FROM @tempNewFontMarker)

		DECLARE @newtbFontMarkerID INT;
		INSERT INTO tblFontMarker(MarkerID,FileName)
		VALUES (@TempMarkerID,@TempFileName) 
		SET @newtbFontMarkerID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblFontMarker', @newtbFontMarkerID

		DELETE FROM @tempNewFontMarker WHERE ID = @TempId
	END

	--Iterating to the new temp tables and adding it to the tblFontMarkerID and tblFontMarkerMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateFontMarker) > 0
	BEGIN
		
		SET @TempId = (SELECT TOP 1 ID FROM @tempUpdateFontMarker)
		SET @TempMarkerID= (SELECT TOP 1 MarkerID FROM @tempUpdateFontMarker)
		SET @TempFileName= (SELECT TOP 1 FileName FROM @tempUpdateFontMarker)

		--Update the tblFontMarker Table and and its Maping Table
		SET @existingFontMarkerId = (SELECT TBFM.FontMarkerID FROM dbo.config_tblFontMarker(@configid) AS TBFM 
		WHERE TBFM.MarkerID = @TempMarkerID)

		DECLARE @updateFontMarkerKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblFontMarker', @existingFontMarkerId, @updateFontMarkerKey out
		SET NOCOUNT OFF
		UPDATE tblFontMarker
		SET FileName = @TempFileName
		WHERE FontMarkerID = @updateFontMarkerKey

		DELETE FROM @tempUpdateFontMarker WHERE ID = @TempId
	END

	DELETE @tempNewFontMarker
	DELETE @tempUpdateFontMarker
END



GO

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
GO

drop proc if exists sp_infoSpelling_getInfoSpelling
go
CREATE PROC sp_infoSpelling_getInfoSpelling  
@configurationId INT,
@languages VARCHAR(MAX)
AS  
BEGIN  

DECLARE @sql NVARCHAR(MAX);

SET @sql= 'select * from (
select infoid,ISNULL(spelling,'''') AS spelling, tbllanguages.[Name] as Language    
from tblinfospelling 
inner join tblinfospellingmap on tblinfospellingmap.infospellingid = tblinfospelling.infospellingid
inner join tbllanguages on tbllanguages.languageid = tblinfospelling.languageid 
inner join tbllanguagesmap on tbllanguagesmap.languageid = tbllanguages.ID 
where tblinfospellingmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' 
and tbllanguagesmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' 
) as sourcetable 
pivot ( 
max(spelling) 
for Language in ('+@languages+') 
) as pivottable 
order by infoid'

EXECUTE sp_executesql @sql;

END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 04/14/2023
-- Description:	Import InfoSpelling from csv
-- Sample EXEC [dbo].[SP_InfoSpelling_Import] 9
-- =============================================
IF OBJECT_ID('[dbo].[SP_InfoSpelling_Import]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_InfoSpelling_Import]
END
GO

CREATE PROCEDURE [dbo].[SP_InfoSpelling_Import]
		@configid INT
AS
BEGIN
 --For new records  
 DECLARE @CurrentInfoSpellingID INT, @existingInfoSpellingId INT, @newInfoSpellingId INT, @tempInfoId INT, @tempLangID INT,@tempInfoSpelling NVARCHAR(MAX);  
 DECLARE @dml AS NVARCHAR(MAX);
 DECLARE @ColumnName AS NVARCHAR(MAX);  
 DECLARE @tempNewInfoSpellingWithIDs TABLE (InfoSpellingId INT IDENTITY (1,1) NOT NULL, InfoId INT NULL, LangTwoLetter NVARCHAR(2) NULL,LangID INT NULL, InfoItem NVARCHAR(MAX)); 
 DECLARE @tempNewInfoSpelling TABLE (InfoSpellingId INT IDENTITY (1,1) NOT NULL, InfoId INT NULL,LangID INT NULL, InfoItem NVARCHAR(MAX));  
 DECLARE @tempUpdateInfoSpelling TABLE (InfoSpellingId INT IDENTITY (1,1) NOT NULL, InfoId INT NULL,LangID INT NULL, InfoItem NVARCHAR(MAX)); 
  
 SELECT @ColumnName= ISNULL(@ColumnName + ',','') 
       + QUOTENAME(name) from sys.columns c
	where c.object_id = OBJECT_ID('dbo.tblTempInfoSpelling') and name LIKE '%Lang%'
  
	SET @dml = 
			N'(SELECT InfoId,(SELECT RIGHT( LangTwoLetter, 2 )), InfoItem  
	FROM   
	(SELECT InfoId, ' +@ColumnName +'
	
	FROM tblTempInfoSpelling) p  
	UNPIVOT  
	(InfoItem FOR LangTwoLetter IN   
		(' + @ColumnName + ')  
	)AS unpvttblTempInfoSpelling)'	

	
	INSERT INTO @tempNewInfoSpellingWithIDs(InfoId,LangTwoLetter,InfoItem) EXEC sp_executesql @dml  
  
  --Updating two letter codes
 UPDATE T1   
 SET T1.LangID = T2.LanguageID  
 FROM @tempNewInfoSpellingWithIDs AS T1 INNER JOIN tblLanguages T2  
 ON T1.LangTwoLetter = t2.[2LetterID_ASXi]  

 --For New Records
 INSERT INTO @tempNewInfoSpelling(InfoId,LangID,InfoItem)
 SELECT TBIS.InfoId,TBIS.LangID, TBIS.InfoItem FROM @tempNewInfoSpellingWithIDs TBIS
 WHERE CAST(TBIS.InfoId as varchar)+'_'+CAST(TBIS.LangID as varchar) NOT IN (SELECT CAST(TBLIS.InfoId as varchar)+'_'+CAST(TBLIS.LanguageId as varchar)
 FROM config_tblInfoSpelling(@configid) TBLIS)

  --For update Records
 INSERT INTO @tempUpdateInfoSpelling(InfoId,LangID,InfoItem)
 SELECT TBIS.InfoId,TBIS.LangID, TBIS.InfoItem FROM @tempNewInfoSpellingWithIDs TBIS
	WHERE CAST(TBIS.InfoId as varchar)+'_'+CAST(TBIS.LangID as varchar) 
		IN (SELECT CAST(TBLIS.InfoId as varchar)+'_'+CAST(TBLIS.LanguageId as varchar)
				FROM config_tblInfoSpelling(@configid) as TBLIS WHERE TBIS.InfoItem != TBLIS.Spelling)

 	--Iterating to the new temp tables and adding it to the tblInfoSpelling and tblInfoSpellingMap
	WHILE(SELECT COUNT(*) FROM @tempNewInfoSpelling) > 0
	BEGIN		
		SET @CurrentInfoSpellingID = (SELECT TOP 1 InfoSpellingId FROM @tempNewInfoSpelling)
		SET @tempInfoId = (SELECT TOP 1 InfoId FROM @tempNewInfoSpelling)
		SET @tempLangID = (SELECT TOP 1 LangID FROM @tempNewInfoSpelling)
		SET @tempInfoSpelling = (SELECT TOP 1 InfoItem FROM @tempNewInfoSpelling)

		--Insert tblFont Table and and its Maping Table
		DECLARE @newtbInfoSpellingID INT;
		INSERT INTO tblInfoSpelling(InfoId,LanguageID,Spelling)
		VALUES (@tempInfoId,@tempLangID,@tempInfoSpelling) 
		SET @newtbInfoSpellingID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblInfoSpelling', @newtbInfoSpellingID

		DELETE FROM @tempNewInfoSpelling WHERE InfoSpellingId = @CurrentInfoSpellingID
	END

	select * from @tempUpdateInfoSpelling
	--Iterating to the udate temp tables and adding it to the tblInfoSpelling and tblInfoSpellingMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateInfoSpelling) > 0
	BEGIN		
		SET @CurrentInfoSpellingID = (SELECT TOP 1 InfoSpellingId FROM @tempUpdateInfoSpelling)
		SET @tempInfoId = (SELECT TOP 1 InfoId FROM @tempUpdateInfoSpelling)
		SET @tempLangID = (SELECT TOP 1 LangID FROM @tempUpdateInfoSpelling)
		SET @tempInfoSpelling = (SELECT TOP 1 InfoItem FROM @tempUpdateInfoSpelling)

		--Update the tblFont Table and and its Maping Table
		SET @existingInfoSpellingId = (SELECT tbInfoSpell.InfoSpellingID FROM config_tblInfoSpelling(@configid) as tbInfoSpell
		WHERE tbInfoSpell.LanguageId = @tempLangID AND tbInfoSpell.InfoId = @tempInfoId)

		DECLARE @updateInfoSpellKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblInfoSpelling', @existingInfoSpellingId, @updateInfoSpellKey out
		SET NOCOUNT OFF
		UPDATE tblInfoSpelling
		SET Spelling = @tempInfoSpelling
		WHERE InfoSpellingID = @updateInfoSpellKey

		DELETE FROM @tempUpdateInfoSpelling WHERE InfoSpellingId = @CurrentInfoSpellingID
	END
 DELETE @tempNewInfoSpelling 
 DELETE @tempUpdateInfoSpelling
 DROP TABLE tblTempInfoSpelling
END
GO

DROP PROC IF EXISTS sp_infoSpelling_insertupdateInfoSpelling
GO
CREATE PROC sp_infoSpelling_insertupdateInfoSpelling 
@configurationId INT,
@infoId INT,
@languageId INT,
@spelling NVARCHAR(MAX)
AS
BEGIN
BEGIN TRY
DECLARE @updateKey int,@infoSepllingId INT

SELECT @infoSepllingId=InfoSpellingId FROM config_tblInfoSpelling(@configurationId) WHERE InfoId=@infoId and LanguageId=@languageId

IF @infoSepllingId > 0
BEGIN
	EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblinfospelling',@infoSepllingId,@updateKey out

	UPDATE tblInfoSpelling SET Spelling=@spelling WHERE InfoSpellingId=@updateKey
END
ELSE
BEGIN
	SELECT @infoSepllingId=MAX(InfoSpellingId)+1 FROM tblInfoSpelling;
	IF @infoId =0
		SELECT @infoId=MAX(InfoId)+1 FROM tblInfoSpelling;
	SET IDENTITY_INSERT tblInfoSpelling ON
	INSERT INTO tblInfoSpelling(InfoSpellingId,InfoId,LanguageId,Spelling)
	VALUES(@infoSepllingId,@infoId,@languageId,@spelling);
	SET IDENTITY_INSERT tblInfoSpelling OFF
	EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId,'tblInfoSpelling',@infoSepllingId;
END
select @infoId as Infoid
END TRY
BEGIN CATCH
          SELECT  ERROR_LINE() AS ErrorLine  
          ,ERROR_MESSAGE() AS ErrorMessage;  
END CATCH
END
GO


GO

DROP PROC IF EXISTS SP_Insert_Updaye_AeroplanTypes
GO
CREATE PROC SP_Insert_Updaye_AeroplanTypes
@configurationId INT,
@aeroplanTypes NVARCHAR(MAX)
AS
BEGIN

DROP TABLE IF EXISTS #TEMPAEROPLANETYPES;
SELECT * INTO #TEMPAEROPLANETYPES FROM STRING_SPLIT(@aeroplanTypes, ',')

DECLARE @type NVARCHAR(MAX)
DECLARE cur_val CURSOR  LOCAL STATIC FORWARD_ONLY READ_ONLY
 FOR
              SELECT value
              FROM   #TEMPAEROPLANETYPES
	OPEN cur_val

            FETCH next FROM cur_val INTO @type
            WHILE @@FETCH_STATUS = 0
              BEGIN
				DECLARE @type_id INT;
				SET @type_id= (SELECT ISNULL(ty.[AeroPlaneTypeID],0) FROM  [dbo].[tblRliAeroPlaneTypes] ty INNER JOIN [dbo].[tblRliAeroPlaneTypesMap]
				tyMap on ty.[AeroPlaneTypeID] = tyMap.[AeroPlaneTypeID] WHERE [Name]=@type AND [ConfigurationID]=@configurationId)
				IF @type_id IS NULL OR @type_id=0
				BEGIN
				--HANDLE UPDATE
					INSERT INTO [dbo].[tblRliAeroPlaneTypes] ([Name]) VALUES(@type);
			
					SET @type_id=(SELECT SCOPE_IDENTITY())

					EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblRliAeroPlaneTypes',@type_id
				END
						  
				FETCH next FROM cur_val INTO @type

			  END

END
GO

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

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Lakshmikanth G R
-- Create date: 5/26/2022
-- Description:	Get language and 2 letter code 
-- Sample: EXEC [dbo].[SP_Language_GetTwoLetterCode] 'English,French,Spanish,Simp_chinese'
-- =============================================
IF OBJECT_ID('[dbo].[SP_Language_GetTwoLetterCode]','P') IS NOT NULL
BEGIN
DROP PROC [dbo].[SP_Language_GetTwoLetterCode]
END
GO
CREATE PROCEDURE [dbo].[SP_Language_GetTwoLetterCode]
@combindedString NVARCHAR(500)

AS
BEGIN
SELECT Distinct dbo.tblLanguages.Name as LanguageName,[2LetterID_ASXi] as TwoletterID FROM dbo.tblLanguages
WHERE [2LetterID_ASXi] is not null and
LOWER(dbo.tblLanguages.Name) IN(SELECT Item
FROM dbo.SplitString(@combindedString, ','))
END
GO

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Procedure to retrieve all Makkah page loading data
-- Sample EXEC [dbo].[SP_Makkah_GetMakkahData] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_Makkah_GetMakkahData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Makkah_GetMakkahData]
END
GO  

CREATE PROCEDURE [dbo].[SP_Makkah_GetMakkahData]  
@ConfigurationId INT   
AS  
BEGIN  
	 DECLARE @tempTable TABLE(Details NVARCHAR(500))  
	 DECLARE @tempDisplayTable Table (Id INT IDENTITY, displayName NVARCHAR(150), displayValue NVARCHAR(150))  
	 DECLARE @geoRefTable TABLE(Id INT IDENTITY, GeoRefId INT)  
	 DECLARE @geoRefId NVARCHAR(100), @location NVARCHAR(250), @xml XML  
  
  
	 --- Region to insert Makkah locations  
  
	 SET @geoRefId = (SELECT RLN.V.value('(text())[1]', 'nvarchar(max)')  
	  FROM cust.config_tblRLI(@configurationId) as R  
	 OUTER APPLY R.Rli.nodes('rli/mecca_rli') AS RLN(V))  
  
	 IF (@geoRefId IS NOT NULL)  
	 BEGIN  
	  IF(@geoRefId = '-10')  
	  BEGIN  
	   SET @location = 'Disabled'  
	  END  
	  ELSE IF(@geoRefId = '-1')  
	  BEGIN  
	   SET @location = 'Departure'  
	  END  
	  ELSE IF(@geoRefId = '-2')  
	  BEGIN  
	   SET @location = 'Destination'  
	  END  
	  ELSE IF(@geoRefId = '-3')  
	  BEGIN  
	   SET @location = 'Closest Location'  
	  END  
	  ELSE IF(@geoRefId = '-4')  
	  BEGIN  
	   SET @location = 'Current Location'  
	  END  
	  ELSE  
	  BEGIN  
	   SET @location = (SELECT GR.Description FROM dbo.config_tblGeoRef(@ConfigurationId) as GR WHERE GR.isMakkahPoi = 1 AND GR.GeoRefId = @geoRefId)  
	  END  
  
	  INSERT INTO @tempTable VALUES(@geoRefId + ',' + @location)  
	 END  
	 ELSE  
	 BEGIN  
	  INSERT INTO @tempTable VALUES('-3, Closest Location')  
	 END  
  
	 -- Region to get prayertime values  
	 SET @geoRefId = (SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId  
	 FROM cust.config_tblMakkah(@configurationId) as M 
	 OUTER APPLY M.Makkah.nodes('makkah/default_calculation_city') AS RLN(V))  
  
	 IF (@geoRefId IS NOT NULL)  
	 BEGIN  
	  IF(@geoRefId = '-1')  
	  BEGIN  
	   SET @location = 'Departure'  
	  END  
	  ELSE IF(@geoRefId = '-2')  
	  BEGIN  
	   SET @location = 'Destination'  
	  END  
	  ELSE IF(@geoRefId = '-3')  
	  BEGIN  
	   SET @location = 'Closest Location'  
	  END  
	  ELSE IF(@geoRefId = '-4')  
	  BEGIN  
	   SET @location = 'Current Location'  
	  END  
	  ELSE  
	  BEGIN  
	   SET @location = (SELECT GR.Description FROM dbo.config_tblGeoRef(@ConfigurationId) as GR WHERE GR.isMakkahPoi = 1 AND GR.GeoRefId = @geoRefId)  
	  END  
  
	  INSERT INTO @tempTable VALUES(@geoRefId + ',' + @location)  
	 END  
	 ELSE  
	 BEGIN  
	  INSERT INTO @tempTable VALUES('-3, Closest Location')  
	 END  
  
	 -- Region to select Makkah values  
	 SET @location = ISNULL((SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId  
	 FROM cust.config_tblMakkah(@configurationId) as M
	 OUTER APPLY M.Makkah.nodes('makkah/prayer_time_calculation') AS RLN(V)), '')
  
	 INSERT INTO @tempTable VALUES (@location)  
  
	 -- Region to get values for mecca display  
	 SET @xml = (SELECT Rli FROM cust.config_tblRLI(@configurationId) as R  )  
  
	 INSERT INTO @tempDisplayTable SELECT   
	 b.value('local-name(.)','varchar(50)') AS columnname,  
	 b.value('.','VARCHAR(MAX)') AS Valuename  
	 FROM @xml.nodes('/rli/mecca_display') p(k)  
	 CROSS APPLY k.nodes('@*') a(b) 
	 ORDER BY columnname ASC
  
	 WHILE (SELECT Count(*) FROM @tempDisplayTable) > 0  
	 BEGIN  
	  SET @location = (SELECT TOP 1 displayValue FROM @tempDisplayTable)  
  
	  INSERT INTO @tempTable VALUES(@location)  
  
	  DELETE TOP (1) FROM @tempDisplayTable  
	 END  
  
	 SELECT * FROM @tempTable  
END  
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get Makkah locations and available locations
-- Sample EXEC [dbo].[SP_Makkah_GetMakkahLocations] 1, 'prayertime'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Makkah_GetMakkahLocations]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Makkah_GetMakkahLocations]
END
GO

CREATE PROCEDURE [dbo].[SP_Makkah_GetMakkahLocations]
@ConfigurationId INT,
@type NVARCHAR(150)
AS
BEGIN
	DECLARE @tmpTable Table(geoRefId INT, Descriptions NVARCHAR(500))
	DECLARE @geoRefTable Table(ID INT IDENTITY, GeoRefID INT)
	DECLARE @Id INT, @Count INT

	IF (@type = 'prayertime')
	BEGIN

		INSERT INTO @geoRefTable SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId
		FROM cust.config_tblMakkah(@configurationId) as M
		OUTER APPLY M.Makkah.nodes('makkah/default_calculation_city') AS RLN(V)

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -4)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-4, 'Current Location')
		END

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -1)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-1, 'Departure')
		END

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -2)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-2, 'Destination')
		END
		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -2)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-3, 'Closest Location')
		END

		INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.config_tblGeoRef(@ConfigurationId) as GR WHERE GR.isMakkahPoi = 1
		AND GR.GeoRefId NOT IN (SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId
				FROM cust.config_tblMakkah(@configurationId) as M
				OUTER APPLY M.Makkah.nodes('makkah/default_calculation_city') AS RLN(V))
	END
	ELSE IF (@type = 'available')
	BEGIN
		
		INSERT INTO @geoRefTable SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId
		FROM cust.config_tblRLI(@configurationId) as R
		OUTER APPLY R.Rli.nodes('rli/mecca_rli') AS RLN(V)

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -10)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-10, 'Disabled')
		END

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -1)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-1, 'Departure')
		END

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -2)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-2, 'Destination')
		END

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -3)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-3, 'Closest Location')
		END

		INSERT INTO @tmpTable SELECT GR.GeoRefId, GR.Description FROM  dbo.config_tblGeoRef(@ConfigurationId) as GR WHERE GR.isMakkahPoi = 1
		AND GR.GeoRefId NOT IN (SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId
				FROM cust.config_tblRLI(@configurationId) as R
				OUTER APPLY R.Rli.nodes('rli/mecca_rli') AS RLN(V))
	END

	SELECT * FROM @tmpTable
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get Makkah prayer times
-- Sample EXEC [dbo].[SP_Makkah_GetMakkahPrayerTimes] 105
-- =============================================

IF OBJECT_ID('[dbo].[SP_Makkah_GetMakkahPrayerTimes]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Makkah_GetMakkahPrayerTimes]
END
GO

CREATE PROCEDURE [dbo].[SP_Makkah_GetMakkahPrayerTimes]
@ConfigurationId INT 
AS
BEGIN
	DECLARE @xmlValue NVARCHAR(500), @featuresetdisplayvalue NVARCHAR(MAX), @featuresetvalue NVARCHAR(MAX), @typeName NVARCHAR(500), @displayName NVARCHAR(MAX),
			@typeId INT, @displayID INT, @typefeatureset INT, @displayfeatureset INT

	SET @xmlValue = (SELECT MN.V.value('(text())[1]', 'nvarchar(max)')
			FROM cust.config_tblMakkah(@ConfigurationId) as M
			OUTER APPLY M.Makkah.nodes('makkah/prayer_time_calculation') AS MN(V))

	SET @featuresetvalue = (SELECT FS.Value FROM tblFeatureSet FS
			INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
			INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
			WHERE FS.Name = 'MakkahCalculation-TypesList' AND C.ConfigurationID = @ConfigurationId)

	SET @typefeatureset = (SELECT FS.FeatureSetID FROM tblFeatureSet FS
			INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
			INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
			WHERE FS.Name = 'MakkahCalculation-TypesList' AND C.ConfigurationID = @ConfigurationId)

	SET @featuresetdisplayvalue = (SELECT FS.Value FROM tblFeatureSet FS
			INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
			INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
			WHERE FS.Name = 'MakkahCalculation-TypesDisplayList' AND C.ConfigurationID = @ConfigurationId)

	SET @displayfeatureset = (SELECT FS.FeatureSetID FROM tblFeatureSet FS
			INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
			INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
			WHERE FS.Name = 'MakkahCalculation-TypesList' AND C.ConfigurationID = @ConfigurationId)

	DECLARE @tmpnametable TABLE(id INT IDENTITY(1,1), featureSetId INT, name NVARCHAR(500))
	DECLARE @tmpdisplaynametable TABLE(id INT IDENTITY(1,1), featureSetId INT, name NVARCHAR(500))
	DECLARE @outputTable TABLE(id INT IDENTITY(1,1), MakkahTypeName NVARCHAR(MAX), MakkahDisplayName NVARCHAR(MAX))

	INSERT INTO @tmpnametable (featureSetId, name) SELECT @typefeatureset, * FROM STRING_SPLIT(@featuresetvalue,',')

	INSERT INTO @tmpdisplaynametable (featureSetId, name) SELECT @displayfeatureset,* FROM STRING_SPLIT(@featuresetdisplayvalue,';')

	IF (@xmlValue IS NOT NULL)
	BEGIN
	INSERT INTO @outputTable(MakkahTypeName, MakkahDisplayName) SELECT A.name, B.name FROM @tmpnametable A
		LEFT JOIN @tmpdisplaynametable B ON a.featuresetid = B.featuresetid
		WHERE B.name LIKE '%' +  A.name + '%' AND A.name NOT IN (@xmlValue)
	END
	ELSE
	BEGIN
		INSERT INTO @outputTable(MakkahTypeName, MakkahDisplayName) SELECT A.name, B.name FROM @tmpnametable A
		LEFT JOIN @tmpdisplaynametable B ON a.featuresetid = B.featuresetid
		WHERE B.name LIKE '%' +  A.name + '%'
	END

	SELECT MakkahTypeName, MakkahDisplayName FROM @outputTable
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get Makkah locations and available locations
-- Sample EXEC [dbo].[SP_Makkah_UpdateMakkahLocationAndPrayerTimeLocation] 1, 'location'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Makkah_UpdateMakkahLocationAndPrayerTimeLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Makkah_UpdateMakkahLocationAndPrayerTimeLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_Makkah_UpdateMakkahLocationAndPrayerTimeLocation]
@ConfigurationId INT,
@data NVARCHAR(150),
@type NVARCHAR(150)
AS
BEGIN
	DECLARE @mappedMakkahId INT, @mappedRLIID INT, @updateKey INT, @currentXML XML, @RliId INT, @makkahID INT
	SET @mappedRLIID = (SELECT RLIID from cust.tblRLIMap WHERE configurationId = @configurationId)
	SET @mappedMakkahId = (SELECT MakkahID from cust.tblMakkahMap WHERE configurationId = @configurationId)

	IF (@type = 'available')
	BEGIN
		IF NOT @mappedRLIID IS NULL
       	BEGIN	
			EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblRLI', @mappedRLIID, @updateKey OUT
			IF EXISTS (SELECT R.Rli	FROM cust.config_tblRLI(@ConfigurationId) AS R WHERE R.Rli.exist('/rli/mecca_rli/text()') = 1 AND R.RLIID = @updateKey)
			BEGIN
				UPDATE R 
				SET Rli.modify('replace value of (/rli/mecca_rli/text())[1] with sql:variable("@data")') 
				FROM cust.config_tblRLI(@ConfigurationId) AS R WHERE R.RLIID = @updateKey
			END
			ELSE
			BEGIN
				SET @currentXML = ('<mecca_rli>'+ @data +'</mecca_rli>')
				UPDATE R 
				SET Rli.modify('insert sql:variable("@currentXML") into (/rli[1])') 
				FROM cust.config_tblRLI(@ConfigurationId) AS R WHERE R.RLIID = @updateKey    	
			END
		END	
		ELSE
		BEGIN
			SET @currentXML = ('<rli><mecca_rli>'+ @data +'</mecca_rli></rli>')

			INSERT INTO cust.tblRli(Rli) VALUES (@currentXML)
			SET @RliId = (SELECT MAX(RLIID) FROM cust.tblRli)

			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblRli', @RliId
		END
	END
	ELSE IF (@type = 'prayertime')
	BEGIN
		IF NOT @mappedMakkahId IS NULL
       	BEGIN	

			EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMakkah', @mappedMakkahId, @updateKey OUT
			IF EXISTS (SELECT M.Makkah FROM cust.config_tblMakkah(@configurationId) AS M WHERE M.Makkah.exist('/makkah/default_calculation_city/text()') = 1 AND M.MakkahId = @updateKey)
			BEGIN
				UPDATE M 
				SET Makkah.modify('replace value of (/makkah/default_calculation_city/text())[1] with sql:variable("@data")') 
				FROM cust.config_tblMakkah(@configurationId) AS M WHERE M.MakkahId = @updateKey
			END
			ELSE
			BEGIN
				SET @currentXML = ('<default_calculation_city>'+ @data +'</default_calculation_city>')
				UPDATE M 
				SET Makkah.modify('insert sql:variable("@currentXML") into (/makkah[1])') 
				FROM cust.config_tblMakkah(@ConfigurationId) AS M WHERE M.MakkahId = @updateKey    	
			END
		END
		ELSE
		BEGIN
			SET @currentXML = ('<makkah><default_calculation_city>'+ @data +'</default_calculation_city></makkah>')

			INSERT INTO cust.tblMakkah (Makkah) VALUES (@currentXML)
			SET @makkahID = (SELECT MAX(MakkahID) FROM cust.tblMakkah)

			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblMakkah', @makkahID
		END
	END
	ELSE IF (@type = 'calculation')
	BEGIN
		IF NOT @mappedMakkahId IS NULL
       	BEGIN	
		   	EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMakkah', @mappedMakkahId, @updateKey OUT
			IF EXISTS (SELECT M.Makkah FROM cust.config_tblMakkah(@configurationId) AS M WHERE M.Makkah.exist('/makkah/prayer_time_calculation/text()') = 1 AND M.MakkahId = @updateKey)
			BEGIN
				UPDATE M 
				SET Makkah.modify('replace value of (/makkah/prayer_time_calculation/text())[1] with sql:variable("@data")') 
				FROM cust.config_tblMakkah(@configurationId) AS M WHERE M.MakkahId = @updateKey
			END
			ELSE
			BEGIN
				SET @currentXML = ('<prayer_time_calculation>'+ @data +'</prayer_time_calculation>')
				UPDATE M 
				SET Makkah.modify('insert sql:variable("@currentXML") into (/makkah[1])') 
				FROM cust.config_tblMakkah(@ConfigurationId) AS M WHERE M.MakkahId = @updateKey    	
			END
		END
		ELSE
		BEGIN
			SET @currentXML = ('<makkah><prayer_time_calculation>'+ @data +'</prayer_time_calculation></makkah>')

			INSERT INTO cust.tblMakkah (Makkah) VALUES (@currentXML)
			SET @makkahID = (SELECT MAX(MakkahID) FROM cust.tblMakkah)

			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblMakkah', @makkahID
		END
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/27/2022
-- Description:	Get Maps section details
-- Sample EXEC [dbo].[SP_Maps_GetConfigurations] 201, 'mapPackage'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Maps_GetConfigurations]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Maps_GetConfigurations]
END
GO

CREATE PROCEDURE [dbo].[SP_Maps_GetConfigurations]
	@configurationId INT,
	@section NVARCHAR(250)
AS
BEGIN
	IF (@section = 'flyoveralerts')
	BEGIN
		SELECT 
        isnull(FlyOverAlert.value('(/flyover_alert/@active)[1]', 'varchar(max)'),'') as IsEnabled, 
        isnull(FlyOverAlert.value('(/flyover_alert/@alert_duration)[1]', 'INT'),'0') as AlertDuration, 
        isnull(FlyOverAlert.value('(/flyover_alert/@alert_sequential_delay)[1]', 'INT'),'0') as  AlertSequentialDelay,
        isnull(FlyOverAlert.value('(/flyover_alert/@lead_time)[1]', 'INT'),'') as ApproachAlertLeadTime
        FROM cust.tblFlyOverAlert 
        INNER JOIN cust.tblFlyOverAlertMap ON cust.tblFlyOverAlert.FlyOverAlertID = cust.tblFlyOverAlertMap.FlyOverAlertID 
        AND cust.tblFlyOverAlertMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = 'tabnavigation')
	BEGIN
        SELECT 
        isnull(WebMainItems.value('(/webmain/tab_nav/@active)[1]', 'varchar(max)'),'') as IsEnabled, 
        isnull(WebMainItems.value('(/webmain/tab_nav/@hover_color)[1]', 'varchar(max)'),'') as HoverColor, 
        isnull(WebMainItems.value('(/webmain/tab_nav/@next_hover_color)[1]', 'varchar(max)'),'') as NextHoverColor
        FROM cust.tblWebMain 
        INNER JOIN cust.tblWebMainMap ON cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID 
        AND cust.tblWebMainMap.ConfigurationID =  @configurationId
	END
	ELSE IF (@section = 'extendedtabnavigation')
	BEGIN
        SELECT  
        isnull(WebMainItems.value('(/webmain/extended_tab_nav/@active)[1]', 'varchar(max)'),'') as IsEnabled, 
        isnull(WebMainItems.value('(/webmain/extended_tab_nav/@timeout)[1]', 'FLOAT'),'0') as TimeOut, 
        isnull(WebMainItems.value('(/webmain/extended_tab_nav/map_pois/@highlighted_color)[1]', 'varchar(max)'),'') as HighlitedColor, 
        isnull(WebMainItems.value('(/webmain/extended_tab_nav/map_pois/@selected_color)[1]', 'varchar(max)'),'') as SelectedColor, 
        isnull(WebMainItems.value('(/webmain/extended_tab_nav/map_pois/@future_color)[1]', 'varchar(max)'),'') as FutureColor
        FROM cust.tblWebMain 
        INNER JOIN cust.tblWebMainMap ON cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID 
        AND cust.tblWebMainMap.ConfigurationID =  @configurationId
	END
	ELSE IF (@section = 'separators')
	BEGIN
        SELECT 
        isnull(Global.value('(/global/separators/@grouping)[1]', 'varchar(max)'),'') as Grouping, 
        isnull(Global.value('(/global/separators/@decimal)[1]', 'varchar(max)'),'') as Decimal
        FROM cust.tblGlobal 
        INNER JOIN cust.tblGlobalMap ON cust.tblGlobal.CustomID = cust.tblGlobalMap.CustomID 
        AND cust.tblGlobalMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = 'trackline')
	BEGIN
		SELECT 
        isnull(MapItems.value('(/maps/trackline/@color)[1]', 'varchar(max)'),'FF00FF00') as TrackLineColor,
        isnull(MapItems.value('(/maps/trackline/@width)[1]', 'FLOAT'),'0') as TrackLineWidth, 
        isnull(MapItems.value('(/maps/trackline/@style)[1]', 'varchar(max)'),'eSolid') as TrackLineStyle,
        isnull(MapItems.value('(/maps/ftrackline/@color)[1]', 'varchar(max)'),'FF00FF00') as FutureTrackLineColor, 
        isnull(MapItems.value('(/maps/ftrackline/@width)[1]', 'FLOAT'),'0') as FutureTrackLineWidth, 
        isnull(MapItems.value('(/maps/ftrackline/@style)[1]', 'varchar(max)'),'eDashed')  as FutureTrackLineStyle
        FROM cust.tblMaps 
        INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
        AND cust.tblMapsMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = '3dtrackline')
	BEGIN
		SELECT 
        isnull(MapItems.value('(/maps/trackline3d/past/@color)[1]', 'varchar(max)'),'FF00FF00') as TrackLineColor,
        isnull(MapItems.value('(/maps/trackline3d/past/@scale)[1]', 'FLOAT'),'0.0') as TrackLineWidth, 
        isnull(MapItems.value('(/maps/trackline3d/past/@style)[1]', 'varchar(max)'),'eSolid') as TrackLineStyle,
        isnull(MapItems.value('(/maps/trackline3d/future/@color)[1]', 'varchar(max)'),'FF00FF00') as FutureTrackLineColor, 
        isnull(MapItems.value('(/maps/trackline3d/future/@scale)[1]', 'FLOAT'),'0.0') as FutureTrackLineWidth, 
        isnull(MapItems.value('(/maps/trackline3d/future/@style)[1]', 'varchar(max)'),'eDashed') as FutureTrackLineStyle
        FROM cust.tblMaps 
        INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
        AND cust.tblMapsMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = 'borders')
	BEGIN
		SELECT 
        isnull(MapItems.value('(/maps/borders/@enabled)[1]', 'varchar(max)'),'false') as IsEnabled, 
        isnull(MapItems.value('(/maps/borders/@hk)[1]', 'varchar(max)'),'false') as IsHongKongEnabled, 
        isnull(MapItems.value('(/maps/broadcast_borders/@enabled)[1]', 'varchar(max)'),'false') as IsBroadcastEnabled
        FROM cust.tblMaps 
        INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
        AND cust.tblMapsMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = 'worldguide')
	BEGIN
		SELECT 
        isnull(WebMainItems.value('(/webmain/world_guide/@active)[1]', 'varchar(max)'),'') as IsEnabled
        FROM cust.tblWebMain 
        INNER JOIN cust.tblWebMainMap ON cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID 
        AND cust.tblWebMainMap.ConfigurationID =  @configurationId
	END
	ELSE IF (@section = 'help')
	BEGIN
		SELECT  
        isnull(WebMainItems.value('(/webmain/help_enabled)[1]', 'varchar(max)'),'') as IsEnabled
        FROM cust.tblWebMain 
        INNER JOIN cust.tblWebMainMap ON cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID 
        AND cust.tblWebMainMap.ConfigurationID =  @configurationId 
	END
	ELSE IF (@section = 'departure' OR @section = 'destination')
	BEGIN
		SELECT 
        isnull(MapItems.value('(/maps/dest_marker//@color)[1]', 'varchar(max)'),'') as DestinationMarkerColor, 
        isnull(MapItems.value('(/maps/depart_marker//@color)[1]', 'varchar(max)'),'') as DepartureMarkerColor 
        FROM cust.tblMaps 
        INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
        AND cust.tblMapsMap.ConfigurationID = @configurationId
	END
	ELSE IF (@section = 'mapPackage')
	BEGIN
		SELECT 
        ISNULL(MapItems.value('(/maps/map_package)[1]', 'varchar(max)'),'') as MapPackage 
        FROM cust.tblMaps 
        INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
        AND cust.tblMapsMap.ConfigurationID = @configurationId
	END
END
GO

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/27/2022
-- Description:	Get Maps layers details
-- Sample EXEC [dbo].[SP_Maps_GetLayers] 112, 'all'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Maps_GetLayers]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Maps_GetLayers]
END
GO

CREATE PROCEDURE [dbo].[SP_Maps_GetLayers]
	@configurationId INT,
	@type NVARCHAR(250)
AS
BEGIN
	 DECLARE @featuresetID INT
	   SET @featuresetID =( SELECT DISTINCT dbo.tblFeatureSet.FeatureSetID 
         FROM dbo.tblFeatureSet INNER JOIN dbo.tblConfigurationDefinitions ON dbo.tblFeatureSet.FeatureSetID = dbo.tblConfigurationDefinitions.FeatureSetID 
         INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionID
         AND dbo.tblConfigurations.ConfigurationID = @configurationId)

	IF (@type = 'layers')
	BEGIN 
		SELECT
        Nodes.LayerItem.value('(./@name)[1]','varchar(max)') as Name, 
        isnull(Nodes.LayerItem.value('(./@active)[1]','varchar(max)'),'false') as Active, 
        isnull(Nodes.LayerItem.value('(./@enable)[1]','varchar(max)'),'false') as Enabled
        FROM
        cust.tblMenu as Menu
        cross apply Menu.Layers.nodes('/category/item') as Nodes(LayerItem)
        INNER JOIN cust.tblMenuMap ON cust.tblMenuMap.MenuID = Menu.MenuID
        WHERE cust.tblMenuMap.ConfigurationID = @configurationId
	END
    ELSE IF (@type = 'all')
    BEGIN
        SELECT
        NameTable.Name as Name,
        DisplayNameTable.DisplayName as DisplayName
        FROM
        (SELECT 
        dbo.tblFeatureSet.Value as Name
        FROM 
        dbo.tblFeatureSet
        WHERE dbo.tblFeatureSet.Name = 'CustomConfig-Maps-LayersList'AND dbo.tblFeatureSet.FeatureSetID = @featuresetID) as NameTable,
        (SELECT 
        dbo.tblFeatureSet.Value as DisplayName
        FROM 
        dbo.tblFeatureSet
        WHERE dbo.tblFeatureSet.Name = 'CustomConfig-Maps-LayersDisplayList'AND dbo.tblFeatureSet.FeatureSetID = @featuresetID) as DisplayNameTable
    END
END
GO

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Adds new compass airplanes
-- Sample EXEC [dbo].[SP_Maps_UpdateSectionData] 35, 'extendedtabnavigation','active', 'false'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Maps_UpdateSectionData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Maps_UpdateSectionData]
END
GO

CREATE PROCEDURE [dbo].[SP_Maps_UpdateSectionData]
	@configurationId INT,
	@section NVARCHAR(250),
	@name NVARCHAR(250),
	@inputvalue NVARCHAR(250)
	
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX), @count INT, @ParmDefinition NVARCHAR(500), @returnMessage NVARCHAR(500),@updateKey int,@WebMainID int
	


	IF (@section = 'flyoveralerts')
	BEGIN
		SET @sql = N' SET @countret = (SELECT COUNT(FlyOverAlert.value(''(/flyover_alert/@'+ @name +')[1]'',''VARCHAR(500)'')) FROM cust.tblFlyOverAlert INNER JOIN cust.tblFlyOverAlertMap ON
				cust.tblFlyOverAlert.FlyOverAlertID = cust.tblFlyOverAlertMap.FlyOverAlertID AND cust.tblFlyOverAlertMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')
				'
				SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

		EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

		IF (@count > 0)
		BEGIN
		   DECLARE @FlyOverAlertID NVARCHAR(Max)
		   SET @FlyOverAlertID = (SELECT cust.tblFlyOverAlertMap.FlyOverAlertID FROM cust.tblFlyOverAlertMap WHERE cust.tblFlyOverAlertMap.ConfigurationID =  @configurationId)
		   EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblFlyOverAlert',@FlyOverAlertID,@updateKey out
			SET @sql = N' UPDATE cust.tblFlyOverAlert SET  FlyOverAlert.modify(''replace value of (/flyover_alert/@'+ @name +')[1] with sql:variable("@value")'')
					WHERE  FlyOverAlertID = '+ CAST( @updateKey AS NVARCHAR)
					SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'
             
			EXEC SP_EXECUTESQL @sql, @ParmDefinition,@value = @inputvalue OUTPUT

			SET @returnMessage = 'Success'
		END
		ELSE
		BEGIN
			SET @returnMessage = @name + ' does not exist in flyover_alert section'
		END
	END
	ELSE IF (@section = 'tabnavigation')
	BEGIN
		SET @sql = N' SET @countret = (SELECT COUNT(WebMainItems.value(''(/webmain/tab_nav/@'+ @name +')[1]'',''VARCHAR(500)'')) FROM cust.tblWebMain INNER JOIN cust.tblWebMainMap ON
				cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID AND cust.tblWebMainMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')
				'
				SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

		EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

		IF (@count > 0)
		BEGIN
		       
			  SET @WebMainID = (SELECT cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap WHERE cust.tblWebMainMap.ConfigurationID =  @configurationId)
		      EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWebMain',@WebMainID,@updateKey out
			SET @sql = N' UPDATE cust.tblWebMain SET  WebMainItems.modify(''replace value of (/webmain/tab_nav/@'+ @name +')[1] with sql:variable("@value")'')
					WHERE  WebMainID = '+ CAST( @updateKey AS NVARCHAR)
					SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'

			EXEC SP_EXECUTESQL @sql, @ParmDefinition, @value = @inputvalue OUTPUT
			
			SET @returnMessage = 'Success'
		END
		ELSE
		BEGIN
			SET @returnMessage = @name + ' does not exist in /webmain/tab_nav section'
		END
	END
	ELSE IF (@section = 'extendedtabnavigation')
	BEGIN
		IF CHARINDEX('color', @name) > 0
		BEGIN
			SET @sql = N' SET @countret = (SELECT COUNT(WebMainItems.value(''(/webmain/extended_tab_nav/map_pois/@'+ @name +')[1]'',''VARCHAR(500)''))
				   FROM cust.tblWebMain INNER JOIN cust.tblWebMainMap ON
				   cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID AND cust.tblWebMainMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')
				   '
				   SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

			EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

			IF (@count > 0)
			BEGIN
			   
				 SET @WebMainID = (SELECT cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap WHERE cust.tblWebMainMap.ConfigurationID =  @configurationId)
		         EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWebMain',@WebMainID,@updateKey out
				SET @sql = N' UPDATE cust.tblWebMain SET  WebMainItems.modify(''replace value of (/webmain/extended_tab_nav/map_pois/@'+ @name +')[1] with sql:variable("@value")'')
					    WHERE  WebMainID = '+ CAST( @updateKey AS NVARCHAR)
						SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'

				EXEC SP_EXECUTESQL @sql, @ParmDefinition, @value = @inputvalue OUTPUT

				SET @returnMessage = 'Success'
			END
			ELSE
			BEGIN
				SET @returnMessage = @name + ' does not exist in /webmain/extended_tab_nav/map_pois/ section'
			END
		END
		ELSE
		BEGIN
			SET @sql = N' SET @countret = (SELECT COUNT(WebMainItems.value(''(/webmain/extended_tab_nav/@'+ @name +')[1]'',''VARCHAR(500)''))
				   FROM cust.tblWebMain INNER JOIN cust.tblWebMainMap ON
				   cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID AND cust.tblWebMainMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')
				   '
				   SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

			EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

			IF (@count > 0)
			BEGIN
			      
				  SET @WebMainID = (SELECT cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap WHERE cust.tblWebMainMap.ConfigurationID =  @configurationId)
		         EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWebMain',@WebMainID,@updateKey out
				SET @sql = N' UPDATE cust.tblWebMain SET  WebMainItems.modify(''replace value of (/webmain/extended_tab_nav/@'+ @name +')[1] with sql:variable("@value")'')
					    WHERE WebMainID = '+ CAST( @updateKey AS NVARCHAR)
						SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'

				EXEC SP_EXECUTESQL @sql, @ParmDefinition, @value = @inputvalue OUTPUT

				SET @returnMessage = 'Success'
			END
			ELSE
			BEGIN
				SET @returnMessage = @name + ' does not exist in /webmain/extended_tab_nav/ section'
			END
		END
	END
	ELSE IF (@section = 'separators')
	BEGIN
		SET @sql = N' SET @countret = (SELECT COUNT(Global.value(''(/global/separators/@'+ @name +')[1]'',''VARCHAR(500)'')) FROM cust.tblGlobal INNER JOIN cust.tblGlobalMap ON
				cust.tblGlobal.CustomID = cust.tblGlobalMap.CustomID AND cust.tblGlobalMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')
				'
				SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

		EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

		IF (@count > 0)
		BEGIN 
		 DECLARE @CustomID Int
		SET @CustomID=( SELECT distinct cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap WHERE cust.tblGlobalMap.ConfigurationID =@configurationId)
		        EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblGlobal',@CustomID,@updateKey out
			SET @sql = N' UPDATE cust.tblGlobal SET  Global.modify(''replace value of (/global/separators/@'+ @name +')[1] with sql:variable("@value")'')
					WHERE cust.tblGlobal.CustomID  '+ CAST( @updateKey AS NVARCHAR)
					SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'

			EXEC SP_EXECUTESQL @sql, @ParmDefinition, @value = @inputvalue OUTPUT

			SET @returnMessage = 'Success'
		END
		ELSE
		BEGIN
			SET @returnMessage = @name + ' does not exist in /global/separators/ section'
		END
	END
	ELSE IF (@section = 'help')
	BEGIN
		SET @sql = N' SET @countret = (SELECT COUNT(WebMainItems.value(''(/webmain/'+ @name +')[1]'',''VARCHAR(500)'')) FROM cust.tblWebMain INNER JOIN cust.tblWebMainMap ON
				cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID AND cust.tblWebMainMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')
				'
				SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

		EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

		IF (@count > 0)
		BEGIN
		    
			  SET @WebMainID = (SELECT cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap WHERE cust.tblWebMainMap.ConfigurationID =  @configurationId)
		     EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWebMain',@WebMainID,@updateKey out
			SET @sql = N' UPDATE cust.tblWebMain SET  WebMainItems.modify(''replace value of (/webmain/'+ @name +'/text())[1] with sql:variable("@value")'')
					WHERE  WebMainID = '+ CAST( @updateKey AS NVARCHAR)
					SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'

			EXEC SP_EXECUTESQL @sql, @ParmDefinition, @value = @inputvalue OUTPUT

			SET @returnMessage = 'Success'
		END
		ELSE
		BEGIN
			SET @returnMessage = @name + ' does not exist in /webmain/ section'
		END
	END
	ELSE IF (@section = 'worldguide')
	BEGIN
		SET @sql = N' SET @countret = (SELECT COUNT(WebMainItems.value(''(/webmain/world_guide/'+'@'+ @name +')[1]'',''VARCHAR(500)'')) FROM cust.tblWebMain INNER JOIN cust.tblWebMainMap ON
				cust.tblWebMain.WebMainID = cust.tblWebMainMap.WebMainID AND cust.tblWebMainMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')
				'
				SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

		EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

		IF (@count > 0)
		BEGIN
		       
			   SET @WebMainID = (SELECT cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap WHERE cust.tblWebMainMap.ConfigurationID =  @configurationId)
		     EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWebMain',@WebMainID,@updateKey out
			SET @sql = N' UPDATE cust.tblWebMain SET  WebMainItems.modify(''replace value of (/webmain/world_guide/'+'@'+ @name +')[1] with sql:variable("@value")'')
					WHERE WebMainID = '+ CAST( @updateKey AS NVARCHAR)
					SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'

			EXEC SP_EXECUTESQL @sql, @ParmDefinition, @value = @inputvalue OUTPUT

			SET @returnMessage = 'Success'
		END
		ELSE
		BEGIN
			SET @returnMessage = @name + ' does not exist in /webmain/ section'
		END
	END
	ELSE IF (@section = 'trackline' OR @section = 'futuretrackline' OR @section = '3dtrackline' OR @section = 'future3dtrackline' OR @section = 'departure' OR @section = 'destination'
			OR @section = 'departure/destination' OR @section = 'borders' OR @section = 'broadcastborders')
	BEGIN
		DECLARE @prefix NVARCHAR(300)
		IF (@section = 'trackline')
		BEGIN
			SET @prefix = '/maps/trackline/'
		END
		ELSE IF (@section = 'futuretrackline')
		BEGIN
			SET @prefix = '/maps/ftrackline/'
		END
		ELSE IF (@section = '3dtrackline')
		BEGIN
			SET @prefix = '/maps/trackline3d/past/'
		END
		ELSE IF (@section = 'future3dtrackline')
		BEGIN
			SET @prefix = '/maps/trackline3d/future/'
		END
		ELSE IF (@section = 'departure')
		BEGIN
			SET @prefix = '/maps/depart_marker/'
		END
		ELSE IF (@section = 'destination')
		BEGIN
			SET @prefix = '/maps/dest_marker/'
		END
		ELSE IF (@section = 'borders')
		BEGIN
			SET @prefix = '/maps/borders/'
		END
		ELSE IF (@section = 'broadcastborders')
		BEGIN
			SET @prefix = '/maps/broadcast_borders/'
		END
		ELSE
		BEGIN
			SET @prefix = ''
		END
		SET @sql = N' SET @countret = (SELECT COUNT(MapItems.value(''('+ @prefix +'@'+ @name +')[1]'',''VARCHAR(500)'')) FROM cust.tblMaps INNER JOIN cust.tblMapsMap ON
				cust.tblMaps.MapID = cust.tblMapsMap.MapID AND cust.tblMapsMap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ')'
				SET @ParmDefinition = N'@countret NVARCHAR(MAX) OUTPUT'

		EXEC SP_EXECUTESQL @sql,@ParmDefinition, @countret = @count OUTPUT

		IF (@count > 0)
		BEGIN
		    DECLARE @MapID NVARCHAR(Max)
		    SET @MapID = (SELECT cust.tblMapsMap.MapID FROM cust.tblMapsMap WHERE cust.tblMapsMap.ConfigurationID =  @configurationId)
			EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMaps',@MapID,@updateKey out
			SET @sql = N' UPDATE cust.tblMaps SET  MapItems.modify(''replace value of ('+ @prefix +'@'+ @name +')[1] with sql:variable("@value")'')
					WHERE MapID = '+ CAST( @updateKey AS NVARCHAR)
					SET @ParmDefinition = N'@value nvarchar(max) OUTPUT'

			EXEC SP_EXECUTESQL @sql, @ParmDefinition,@value = @inputvalue OUTPUT

			SET @returnMessage = 'Success'
		END
		ELSE
		BEGIN
			SET @returnMessage = @name + ' does not exist in /webmain/ section'
		END
	END

	SELECT @returnMessage AS message
END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	get the maximum script id
-- Sample: EXEC [dbo].[SP_MaxScriptId] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_MaxScriptId]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_MaxScriptId]
END
GO

CREATE PROCEDURE [dbo].[SP_MaxScriptId]
        @configurationId INT
       
AS

BEGIN

                    SELECT MAX(ISNULL(Nodes.item.value('(./@id)[1]','int'),0)) AS maxScriptId 
                    FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c ON c.ScriptDefID = b.ScriptDefID
                    CROSS APPLY b.ScriptDefs.nodes('/script_defs/script') Nodes(item) WHERE ConfigurationID  = @configurationId
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	Update max script Id based on configurationId and xmlScript
-- Sample: EXEC [dbo].[SP_MaxScriptIdDefs] 1,'ENGLISH'
-- =============================================
IF OBJECT_ID('[dbo].[SP_MaxScriptIdDefs]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_MaxScriptIdDefs]
END
GO

CREATE PROCEDURE [dbo].[SP_MaxScriptIdDefs]
        @configurationId INT,
		@xmlScript  NVARCHAR(100)
		
		
		       
AS

BEGIN
            DECLARE @sql NVARCHAR(Max),@scriptDefId Int,@updateKey Int
			 DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
			     SELECT @scriptDefId=ScriptDefID FROM cust.tblScriptDefsMap WHERE ConfigurationID =  @configurationId
			  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey out
            SET @sql=('update [cust].[tblscriptdefs] 
                    set scriptdefs.modify(''insert  '+@xmlScript +'  as last into (/script_defs)[1]'') 
                    from cust.tblscriptdefs b inner join[cust].tblscriptdefsmap c on c.scriptdefid = b.scriptdefid 
                   cross apply b.scriptdefs.nodes(''/script_defs'') nodes(item) where configurationid = @configurationid AND  b.ScriptDefID = @updateKey')
			 EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey 
END
GO


GO

GO
DROP PROC IF EXISTS SP_MergeConfiguration_MergeConflictCount
GO
CREATE PROC SP_MergeConfiguration_MergeConflictCount
@taskId UNIQUEIDENTIFIER 
AS
BEGIN
SELECT COUNT(1) AS count FROM tblMergeDetails WHERE TaskId=@taskId
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 10/17/2022
-- Description:	Populate the merge details table with the keys of parent configuration AND child configuration for all the table. This data will be used to populate the screen with values.
-- Sample EXEC [dbo].[SP_MergeConfiguration_PopulateMergeDetails] 105, 112, '5CAA57A1-2DE9-403C-9756-01CCE173A06C'
-- =============================================

IF OBJECT_ID('[dbo].[SP_MergeConfiguration_PopulateMergeDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_MergeConfiguration_PopulateMergeDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_MergeConfiguration_PopulateMergeDetails]
@configurationId INT,
@parentConfigurationId INT,
@taskId uniqueidentifier
AS
BEGIN
	DECLARE @config_table VARCHAR(100), @sqlUpdateStatement NVARCHAR(MAX), @sqlDeleteStatement NVARCHAR(MAX), @sqlInsertStatement NVARCHAR(MAX)
	BEGIN TRY
		UPDATE tblTasks SET DetailedStatus = 'In Progress', TaskStatusID = 2, DateLastUpdated = GETDATE() WHERE ID = @taskId
		BEGIN TRAN
			DECLARE cur_tbl CURSOR  LOCAL STATIC FORWARD_ONLY READ_ONLY FOR
			SELECT tblName FROM tblConfigTables WHERE IsUsedForMergeConfiguration = 1
		
			OPEN cur_tbl

				FETCH next FROM cur_tbl INTO @config_table
				WHILE @@FETCH_STATUS = 0

				BEGIN

					DECLARE @mapTable VARCHAR(MAX) = @config_table + 'Map'
					DECLARE @mapColumn VARCHAR(MAX), @dataColumn VARCHAR(MAX), @mapSchema VARCHAR(MAX)

					EXEC dbo.Sp_configmanagement_findmappingbetween
						@mapTable, @config_table, @mapColumn output, @dataColumn output, @mapSchema output

					-- Inserting data when parent configuration data is changed
					SET @sqlUpdateStatement = 'INSERT INTO tblMergeDetails (TaskId, TableName, ParentKey, ChildKey, MergeChoice, SelectedKey, action)
							SELECT ''' + CONVERT(NVARCHAR(36), @taskId) + ''',''' + @config_table + ''',' + 'source.' + @mapColumn + ',' + 
							'destination.' + @mapColumn + ', 2, NULL, ''Update'' FROM
							' + @mapSchema + '.' + @mapTable + '(NOLOCK) destination INNER JOIN ' + @mapSchema + '.' + @mapTable + '(NOLOCK) source ON 
							source.Previous' + @mapColumn + ' = destination.'+ @mapColumn +' AND source.configurationid = '''+
							CAST(@parentConfigurationId AS NVARCHAR) +''' AND destination.configurationId =''' + CAST(@configurationId AS NVARCHAR) + '''
							AND destination.' + @mapColumn + ' <> source.'+ @mapColumn +';';

					EXEC (@sqlUpdateStatement)

					-- Inserting data when parent configuration data is deleted
					SET @sqlDeleteStatement = 'INSERT INTO tblMergeDetails (TaskId, TableName, ParentKey, ChildKey, MergeChoice, SelectedKey, action)
							SELECT ''' + CONVERT(nvarchar(36), @taskId) + ''',''' + @config_table + ''',' + 'source.' + @mapColumn + ',' + 'destination.'+ @mapColumn + ',
							1, NULL, ''Delete'' FROM  '+ @mapSchema + '.' + @mapTable +'  (NOLOCK) destination INNER JOIN '+ @mapSchema + '.' + @mapTable +'
							(NOLOCK) source ON source.' + @mapColumn + ' = destination.' + @mapColumn + ' AND source.configurationId = ''' + 
							Cast(@parentConfigurationId AS NVARCHAR) + ''' AND source.isDeleted = 1 AND 
							destination.configurationId IN(''' + Cast(@configurationId AS NVARCHAR) + ''');';

					 EXEC (@sqlDeleteStatement)

					-- Inserting data when new data is added to parent configuration
					SET @sqlInsertStatement = 'INSERT INTO tblMergeDetails (TaskId, TableName, ParentKey, ChildKey, MergeChoice, SelectedKey, action)
							SELECT ''' + CONVERT(nvarchar(36), @taskId) + ''',''' + @config_table + ''',' + @mapColumn + ',' + 'NULL, 1, NULL, ''Insert'' FROM 
							'+ @mapSchema + '.' + @mapTable + ' (NOLOCK) WHERE ' + @mapColumn + ' NOT IN (SELECT ' + @mapColumn + ' FROM ' + @mapSchema +
							'.' + @mapTable + ' (NOLOCK) WHERE configurationid IN(''' + Cast(@configurationId AS NVARCHAR) + ''')) AND  ' + @mapSchema + '.'
							+ @mapTable + '.configurationId = ''' + Cast(@parentConfigurationId AS NVARCHAR) + ''' AND '
							+ @mapSchema + '.' + @mapTable + '.isdeleted = 0 AND ' + @mapSchema + '.' + @mapTable + '.Previous' + @mapColumn + ' = 0;'

					 EXEC (@sqlInsertStatement)

					--Check if same record is updated in the another versions of Parent configuration 
					--and then update the latest mapcolumn value in merge details table ParentKey field
					DECLARE @tempDetails TABLE
					( id INT IDENTITY,
					  CurrentKey INT
					);
					DELETE FROM @tempDetails
					INSERT INTO @tempDetails
					SELECT ParentKey FROM tblMergeDetails WHERE TableName = @config_table AND TaskId = @taskId
					DECLARE @cnt INT
					DECLARE @cnt_total INT
					DECLARE @CurrentKey INT
					IF (SELECT COUNT(*) FROM @tempDetails) > 0
					BEGIN
						SELECT @cnt = min(id) , @cnt_total = max(id) FROM @tempDetails
						--Loop and update the latest mapping id
						WHILE @cnt <= @cnt_total
						BEGIN
							SELECT @CurrentKey = CurrentKey FROM @tempDetails WHERE id = @cnt 
							DECLARE @MergeDetailsUpdateStatement NVARCHAR(MAX)
							SET @MergeDetailsUpdateStatement = 'IF EXISTS (SELECT 1 FROM ' + @mapSchema + '.' + @mapTable + ' WHERE ' + @mapSchema + '.' + @mapTable + '.Previous' + @mapColumn + ' = ' + Cast(@CurrentKey AS NVARCHAR) + ' AND ConfigurationID = ' + Cast(@parentConfigurationId AS NVARCHAR) + ')' 
							 + 'BEGIN '
							 + 'UPDATE tblMergeDetails SET ParentKey = (SELECT ' + @mapColumn + ' FROM ' + @mapSchema + '.' + @mapTable + ' WHERE '+ @mapSchema + '.' + @mapTable + '.Previous' + @mapColumn + ' = ' + Cast(@CurrentKey AS NVARCHAR) + ' AND ConfigurationID = ' + Cast(@parentConfigurationId AS NVARCHAR)  + ')' 
							 + ' WHERE ParentKey = ' + Cast(@CurrentKey AS NVARCHAR) 
							 + ' AND TaskId = ''' + convert(NVARCHAR(36), @taskId)
							 + ''' END'
							--PRINT @MergeDetailsUpdateStatement
							EXEC (@MergeDetailsUpdateStatement)
							SET @cnt = @cnt + 1
						END
					END
					FETCH next FROM cur_tbl INTO @config_table
				END

			CLOSE cur_tbl
			DEALLOCATE cur_tbl
			
			COMMIT TRAN
		END TRY

		BEGIN CATCH
			ROLLBACK TRAN
			UPDATE tblTasks SET DetailedStatus = 'Not Started', TaskStatusID = 1, DateLastUpdated = GETDATE() WHERE ID = @taskId
			--print 'after update'
		END CATCH
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 09/28/2022
-- Description:	To get version number locked date and release notes for given configurationid
-- Sample EXEC [dbo].[SP_MergeConfig_GetUpdatesDetails] 2
-- =============================================

IF OBJECT_ID('[dbo].[SP_MergeConfig_GetUpdatesDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_MergeConfig_GetUpdatesDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_MergeConfig_GetUpdatesDetails]
	@configurationDefinitionID INT
AS
BEGIN

DECLARE @parentVersion INT
DECLARE @ChildVersion INT,@parentDefId INT

select @parentDefId=ConfigurationDefinitionParentID from tblConfigurationDefinitions where ConfigurationDefinitionID=@configurationDefinitionID and ConfigurationDefinitionParentID>0 and ConfigurationDefinitionParentID!=ConfigurationDefinitionID

select @ChildVersion= ISNULL(CD.UpdatedUpToVersion, 0)
from tblConfigurations C INNER JOIN tblConfigurationDefinitions CD on c.ConfigurationDefinitionID=cd.ConfigurationDefinitionID
where cd.ConfigurationDefinitionID=@configurationDefinitionID and c.Locked=1 group by c.ConfigurationDefinitionID,CD.UpdatedUpToVersion

	SELECT C.Version, C.LockDate, C.LockComment, C.ConfigurationID FROM tblConfigurations C 
	WHERE  Locked = 1 AND C.ConfigurationDefinitionID = @parentDefId AND Version>@ChildVersion
	
	ORDER BY C.Version DESC
END
GO
GO

/****** Object:  StoredProcedure [dbo].[SP_MergeConflicts_GetConflictData]    Script Date: 10/25/2022 11:03:23 AM ******/
IF OBJECT_ID('[dbo].[SP_MergeConflicts_GetConflictData]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_MergeConflicts_GetConflictData]
END
GO
/****** Object:  StoredProcedure [dbo].[SP_MergeConflicts_GetConflictData]    Script Date: 10/25/2022 11:03:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_MergeConflicts_GetConflictData]
	@taskID UNIQUEIDENTIFIER = NULL
AS
BEGIN
	DROP TABLE IF EXISTS #TEMP_RESULT
	CREATE TABLE #TEMP_RESULT (ID INT, ContentID INT, ContentType NVARCHAR(max), Description NVARCHAR(max),DisplayName NVARCHAR(MAX), ParentValue NVARCHAR(MAX), ChildValue NVARCHAR(MAX),SelectedValue NVARCHAR(MAX))
	INSERT INTO #TEMP_RESULT
	EXEC SP_getCountryConflicts @taskID
	INSERT INTO #TEMP_RESULT
	EXEC SP_getPlaceNameConflicts @taskID
	INSERT INTO #TEMP_RESULT
	EXEC SP_getRegionConflicts @taskID
	INSERT INTO #TEMP_RESULT
	EXEC SP_getAirportConflicts @taskID
	SELECT * FROM #TEMP_RESULT ORDER BY ID
END
GO

/****** Object:  StoredProcedure [dbo].[SP_MergeConflicts_UpdateSelection]    Script Date: 10/25/2022 11:03:23 AM ******/
IF OBJECT_ID('[dbo].[SP_MergeConflicts_UpdateSelection]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_MergeConflicts_UpdateSelection]
END
GO
/****** Object:  StoredProcedure [dbo].[SP_MergeConflicts_UpdateSelection]    Script Date: 10/25/2022 11:03:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_MergeConflicts_UpdateSelection]
	@taskId UNIQUEIDENTIFIER,
	@collinsContentIds NVARCHAR(MAX) = NULL, --'1,2,3'
	@childContentIds NVARCHAR(MAX) = NULL, --'1,2,3'
	@status INT = NULL
AS
BEGIN

	IF @CollinsContentIds IS NOT NULL
	BEGIN
		UPDATE tblMergeDetails SET SelectedKey = ParentKey, MergeChoice = @status WHERE TaskId = @taskId AND
			ID IN (select value from STRING_SPLIT(@collinsContentIds, ','))
	END
	IF @ChildContentIds IS NOT NULL
	BEGIN
		UPDATE tblMergeDetails SET SelectedKey = ChildKey, MergeChoice = @status WHERE TaskId = @taskId AND 
			ID IN (select value from STRING_SPLIT(@childContentIds, ','))
	END
END
GO

DROP PROCEDURE IF EXISTS [dbo].[SP_MergeConflict_MoveDataToMapTable]
--[dbo].[Sp_mergeconflict_movedatatomaptable]	 105,'d9978e53-2715-461d-b5d2-7c8c05896286'
GO
SET ansi_nulls ON
GO
SET quoted_identifier ON
GO
CREATE PROC [dbo].[Sp_mergeconflict_movedatatomaptable]
  @configurationId INT,
  @taskId UNIQUEIDENTIFIER
AS
  BEGIN
    SELECT *
    INTO   #tempmergedetails_updated
    FROM   tblmergedetails
    WHERE  taskid=@taskId
    AND    (selectedkey!=childkey OR SelectedKey IS NULL)
    --Added records will be added here
    -- lop the above results and insert/update into the mapping for the child config id

	SELECT * FROM #tempmergedetails_updated
    DECLARE cur_tbl CURSOR local static forward_only read_only FOR
    SELECT tablename,
           selectedkey,
           childkey,
           action
    FROM   #tempmergedetails_updated
    OPEN cur_tbl
    DECLARE @tableName VARCHAR(50),
      @ChildKey        INT,
      @selectedKey     INT,
      @action          VARCHAR(20)
    FETCH next
    FROM  cur_tbl
    INTO  @tableName,
          @selectedKey,
          @ChildKey,
          @action
    print @tableName
    WHILE @@FETCH_STATUS = 0
    BEGIN
      DECLARE @sql_update NVARCHAR(max)
      DECLARE @mapTable   VARCHAR(max) = @tableName + 'Map'
      DECLARE @mapColumn  VARCHAR(max)
      DECLARE @dataColumn VARCHAR(max)
      DECLARE @mapSchema  VARCHAR(max)
      EXEC dbo.Sp_configmanagement_findmappingbetween
        @mapTable,
        @tableName,
        @mapColumn output,
        @dataColumn output,
        @mapSchema output
      IF @action = 'update'
      BEGIN
        SET @sql_update= 'update toUpdate set Previous'+@mapColumn +' = toUpdate.'+@mapColumn+', toUpdate.'+@mapColumn+' = '+Cast(@selectedKey AS NVARCHAR)+' FROM '
		+@mapSchema + '.' + @mapTable+' (nolock) toUpdate WHERE toUpdate.configurationId IN( '+Cast(@configurationId AS NVARCHAR)+' ) AND 
		toUpdate.'+@mapColumn+' = '+Cast(@ChildKey AS NVARCHAR)+' AND '+Cast(@ChildKey AS NVARCHAR)+' <> '+Cast(@selectedKey AS NVARCHAR)+';';
        print @sql_update
		EXEC sys.Sp_executesql
          @sql_update
      END
      ELSE
      IF @action='Insert'
      BEGIN
        DECLARE @sql_insert NVARCHAR(max)
        SET @sql_insert='insert into '+@mapSchema + '.' + @mapTable+' ('+@mapColumn+', configurationid, Previous'+@mapColumn+', isdeleted) VALUES( '+ @selectedKey+','+@configurationId+',NULL,0)';
        EXEC sys.Sp_executesql
          @sql_insert
      END
      ELSE
      IF @action = 'Delete'
      BEGIN
        DECLARE @sql_delete NVARCHAR(max)
        SET @sql_delete= 'update toUpdate set toUpdate.isDeleted = 1 from '+@mapSchema + '.' + @mapTable+'  (NOLOCK) toUpdate toUpdate.'+@mapColumn+'='+@selectedKey+' toUpdate.configurationId IN( '+Cast(@configurationId AS NVARCHAR)+' );';
        EXEC sys.Sp_executesql
          @sql_delete
      END

FETCH next
    FROM  cur_tbl
    INTO  @tableName,
          @selectedKey,
          @ChildKey,
          @action

    END
    CLOSE cur_tbl
    DEALLOCATE cur_tbl
  END
  
  GO
GO

GO
DROP PROC IF EXISTS SP_MergeConflict_SetConfigUpdatedVersion
GO
CREATE PROC SP_MergeConflict_SetConfigUpdatedVersion
@parentConfigId INT,
@childConfigDefId INT
AS
BEGIN

DECLARE @version INT;

SELECT @version=Version FROM tblConfigurations WHERE ConfigurationID=@parentConfigId;

UPDATE tblConfigurationDefinitions SET UpdatedUpToVersion=@version WHERE ConfigurationDefinitionID=@childConfigDefId;

END

GO
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	add new mode
-- Sample EXEC [dbo].[sp_mode_addmode] 1, 'test',1,1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_addmode]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_addmode]
END
GO

CREATE PROC [dbo].[sp_mode_addmode]
@modeId INT,
@name NVARCHAR(200),
@scriptId INT,
@configurationId INT

AS 
BEGIN

DECLARE @strModeNode xml = '<mode_defs><mode id ="' +cast(@modeId as varchar) +'" name = "' + @name + '"> ' +
                                    '<mode_item channel="1" scriptidref=  "'+ cast(@scriptId as varchar) +' " type="analog" /> ' +
                                    '<mode_item channel="1" scriptidref= "' + cast(@scriptId as varchar) + '"  type="digital3d" />' +
                                    '<mode_item channel="2" scriptidref= "' + cast(@scriptId as varchar) + '"  type="analog" />'  +
                              ' </mode></mode_defs>'

						UPDATE cust.tblModeDefs 
                        SET ModeDefs =  @strModeNode 
                         WHERE cust.tblModeDefs.ModeDefID IN ( 
                        SELECT distinct cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap 
                        WHERE cust.tblModeDefsMap.ConfigurationID = @configurationId)
END
GO


GO



/****** Object:  StoredProcedure [dbo].[sp_mode_addmodeitem]    Script Date: 1/30/2022 9:14:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	add new mode
-- Sample EXEC [dbo].[sp_mode_addmodeitem] 1,'test',1,1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_addmodeitem]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_addmodeitem]
END
GO
CREATE PROC [dbo].[sp_mode_addmodeitem]
@modeId INT,
@name NVARCHAR(200),
@scriptId INT,
@configurationId INT


AS 
BEGIN

DECLARE @strModeDef xml = '<mode id ="' +cast(@modeId as varchar) +'" name = "' + @name + '"> ' +
                                    '<mode_item channel="1" scriptidref=  "'+ cast(@scriptId as varchar) +' " type="analog" /> ' +
                                    '<mode_item channel="1" scriptidref= "' + cast(@scriptId as varchar) + '"  type="digital3d" />' +
                                    '<mode_item channel="2" scriptidref= "' + cast(@scriptId as varchar) + '"  type="analog" />'  +
                              ' </mode>'

	declare @modeNode xml = cast(@strModeDef as xml), @updateKey int,@ModeDefID INT
	SET @ModeDefID = (SELECT cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap WHERE cust.tblModeDefsmap.ConfigurationID = @configurationId)
	  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblModeDefs',@ModeDefID,@updateKey out
	
					    UPDATE cust.tblModeDefs 
                        SET ModeDefs.modify(' insert sql:variable("@modeNode") into /mode_defs[1]') 
                        WHERE cust.tblModeDefs.ModeDefID IN ( 
                        SELECT distinct cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap 
                        WHERE cust.tblModeDefsMap.ConfigurationID = @configurationId AND ModeDefId = @updateKey)
						
						

END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_mode_getallmodes]    Script Date: 1/30/2022 9:16:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	get modes for config
-- Sample EXEC [dbo].[sp_mode_getallmodes] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_getallmodes]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_getallmodes]
END
GO

CREATE PROC [dbo].[sp_mode_getallmodes] 
@configurationId INT 
AS
BEGIN

SELECT DISTINCT 
                ModesResult.ModeName as Name,
                ModesResult.ModeId as Id,
                ScriptIdLookup.ScriptName as ScriptName,
                ScriptIdLookup.ScriptId as ScriptId

                FROM

                (SELECT 
                isnull(Nodes.Mode.value('(./@name)[1]', 'varchar(max)'),'') as ModeName,
                isnull(Nodes.Mode.value('(./@id)[1]', 'varchar(max)'),'') as ModeId,
                isnull(Nodes.Mode.value('(./mode_item/@scriptidref)[1]', 'varchar(max)'),'') as ScriptId
                FROM cust.tblModeDefs as Modes
                cross apply Modes.ModeDefs.nodes('/mode_defs/mode') as Nodes(Mode)
                INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID
                AND cust.tblModeDefsMap.ConfigurationID = @configurationId)

                as ModesResult

                LEFT OUTER JOIN(
                   SELECT
                isnull(Nodes.Script.value('(./@name)[1]', 'varchar(max)'),'') as ScriptName,
                isnull(Nodes.Script.value('(./@id)[1]', 'varchar(max)'),'') as ScriptId
                FROM cust.tblScriptDefs as Scripts
                cross apply Scripts.ScriptDefs.nodes('/script_defs/script') as Nodes(Script)
                INNER JOIN cust.tblScriptDefsMap ON cust.tblScriptDefsMap.ScriptDefID = Scripts.ScriptDefID
                AND cust.tblScriptDefsMap.ConfigurationID = @configurationId
                )

                as ScriptIdLookup ON ScriptIdLookup.ScriptId = ModesResult.ScriptId

END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_mode_getmaxmodedefid]    Script Date: 1/30/2022 9:17:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	get max modedef id
-- Sample EXEC [dbo].[sp_mode_getmaxmodedefid] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_getmaxmodedefid]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_getmaxmodedefid]
END
GO

CREATE PROC [dbo].[sp_mode_getmaxmodedefid]
@configurationId INT
AS
BEGIN

SELECT
                        isnull(Max(Nodes.Mode.value('(./@id)', 'int')),'0')
                        FROM cust.tblModeDefs as Modes
                        CROSS APPLY Modes.ModeDefs.nodes('/mode_defs/mode') as Nodes(Mode)
                        INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID 
                        AND cust.tblModeDefsMap.ConfigurationID = @configurationId

END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_mode_getmaxmodeid]    Script Date: 1/30/2022 9:18:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	get max mode id
-- Sample EXEC [dbo].[sp_mode_getmaxmodeid]
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_getmaxmodeid]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_getmaxmodeid]
END
GO

CREATE PROC [dbo].[sp_mode_getmaxmodeid]
AS
BEGIN
SELECT MAX(cust.tblModeDefs.ModeDefID) FROM cust.tblModeDefs
END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_mode_getmode]    Script Date: 1/30/2022 9:20:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	get mode details for mode
-- Sample EXEC [dbo].[sp_mode_getmode] 1,1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_getmode]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_getmode]
END
GO

CREATE PROC [dbo].[sp_mode_getmode]
@modeid INT,
@configurationId INT
AS
BEGIN

SELECT DISTINCT 
                 ModesResult.ModeName as Name, 
                 ModesResult.ModeId as Id, 
                 ScriptIdLookup.ScriptName as ScriptName, 
                 ScriptIdLookup.ScriptId as ScriptId 

                 FROM 

                 (SELECT  
                 isnull(Nodes.Mode.value('(./@name)[1]', 'varchar(max)'),'') as ModeName, 
                 isnull(Nodes.Mode.value('(./@id)[1]', 'varchar(max)'),'') as ModeId, 
                 isnull(Nodes.Mode.value('(./mode_item/@scriptidref)[1]', 'varchar(max)'),'') as ScriptId 
                 FROM cust.tblModeDefs as Modes 
                 cross apply Modes.ModeDefs.nodes('/mode_defs/mode[@id = sql:variable("@modeid")]') as Nodes(Mode) 
                 INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID 
                 AND cust.tblModeDefsMap.ConfigurationID = @configurationId) 

                 as ModesResult 

                 LEFT OUTER JOIN(
                    SELECT 
                 isnull(Nodes.Script.value('(./@name)[1]', 'varchar(max)'),'') as ScriptName, 
                 isnull(Nodes.Script.value('(./@id)[1]', 'varchar(max)'),'') as ScriptId 
                 FROM cust.tblScriptDefs as Scripts 
                 cross apply Scripts.ScriptDefs.nodes('/script_defs/script') as Nodes(Script)
                 INNER JOIN cust.tblScriptDefsMap ON cust.tblScriptDefsMap.ScriptDefID = Scripts.ScriptDefID 
                 AND cust.tblScriptDefsMap.ConfigurationID = @configurationId 
                 ) 

                 as ScriptIdLookup ON ScriptIdLookup.ScriptId = ModesResult.ScriptId

END
GO


GO

/****** Object:  StoredProcedure [dbo].[sp_mode_getmodeitemcount]    Script Date: 1/30/2022 9:21:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	getting mode count
-- Sample EXEC [dbo].[sp_mode_getmodeitemcount] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_getmodeitemcount]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_getmodeitemcount]
END
GO

CREATE PROC [dbo].[sp_mode_getmodeitemcount]
@configurationId INT

AS
BEGIN

SELECT
                        Modes.ModeDefs.value('count(/mode_defs/mode)', 'int')
                        FROM cust.tblModeDefs as Modes
                        INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID 
                        AND cust.tblModeDefsMap.ConfigurationID = @configurationId

END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_mode_insertmode]    Script Date: 1/30/2022 9:23:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	add new mode
-- Sample EXEC [dbo].[sp_mode_insertmode] 1,'test',1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_insertmode]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_insertmode]
END
GO

CREATE PROC [dbo].[sp_mode_insertmode]
@modeId INT,
@name NVARCHAR(200),
@scriptId INT
AS 
BEGIN

DECLARE @strModeNode xml = '<mode_defs><mode id ="' +cast(@modeId as varchar) +'" name = "' + @name + '"> ' +
                                    '<mode_item channel="1" scriptidref=  "'+ cast(@scriptId as varchar) +' " type="analog" /> ' +
                                    '<mode_item channel="1" scriptidref= "' + cast(@scriptId as varchar) + '"  type="digital3d" />' +
                                    '<mode_item channel="2" scriptidref= "' + cast(@scriptId as varchar) + '"  type="analog" />'  +
                              ' </mode></mode_defs>'

						INSERT INTO cust.tblModeDefs(ModeDefs) VALUES(@strModeNode)
END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_mode_removemode]    Script Date: 1/30/2022 9:24:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	remove node
-- Sample EXEC [dbo].[sp_mode_removemode] 1,1
-- =============================================
IF OBJECT_ID('[dbo].[sp_mode_removemode]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_mode_removemode]
END
GO

CREATE PROC [dbo].[sp_mode_removemode]
@modeId INT,
@configurationId INT

AS
BEGIN
DECLARE @updateKey int,@ModeDefID INT
 SET @ModeDefID = (SELECT distinct cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap  WHERE cust.tblModeDefsMap.ConfigurationID = @configurationId  )    
	  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblModeDefs',@ModeDefID,@updateKey out
     
UPDATE cust.tblModeDefs 
                          SET ModeDefs.modify('delete /mode_defs/mode[@id = sql:variable("@modeId")]') 
                          WHERE cust.tblModeDefs.ModeDefID IN ( 
                          SELECT distinct cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap 
                          WHERE cust.tblModeDefsMap.ConfigurationID = @configurationId AND ModeDefID = @updateKey)
END
GO



GO


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

GO


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

GO


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


GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 03/07/2022
-- Description:	Import new Airports FROM navDB, Airport.csv Data Source files, If there is no new Airport now row will get modified
--				Date 03/31/2022 Laksmikanth Updated the SP to update ConfigurationHistoryTable
--				Date 04/20/2022 Laksmikanth Updated the SP to handle four letter ID with Same GeoRefID
--				Date 07/08/2022 Laksmikanth Updated the SP to handle Update the Airports Data
-- Sample EXEC [dbo].[SP_NewNavDBAirports_Import] 1, '8435FAA9-7174-4F4D-A1E7-A4C52A020142' , '83A32F91-81A0-49F2-B7E7-47EA335C94DC'
-- =============================================

IF OBJECT_ID('[dbo].[SP_NewNavDBAirports_Import]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_NewNavDBAirports_Import]
END
GO

CREATE PROCEDURE [dbo].[SP_NewNavDBAirports_Import]
	@configid INT,
	@LastModifiedBy NVARCHAR(250),
	@currentTaskID NVARCHAR(50)
AS
BEGIN
	DECLARE @geoRefId INT,@userName NVARCHAR(50);
	DECLARE @tempId INT, @tempGeoRefId INT, @tempCity VARCHAR(50),@tempLat DECIMAL (12, 9), @tempLong DECIMAL (12, 9), @tempCityDesc VARCHAR(250),
		@tempThreeLetID VARCHAR(10),@tempFourLetID VARCHAR(10),@GeoRefRank INT,@tbNewAirportsCounter INT,@UpdateAirportsCounter INT,
		 @existingGeoRefId INT, @existingSegmentId INT, @existingSpellingId INT, @existingAppearanceId INT, @existingAirportInfoId INT;


	--Temp Tables
	DECLARE @resolutionlistTbl table (Zlevel INT IDENTITY (1,1), res FLOAT, resMap INT);
	DECLARE @temptbNewAirportsWithID TABLE (AirportID INT IDENTITY (1,1) NOT NULL ,FourLetId NVARCHAR(10) NULL,ThreeLetId NVARCHAR(10) NULL,Lat DECIMAL(12,9) NULL,Long DECIMAL(12,9) NULL,Description NVARCHAR(250) NULL,City NVARCHAR(50),SN INT NULL,existingGeorefId INT NULL);
	CREATE TABLE #tbNewAirports (ID INT IDENTITY (1,1),FourLetId NVARCHAR(10) NULL,ThreeLetId NVARCHAR(10) NULL,Lat DECIMAL(12,9) NULL,Long DECIMAL(12,9) NULL,Description NVARCHAR(250) NULL,City NVARCHAR(50),SN INT NULL,existingGeorefId INT NULL);
	CREATE TABLE #tbUpdateAirports (ID INT IDENTITY (1,1),FourLetId NVARCHAR(10) NULL,ThreeLetId NVARCHAR(10) NULL,Lat DECIMAL(12,9) NULL,Long DECIMAL(12,9) NULL,Description NVARCHAR(250) NULL,City NVARCHAR(50),SN INT NULL,existingGeorefId INT NULL);
	
	--resolutionlistTbl has all the resolulations and their mapings
	INSERT INTO @resolutionlistTbl values (0,60), (0,120), (0,240), (0.971922,30), (3,0), (6,0),(15,480),(30,960),
		(60,0),(75,1920),(150,3840),(300,7680),(600,15360),(1620,0),(2025,0)

	BEGIN

		DELETE FROM dbo.tblNavDBAirports
				 WHERE SN NOT IN
						(
						SELECT MAX(SN)
							FROM dbo.tblNavDBAirports GROUP BY FourLetId,City
							);
		INSERT INTO @temptbNewAirportsWithID SELECT * FROM dbo.tblNavdbAirports


		--' Import source data to a temporary table For new records. 
		INSERT INTO #tbNewAirports(FourLetId,ThreeLetId,Lat,Long,City,Description)
		SELECT TN.FourLetId, TN.ThreeLetId,TN.Lat,TN.Long,TN.City,TN.Description
		FROM @temptbNewAirportsWithID TN WHERE TN.FourLetId NOT IN (SELECT AirpotInfo.FourLetId FROM dbo.config_tblAirportInfo(@configid) AS AirpotInfo);


		--' Import source data to a temporary table For Modified records. 
		INSERT INTO #tbUpdateAirports(FourLetId,ThreeLetId,Lat,Long,City,Description)
		SELECT  TN.FourLetId, TN.ThreeLetId,TN.Lat,TN.Long,TN.City,TN.Description
		FROM @temptbNewAirportsWithID TN WHERE TN.FourLetId  IN (SELECT AirpotInfo.FourLetId FROM dbo.config_tblAirportInfo(@configid) AS AirpotInfo
			WHERE ROUND(TN.Lat,4) != ROUND(AirpotInfo.Lat,4) OR
					ROUND(TN.Long,4) != ROUND(AirpotInfo.Lon,4));


	--Iterating to the new temp entires and updaing the records
	WHILE(SELECT COUNT(*) FROM #tbNewAirports) > 0
	BEGIN	

		SET @tempGeoRefId = (select max(dbo.tblGeoRef.GeoRefId) FROM  dbo.tblGeoRef)
		SET @tbNewAirportsCounter = (SELECT TOP 1 ID FROM #tbNewAirports)
		SET @tempCity= (SELECT TOP 1 City FROM #tbNewAirports)
		SET @tempFourLetID = (SELECT TOP 1 FourLetID FROM #tbNewAirports)
		SET @existingGeoRefId = (SELECT TOP 1 airinfo.GeoRefID FROM dbo.tblAirportInfo airinfo WHERE airinfo.CityName = @tempCity);
		SET @tempLat =(SELECT TOP 1 Lat FROM #tbNewAirports)
		SET @tempLong= (SELECT TOP 1 Long FROM #tbNewAirports)
		SET @tempCity= (SELECT TOP 1 City FROM #tbNewAirports)
		SET @tempCityDesc= (SELECT TOP 1 Description FROM #tbNewAirports)



		--If New Airport(FourLetID) for a new city(There is no GeoRef in the Database), then create new georefId and update all the 
		-- the  tables tblGeoRef , tblSpelling ,tblAirportInfo, tblCoverageSegment tblAppearance
		--If it is New Airport(FourLetID) for existing place(There is a GeoRef in the Database), Then use same GeoRef and Update
		--tblAirportInfo and tblCoverageSegment
		IF @existingGeoRefId IS NULL OR @existingGeoRefId = ''
		BEGIN
			SET @geoRefId = @tempGeoRefId + 1
			--Insert tblGeoRef Table and and its Maping Table
			DECLARE @GeoReftblID INT;
			INSERT INTO dbo.tblGeoRef(GeoRefId, Description, CatTypeId, AsxiCatTypeId, PnType, 
						isAirport, isAirportPoi,isAttraction, isCapitalCountry, isCapitalState, isClosestPoi, 
						isInteractivePoi, isInteractiveSearch, isMakkahPoi, isRliPoi,isShipWreck, isSnapshot,
						isSummit, isTerrainLand, isTerrainOcean, isTimeZonePoi, isWaterBody, isWorldClockPoi, 
						isWGuide,Priority, AsxiPriority, RliAppearance, KeepNew, Display)
			VALUES (@geoRefId,@tempCityDesc,2, 10, 1, 
						0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 0,0, 0);
			SET @GeoReftblID = SCOPE_IDENTITY();

			INSERT INTO dbo.tblGeoRefMap(ConfigurationID,GeoRefId,PreviousGeoRefID,IsDeleted)
			VALUES ( @configid,@GeoReftblID,0, 0)

			--Insert tblCoverageSegment Table and and its Maping Table
			DECLARE @CoverageSegmenttblId INT;
			INSERT INTO dbo.tblCoverageSegment(GeoRefId, SegmentId, Lat1, Lon1, Lat2, Lon2, dataSourceId )
			VALUES(@geoRefId,1,@tempLat,@tempLong,0, 0, 7);
			SET @CoverageSegmenttblId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblCoverageSegment', @CoverageSegmenttblId  
	
			--Insert tblAirportInfo Table and and its Maping Table
			DECLARE @airportinfoId INT;
			INSERT INTO dbo.tblAirportInfo(GeoRefID,FourLetID, ThreeLetID,Lat,Lon,CityName, dataSourceId)
			VALUES(@geoRefId,@tempFourLetID,@tempThreeLetID,@tempLat,@tempLong,@tempCity,7);
			SET @airportinfoId = SCOPE_IDENTITY();
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblAirportInfo', @airportinfoId
		
			--Insert tblSpelling Table and and its Maping Table
			DECLARE @SpellingtblId INT;
			INSERT INTO dbo.tblSpelling ( GeoRefId, LanguageId, UnicodeStr, FontId, SphereMapFontId, dataSourceId )
			VALUES(@geoRefId,1,@tempCity,1002,1015,7);
			SET @SpellingtblId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblSpelling', @SpellingtblId
	
			-- Update tblAppearance Table only for English)
			--Update the Maping table List, This is used to iterate tblAppearance table for all the resolutions
			DECLARE @existAppearanceTblID INT,@newAppearanceTbleID INT,@NumRes INT, @Init INT;	
			SELECT @NumRes= COUNT(*) FROM @resolutionlistTbl
			SET @Init =1
			WHILE @Init<= @NumRes
			BEGIN
				DECLARE @AppearancetblId INT;
				INSERT INTO dbo.tblAppearance(GeoRefId,Resolution, ResolutionMpp, Exclude, SphereMapExclude )
				VALUES(@geoRefId,(SELECT TOP 1 res FROM @resolutionlistTbl where Zlevel =@Init),(SELECT TOP 1 resMap FROM @resolutionlistTbl where Zlevel =@Init),0,0);
				SET @AppearancetblId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblAppearance', @AppearancetblId
				SET @Init= @Init + 1
			END				
		END
		ELSE
		BEGIN
			SET @geoRefId = @existingGeoRefId
		END
		IF @existingGeoRefId IS NOT NULL
		BEGIN
			--Insert tblCoverageSegment Table and and its Maping Table
			DECLARE @CoverageSegmentId INT;
			INSERT INTO dbo.tblCoverageSegment(GeoRefId, SegmentId, Lat1, Lon1, Lat2, Lon2, dataSourceId )
			VALUES(@existingGeoRefId,1,@tempLat,@tempLong,0, 0, 7);
			SET @CoverageSegmentId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblCoverageSegment', @CoverageSegmentId  
	
			--Insert tblAirportInfo Table and and its Maping Table
			DECLARE @airportinfotbId INT;
			INSERT INTO dbo.tblAirportInfo(GeoRefID,FourLetID, ThreeLetID,Lat,Lon,CityName, dataSourceId)
			VALUES(@existingGeoRefId,@tempFourLetID,@tempThreeLetID,@tempLat,@tempLong,@tempCity,7);
			SET @airportinfotbId = SCOPE_IDENTITY();
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblAirportInfo', @airportinfotbId
		END


		DELETE FROM #tbNewAirports WHERE ID = @tbNewAirportsCounter
	END

	--Iterating to the new modified entires and updaing the records
	WHILE(SELECT COUNT(*) FROM #tbUpdateAirports) > 0
	BEGIN	
		SET @UpdateAirportsCounter = (SELECT TOP 1 ID FROM #tbUpdateAirports)
		SET @tempFourLetID = (SELECT TOP 1 FourLetID FROM #tbUpdateAirports)
		SET @geoRefId = (SELECT TOP 1 airinfo.GeoRefID FROM dbo.tblAirportInfo airinfo WHERE airinfo.FourLetID = @tempFourLetID);		
		SET @tempLat =(SELECT TOP 1 Lat FROM #tbUpdateAirports)
		SET @tempLong= (SELECT TOP 1 Long FROM #tbUpdateAirports)
		SET @tempCity= (SELECT TOP 1 City FROM #tbUpdateAirports)
		SET @tempCityDesc= (SELECT TOP 1 Description FROM #tbUpdateAirports)


		--Update the tblAirportInfo and its Maping Table
		SET @existingAirportInfoId = (SELECT airportinfo.AirportInfoID FROM dbo.config_tblAirportInfo(@configid) AS airportinfo 
			WHERE airportinfo.FourLetID = @tempFourLetID AND (airportinfo.GeoRefID  = @geoRefId OR airportinfo.GeoRefID IS NULL))
		IF(@existingAirportInfoId IS NOT NULL AND @existingAirportInfoId !='')
		BEGIN
			DECLARE @updateKey INT
			exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblAirportInfo', @existingAirportInfoId, @updateKey out
			SET NOCOUNT OFF
			UPDATE tblAirportInfo
			SET Lat = @tempLat, Lon = @tempLong, CityName = @tempCity
			WHERE AirportInfoID = @updateKey
		END

		-- --Update the tblCoverageSegment Table and and its Maping Table
		-- SET @existingSegmentId = (SELECT TOP 1 coveragesegment.ID FROM dbo.config_tblCoverageSegment(@configid) AS coveragesegment 
			-- WHERE coveragesegment.GeoRefID = @geoRefId)
		-- IF(@existingSegmentId IS NOT NULL AND @existingSegmentId !='')
		-- BEGIN
			-- DECLARE @updateSegmentKey INT
			-- exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblCoverageSegment', @existingSegmentId, @updateSegmentKey out
			-- SET NOCOUNT OFF
			-- UPDATE tblCoverageSegment
			-- SET  Lat1 = @tempLat, Lon1 = @tempLong
			-- WHERE ID = @updateSegmentKey
		-- END

		DELETE FROM #tbUpdateAirports WHERE ID = @UpdateAirportsCounter
	END

	END
	--Delete the temp table once import is done
	DELETE dbo.tblNavdbAirports;
	DELETE #tbNewAirports
	DELETE #tbUpdateAirports
	DELETE @temptbNewAirportsWithID	
	--Update tblConfigurationHistory with the content
	DECLARE @comment NVARCHAR(MAX)
	SET @comment = ('Imported new airport data for ' + (SELECT CT.Name FROM tblConfigurations C
				INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
				INNER JOIN tblConfigurationTypes CT ON CD.ConfigurationTypeID = CT.ConfigurationTypeID
				WHERE C.ConfigurationID = @configid) + ' configuration version V' + CONVERT(NVARCHAR(10),(SELECT C.Version FROM tblConfigurations C
				INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
				WHERE C.ConfigurationID = @configid)))

	SET @userName =   (SELECT FirstName + ' ' + LastName FROM dbo.AspNetUsers WHERE Id IN (SELECT StartedByUserID FROM tblTasks WHERE Id = @currentTaskID) );

	IF EXISTS (SELECT 1 FROM tblConfigurationHistory WHERE ContentType = 'airports' AND ConfigurationID = @configid)
	BEGIN
		UPDATE tblConfigurationHistory SET UserComments = @comment, DateModified = GETDATE(), TaskID = CONVERT(uniqueidentifier ,@currentTaskID), CommentAddedBy = @userName
		WHERE ContentType = 'airports' AND ConfigurationID = @configid
	END
	ELSE
	BEGIN
		INSERT INTO dbo.tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID,UserComments)
		VALUES(@configid,'airports',@userName,GETDATE(),CONVERT(uniqueidentifier,@currentTaskID),@comment)
	END
END
GO

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 03/07/2022
-- Description:	Import new PlaceNames from The external DataSources
-- Sample EXEC [dbo].[SP_NewPlaceNames_Import] 1, 'userName' , '02c3cb7c-d072-4136-b19e-ded5aafa53e9'
-- =============================================

IF OBJECT_ID('[dbo].[SP_NewPlaceNames_Import]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_NewPlaceNames_Import]
END
GO

CREATE PROCEDURE [dbo].[SP_NewPlaceNames_Import]
	@configid INT,
	@LastModifiedBy NVARCHAR(250),
	@currentTaskID NVARCHAR(50),
	@isUSPlacename BIT
AS
BEGIN
	DECLARE @geoRefId INT,@userName NVARCHAR(50);
	DECLARE @resolutionlistTbl table (Zlevel INT, res FLOAT, resMap INT);
	DECLARE @ExistingPlaceNames table (GeoRefID INT);
	DECLARE @NewPlaceNames table (PlaceName NVARCHAR(250), Lat DECIMAL (12, 9),Long DECIMAL (12, 9),Population INT);
	DECLARE @FinalPlaceNames table (Id INT IDENTITY(1,1), PlaceName NVARCHAR(250), Lat DECIMAL (12, 9),Long DECIMAL (12, 9),Population INT);

	IF (@isUSPlacename = 1)
	BEGIN
		INSERT INTO @NewPlaceNames 
		SELECT rtrim(TPN.CityName) AS PlaceName,CAST(TPN.Lat AS DECIMAL(12, 9)) AS Lat,CAST(TPN.Long AS DECIMAL(12, 9)) AS Long,CAST(TC.Population AS INT) AS Population 
		FROM tblTempCityInfo TC 
		INNER JOIN  tblTempPlacNamesNationalFile TPN ON rtrim(TC.City) = rtrim(TPN.CityName)
		WHERE TC.Population > 50000 ;
	END
	ELSE
	BEGIN
		INSERT INTO @NewPlaceNames 
		SELECT rtrim(TPN.CityName) AS PlaceName,CAST(TPN.Lat AS DECIMAL(12, 9)) AS Lat,CAST(TPN.Long AS DECIMAL(12, 9)) AS Long,CAST(TC.Population AS INT) AS Population 
		FROM tblTempCityInfo TC 
		INNER JOIN  tblTempPlacNamesNationalFile TPN ON rtrim(TC.City) = rtrim(TPN.CityName)
		WHERE TC.Population > 150000 AND TPN.BGNFilter = 'N';
	END;

	--Delete Duplicate Placenames from @NewPlaceNames
	WITH tmp AS (
      SELECT PlaceName, ROW_NUMBER() OVER(PARTITION BY PlaceName ORDER BY PlaceName) AS ROWNUMBER
      FROM @NewPlaceNames
	  )
	DELETE tmp
		WHERE ROWNUMBER > 1;

   --Getting the existing Placenames from the Database
	INSERT INTO @ExistingPlaceNames
	SELECT GeoRefId FROM tblGeoRef Where GeoRefId IN
	(SELECT TS.GeoRefID FROM tblSpelling TS 
		INNER JOIN  
		  @NewPlaceNames NP ON TS.UnicodeStr = NP.PlaceName
	WHERE TS.LanguageID = 1)

	--Delete the existing place names from @NewPlaceNames to avoid the duplicate insertion
	DELETE NPN FROM @NewPlaceNames NPN
	INNER JOIN 
	(SELECT DISTINCT UnicodeStr
		FROM tblSpelling WHERE
		GeoRefID IN (SELECT GeoRefID FROM @ExistingPlaceNames) AND LanguageID = 1) TEMP
		ON TEMP.UnicodeStr = NPN.PlaceName

	--Import all the Data to @temptbNewAirportswWithID
	INSERT INTO @FinalPlaceNames SELECT * FROM @NewPlaceNames

	--Get GgeoRefId
	SET @geoRefId = (select max(dbo.tblGeoRef.GeoRefId) FROM  dbo.tblGeoRef);
	
	--resolutionlistTbl has all the resolulations and their mapings
	INSERT INTO @resolutionlistTbl values (1,0,60), (2,0,120), (3,0,240), (4,0.971922,30), (5,3,0), (6,6,0),(7,15,480),(8,30,960),
		(9,60,0),(10,75,1920),(11,150,3840),(12,300,7680),(13,600,15360),(14,1620,0),(15,2025,0)

	WHILE(SELECT COUNT(*) FROM @FinalPlaceNames) > 0
	BEGIN
		DECLARE @tempId INT, @tempGeoRefId INT, @tempCity VARCHAR(50),@tempLat FLOAT, @tempLong FLOAT, @tempCityDesc VARCHAR(250);

		SET @tempId = (SELECT TOP 1 Id from @FinalPlaceNames);
		SET @tempGeoRefId = @tempId + @geoRefId;
		SET @tempCity = (SELECT TOP 1 PlaceName FROM @FinalPlaceNames WHERE Id = @tempId);
		SET @tempLat = (SELECT TOP 1 Lat FROM @FinalPlaceNames WHERE Id = @tempId);
		SET @tempLong = (SELECT TOP 1 Long FROM @FinalPlaceNames WHERE Id = @tempId);

		-- Update tblGeoRef Table
		BEGIN

			DECLARE @newGeorRefTblID INT;

			--Update tblGeoRef
			INSERT INTO dbo.tblGeoRef(GeoRefId, Description, CatTypeId, AsxiCatTypeId, PnType, 
					isAirport, isAirportPoi,isAttraction, isCapitalCountry, isCapitalState, isClosestPoi, 
					isInteractivePoi, isInteractiveSearch, isMakkahPoi, isRliPoi,isShipWreck, isSnapshot,
					isSummit, isTerrainLand, isTerrainOcean, isTimeZonePoi, isWaterBody, isWorldClockPoi, 
					isWGuide,Priority, AsxiPriority, RliAppearance, KeepNew, Display)
			VALUES (@tempGeoRefId,@tempCity,2, 10, 1, 
					0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 0,0, 0);
	
			--Get New ID 
			SET @newGeorRefTblID =(SELECT MAX(ID) FROM dbo.tblGeoRef WHERE GeoRefID = @tempGeoRefId);
			
			--Update tblGeoRefMap
			INSERT INTO dbo.tblGeoRefMap(ConfigurationID,GeoRefId,PreviousGeoRefID,IsDeleted)
			VALUES ( @configid,@newGeorRefTblID,0, 0)
		END

		-- Update tbCoverageSegment Table		
		BEGIN
			DECLARE @newCoverageSegmentID INT;

			--Update tbCoverageSegment
			INSERT INTO dbo.tblCoverageSegment(GeoRefId, SegmentId, Lat1, Lon1, Lat2, Lon2, dataSourceId )
			VALUES(@tempGeoRefId,1,@tempLat,@tempLong,0, 0, 7);
	
			--Get New ID 
			SET @newCoverageSegmentID =(SELECT MAX(ID) FROM dbo.tblCoverageSegment WHERE GeoRefID = @tempGeoRefId);
			
			-- Update tbCoverageSegmentMap
			INSERT INTO dbo.tblCoverageSegmentMap(ConfigurationID,CoverageSegmentID,PreviousCoverageSegmentID,IsDeleted)
			VALUES ( @configid,@newCoverageSegmentID,0, 0)
		END		

		-- Update tbSpelling Table only for English) and Mark DoSpellCheck = 1 as it is a new entry and ready for Language Translation
		BEGIN
			DECLARE @newSpellingTblID INT;				
	
			--Update tbSpelling
			INSERT INTO dbo.tblSpelling ( GeoRefId, LanguageId, UnicodeStr, FontId, SphereMapFontId, dataSourceId,DoSpellCheck )
			VALUES(@tempGeoRefId,1,@tempCity,1002,1015,7,1);
	
			--Get New ID 
			SET @newSpellingTblID =(SELECT MAX(SpellingID) FROM tblSpelling WHERE GeoRefID = @tempGeoRefId);
			
			--Update tblSpellingMap
			INSERT INTO dbo.tblSpellingMap(ConfigurationID,SpellingID,PreviousSpellingID,IsDeleted)
			VALUES ( @configid,@newSpellingTblID,0, 0)
		END
		-- Update tblAppearance Table only for English)
		--Update the Maping table List, This is used to iterate tblAppearance table for all the resolutions		
		BEGIN
			DECLARE @newAppearanceTbleID INT,@NumRes INT, @Init INT;	
			SELECT @NumRes= COUNT(*) FROM @resolutionlistTbl
			SET @Init =1
			WHILE @Init<= @NumRes
			BEGIN
			
				--Update tblAppearance
				INSERT INTO dbo.tblAppearance(GeoRefId,Resolution, ResolutionMpp, Exclude, SphereMapExclude )
				VALUES(@tempGeoRefId,(SELECT TOP 1 res FROM @resolutionlistTbl where Zlevel =@Init),(SELECT TOP 1 resMap FROM @resolutionlistTbl where Zlevel =@Init),0,0);

				--Get New ID 
				SET @newAppearanceTbleID =(SELECT MAX(AppearanceID) FROM dbo.tblAppearance WHERE GeoRefID = @tempGeoRefId);
				
				--tblAppearanceMap
				INSERT INTO dbo.tblAppearanceMap(ConfigurationID,AppearanceID,PreviousAppearanceID,IsDeleted)
				VALUES ( @configid,@newAppearanceTbleID,0, 0)
				SET @Init= @Init + 1
			END
		END
	DELETE FROM @FinalPlaceNames WHERE Id = @tempId;
	END
	--Delete the temp table once import is done
	DELETE dbo.tblTempCityInfo;
	DELETE dbo.tblTempPlacNamesNationalFile;
	DELETE @ExistingPlaceNames
	DELETE @NewPlaceNames
	--Update tblConfigurationHistory with the content
	DECLARE @comment NVARCHAR(MAX)
	SET @comment = ('Imported new palcenames data for ' + (SELECT CT.Name FROM tblConfigurations C
				INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
				INNER JOIN tblConfigurationTypes CT ON CD.ConfigurationTypeID = CT.ConfigurationTypeID
				WHERE C.ConfigurationID = @configid) + ' configuration version V' + CONVERT(NVARCHAR(10),(SELECT C.Version FROM tblConfigurations C
				INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
				WHERE C.ConfigurationID = @configid)))

	SET @userName =   (SELECT FirstName + ' ' + LastName FROM dbo.AspNetUsers WHERE Id IN (SELECT StartedByUserID FROM tblTasks WHERE Id = @currentTaskID) );

	IF EXISTS (SELECT 1 FROM tblConfigurationHistory WHERE ContentType = 'placenames' AND ConfigurationID = @configid)
	BEGIN
		UPDATE tblConfigurationHistory SET UserComments = @comment, DateModified = GETDATE(), TaskID = CONVERT(uniqueidentifier ,@currentTaskID), CommentAddedBy = @userName
		WHERE ContentType = 'placenames' AND ConfigurationID = @configid
	END
	ELSE
	BEGIN
		INSERT INTO dbo.tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID,UserComments)
		VALUES(@configid,'placenames',@userName,GETDATE(),CONVERT(uniqueidentifier,@currentTaskID),@comment)
	END
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 03/25/2022
-- Description:	Import new WG Cities FROM Data Source files,
--				Date 03/31/2022 Laksmikanth Updated the SP to update ConfigurationHistoryTable
-- Sample EXEC [dbo].[SP_NewWGCities_Import] 1, '8435FAA9-7174-4F4D-A1E7-A4C52A020142' , '83A32F91-81A0-49F2-B7E7-47EA335C94DC'
-- =============================================

IF OBJECT_ID('[dbo].[SP_NewWGCities_Import]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_NewWGCities_Import]
END
GO

CREATE PROCEDURE [dbo].[SP_NewWGCities_Import]
	@configid INT,
	@LastModifiedBy NVARCHAR(250),
	@currentTaskID NVARCHAR(50)

AS
BEGIN
	DECLARE @geoRefId INT,@tempID INT,@tempImageID INT,@CurrentImageID INT,@tempPreviousImageID INT,@tempImagName NVARCHAR(250),@userName NVARCHAR(50);
	DECLARE @tempTextID INT,@CurrentTextID INT,@tempPreviousTextID INT,@temptextName NVARCHAR(MAX),@tempLang NVARCHAR(50);
	DECLARE @CurrentContentID INT,@tempPrevioudContentID INT;
	DECLARE @MaxImageID INT,@MaxTextID INT;

	DECLARE @tblTempWGDetailedFlightInfo_toLoop TABLE(ID INT IDENTITY(1,1),DataId INT,GeoRefID INT, Overview NVARCHAR(MAX),Features NVARCHAR(MAX),Sights NVARCHAR(MAX),Stats NVARCHAR(MAX),ImageFileName NVARCHAR(MAX),Text_Description NVARCHAR(MAX))
	DECLARE @tblTempWGCityFlightInfo_toLoop TABLE(ID INT IDENTITY(1,1),DataId INT,ImageFileName NVARCHAR(MAX),DescriptionInLang NVARCHAR(MAX),Language NVARCHAR(250),GeoRefID INT )
	DECLARE @tempWGImage TABLE(ID INT IDENTITY(1,1), FileName NVARCHAR(250))
	DECLARE @tempWGText TABLE(ID INT IDENTITY(1,1) ,Text_Description NVARCHAR(MAX))
	DECLARE @temptextLang TABLE(ID INT IDENTITY(1,1) ,Lang NVARCHAR(50))
	BEGIN

		--Import tblTempWGDetailedFlightInfo to a temp table to loop the entire table
		INSERT INTO @tblTempWGDetailedFlightInfo_toLoop SELECT * FROM tblTempWGDetailedFlightInfo AS TWG WHERE TWG.ImageFileName NOT IN
		(SELECT ImageFileName FROM dbo.tblWGImage WGI INNER JOIN dbo.tblWGImageMap WGIM ON WGI.ID = WGIM.ImageID WHERE WGIM.ConfigurationID =@configid) 

		--Import tblTempWGDetailedFlightInfo to a temp table to loop the entire table
		INSERT INTO @tblTempWGCityFlightInfo_toLoop SELECT * FROM tblTempWGCityFlightInfo AS TWG WHERE TWG.ImageFileName NOT IN
		(SELECT ImageFileName FROM dbo.tblWGImage WGI INNER JOIN dbo.tblWGImageMap WGIM ON WGI.ID = WGIM.ImageID WHERE WGIM.ConfigurationID =@configid) 

		-- Delete the existing entries in the table for the configuration id to avoid duplicate inserts.
		UPDATE dbo.tblWGImageMap
		SET IsDeleted = 1
		WHERE dbo.tblWGImageMap.ConfigurationID = @configid;

		UPDATE dbo.tblWGtextMap
		SET IsDeleted = 1
		WHERE dbo.tblWGtextMap.ConfigurationID = @configid;

		UPDATE dbo.tblWGContentMap
		SET IsDeleted = 1
		WHERE dbo.tblWGContentMap.ConfigurationID = @configid;
		--Processing Rockwell.xml Data
		WHILE(SELECT COUNT(*) FROM @tblTempWGDetailedFlightInfo_toLoop) > 0

			BEGIN
				SET @geoRefId = (SELECT TOP 1 GeoRefID FROM @tblTempWGDetailedFlightInfo_toLoop)
				SET @tempID = (SELECT TOP 1 ID FROM @tblTempWGDetailedFlightInfo_toLoop)


				--Get Data to @tempWGImage for further processing
				INSERT INTO @tempWGImage(FileName)
				SELECT * FROM string_split((SELECT TOP 1 ImageFileName FROM @tblTempWGDetailedFlightInfo_toLoop),'|')
				DELETE @tempWGImage WHERE FileName = ''

				--Get Data to @tempWGText for further processing
				INSERT INTO @tempWGText(Text_Description)
				SELECT * FROM string_split((SELECT TOP 1 Text_Description FROM @tblTempWGDetailedFlightInfo_toLoop),'|')
				DELETE @tempWGText WHERE Text_Description = ''


				BEGIN
					DECLARE @tempID1 INT,@tempID2 INT ;
					WHILE(SELECT COUNT(*) FROM @tempWGImage) > 0
						BEGIN
							SET @MaxImageID = (SELECT COALESCE(MAX(WGI.ImageID),0) FROM dbo.tblWGImage AS WGI)
							SET @MaxTextID = (SELECT COALESCE(MAX(WGT.TextID),0) FROM dbo.tblWGtext AS WGT)
							SET @tempID1 = (SELECT TOP 1  ID FROM @tempWGImage)
							SET @tempID2 = (SELECT TOP 1  ID FROM @tempWGText)
							SET @tempImageID = 1 + @MaxImageID
							SET @tempTextID = 1 + @MaxTextID

							SET @tempImagName = (SELECT TOP 1 FileName FROM @tempWGImage)
							SET @temptextName = (SELECT TOP 1 Text_Description FROM @tempWGText)

							--Insert tblWGImage Table and and its Maping Table
							DECLARE @WGImageId INT;
							INSERT INTO dbo.tblWGImage(ImageID,FileName)
							VALUES(@tempImageID,@tempImagName);
							SET @WGImageId = SCOPE_IDENTITY()
							EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGImage', @WGImageId  

							--Insert tblWGtext Table and and its Maping Table
							DECLARE @WGTextId INT;
							INSERT INTO dbo.tblWGtext(TextID,Text_EN)
							VALUES(@tempTextID,@temptextName);
							SET @WGTextId = SCOPE_IDENTITY()
							EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGtext', @WGTextId  

							--Insert tblWGContent Table and and its Maping Table
							DECLARE @WGContentId INT;
							INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
							VALUES(@geoRefId,1,@tempImageID,@tempTextID);
							SET @WGContentId = SCOPE_IDENTITY()
							EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGContent', @WGContentId  

							DELETE @tempWGImage WHERE ID = @tempID1
							DELETE @tempWGText WHERE ID = @tempID2

					END
				END
				--Update tblWGText and tblWGContent which does'nt have images but having text
				--Updated the table With Overview Data
				SET @MaxImageID = (SELECT COALESCE(MAX(WGI.ImageID),0) FROM dbo.tblWGImage AS WGI)
				SET @MaxTextID = (SELECT COALESCE(MAX(WGT.TextID),0) FROM dbo.tblWGtext AS WGT)

				SET @temptextName = (SELECT TOP 1 Overview FROM @tblTempWGDetailedFlightInfo_toLoop)
				SET @tempTextID = 1 + @MaxTextID
					
				--Insert tblWGtext Table and and its Maping Table
				DECLARE @WGTextOverviewId INT;
				INSERT INTO dbo.tblWGtext(TextID,Text_EN)
				VALUES(@tempTextID,@temptextName);
				SET @WGTextOverviewId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGtext', @WGTextOverviewId  

				--Insert tblWGContent Table and and its Maping Table
				DECLARE @WGOverviewContentId INT;
				INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
				VALUES(@geoRefId,1,-1,@tempTextID);
				SET @WGContentId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGContent', @WGOverviewContentId  

				--Updated the table With Features Data
				SET @MaxImageID = (SELECT COALESCE(MAX(WGI.ImageID),0) FROM dbo.tblWGImage AS WGI)
				SET @MaxTextID = (SELECT COALESCE(MAX(WGT.TextID),0) FROM dbo.tblWGtext AS WGT)
				SET @temptextName = (SELECT TOP 1 Features FROM @tblTempWGDetailedFlightInfo_toLoop)
				SET @tempTextID = 1 + @MaxTextID

				--Insert tblWGtext Table and and its Maping Table
				DECLARE @WGTextFeaturesId INT;
				INSERT INTO dbo.tblWGtext(TextID,Text_EN)
				VALUES(@tempTextID,@temptextName);
				SET @WGTextFeaturesId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGtext', @WGTextFeaturesId  

				--Insert tblWGContent Table and and its Maping Table
				DECLARE @WGFeaturesContentId INT;
				INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
				VALUES(@geoRefId,3,-1,@tempTextID);
				SET @WGFeaturesContentId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGContent', @WGFeaturesContentId  

				--Updated the table With Sights Data
				SET @MaxImageID = (SELECT COALESCE(MAX(WGI.ImageID),0) FROM dbo.tblWGImage AS WGI)
				SET @MaxTextID = (SELECT COALESCE(MAX(WGT.TextID),0) FROM dbo.tblWGtext AS WGT)
				SET @temptextName = (SELECT TOP 1 Sights FROM @tblTempWGDetailedFlightInfo_toLoop)
				SET @tempTextID = 1 + @MaxTextID

				--Insert tblWGtext Table and and its Maping Table
				DECLARE @WGTextSightsId INT;
				INSERT INTO dbo.tblWGtext(TextID,Text_EN)
				VALUES(@tempTextID,@temptextName);
				SET @WGTextSightsId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGtext', @WGTextSightsId  

				--Insert tblWGContent Table and and its Maping Table
				DECLARE @WGSightsContentId INT;
				INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
				VALUES(@geoRefId,4,-1,@tempTextID);
				SET @WGSightsContentId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGContent', @WGSightsContentId  

				--Updated the table With Stats Data
				SET @MaxImageID = (SELECT COALESCE(MAX(WGI.ImageID),0) FROM dbo.tblWGImage AS WGI)
				SET @MaxTextID = (SELECT COALESCE(MAX(WGT.TextID),0) FROM dbo.tblWGtext AS WGT)
				SET @temptextName = (SELECT TOP 1 Stats FROM @tblTempWGDetailedFlightInfo_toLoop)
				SET @tempTextID = 1 + @MaxTextID

				--Insert tblWGtext Table and and its Maping Table
				DECLARE @WGTextStatsId INT;
				INSERT INTO dbo.tblWGtext(TextID,Text_EN)
				VALUES(@tempTextID,@temptextName);
				SET @WGTextSightsId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGtext', @WGTextStatsId  

				--Insert tblWGContent Table and and its Maping Table
				DECLARE @WGStatsContentId INT;
				INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
				VALUES(@geoRefId,2,-1,@tempTextID);
				SET @WGStatsContentId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGContent', @WGStatsContentId  

				DELETE @tblTempWGDetailedFlightInfo_toLoop WHERE Id = @tempID
		END


		--Processing flight_POI.xml Data
		DELETE @tempWGText
		WHILE(SELECT COUNT(*) FROM @tblTempWGCityFlightInfo_toLoop) > 0
			BEGIN
			SET @tempID = (SELECT TOP 1 Id FROM @tblTempWGCityFlightInfo_toLoop)
			SET @geoRefId = (SELECT TOP 1 GeoRefID FROM @tblTempWGCityFlightInfo_toLoop)

			print @tempID
			--Get Data to @tempWGText for further processing

			INSERT INTO @tempWGText(Text_Description)
			SELECT * FROM string_split((SELECT TOP 1 DescriptionInLang FROM @tblTempWGCityFlightInfo_toLoop),'|')
			DELETE @tempWGText WHERE Text_Description = ''

			--Get Data to @temptextLang for further processing
			INSERT INTO @temptextLang(Lang)
			SELECT * FROM string_split((SELECT TOP 1 Language FROM @tblTempWGCityFlightInfo_toLoop),'|')
			DELETE @temptextLang WHERE Lang = ''
		


			SET @MaxImageID = (SELECT COALESCE(MAX(WGI.ImageID),0) FROM dbo.tblWGImage AS WGI)
			SET @MaxTextID = (SELECT COALESCE(MAX(WGT.TextID),0) FROM dbo.tblWGtext AS WGT)
			SET @tempImageID = 1 + @MaxImageID
			SET @tempImagName = (SELECT TOP 1 ImageFileName FROM @tblTempWGCityFlightInfo_toLoop);	
			SET @tempTextID = 1 + @MaxTextID

			--Insert tblWGImage Table and and its Maping Table
			DECLARE @WGFlightImageId INT;
			INSERT INTO dbo.tblWGImage(ImageID,FileName)
			VALUES(@tempImageID,@tempImagName);
			SET @WGFlightImageId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGImage', @WGFlightImageId  

			--Insert tblWGtext Table and and its Maping Table
			DECLARE @WGWGFlightTextId INT;
			INSERT INTO dbo.tblWGtext(TextID)
			VALUES(@tempTextID);
			--Loop through tempWGText and fill dbo.tblWGtext desciption for all the languages
			DECLARE @tempID3 INT;
			WHILE(SELECT COUNT(*) FROM @tempWGText) > 0
				BEGIN				
					SET @tempID3 = (SELECT TOP 1 ID FROM @tempWGText)
					SET @tempLang = (SELECT TOP 1 Lang FROM @temptextLang)
						
	
					IF @tempLang = 'en' 
					BEGIN 
						SET @temptextName = (SELECT TOP 1 Text_Description FROM @tempWGText)	
						UPDATE dbo.tblWGtext SET Text_EN = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'de'
					BEGIN 
						UPDATE dbo.tblWGtext SET Text_DE = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'es'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_ES = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'fr'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_FR = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'it'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_IT = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'zh'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_ZH = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'zh-tw'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_HK = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'ja'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_JA = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'ko'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_KO = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'pt'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_PT = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'ru'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_RU = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'tr'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_TR = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					ELSE IF @tempLang = 'ar'
					BEGIN
						UPDATE dbo.tblWGtext SET Text_AR = (SELECT TOP 1 Text_Description FROM @tempWGText) where TextID = @tempTextID
					END
					DELETE @temptextLang WHERE lang = @tempLang
					DELETE @tempWGText WHERE ID = @tempID3
				END
			SET @WGWGFlightTextId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGtext', @WGWGFlightTextId  

			--Insert tblWGContent Table and and its Maping Table
			DECLARE @WGWGFlightContentId INT;
			INSERT INTO dbo.tblWGContent(GeoRefID,TypeID,ImageID,TextID)
			VALUES(@geoRefId,1,@tempImageID,@tempTextID);
			SET @WGWGFlightContentId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblWGContent', @WGWGFlightContentId  

			DELETE @tblTempWGCityFlightInfo_toLoop WHERE Id = @tempID	
		END			
	DELETE tblTempWGDetailedFlightInfo
	DELETE tblTempWGCityFlightInfo

	--Update tblConfigurationHistory with the content
	DECLARE @comment NVARCHAR(MAX)
	SET @comment = ('Imported new world guide cities data for ' + (SELECT CT.Name FROM tblConfigurations C
					INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
					INNER JOIN tblConfigurationTypes CT ON CD.ConfigurationTypeID = CT.ConfigurationTypeID
					WHERE C.ConfigurationID = @configid) + ' configuration version V' + CONVERT(NVARCHAR(10),(SELECT C.Version FROM tblConfigurations C
					INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
					WHERE C.ConfigurationID = @configid)))

	SET @userName =   (SELECT FirstName + ' ' + LastName FROM dbo.AspNetUsers WHERE Id IN (SELECT StartedByUserID FROM tblTasks WHERE Id = @currentTaskID) );

	IF EXISTS (SELECT 1 FROM tblConfigurationHistory WHERE ContentType = 'world guide cities' AND ConfigurationID = @configid)
	BEGIN
		UPDATE tblConfigurationHistory SET UserComments = @comment, DateModified = GETDATE(), TaskID = CONVERT(uniqueidentifier ,@currentTaskID), CommentAddedBy = @userName
		WHERE ContentType = 'world guide cities' AND ConfigurationID = @configid
	END
	ELSE
	BEGIN
		INSERT INTO dbo.tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID,UserComments)
		VALUES(@configid,'world guide cities',@userName,GETDATE(),CONVERT(uniqueidentifier,@currentTaskID),@comment)
	END
	END
END
GO

-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	returns the place name cat type
-- =============================================

GO
IF OBJECT_ID('[dbo].[sp_placenames_getcattypes]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_getcattypes]
END
GO
CREATE PROC sp_placenames_getcattypes
@placeNameId INT,
@configurationId INT
AS
BEGIN

DECLARE @catId INT =0

select @catId=AsxiCatTypeId from config_tblGeoRef(@configurationId) WHERE ID=@placeNameId

SELECT CategoryTypeID,Description,
CASE WHEN CategoryTypeID=@catId THEN 1
ELSE 0 END AS isSelected
FROM tblCategoryType A 

END

GO
GO

-- =============================================
-- Author:		Abhishek
-- Create date: 9/14/2022
-- Description:	returns the lat and lon values
-- =============================================

GO
IF OBJECT_ID('[dbo].[sp_placenames_GetLatLonValue]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_GetLatLonValue]
END
GO
CREATE PROC  [dbo].[sp_placenames_GetLatLonValue]
       @placeNameId INT,
       @geoRefId INT

AS
BEGIN
	DECLARE @tempGeoRef int
	IF(@placeNameId != 0)
		BEGIN
		SET	@tempGeoRef =( select GeoRefId from tblGeoRef where ID =@placeNameId)
			SELECT Lat1 AS Lat ,Lon1 AS Lon FROM tblCoverageSegment WHERE GeoRefID = @tempGeoRef 
		END
	ELSE IF(@geoRefId != 0)
		BEGIN
			SELECT Lat1 AS Lat ,Lon1 AS Lon FROM tblCoverageSegment WHERE GeoRefID = @geoRefId 
		END
END
GO
GO

-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	returns the place name information with LON and LAN
-- =============================================

GO
IF OBJECT_ID('[dbo].[sp_placenames_getplacenameinfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_getplacenameinfo]
END
GO
CREATE PROC sp_placenames_getplacenameinfo
@configurationId INT,
@placeNameId INT
AS
BEGIN

DECLARE @ENG_lang_id INT
SELECT @ENG_lang_id=LanguageID FROM config_tblLanguage(@configurationId) WHERE [2LetterID_4xxx]='EN';

select distinct seg.ID as SegId,seg.Lat1,seg.Lon1,seg.Lat2,seg.Lon2,ctry.CountryID,ctry.Description,rgn.RegionID,rgn.RegionName,geoRef.ID,geoRef.GeoRefId
from config_tblGeoRef(@configurationId) geoRef 
INNER JOIN config_tblCoverageSegment(@configurationId) seg ON seg.GeoRefID=geoRef.GeoRefID
LEFT JOIN config_tblCountry(@configurationId) ctry ON ctry.CountryID=geoRef.CountryID
LEFT JOIN config_tblRegion(@configurationId) rgn ON rgn.RegionID=georef.RegionID AND rgn.LanguageId=@ENG_lang_id
WHERE geoRef.ID=@placeNameId AND seg.SegmentID=1

END


GO
GO

-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	returns the list of placenames for given config id


-- =============================================

IF OBJECT_ID('[dbo].[sp_placenames_getplacenames]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_getplacenames]
END
GO
CREATE PROC sp_placenames_getplacenames
@configurationId INT
AS
BEGIN
   select georef.ID,georef.GeoRefId,georef.Description,country.Description as CountryName,region.RegionNAme
   from   config_tblGeoRef(@configurationId) as georef 
   inner join config_tblCountry(@configurationId) as country on georef.CountryId = country.CountryId
   inner join config_tblRegion (@configurationId) as region on georef.RegionId = region.RegionId
   where  region.languageId =1  ORDER BY Description

		
END

GO
GO

-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	returns the list of placename with spelling info for given config id and geo ref id
-- =============================================
GO
IF OBJECT_ID('[dbo].[sp_placenames_getplacenamespelling]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_getplacenamespelling]
END
GO
CREATE PROC sp_placenames_getplacenamespelling
@geoRefId INT,
@configurationId INT
AS
BEGIN

select spel.SpellingID,lang.Name,spel.UnicodeStr from tblSpelling spel 
INNER JOIN tblSpellingMap spellMap on spellMap.SpellingID=spel.SpellingID 
INNER JOIN tblLanguages lang ON lang.LanguageID=spel.LanguageID
INNER JOIN tblLanguagesMap langMap on langMap.LanguageID=lang.LanguageID 
WHERE spel.GeoRefID=@geoRefId AND spellMap.ConfigurationID=@configurationId AND spellMap.IsDeleted=0 
AND langMap.ConfigurationID=@configurationId AND langMap.IsDeleted=0

END

GO
GO

-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	returns the list of placename visibility for given config id and georef id
-- =============================================
GO
IF OBJECT_ID('[dbo].[sp_placenames_getvisibility]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_getvisibility]
END
GO
CREATE PROC sp_placenames_getvisibility
@geoRefId INT,
@configurationId INT
AS
BEGIN

SELECT appearnce.appearanceid,
		appearnce.ResolutionMpp as resolution,
		appearnce.Priority,
		cast(appearnce.exclude as int) as exclude
FROM config_tblGeoRef(@configurationId) geoRef INNER JOIN config_tblappearance(@configurationId) appearnce
ON appearnce.GeoRefID=geoRef.GeoRefId WHERE geoRef.GeoRefId=@geoRefId AND appearnce.ResolutionMpp <>0 ORDER BY appearnce.ResolutionMpp
END


GO

GO

-- =============================================
-- Author:    Sathya
-- Create date: 31-May-2022
-- Description:  inserts or updates geo ref
-- =============================================
go

IF Object_id('[dbo].[sp_placenames_insertupdategeoref]', 'P') IS NOT NULL
  BEGIN
      DROP PROC [dbo].[sp_placenames_insertupdategeoref]
  END

go

CREATE PROC Sp_placenames_insertupdategeoref @configurationId INT,
                                             @geoRefId        INT=0,
                                             @id              INT=0,
                                             @name            NVARCHAR(max)=NULL,
                                             @regionId        INT=NULL,
                                             @countryId       INT=NULL,
                                             @covSegmentId    INT=0,
                                             @lat1            decimal(12,9)=0,
                                             @lon1            decimal(12,9)=0,
                                             @lan2            decimal(12,9)=0,
                                             @lon2            decimal(12,9)=0,
											 @modlistinfo [ModListTable] READONLY
AS

  BEGIN
      IF @id IS NULL
          OR @id = 0
        BEGIN
            --INSERT LOGIC
            DECLARE @maxGeoRef INT=0
            DECLARE @identity_geoRef INT=0;

            SELECT @maxGeoRef = Max(georefid)
            FROM   tblgeoref (nolock);

            SET @geoRefId=@maxGeoRef + 1;

            INSERT INTO [dbo].[tblgeoref]
                        ([georefid],
                         [description],
                         [regionid],
                         [countryid],
                         isinteractivepoi,
                         isinteractivesearch,
                         isrlipoi,
                         istimezonepoi,
                         isworldclockpoi)
            VALUES      (@geoRefId,
                         @name,
                         @regionId,
                         @countryId,
                         1,
                         1,
                         1,
                         1,
                         1 )

            SELECT @identity_geoRef = Scope_identity();

            --Insert geo ref
            EXEC [dbo].[Sp_configmanagement_handleadd]
              @configurationId,
              'tblGeoRef',
              @identity_geoRef;

            --insert into spelling & appearance & segment
            EXEC [dbo].[Sp_placenames_insert_update_spelling]
              @configurationId,
              @geoRefId,
              @name,
              0;

            EXEC [dbo].[Sp_placenames_insert_update_appearance]
              @configurationId,
              @geoRefId,
              0,
              0,
              0;

            EXEC [dbo].[Sp_placenames_insert_update_coverageseg]
              @configurationId,
              @geoRefId,
              @covSegmentId,
              @lat1,
              @lon1,
              @lan2,
              @lon2;

            SELECT @identity_geoRef,
                   @geoRefId
        END
      ELSE
        BEGIN
            --update geo ref
            DECLARE @updateKey INT

            EXEC dbo.Sp_configmanagement_handleupdate
              @configurationId,
              'tblGeoRef',
              @id,
              @updateKey out;

            UPDATE tblgeoref
            SET    countryid = @countryId,
                   regionid = @regionId
            WHERE  id = @updateKey;

			EXEC [dbo].[Sp_placenames_insert_update_coverageseg]
              @configurationId,
              @geoRefId,
              @covSegmentId,
              @lat1,
              @lon1,
              @lan2,
              @lon2;

            SELECT @updateKey,
                   @geoRefId;

        END
	  
		exec dbo.SP_SetIsDirty @configurationId ,@modlistinfo

  END

go 
GO

-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	inserts or updates the appearance
-- =============================================

GO

IF OBJECT_ID('[dbo].[sp_placenames_insert_update_appearance]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_insert_update_appearance]
END
GO
CREATE PROC sp_placenames_insert_update_appearance
@configurationId INT,
@geoRefId INT,
@appearanceId INT=0,
@isExclude INT =0,
@priority INT,
@modlistinfo [ModListTable] READONLY
AS
BEGIN
IF @appearanceId IS NULL OR @appearanceId=0
BEGIN

DECLARE @max_appearanceId INT=0;--DECLARE @appearanceId INT=0

--SELECT @max_appearanceId=MAX(AppearanceID) FROM tblAppearance(nolock);
--SET IDENTITY_INSERT [dbo].[tblAppearance] ON
INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,0,0,'3.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,0,0,'6.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,0,0,'60.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,0,0,'1620.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,0,0,'2025.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,30,0,'0.9719220000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,60,0,'0.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,120,0,'0.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,240,0,'0.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,480,0,'15.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,960,0,'30.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,1920,0,'75.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,3840,0,'150.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,7680,0,'300.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;

INSERT INTO tblAppearance(GeoRefID,ResolutionMpp,Exclude,Resolution) values
(@geoRefId,15360,0,'600.0000000000');
SELECT @appearanceId=SCOPE_IDENTITY();
EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblAppearance',@appearanceId;
--SET IDENTITY_INSERT [dbo].[tblAppearance] OFF 
END
ELSE
BEGIN

	declare @updateKey int
	exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblAppearance', @appearanceId, @updateKey out
	UPDATE tblAppearance SET Exclude=@isExclude,Priority=@priority WHERE AppearanceID=@updateKey;
	exec dbo.SP_SetIsDirty @configurationId ,@modlistinfo
END

	
END

GO
GO

-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	inserts or updates the coveragesegment information
-- =============================================
GO

IF OBJECT_ID('[dbo].[sp_placenames_insert_update_coverageseg]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_insert_update_coverageseg]
END
GO
CREATE PROC sp_placenames_insert_update_coverageseg
@configurationId INT,
@geoRefId INT,
@covSegmentId INT=0,
@lat1 VARCHAR(200),
@lon1 VARCHAR(200),
@lat2 VARCHAR(200),
@lon2 VARCHAR(200)
AS
BEGIN
IF @covSegmentId IS NULL OR @covSegmentId=0
BEGIN
INSERT INTO tblCoverageSegment(GeoRefID,SegmentID,Lat1,Lon1,Lat2,Lon2,DataSourceID)
VALUES(@geoRefId,1,@lat1,@lon1,@lat2,@lon2,-3)
SELECT @covSegmentId=SCOPE_IDENTITY();

EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblCoverageSegment',@covSegmentId;

END
ELSE
BEGIN
	declare @updateKey int
	exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblCoverageSegment', @covSegmentId, @updateKey out

	UPDATE tblCoverageSegment SET Lat1=@lat1,Lon1=@lon1,Lat2=@lat2,Lon2=@lon2 WHERE id=@updateKey
END
END
GO
GO

-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	inserts or updates spelling for the given config and spelling id (if place name added all spelling will be same)
-- =============================================

GO

IF OBJECT_ID('[dbo].[sp_placenames_insert_update_spelling]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_insert_update_spelling]
END
GO
CREATE PROC sp_placenames_insert_update_spelling
@configurationId INT,
@geoRefId INT,
@placeName NVARCHAR(MAX)=NULL,
@spellingId INT

AS
BEGIN
IF @spellingId IS NULL OR @spellingId=0

BEGIN

DECLARE @max_spellingId INT=0;--DECLARE @spellingId INT=0

SELECT @max_spellingId=MAX(SpellingID) FROM tblSpelling(nolock);
SET @spellingId=@max_spellingId+1;

DROP TABLE IF EXISTS #temp_georef;
CREATE TABLE #temp_georef(SpellingID INT,GeoRefID INT,LanguageID INT,UnicodeStr NVARCHAR(MAX));

INSERT INTO #temp_georef(SpellingID,GeoRefID,LanguageID,UnicodeStr) 
SELECT @max_spellingId + ROW_NUMBER() OVER (ORDER BY languageId) ID,@geoRefId,languageId,@placeName FROM config_tblLanguage(@configurationId)


DECLARE @cur_spelId INT,@cur_langId INT
--SET IDENTITY_INSERT [dbo].[tblSpelling] ON
DECLARE cur_tbl CURSOR  FOR SELECT SpellingID,languageId FROM #temp_georef
OPEN cur_tbl

            FETCH next FROM cur_tbl INTO @cur_spelId,@cur_langId

            WHILE @@FETCH_STATUS = 0
              BEGIN

			  --INSERT INTO DATA TABLE
				 DECLARE @ident_spellingID INT
			     INSERT INTO tblSpelling(GeoRefID,LanguageID,UnicodeStr) 
				 VALUES(@geoRefId,@cur_langId,@placeName);
				 SELECT @ident_spellingID=SCOPE_IDENTITY();

			 --INSERT INTO MAPPING TABLE
				 EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblSpelling',@ident_spellingID;
			     FETCH next FROM cur_tbl INTO @cur_spelId,@cur_langId
			  END
			 CLOSE cur_tbl
			 --SET IDENTITY_INSERT [dbo].[tblSpelling] OFF
END
ELSE
BEGIN
		declare @updateKey int
		exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblSpelling', @spellingId, @updateKey out

		UPDATE tblSpelling SET UnicodeStr=@placeName WHERE SpellingID=@updateKey;

END

END

GO

GO

-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	sets the cat type for given place name
-- =============================================

GO
IF OBJECT_ID('[dbo].[sp_placenames_updatecattype]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_updatecattype]
END
GO
CREATE PROC sp_placenames_updatecattype
@configurationId INT,
@placeNameId INT,
@catTypeId INT,
@modlistinfo [ModListTable] READONLY
AS
BEGIN

declare @updateKey int, @as4xxxCatId INT
DECLARE @TempModListTable TABLE( Id INT,Row INT, Columns INT,Resolution INT)

	exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblGeoRef', @placeNameId, @updateKey out

	SET @as4xxxCatId = (SELECT [dbo].[FN_GetCatValuesBasedOnASXICatValues](@catTypeId))

	UPDATE tblGeoRef SET AsxiCatTypeId=@catTypeId, CatTypeId = @as4xxxCatId WHERE ID=@updateKey;

	exec dbo.SP_SetIsDirty @configurationId ,@modlistinfo
	

END

GO
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
IF OBJECT_ID('[dbo].[SP_PurgeConfigurationDefinition]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_PurgeConfigurationDefinition]
END
GO

CREATE PROCEDURE [dbo].[SP_PurgeConfigurationDefinition]
	@configurationDefinitionId int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    delete from tblconfigurations where ConfigurationDefinitionID = @configurationDefinitionId;
	delete from tblConfigurationDefinitions where ConfigurationDefinitionID = @configurationDefinitionId;
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	adds new region entry onto tblRegionSpelling
-- =============================================

IF OBJECT_ID('[dbo].[SP_Region_Add]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Region_Add]
END
GO

CREATE PROCEDURE [dbo].[SP_Region_Add]
	@configurationId INT,
    @regionName NVARCHAR(MAX)
AS
BEGIN

    DECLARE @regionId INT;
    SET @regionId = (SELECT MAX(Region.RegionID) FROM dbo.config_tblRegionSpelling(@configurationId) as Region) 
    IF @regionId IS NULL 
    BEGIN
        SET @regionId = 1
    END
    ELSE 
    BEGIN 
        SET @regionId = @regionId + 1
    END
   SELECT @regionId as regionId
END    
GO  
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	adds new region entry onto tblRegionSpelling
 --EXEC [dbo].[SP_Region_AddRegionDetails] 107,33,1,'h'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Region_AddRegionDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Region_AddRegionDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Region_AddRegionDetails]
	@configurationId INT,
    @regionId INT,
    @languageId INT,
    @regionName NVARCHAR(MAX)
AS
BEGIN
	DECLARE @SpellingId INT  = 0;
	IF EXISTS(select tblRegionSpelling.regionName FROM tblRegionSpelling INNER JOIN tblRegionSpellingMap ON tblRegionSpellingMap.SpellingID = tblRegionSpelling.SpellingID
    WHERE tblRegionSpellingMap.ConfigurationID = @configurationId AND tblRegionSpellingMap.IsDeleted = 0 AND tblRegionSpelling.regionName = @regionName AND tblRegionSpelling.languageId =@languageId) 
		 BEGIN
		   SET @SpellingId =3
		 END
		ELSE
		 BEGIN
		   BEGIN TRY
             INSERT INTO dbo.tblRegionSpelling (RegionID,RegionName,LanguageId,CustomChangeBitMask)VALUES(@regionId,@regionName,@languageId,1)
	         SET @SpellingId=SCOPE_IDENTITY();
	         EXEC SP_ConfigManagement_HandleAdd @ConfigurationId,'tblRegionSpelling',@SpellingId
			END TRY
			BEGIN CATCH
				SET @SpellingId =-1
			END CATCH
	     END
		 SELECT @SpellingId as SpellingId
    
END    
GO  
GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Returns list of all the region for the given configuration
-- =============================================
IF OBJECT_ID('[dbo].[SP_Region_GetAll]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Region_GetAll]
END
GO

CREATE PROCEDURE [dbo].[SP_Region_GetAll]
	@configurationId int
AS
BEGIN
   
  SELECT DISTINCT Region.RegionID,
  Region.RegionName
  FROM dbo.config_tblRegionSpelling(@configurationId) as Region
  WHERE Region.LanguageID = 1

END

GO
GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Returns Details of the region as name of the region in all the selected languages
-- =============================================
IF OBJECT_ID('[dbo].[SP_Region_GetDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Region_GetDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Region_GetDetails]
	@configurationId int,
    @regionId int
AS
BEGIN
   
   CREATE TABLE #tmpSelectedLanguages
(
	[RowNum] int not null,
    [ID] int NOT NULL ,
	[LanguageID] int NOT NULL,	
	[Name] nvarchar(100) NULL,	
	[NativeName] nvarchar(100) NULL,
	[Description] nvarchar(255) NULL,
	[ISLatinScript] bit NULL,
	[Tier] smallint NULL,	
	[2LetterID_4xxx] nvarchar(50) NULL,	
	[3LetterID_4xxx] nvarchar(50) NULL,	
	[2LetterID_ASXi] nvarchar(50) NULL,	
	[3LetterID_ASXi] nvarchar(50) NULL,
	[HorizontalOrder] smallint NULL DEFAULT 0,
	[HorizontalScroll] smallint NULL DEFAULT 0,	
	[VerticalOrder] smallint NULL DEFAULT 0,
	[VerticalScroll] smallint NULL DEFAULT 0
);

    INSERT INTO #tmpSelectedLanguages EXEC cust.SP_Global_GetSelectedLanguages @configurationId

    SELECT regionSpelling.RegionID,
	regionSpelling.SpellingID,
	regionSpelling.LanguageID,
	Name as Language,
	regionSpelling.RegionName

    FROM dbo.config_tblRegionSpelling(@configurationId) as regionSpelling
    inner join #tmpSelectedLanguages ON #tmpSelectedLanguages.LanguageID = regionSpelling.LanguageID
    WHERE regionSpelling.RegionId = @regionId ORDER BY #tmpSelectedLanguages.RowNum ASC

    DROP TABLE #tmpSelectedLanguages
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Updates region name of the given language, for the given country of the given configuration
-- =============================================

IF OBJECT_ID('[dbo].[SP_Region_UpdateDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Region_UpdateDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Region_UpdateDetails]
	@configurationId INT,
    @regionId INT,
    @languageId INT,
    @regionName NVARCHAR(MAX)
AS
BEGIN
    DECLARE @custom INT, @existingvalue INT,@updatedvalue INT
	SET @custom =2
	SET @existingvalue = (SELECT CustomChangeBitMask FROM tblRegionSpelling WHERE tblRegionSpelling.regionId = @regionId AND tblRegionSpelling.LanguageID = @languageId )
	SET @updatedvalue =(@existingvalue | @custom)
    UPDATE regionSpelling 
    SET regionSpelling.regionName =  @regionName,regionSpelling.CustomChangeBitMask =@updatedvalue FROM 
    dbo.config_tblRegionSpelling(@configurationId) as regionSpelling 
    WHERE regionSpelling.regionId = @regionId AND regionSpelling.LanguageID = @languageId   
END    
GO  
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa,Brinda Chindamada
-- Create date: 26/5/2022
-- Description:	Removes  the forced language settings
-- Sample: EXEC [dbo].[SP_RemoveForcedLang] 36,4
-- =============================================
IF OBJECT_ID('[dbo].[SP_RemoveForcedLang]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_RemoveForcedLang]

END

GO

CREATE PROCEDURE [dbo].[SP_RemoveForcedLang]
                        @configurationId INT,
                        @ScriptId NVARCHAR(100)
                       

AS

BEGIN        
         DECLARE @sql NVARCHAR(Max),@scriptDefId Int,@updateKey Int
		 DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
		  SELECT @scriptDefId=ScriptDefID FROM cust.tblScriptDefsMap WHERE ConfigurationID =  @configurationId
		  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey out
         SET @sql=('UPDATE [cust].[tblScriptDefs]  SET ScriptDefs.modify(''delete (/script_defs/script/@forced_langs)[../@id='+@scriptId+'][1]'') 
			FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID 
			CROSS APPLY b.ScriptDefs.nodes(''/script_defs/script'') Nodes(item) WHERE 
			  ConfigurationID =  @configurationId  AND b.ScriptDefID = @updateKey' )
		  EXEC sys.Sp_executesql @sql ,@params,@configurationId = @configurationId,@updateKey=@updateKey
END

GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan Abhishek Padinarapurayil
-- Create date: 5/24/2022
--Description: Deletes the particular row from UserRoleAssignments based on userId and roleID
--sample EXEC: exec [dbo].[SP_RemoveRoleAssignment_Userid] '3CD9AEB9-564F-41A4-AC03-00EF897F29F7','3A638B85-7F31-4E6A-BFA1-40C6003AC404'
-- =============================================
IF OBJECT_ID('[dbo].[SP_RemoveRoleAssignment_Userid]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_RemoveRoleAssignment_Userid]
END
GO
CREATE PROCEDURE [dbo].[SP_RemoveRoleAssignment_Userid]
			@userId  uniqueidentifier,
			@roleId uniqueidentifier
			
AS
BEGIN
		
		DELETE FROM dbo.UserRoleAssignments WHERE dbo.UserRoleAssignments.UserID = @userId AND dbo.UserRoleAssignments.RoleID = @roleId
		
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan,Abhishek Padinarapurayil
-- Create date: 5/24/2022
-- Description:	deletes the record from userRoleAssignments based on userID ,and roleid
--Sample EXEC: exec [dbo].[SP_RemoveRole_Userid] '3CD9AEB9-564F-41A4-AC03-00EF897F29F7','3A638B85-7F31-4E6A-BFA1-40C6003AC404','3A638B85-7F31-4E6A-BFA1-40C6003AC404'
-- ===========================================
IF OBJECT_ID('[dbo].[SP_RemoveRole_Userid]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_RemoveRole_Userid]
END
GO
CREATE PROCEDURE [dbo].[SP_RemoveRole_Userid]
			@userId  uniqueidentifier,
			@manageRoleId uniqueidentifier,
			@viewRoleId uniqueidentifier
			
AS
BEGIN
		
		DELETE FROM dbo.UserRoleAssignments WHERE dbo.UserRoleAssignments.UserID = @userId AND (dbo.UserRoleAssignments.RoleID = @manageRoleId OR dbo.UserRoleAssignments.RoleID = @viewRoleId)
		
END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	This sp will return name,id,scriptname and id based on configurationId
--Sample: EXEC [dbo].[SP_RemoveScript] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_RemoveScript]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_RemoveScript]
END
GO

CREATE PROCEDURE [dbo].[SP_RemoveScript]
        @configurationId INT
       
AS

BEGIN

       SELECT DISTINCT 
                ModesResult.ModeName as Name,
                ModesResult.ModeId as Id,
                ScriptIdLookup.ScriptName as ScriptName,
                ScriptIdLookup.ScriptId as ScriptId

                FROM

                (SELECT 
                isnull(Nodes.Mode.value('(./@name)[1]', 'varchar(max)'),'') as ModeName,
                isnull(Nodes.Mode.value('(./@id)[1]', 'varchar(max)'),'') as ModeId,
                isnull(Nodes.Mode.value('(./mode_item/@scriptidref)[1]', 'varchar(max)'),'') as ScriptId
                FROM cust.tblModeDefs as Modes
                cross apply Modes.ModeDefs.nodes('/mode_defs/mode') as Nodes(Mode)
                INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID
                AND cust.tblModeDefsMap.ConfigurationID = @configurationId)

                as ModesResult

                LEFT OUTER JOIN(
                   SELECT
                isnull(Nodes.Script.value('(./@name)[1]', 'varchar(max)'),'') as ScriptName,
                isnull(Nodes.Script.value('(./@id)[1]', 'varchar(max)'),'') as ScriptId
                FROM cust.tblScriptDefs as Scripts
                cross apply Scripts.ScriptDefs.nodes('/script_defs/script') as Nodes(Script)
                INNER JOIN cust.tblScriptDefsMap ON cust.tblScriptDefsMap.ScriptDefID = Scripts.ScriptDefID
                AND cust.tblScriptDefsMap.ConfigurationID = @configurationId
                )

                as ScriptIdLookup ON ScriptIdLookup.ScriptId = ModesResult.ScriptId
END
GO


GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date:  5/25/2022
-- Description:	This SP will update table scriptdefs based on configurationId and scriptId
--Sample: EXEC [dbo].[SP_RemoveScriptDefs] 36,4
-- =============================================

IF OBJECT_ID('[dbo].[SP_RemoveScriptDefs]','P') IS NOT NULL

BEGIN
        DROP PROC[dbo].[SP_RemoveScriptDefs]
END
GO

CREATE PROCEDURE [dbo].[SP_RemoveScriptDefs]
        @configurationId INT,
		@scriptId INT
       
AS

BEGIN       
            DECLARE @sql NVARCHAR(Max),@updateKey Int,@scriptDefId INT
		    DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int,@scriptParamId Int'
			--SET @scriptId = (SELECT cust.tblScriptDefsMap.ScriptDefID FROM cust.tblScriptDefsMap WHERE cust.tblScriptDefsMap.ConfigurationID =  @configurationId )
			SELECT @scriptDefId=ScriptDefID FROM cust.tblScriptDefsMap WHERE ConfigurationID =  @configurationId
		  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey out
		  
      SET @sql =(' UPDATE [cust].[tblScriptDefs] 
            SET ScriptDefs.modify(''delete (/script_defs/script)[@id='+CAST(@scriptId as varchar)+']'')
            FROM cust.tblScriptDefs b INNER JOIN [cust].tblScriptDefsMap c on c.ScriptDefID=b.ScriptDefID 
            CROSS APPLY b.ScriptDefs.nodes(''/script_defs/script'') Nodes(item) WHERE ISNULL(Nodes.item.value(''(./@id)[1]'',''int''),'''')= @scriptParamId AND 
            ConfigurationID= @configurationId AND b.ScriptDefID = @updateKey ' )
      EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey,@scriptParamId = @scriptId 
	
       
END
GO


GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa,Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	This SP will update the row in scriptdefs based on configurationId and scriptId
-- Sample: EXEC [dbo].[SP_RemoveSCriptItems] 67,8

--select * from [cust].[tblScriptDefsMap] where configurationId=67

-- =============================================
IF OBJECT_ID('[dbo].[SP_RemoveSCriptItems]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_RemoveSCriptItems]

END

GO

CREATE PROCEDURE [dbo].[SP_RemoveSCriptItems]
                        @configurationId INT,
                        @scriptId   INT
                       

AS

BEGIN        
            DECLARE @sql NVARCHAR(Max),@updateKey Int,@scriptDefId INT
		  DECLARE @params NVARCHAR(4000) = '@scriptParamId Int'
		  SELECT @scriptDefId=ScriptDefID FROM [cust].[tblScriptDefsMap] WHERE ConfigurationID=@configurationId
		  print @scriptDefId
		  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey OUT

      SET @sql=('UPDATE [cust].[tblScriptDefs] 
             SET ScriptDefs.modify(''delete (/script_defs/script[@id='+CAST(@scriptId as varchar)+ ']/item)'') 
             FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID 
             WHERE ConfigurationID = '+CAST(@configurationId AS varchar)+' AND b.ScriptDefID = '+CAST(@updateKey AS varchar)+' ')

print @updateKey

	  EXEC sys.Sp_executesql @sql,@params,@scriptParamId = @scriptId
END

GO

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Brinda
-- Create date: 01/31/2023
-- Description:	saves the extracted partnumbers
-- EXEC [dbo].[SP_SaveExtractedPartnumber] 5080,11,'072-4600-852853'
-- =============================================

IF OBJECT_ID('[dbo].[SP_SaveExtractedPartnumber]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_SaveExtractedPartnumber]
END
GO

CREATE PROCEDURE [dbo].[SP_SaveExtractedPartnumber]
   @configurationDefinitionID INT,
   @partNumberID INT,
   @partNumber NVARCHAR(255)
AS

BEGIN
    DECLARE @configurationDefinitionParentID INT
    Set @configurationDefinitionParentID = (select configurationDefinitionParentID from tblConfigurationDefinitions where configurationDefinitionID = @configurationDefinitionID)
    IF NOT EXISTS(select 1 from tblConfigurationDefinitionPartNumber where configurationdefinitionid = @configurationDefinitionParentID AND partNumberID = @partNumberID)
	BEGIN
	INSERT INTO tblConfigurationDefinitionPartNumber (ConfigurationDefinitionID, PartNumberID,Value) VALUES (@configurationDefinitionParentID,@partNumberID, @partNumber)
	END
	ELSE
	BEGIN
    Update tblConfigurationDefinitionPartNumber SET Value = @partNumber where ConfigurationDefinitionID  = @configurationDefinitionParentID AND PartNumberID = @partNumberID
	END
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 01/27/2023
-- Description:	To save feature set values
-- Sample EXEC [dbo].[SP_SaveFeatureSet] 'AS4XXX Product FeatureSet,ASXI-3 Product FeatureSet', 1, 3, 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_SaveFeatureSet]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_SaveFeatureSet]
END
GO

CREATE PROCEDURE [dbo].[SP_SaveFeatureSet]
    @selectedFeatureSetName NVARCHAR(MAX),
	@isAdded NVARCHAR(15),
	@configurationDefinitionId INT,
	@featureSetId INT,
	@featureSetName NVARCHAR(500) = NULL,
	@featureSetValue NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @tblTempFeatureSet TABLE(Id INT IDENTITY(1,1), FeatureSetId INT, Name NVARCHAR(MAX), Value NVARCHAR(MAX), IsConfigurable BIT, InputTypeId INT, KeyFeatureSetId INT)
	DECLARE @selectedFeatureSetID INT, @id INT, @name NVARCHAR(500)
	DECLARE @inputtype NVARCHAR(50), @keyId INT, @selectedFeatureSetValue NVARCHAR(500)
	DECLARE @selectedFeatureSetValueList TABLE(ID INT IDENTITY(1,1), val NVARCHAR(500))
	DECLARE @keyValueList TABLE(ID INT IDENTITY(1,1), selectedKey NVARCHAR(MAX), selectedValue NVARCHAR(MAX))
	DECLARE @CommaSeparatedKeyString NVARCHAR(MAX), @CommaSeparatedValueString NVARCHAR(MAX)

	SET @selectedFeatureSetID = (SELECT FeatureSetID FROM tblConfigurationDefinitions WHERE ConfigurationDefinitionID = @configurationDefinitionId)
	IF (@isAdded = 0)
	BEGIN
		SET @inputtype = (SELECT Name FROM tblFeatureSetInputType WHERE InputTypeID = (SELECT InputTypeID FROM tblFeatureSet WHERE NAME IN (SELECT * FROM STRING_SPLIT(@selectedFeatureSetName, ',')) AND FeatureSetID = @featureSetId))
		SET @keyId = (SELECT KeyFeatureSetID FROM tblFeatureSet WHERE NAME IN (SELECT * FROM STRING_SPLIT(@selectedFeatureSetName, ',')) AND FeatureSetID = @featureSetId)
		IF (@inputtype = 'dropdown' AND @keyId IS NOT NULL)
		BEGIN
			DELETE FROM tblFeatureSet WHERE FeatureSetID = @featureSetId AND NAME IN (SELECT * FROM STRING_SPLIT(@selectedFeatureSetName, ','))
			DELETE FROM tblFeatureSet WHERE FeatureSetID = @featureSetId AND ID = @keyId
		END
		ELSE
		BEGIN
			DELETE FROM tblFeatureSet WHERE FeatureSetID = @featureSetId AND NAME IN (SELECT * FROM STRING_SPLIT(@selectedFeatureSetName, ','))
		END
	END
	ELSE
	BEGIN
		IF (@featureSetName IS NOT NULL AND @featureSetValue IS NOT NULL)
		BEGIN
			SET @inputtype = (SELECT Name FROM tblFeatureSetInputType WHERE InputTypeID = (SELECT InputTypeID FROM tblFeatureSet WHERE name IN (@featureSetName) AND FeatureSetID = @selectedFeatureSetID))
			SET @keyId = (SELECT KeyFeatureSetID FROM tblFeatureSet WHERE name IN (@featureSetName) AND FeatureSetID = @selectedFeatureSetID)
			IF (@inputtype = 'dropdown' AND @keyId IS NOT NULL)
			BEGIN
				SET @CommaSeparatedKeyString = NULL
				SET @CommaSeparatedValueString = NULL
				
				INSERT INTO @selectedFeatureSetValueList SELECT * FROM STRING_SPLIT(@featureSetValue, ',')
				
				INSERT INTO @keyValueList
				SELECT REVERSE(PARSENAME(REPLACE(REVERSE(val), '|', '.'), 1)) AS SelectedKey
					, REVERSE(PARSENAME(REPLACE(REVERSE(val), '|', '.'), 2)) AS SelectedValue FROM @selectedFeatureSetValueList
				
				SELECT @CommaSeparatedKeyString = COALESCE(@CommaSeparatedKeyString + ',', '') + (LTRIM(RTRIM(SelectedKey))) FROM @keyValueList
				SELECT @CommaSeparatedValueString = COALESCE(@CommaSeparatedValueString + ',', '') + (LTRIM(RTRIM(SelectedValue))) FROM @keyValueList

				UPDATE tblFeatureSet SET value = @CommaSeparatedKeyString WHERE ID = @keyId AND FeatureSetID = @selectedFeatureSetID
				UPDATE tblFeatureSet SET VALUE = @CommaSeparatedValueString WHERE NAME = @featureSetName AND FeatureSetID = @selectedFeatureSetID
			END
			ELSE
			BEGIN
				UPDATE tblFeatureSet SET VALUE = @featureSetValue WHERE NAME = @featureSetName AND FeatureSetID = @selectedFeatureSetID
			END
		END
		ELSE IF (@selectedFeatureSetName IS NOT NULL)
		BEGIN
			IF(@selectedFeatureSetID IS NULL)
			BEGIN
				SET @selectedFeatureSetID = (SELECT MAX(FeatureSetID) + 1 FROM tblFeatureSet)
				UPDATE tblConfigurationDefinitions SET FeatureSetID = @selectedFeatureSetID WHERE ConfigurationDefinitionID = @configurationDefinitionId
			END
			INSERT INTO @tblTempFeatureSet (FeatureSetId, Name, Value, IsConfigurable, InputTypeId, KeyFeatureSetId) SELECT @selectedFeatureSetID, Name, Value, IsConfigurable, InputTypeID, KeyFeatureSetID FROM tblFeatureSet WHERE FeatureSetID = 1 AND   
			Name IN (SELECT * FROM STRING_SPLIT(@selectedFeatureSetName, ','))  
    
			WHILE (SELECT COUNT(*) FROM @tblTempFeatureSet) > 0  
			BEGIN  
				SET @id = (SELECT TOP 1 Id FROM @tblTempFeatureSet)  
				SET @name = (SELECT Name FROM @tblTempFeatureSet WHERE Id = @id)
				SET @inputtype = (SELECT Name FROM tblFeatureSetInputType WHERE InputTypeID = (SELECT InputTypeID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1))
				SET @keyId = (SELECT KeyFeatureSetID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1)

				IF (@inputtype = 'dropdown' AND @keyId IS NOT NULL)
				BEGIN
					INSERT INTO tblFeatureSet (FeatureSetID, Name, Value, IsConfigurable, InputTypeID) 
					SELECT @selectedFeatureSetID, Name, Value, IsConfigurable, InputTypeID FROM tblFeatureSet WHERE FeatureSetID = 1 AND  NAME = @name
					
					INSERT INTO tblFeatureSet (FeatureSetID, Name, Value, IsConfigurable, InputTypeID) 
					SELECT @selectedFeatureSetID, Name, Value, IsConfigurable, InputTypeID FROM tblFeatureSet WHERE FeatureSetID = 1 AND  ID = @keyId

					UPDATE tblFeatureSet SET KeyFeatureSetID = SCOPE_IDENTITY() WHERE FeatureSetID = @selectedFeatureSetID AND Name = @name
				END
				ELSE
				BEGIN
					INSERT INTO tblFeatureSet (FeatureSetID, Name, Value, IsConfigurable, InputTypeID) 
					SELECT @selectedFeatureSetID, Name, Value, IsConfigurable, InputTypeID FROM tblFeatureSet WHERE FeatureSetID = 1 AND  NAME = @name
				END
				DELETE FROM @tblTempFeatureSet WHERE Id = @id 
			END
		END
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 01/23/2023
-- Description:	Update product data and create or update platforms under the product.
-- Sample EXEC [dbo].[SP_SaveProductConfigurationData] 'Product4', 'Product4', 5072, null, 1, null
-- =============================================

IF OBJECT_ID('[dbo].[SP_SaveProductConfigurationData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_SaveProductConfigurationData]
END
GO

CREATE PROCEDURE [dbo].[SP_SaveProductConfigurationData]
	@productName NVARCHAR(500),
    @productDescription NVARCHAR(MAX),
    @configurationDefinitionId INT,
    @userID UNIQUEIDENTIFIER,
	@outputTypeID INT,
	@TopLevelPartnumber NVARCHAR(MAX),
	@platformData [Type_PlatformData] READONLY
	
	
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION SavePlatforms
		DECLARE @TempPlatformDataTable TABLE( Id INT IDENTITY(1,1), ConfigurationDefinitionID INT, PlatformName NVARCHAR(MAX), PlatformDescription NVARCHAR(MAX), 
		PlatformId INT, InstallationTypeID UNIQUEIDENTIFIER)

		DECLARE @Id INT, @PlatformId INT, @platformName NVARCHAR(500), @platformDescription NVARCHAR(MAX), @platformConfigurationDefinitionID INT,
		@installationTypeID UNIQUEIDENTIFIER, @maxConfigDefID INT, @featureSetID INT, @maxPlatformID INT, @description NVARCHAR(MAX), @configurationTypeID INT,
		@configurationDefinitionParentId INT, @parentConfigConfigurationId INT, @branchDescription NVARCHAR(MAX)

		---*** Region to update Product data ***---
		UPDATE P
		SET P.Name = @productName, P.Description = @productDescription, p.LastModifiedBy = @userID,p.TopLevelPartnumber =@TopLevelPartnumber
		FROM tblProducts P
		INNER JOIN tblProductConfigurationMapping PCM ON P.ProductID = PCM.ProductID
		WHERE PCM.ConfigurationDefinitionID = @configurationDefinitionId
		---*** End Region ***---

		---*** Update ConfigurationDefinition Table ***---
		UPDATE tblConfigurationDefinitions
		SET OutputTypeID = @outputTypeID
		WHERE ConfigurationDefinitionID = @configurationDefinitionId
		---*** End Region ***---

		DECLARE @parentConfigVersion INT;

		SELECT @parentConfigVersion=MAX(VERSION) FROM tblConfigurations WHERE ConfigurationDefinitionID=@configurationDefinitionId AND Locked=1

		---*** Update / Insert data to platforms table ***---
		INSERT INTO @TempPlatformDataTable SELECT * FROM @platformData

		WHILE (SELECT COUNT(*) FROM @TempPlatformDataTable) > 0
		BEGIN
			SET @Id = (SELECT TOP 1 Id FROM @TempPlatformDataTable)
			SET @PlatformId = (SELECT TOP 1 PlatformId FROM @TempPlatformDataTable WHERE Id = @Id)
			SET @platformName = (SELECT TOP 1 PlatformName FROM @TempPlatformDataTable WHERE Id = @Id)
			SET @platformDescription = (SELECT TOP 1 PlatformDescription FROM @TempPlatformDataTable WHERE Id = @Id)
			SET @platformConfigurationDefinitionID = (SELECT TOP 1 ConfigurationDefinitionID FROM @TempPlatformDataTable WHERE Id = @Id)
			SET @installationTypeID = (SELECT TOP 1 InstallationTypeID FROM @TempPlatformDataTable WHERE Id = @Id)
			SET @featureSetID = (SELECT FeatureSetID FROM tblConfigurationDefinitions WHERE ConfigurationDefinitionID = @configurationDefinitionId)

			IF @PlatformId <> 0 AND EXISTS (SELECT 1 FROM tblPlatforms P INNER JOIN tblPlatformConfigurationMapping PCM ON P.PlatformID = PCM.PlatformID 
				WHERE P.PlatformID = @PlatformId)
			BEGIN
				UPDATE P
				SET P.Name = @platformName, P.Description = @platformDescription, P.InstallationTypeID = @installationTypeID
				FROM tblPlatforms P
				INNER JOIN tblPlatformConfigurationMapping PCM ON P.PlatformID = PCM.PlatformID
				WHERE PCM.ConfigurationDefinitionID = @platformConfigurationDefinitionID
			END
			ELSE
			BEGIN
				SET @maxConfigDefID = (SELECT MAX(ConfigurationDefinitionID) FROM tblConfigurationDefinitions)
				SET @configurationTypeID = (SELECT ConfigurationTypeID FROM tblConfigurationDefinitions WHERE ConfigurationDefinitionID = @configurationDefinitionId)
				SET @description = (SELECT CONCAT(@platformDescription, ' Product ', @productName))
				SET @configurationDefinitionParentId = (SELECT ConfigurationDefinitionParentID FROM tblConfigurationDefinitions 
						WHERE ConfigurationDefinitionID = @configurationDefinitionId)
			
				INSERT INTO tblConfigurationDefinitions (ConfigurationDefinitionID, ConfigurationDefinitionParentID, OutputTypeID, Active, AutoLock, 
					AutoMerge, AutoDeploy, FeatureSetID, ConfigurationTypeID,UpdatedUpToVersion)
					VALUES (@maxConfigDefID + 1, @configurationDefinitionId, @outputTypeID, 1, 1, 1, 1, @featureSetID, @configurationTypeID,@parentConfigVersion)
			
				SELECT @maxConfigDefID = (SELECT MAX(ConfigurationDefinitionID) FROM tblConfigurationDefinitions);

				SET @maxPlatformID = (SELECT ISNULL(MAX(PlatformID), 0) FROM tblPlatforms)

				INSERT INTO tblPlatforms (PlatformID, Name, Description, InstallationTypeID)
				VALUES (@maxPlatformID + 1, @platformName, @description, @installationTypeID)

				SET @maxPlatformID = (SELECT MAX(PlatformID) FROM tblPlatforms)
				INSERT INTO tblPlatformConfigurationMapping(PlatformID, ConfigurationDefinitionID) VALUES (@maxPlatformID, @maxConfigDefID)

				SET @branchDescription = CONCAT(@platformName, ' Platform Configuration')
				SET @parentConfigConfigurationId = (SELECT TOP 1 ConfigurationID FROM tblConfigurations WHERE ConfigurationDefinitionID = @configurationDefinitionId AND Locked = 1 ORDER BY Version DESC)
				EXEC dbo.SP_CreateBranch @parentConfigConfigurationId, @maxConfigDefID, 'Initial Setup', @branchDescription
			END
			DELETE FROM @TempPlatformDataTable WHERE Id = @Id;
			
		END
		COMMIT TRANSACTION SavePlatforms
	---*** End Region ---***
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION SavePlatforms
	END CATCH
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 01/24/2023
-- Description:	Procedure to create new product data
-- Sample EXEC [dbo].[SP_SaveProductData] 'test2','testing', 1,NULL,2
-- =============================================

IF OBJECT_ID('[dbo].[SP_SaveProductData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_SaveProductData]
END
GO

CREATE PROCEDURE [dbo].[SP_SaveProductData]
	@productName NVARCHAR(500),
    @productDescription NVARCHAR(MAX),
	@configurationDefinitionId INT,
	@userID UNIQUEIDENTIFIER,
	@outputTypeID INT,
	@topLevelPartNumber NVARCHAR(500)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION SaveProducts
		DECLARE @maxConfigDefID INT, @maxProductID INT, @maxConfigurationTypeID INT, @parentConfigConfigurationId INT, @description NVARCHAR(MAX)
		Declare @outputTable TABLE(ConfigurationId INT, Message NVARCHAR(500), ConfigurationDefinitionId INT)
		SET @maxConfigDefID = (SELECT MAX(ConfigurationDefinitionID) FROM tblConfigurationDefinitions)
		
		SET @maxConfigurationTypeID = (SELECT MAX(ConfigurationTypeID) FROM tblConfigurationTypes)


		---*** Region to insert Configuration types ***---
		INSERT INTO tblConfigurationTypes (ConfigurationTypeID, Name, UsesTimezone, UsesPlacenames)
		VALUES (@maxConfigurationTypeID + 1, @productName, 1, 1)
		---*** End region ***---

		DECLARE @parentConfigVersion INT;

		SELECT @parentConfigVersion=MAX(VERSION) FROM tblConfigurations WHERE ConfigurationDefinitionID=1 AND Locked=1

		---*** Region Insert data to configurationdefinition table ***---
		INSERT INTO tblConfigurationDefinitions (ConfigurationDefinitionID, ConfigurationDefinitionParentID, OutputTypeID, Active, AutoLock, 
			AutoMerge, AutoDeploy, ConfigurationTypeID,UpdatedUpToVersion) VALUES (@maxConfigDefID + 1, 1, @outputTypeID, 1, 1, 1, 1, @maxConfigurationTypeID,@parentConfigVersion)
			
		SET @maxConfigDefID = (SELECT MAX(ConfigurationDefinitionID) FROM tblConfigurationDefinitions)
		---*** End Region ***---

		---*** Insert data to products table ***--
		SET @maxProductID = (SELECT MAX(ProductID) FROM tblProducts)

		INSERT INTO tblProducts(ProductID, Name, Description, LastModifiedBy,TopLevelPartnumber)  
        VALUES (@maxProductID + 1, @productName, @productDescription, @userID,@topLevelPartNumber)  

		SET @maxProductID = (SELECT MAX(ProductID) FROM tblProducts)
		INSERT INTO tblProductConfigurationMapping(ProductID, ConfigurationDefinitionID) VALUES (@maxProductID, @maxConfigDefID)
		---*** End Region ***---
		
		SET @description = CONCAT(@productName, ' Product Configuration')
		INSERT INTO @outputTable (ConfigurationId, Message) EXEC dbo.SP_CreateBranch 1, @maxConfigDefID, 'Initial Setup', @description

		SELECT @maxConfigDefID AS ConfigurationDefinitionID
		COMMIT  TRANSACTION SaveProducts
	END TRY
	BEGIN CATCH
		SELECT 0 AS ConfigurationDefinitionID
		ROLLBACK  TRANSACTION SaveProducts
	END CATCH
END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date:  5/25/2022
-- Description:	This will update the scriptdefs table based on condition 
-- Sample: EXEC [dbo].[SP_SaveScript] 67,2,'Tasdfsdfest1234dfa'
-- =============================================

IF OBJECT_ID('[dbo].[SP_SaveScript]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_SaveScript]
END
GO

CREATE PROCEDURE [dbo].[SP_SaveScript]
        @configurationId INT,
		@scriptId INT,
		@scriptName  NVARCHAR(100)

       
AS

BEGIN
     
	DECLARE @sql NVARCHAR(Max),@updateKey Int,@scriptDefId INT
    DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int,@scriptParamId Int'
    SELECT @scriptDefId=ScriptDefID FROM cust.tblScriptDefsMap WHERE ConfigurationID =  @configurationId
    EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey out
	print @updateKey
    SET @sql='UPDATE [cust].[tblScriptDefs]
	SET ScriptDefs.modify(''replace value of (/script_defs/script/@name)[../@id = '+CAST(@scriptId as varchar)+'][1] with "'+ @scriptName +'"'')
    FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID
    CROSS APPLY b.ScriptDefs.nodes(''/script_defs/script'') Nodes(item) WHERE ISNULL(Nodes.item.value(''(./@id)[1]'', ''int''), '''') = @scriptParamId AND ConfigurationID = @configurationId and b.ScriptDefID = @updateKey '

    EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey, @scriptParamId = @scriptId
END
GO


GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Brinda	
-- Create date: 6/1/2022
-- Description:	this sp will update the row in scriptdefs based on configurationid,strxmlitem and scriptid
--Sample: EXEC [dbo].[SP_SaveScriptItems] 1,'ENGLISH',1
-- =============================================
	-- =============================================
IF OBJECT_ID('[dbo].[SP_SaveScriptItems]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_SaveScriptItems]

END

GO

CREATE PROCEDURE [dbo].[SP_SaveScriptItems]
                        @configurationId INT,
						@strXmlitem NVARCHAR(MAX),
						@scriptId INT
                      
                       

AS

BEGIN 
            DECLARE @sql NVARCHAR(Max),@updateKey Int,@scriptDefId Int
			    DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int,@scriptParamId Int'
				SELECT @scriptDefId=ScriptDefID FROM cust.tblScriptDefsMap WHERE ConfigurationID =  @configurationId
    EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey out
      SET @sql='UPDATE [cust].[tblScriptDefs] 
            SET ScriptDefs.modify(''insert (' + @strXmlitem + ' )into 
             (/script_defs/script)[@id='+CAST(@scriptId as varchar)+'][1]'') 
            FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID 
            CROSS APPLY b.ScriptDefs.nodes(''/script_defs/script'') Nodes(item) WHERE ConfigurationID =  @configurationId AND  b.ScriptDefID = @updateKey '
	  EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey, @scriptParamId = @scriptId
END

GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	This query will return  the number of column name  from scriptdefs
-- Sample: EXEC [dbo].[SP_Script_CountFlightInfoAddView] 1,'Info Page 2_3D'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Script_CountFlightInfoAddView]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_Script_CountFlightInfoAddView]
END
GO

CREATE PROCEDURE [dbo].[SP_Script_CountFlightInfoAddView]
        @configurationId INT,
        @infoName  NVARCHAR(100)
AS

BEGIN
             
            SELECT COUNT(1) FROM cust.tblScriptDefs SD
           INNER JOIN cust.tblScriptDefsMap SDM ON SD.ScriptDefID = SDM.ScriptDefID
           CROSS APPLY SD.ScriptDefs.nodes('/script_defs/infopages/infopage') Nodes(item)
            where SDM.ConfigurationID = @configurationId and isnull(nodes.item.value('(./@name)[1]','nvarchar(max)'),'') = @infoName
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/24/2022
-- Description:	Get language list and default language 
-- Sample: EXEC [dbo].[SP_script_GetForcedLanguages] 67
-- =============================================
IF OBJECT_ID('[dbo].[SP_script_GetForcedLanguages]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_script_GetForcedLanguages]
END
GO

CREATE PROCEDURE [dbo].[SP_script_GetForcedLanguages]
        @configurationId INT
       
AS

BEGIN

               SELECT Global.value('(/global/language_set)[1]', 'varchar(max)') AS lang_list,
               ISNULL(Nodes.item.value('(./@default)[1]','varchar(max)'),'') AS default_lang 
               FROM cust.tblGlobal b CROSS APPLY b.Global.nodes('/global/language_set') Nodes(item)
			   INNER JOIN cust.tblGlobalMap ON cust.tblGlobalMap.ConfigurationID = tblGlobalMap.ConfigurationID 
               WHERE tblGlobalMap.ConfigurationID = @configurationId
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada
-- Create date: 5/26/2022
-- Description:	Get language and 2 letter code 
-- Sample: EXEC [dbo].[SP_script_GetLang] 'English,French,Spanish,Simp_chinese'
-- =============================================
IF OBJECT_ID('[dbo].[SP_script_GetLang]','P') IS NOT NULL
BEGIN
DROP PROC [dbo].[SP_script_GetLang]
END
GO
CREATE PROCEDURE [dbo].[SP_script_GetLang]
@combindedString NVARCHAR(250)

AS
BEGIN
SELECT Distinct LOWER(dbo.tblLanguages.Name) as LanguageName,[2LetterID_4xxx] as TwoletterID FROM dbo.tblLanguages
WHERE [2LetterID_4xxx] is not null and
LOWER(dbo.tblLanguages.Name) IN(SELECT Item
FROM dbo.SplitString(@combindedString, ','))
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa,Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	update old language based on conditions
-- Sample: EXEC [dbo].[SP_script_OldLanguage] 67,8,'EN'
-- =============================================
IF OBJECT_ID('[dbo].[SP_script_OldLanguage]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_script_OldLanguage]

END

GO

CREATE PROCEDURE [dbo].[SP_script_OldLanguage]
                        @configurationId INT,
                        @scriptId INT,
                        @twoLetterlanguageCodes  NVARCHAR(100)

AS

BEGIN

         DECLARE @sql NVARCHAR(Max),@updateKey Int,@scriptDefId INT
	   	 DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int,@scriptParamId Int'
		 SELECT @scriptDefId=ScriptDefID FROM cust.tblScriptDefsMap WHERE ConfigurationID =  @configurationId
		 EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey out
            SET @sql=('UPDATE [cust].[tblScriptDefs] 
                 SET ScriptDefs.modify(''insert attribute forced_langs {"' + @twoLetterlanguageCodes +'" } into (/script_defs/script[@id='+CAST(@scriptId as varchar)+'])[1]'')
                 FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID
                 CROSS APPLY b.ScriptDefs.nodes(''/script_defs/script'') Nodes(item) WHERE ISNULL(Nodes.item.value(''(./@id)[1]'','' int''), '''') = @scriptParamId AND ConfigurationID =  @configurationId AND b.ScriptDefID = @updateKey' )
	  EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey,@scriptParamId = @scriptId
END

GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	this will return scriptdefId based on configurationId
-- Sample:EXEC [dbo].[SP_script_SaveScript] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_script_SaveScript]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_script_SaveScript]
END
GO

CREATE PROCEDURE [dbo].[SP_script_SaveScript]
        @configurationId INT
       
AS

BEGIN

       SELECT TOP 1 ScriptDefID FROM [cust].[tblScriptDefsMap] WHERE ConfigurationID=@configurationId 
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	update scriptdef based on configurationid and xmlScript
-- Sample: EXEC [dbo].[SP_script_ScriptDef] 1,'ENGLISH'
-- =============================================
IF OBJECT_ID('[dbo].[SP_script_ScriptDef]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_script_ScriptDef]
END
GO

CREATE PROCEDURE [dbo].[SP_script_ScriptDef]
        @configurationId INT,
		@xmlScript NVARCHAR(100)
       
AS

BEGIN
       DECLARE @sql NVARCHAR(Max),@scriptDefId Int,@updateKey Int, @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int'
	   SET @scriptDefId = (SELECT cust.tblScriptDefsMap.ScriptDefID FROM cust.tblScriptDefsMap WHERE cust.tblScriptDefsMap.configurationId = @configurationId)
		EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey out
       SET @sql=('UPDATE [cust].[tblScriptDefs] 
                 SET ScriptDefs.modify(''insert '+ @xmlScript+'  as last into (/script_defs)[1]'')
                  FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID
                   CROSS APPLY b.ScriptDefs.nodes(''/script_defs'') Nodes(item) WHERE ConfigurationID =  @configurationId AND b.ScriptDefID = @updateKey')
		EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey
END
GO



GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Aiyappa, Brinda Chindamada		
-- Create date:  5/25/2022
-- Description:	get the forced language based on configurationid and scriptid
-- Sample: EXEC [dbo].[SP_Script_SetForcedLanguage] 67,8
-- =============================================
IF OBJECT_ID('[dbo].[SP_Script_SetForcedLanguage]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_Script_SetForcedLanguage]
END
GO

CREATE PROCEDURE [dbo].[SP_Script_SetForcedLanguage]
        @configurationId INT,
		@scriptId INT
       
AS

BEGIN

       SELECT ISNULL(Nodes.item.value('(./@forced_langs)[1]','varchar(max)'),'') AS forced_lang 
       FROM cust.tblScriptDefs b INNER JOIN [cust].tblScriptDefsMap c on c.ScriptDefID=b.ScriptDefID 
       CROSS APPLY b.ScriptDefs.nodes('/script_defs/script') Nodes(item) WHERE ISNULL(Nodes.item.value('(./@id)[1]','int'),'')= @scriptId AND ConfigurationID=@configurationId
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date:  5/25/2022
-- Description:	this query will return the items based on configurationid and selected info
-- Sample: EXEC [dbo].[SP_SetFlightInfoViewForItem] 1,'Info Page 2_3D'
-- =============================================
IF OBJECT_ID('[dbo].[SP_SetFlightInfoViewForItem]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_SetFlightInfoViewForItem]
END
GO

CREATE PROCEDURE [dbo].[SP_SetFlightInfoViewForItem]
        @ConfigurationID INT,
		@selectedInfo NVARCHAR(300)
       
AS

BEGIN
                    SELECT ISNULL(Nodes.item.value('(./@infoitems)[1]','varchar(max)'),'') AS items
                    FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID
                    CROSS APPLY b.ScriptDefs.nodes('/script_defs/infopages/infopage') Nodes(item) 
					WHERE ConfigurationID  = @ConfigurationID AND UPPER(ISNULL(Nodes.item.value('(./@name)[1]','varchar(max)'),''))=@selectedInfo
   
END
GO


GO

-- =============================================
-- Author:		Abhishek PM
-- Create date: 9/19/2022
-- Description:	updates the isdirty flag =1
-- =============================================


IF OBJECT_ID('[dbo].[SP_SetIsDirty]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_SetIsDirty]
END
GO

CREATE PROCEDURE [dbo].[SP_SetIsDirty]
@configurationId INT,
@modlistinfo [ModListTable] READONLY
AS
BEGIN
DECLARE @TempModListTable TABLE( Id INT,Row INT, Columns INT,Resolution INT)
	INSERT into @TempModListTable SELECT * from @modlistinfo
	DECLARE @Id int , @Row int,@Columns int,@Resolution int
	
	WHILE (SELECT COUNT(*) FROM @TempModListTable) > 0
	BEGIN
	 SET @Id = (SELECT TOP 1 Id from @TempModListTable)
	 SET @Row = (SELECT  Row  from @TempModListTable WHERE Id =@Id)
	 SET @Columns = (SELECT  Columns  from @TempModListTable WHERE Id =@Id)
	 SET @Resolution = (SELECT  Resolution  from @TempModListTable WHERE Id =@Id)
	 
	 IF EXISTS(SELECT 1 FROM tblModList m INNER JOIN tblModListMap mm on m.ModlistId = mm.ModlistID where m.Row = @row and m.Col = @columns and m.resolution = @resolution and mm.ConfigurationID = @configurationId)
	 begin
	 update m 
	 set isdirty = 1 
	 from tblmodlist m inner join tblmodlistmap mm on m.modlistid = mm.modlistid 
	 where  m.Row = @row and m.col = @columns and m.resolution = @resolution and mm.ConfigurationID = @configurationId
	 end

	 DELETE FROM @TempModListTable WHERE Id =@Id
	END
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Brinda
-- Create date: 01/31/2023
-- Description:	copies the top level partnumber
-- =============================================

IF OBJECT_ID('[dbo].[SP_SetTopLevelPartnumber]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_SetTopLevelPartnumber]
END
GO

CREATE PROCEDURE [dbo].[SP_SetTopLevelPartnumber]
    @copyFileName VARCHAR(15),
	@configurationDefinitionID INT 
AS
BEGIN
      update tblproducts SET TopLevelPartnumber = @copyFileName from tblproducts   inner join tblproductconfigurationmapping on tblproducts.productid = tblproductconfigurationmapping.productid 
      inner join tblconfigurationdefinitions on tblproductconfigurationmapping.configurationdefinitionid = tblconfigurationdefinitions.ConfigurationDefinitionParentID 
      where tblConfigurationDefinitions.ConfigurationDefinitionID = @configurationDefinitionID
END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Mohan,Abhishek Padinarapurayil>
-- Create date: <5/23/2022>
--description: returns rows from tblSubscriptionFeatureAssignment based on SubscriptionId provided
--Sample EXEC:exec [dbo].[SP_Subscription_Find] 'AC5A159E-4519-455E-BBAC-DF0A568E01FB'
-- =============================================
IF OBJECT_ID('[dbo].[SP_Subscription_Find]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_Subscription_Find]
END
GO
CREATE PROCEDURE [dbo].[SP_Subscription_Find]
			@subscriptionId  uniqueidentifier
AS
BEGIN
		
		select * FROM dbo.tblSubscriptionFeatureAssignment WHERE subscriptionId = @subscriptionId
		
END
GO
GO


/****** Object:  StoredProcedure [dbo].[sp_ticker_addupdatetickerparam]    Script Date: 1/30/2022 9:26:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	add ticker param
-- Sample EXEC [dbo].[sp_ticker_addupdatetickerparam] 1,''
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_addupdatetickerparam]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_addupdatetickerparam]
END
GO

CREATE PROC [dbo].[sp_ticker_addupdatetickerparam]
@configurationId INT,
@xmlValue xml
AS
BEGIN
UPDATE 
                cust.tblWebMain
                SET InfoItems = @xmlValue
                 WHERE cust.tblWebMain.WebMainID IN (
	                SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap
	                WHERE cust.tblWebMainMap.ConfigurationID = @configurationId
	                )
END
GO


GO


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


GO


/****** Object:  StoredProcedure [dbo].[sp_ticker_getinfoitems]    Script Date: 1/30/2022 9:29:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	get all ticer info items
-- Sample EXEC [dbo].[sp_ticker_getinfoitems] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_getinfoitems]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_getinfoitems]
END
GO

CREATE PROC [dbo].[sp_ticker_getinfoitems]
@configurationId INT
AS 
BEGIN
SELECT 
                InfoItems
                FROM cust.tblWebMain
                INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = cust.tblWebMain.WebMainID
                AND cust.tblWebMainMap.ConfigurationID = @configurationId
END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_ticker_getselectedtickerparam]    Script Date: 1/30/2022 9:30:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	retunrs selected ticker params for config
-- Sample EXEC [dbo].[sp_ticker_getselectedtickerparam] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_getselectedtickerparam]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_getselectedtickerparam]
END
GO

CREATE PROC [dbo].[sp_ticker_getselectedtickerparam]
@configurationId INT
AS
BEGIN
SELECT  Nodes.InfoItem.value('(.)[1]','varchar(max)') as Parameter 
                FROM 
                cust.tblWebMain as WebMain 
                cross apply WebMain.InfoItems.nodes('/infoitems/infoitem[@ticker= "true"]') as Nodes(InfoItem) 
                INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = WebMain.WebMainID 
                AND cust.tblWebMainMap.ConfigurationID = @configurationId
END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_ticker_getticker]    Script Date: 1/30/2022 9:31:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	getting ticker details
-- Sample EXEC [dbo].[sp_ticker_getticker] 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_getticker]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_getticker]
END
GO

CREATE PROC [dbo].[sp_ticker_getticker]
@configurationId INT
AS
BEGIN

SELECT 
                isnull(Ticker.value('(/ticker/@position)[1]', 'varchar(max)'),'bottom') as Position, 
                isnull(Ticker.value('(/ticker/@speed)[1]', 'INT'),'0') as Speed, 
                isnull(Ticker.value('(/ticker/@visible)[1]', 'varchar(max)'),'true') as Visible
                FROM cust.tblTicker 
                INNER JOIN cust.tblTickerMap ON cust.tblTickerMap.TickerID = cust.tblTicker.TickerID 
                AND cust.tblTickerMap.ConfigurationID = @configurationId

END
GO


GO

/****** Object:  StoredProcedure [dbo].[sp_ticker_gettickercount]    Script Date: 1/30/2022 9:33:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	returns ticker details
-- Sample EXEC [dbo].[sp_ticker_gettickercount] 'position', 1
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_gettickercount]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_gettickercount]
END
GO

CREATE PROC [dbo].[sp_ticker_gettickercount]
@name VARCHAR(200),
@configurationId INT
AS
BEGIN

 SELECT count(b.value('local-name(.)','VARCHAR(MAX)'))
FROM cust.tblTicker b
  INNER JOIN cust.tblTickerMap c ON b.TickerID = c.TickerID 
  CROSS APPLY b.Ticker.nodes('/ticker') test(item) cross apply item.nodes('@*') a(b) WHERE ConfigurationID=@configurationId  
  AND b.value('local-name(.)','VARCHAR(MAX)')=@name

END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_ticker_istickeritemdisabled]    Script Date: 1/30/2022 9:34:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	checks if the ticker disabled
-- Sample EXEC [dbo].[sp_ticker_istickeritemdisabled] 1, 'position'
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_istickeritemdisabled]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_istickeritemdisabled]
END
GO

CREATE PROC [dbo].[sp_ticker_istickeritemdisabled]
@configurationId INT,
@tickeritem VARCHAR(200)
AS
BEGIN

SELECT 
                COUNT(*) 
                FROM 
                cust.tblWebMain as WebMain 
                cross apply WebMain.InfoItems.nodes('/infoitems/infoitem') as Nodes(InfoItem)
                INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = WebMain.WebMainID 
                AND cust.tblWebMainMap.ConfigurationID = @configurationId AND Nodes.InfoItem.value('(.)[1]', 'varchar(max)') like '%'+@tickeritem+'%' 
                WHERE Nodes.InfoItem.value('(./@ticker)[1]', 'varchar(max)') like '%false%'

END
GO


GO


/****** Object:  StoredProcedure [dbo].[sp_ticker_removetickerparam]    Script Date: 1/30/2022 9:36:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 1/30/2022
-- Description:	remove tikcer param
-- Sample EXEC [dbo].[sp_ticker_removetickerparam] 1, 'position'
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_removetickerparam]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_ticker_removetickerparam]
END
GO

CREATE PROC [dbo].[sp_ticker_removetickerparam]
@configurationId INT,
@tickeritem VARCHAR(200)
AS
BEGIN

UPDATE cust.tblWebMain 
                 SET InfoItems.modify('delete /infoitems/infoitem[text()][contains(.,sql:variable("@tickeritem"))]') 
                 WHERE cust.tblWebMain.WebMainID IN( 
                 SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap 
                 WHERE cust.tblWebMainMap.ConfigurationID = @configurationId 
                 ) 

END
GO


GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan,Abhishek Padinarapurayil
-- Create date: 5/24/2022
-- Description:	this will update the ticker value
--EXEC [dbo].[sp_ticker_update] 67,'visible','false'
-- =============================================
IF OBJECT_ID('[dbo].[sp_ticker_update]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[sp_ticker_update]
END
GO
CREATE PROCEDURE [dbo].[sp_ticker_update]
			@configurationId INT,
			@name NVARCHAR(Max),
			@value NVARCHAR(Max)
			
AS
BEGIN
		DECLARE @sql NVARCHAR(MAX),@UpdateKey int,@TickerID int,@params NVARCHAR(400)='@updatekey int'
		SET @TickerID = (SELECT  cust.tblTickerMap.TickerID FROM cust.tblTickerMap WHERE cust.tblTickerMap.ConfigurationID = @configurationId)
		EXEC SP_ConfigManagement_HandleUpdate @configurationId ,'tblTicker',@TickerID,@UpdateKey out
		SET  @sql ='UPDATE cust.tblTicker
              SET  Ticker.modify(''replace value of (/ticker/@' +@name + ')[1] with "'  + @value + '"'') 
              WHERE cust.tblTicker.TickerID  =@UpdateKey'
		EXEC sys.Sp_executesql @sql,@params,@UpdateKey=@UpdateKey
END
GO



GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Gets different locations for view type
-- Sample EXEC [SP_Timezone_ColorsData] 18,'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Timezone_ColorsData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Timezone_ColorsData]
END
GO

CREATE PROCEDURE [dbo].[SP_Timezone_ColorsData]  
 @configurationId INT,
 @type NVARCHAR(500),
 @color NVARCHAR(500) = NULL,
 @nodeName NVARCHAR(500) = NULL
AS  
BEGIN
	IF (@type = 'get')
	BEGIN
		SELECT PlaceNames.value('(world_timezone_placenames/@depart_color)[1]', 'varchar(max)') as Departure_Color,
		PlaceNames.value('(world_timezone_placenames/@dest_color)[1]', 'varchar(max)') as Destination_Color,
		PlaceNames.value('(world_timezone_placenames/@timeatpp_color)[1]', 'varchar(max)') as Present_Color 
		FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ
	END
	ELSE IF (@type = 'update')
	BEGIN

		DECLARE @mappedPlaceNameID INT	
        DECLARE @updateKey INT

        SET @mappedPlaceNameID = (SELECT PlaceNameID FROM cust.tblWorldTimeZonePlaceNamesMap WHERE configurationId = @configurationId)
        IF NOT @mappedPlaceNameID IS NULL
        BEGIN
		    EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWorldTimeZonePlaceNames', @mappedPlaceNameID, @updateKey OUT

			IF (@nodeName = 'depart_color')  
			BEGIN  
				UPDATE TZ   
				SET PlaceNames.modify('replace value of (/world_timezone_placenames/@depart_color)[1] with sql:variable("@color")')   
				FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ WHERE TZ.PlaceNameID = @updateKey
			END  
			ELSE IF (@nodeName = 'dest_color')  
			BEGIN  
				UPDATE TZ   
				SET PlaceNames.modify('replace value of (/world_timezone_placenames/@dest_color)[1] with sql:variable("@color")')   
				FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ WHERE TZ.PlaceNameID = @updateKey
			END  
			ELSE IF (@nodeName = 'timeatpp_color')  
			BEGIN  
				UPDATE TZ   
				SET PlaceNames.modify('replace value of (/world_timezone_placenames/@timeatpp_color)[1] with sql:variable("@color")')   
				FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ WHERE TZ.PlaceNameID = @updateKey
			END
		END
		ELSE
		BEGIN
			DECLARE @currentXML XML

			IF (@nodeName = 'timeatpp_color')
			BEGIN
			SET @currentXML = ('<world_timezone_placenames timeatpp_color="' + @color + '"></world_timezone_placenames>')
			END
			ELSE IF (@nodeName = 'dest_color')
			BEGIN
			SET @currentXML = ('<world_timezone_placenames dest_color="' + @color + '"></world_timezone_placenames>')
			END
			ELSE IF (@nodeName = 'depart_color')
			BEGIN
			SET @currentXML = ('<world_timezone_placenames depart_color="' + @color + '"></world_timezone_placenames>')
			END

			DECLARE @placeNameID INT
			INSERT INTO cust.tblWorldTimeZonePlaceNames (PlaceNames) VALUES (@currentXML)
			SET @placeNameID = (SELECT MAX(PlaceNameID) FROM cust.tblWorldTimeZonePlaceNames)

			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblWorldTimeZonePlaceNames', @placeNameID
		END
	END
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get timezone locations
-- Sample EXEC [dbo].[SP_Timezone_GetAvailableTimeoneLocation] 18
-- =============================================

IF OBJECT_ID('[dbo].[SP_Timezone_GetAvailableTimeoneLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Timezone_GetAvailableTimeoneLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_Timezone_GetAvailableTimeoneLocation]
@configurationId INT
AS
BEGIN
	SELECT
    TZV.V.value('@name', 'nvarchar(max)') AS city,
    TZV.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId
    FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ
    OUTER APPLY TZ.PlaceNames.nodes('world_timezone_placenames/city') AS TZV(V)
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Add or remove timezone locations
-- Sample EXEC [dbo].[SP_Timezone_UpdateTimezoneLocation] 18, '25,9', 'remove'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Timezone_UpdateTimezoneLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Timezone_UpdateTimezoneLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_Timezone_UpdateTimezoneLocation]
@configurationId INT,
@InputList NVARCHAR(500),
@type NVARCHAR(150)
AS
BEGIN
	DECLARE @tmpTable Table(Descriptions NVARCHAR(500), id INT)
	DECLARE @xmlData XML, @tmpxml XML, @currentXML XML, @data NVARCHAR(250), @geoRefID NVARCHAR(150)
	DECLARE @retTable TABLE (id INT)

	SET @xmlData = (SELECT PlaceNames as xmlData FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId))

	IF (@type = 'add')
	BEGIN
		INSERT INTO @tmpTable  SELECT GR.Description, GR.GeoRefId FROM dbo.config_tblGeoRef(@configurationId) as GR
		WHERE GR.isTimeZonePoi = 1 AND  GR.GeoRefId in (SELECT * FROM STRING_SPLIT(@InputList, ','))
		AND GR.Description NOT IN (
		SELECT ISNULL(TZN.V.value('@name', 'nvarchar(max)'), '') AS city
		FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ
		OUTER APPLY TZ.PlaceNames.nodes('world_timezone_placenames/city') AS TZN(V))
	END
	ELSE IF (@type = 'remove')
	BEGIN
		INSERT INTO @tmpTable  SELECT GR.Description, GR.GeoRefId FROM  dbo.config_tblGeoRef(@configurationId) as GR
		WHERE GR.isTimeZonePoi = 1 AND  GR.GeoRefId in (SELECT * FROM STRING_SPLIT(@InputList, ','))
		AND GR.Description IN (
		SELECT ISNULL(TZN.V.value('@name', 'nvarchar(max)'), '') AS city
		FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ
		OUTER APPLY TZ.PlaceNames.nodes('world_timezone_placenames/city') AS TZN(V))
	END

	SET @currentXML = (SELECT TZ.PlaceNames FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ)

	WHILE (SELECT Count(*) FROM @tmpTable) > 0
	BEGIN
		SET @data = (SELECT TOP 1 Descriptions FROM @tmpTable)
		SET @geoRefID = (SELECT TOP 1 id FROM @tmpTable)
		
		IF (@type = 'add')
		BEGIN
			IF (@currentXML IS NULL)
			BEGIN
				SET @currentXML = ('<world_timezone_placenames><city name="'+ @data +'">'+ @geoRefID +'</city></world_timezone_placenames>')
			END
			ELSE
			BEGIN
				SET @tmpxml = ('<city name="'+ @data +'">'+ @geoRefID +'</city>')
				SET @currentXML.modify('insert sql:variable("@tmpxml")into (world_timezone_placenames)[1]')
			END
		END
		ELSE IF (@type = 'remove')
		BEGIN
			SET @currentXML.modify('delete /world_timezone_placenames/city[text() = sql:variable("@geoRefID")]')
		END
		DELETE @tmpTable WHERE Id = @geoRefID
	END

	DECLARE @mappedPlaceNameID INT	
    DECLARE @updateKey INT

    SET @mappedPlaceNameID = (SELECT PlaceNameID FROM cust.tblWorldTimeZonePlaceNamesMap WHERE configurationId = @configurationId)
    IF NOT @mappedPlaceNameID IS NULL
    BEGIN

		EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWorldTimeZonePlaceNames', @mappedPlaceNameID, @updateKey OUT

		BEGIN TRY
			UPDATE TZ
			SET TZ.PlaceNames = @currentXML FROM
			cust.config_tblWorldTimeZonePlaceNames(@configurationId) AS TZ WHERE TZ.PlaceNameID = @updateKey

			INSERT INTO @retTable(id) VALUES (1)
		END TRY	
		BEGIN CATCH
				INSERT INTO @retTable(id) VALUES (0)
		END CATCH
	END	
	ELSE
	BEGIN
		DECLARE @placeNameID INT
		INSERT INTO cust.tblWorldTimeZonePlaceNames (PlaceNames) VALUES (@currentXML)
		SET @placeNameID = (SELECT MAX(PlaceNameID) FROM cust.tblWorldTimeZonePlaceNames)

		EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblWorldTimeZonePlaceNames', @placeNameID
		INSERT INTO @retTable(id) VALUES (1)
	END
	SELECT * FROM @retTable
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 5/17/2022
-- Description:	When a file is uploaded to Azure, update the details in the configuration components table.
-- Sample EXEC [dbo].[SP_UpdateFileUploadDetails] 67, 1, '', 'systemconfig', null, 'systemconfig'
-- =============================================
IF OBJECT_ID('[dbo].[SP_UpdateFileUploadDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_UpdateFileUploadDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_UpdateFileUploadDetails]
	 @configurationId INT,
	 @url NVARCHAR(MAX),
	 @fileName NVARCHAR(50),
	 @userId NVARCHAR(MAX),
	 @pageName NVARCHAR(150),
	 @errorMessage NVARCHAR(MAX)
AS
BEGIN
	DECLARE @configurationComponentTypeId INT, @configurationComponentId INT, @userName NVARCHAR(500), @existingComponentId INT, @newComponentID INT

	SET  @configurationComponentTypeId = (SELECT ConfigurationComponentTypeID FROM tblConfigurationComponentType WHERE Name LIKE '%' + @pageName + '%')
	--SET @configurationComponentId = (SELECT ISNULL(MAX([ConfigurationComponentID]),0) + 1 FROM tblConfigurationComponents as results)
	SET @userName = (SELECT FirstName + ' ' + LastName FROM AspNetUsers WHERE Id = @userId)
	
	IF EXISTS(SELECT 1 FROM tblConfigurationComponentsMap CCM 
			  INNER JOIN tblConfigurationComponents CC ON CC.[ConfigurationComponentID] = CCM.ConfigurationComponentID
			  WHERE CCM.ConfigurationID = @configurationId	AND CC.ConfigurationComponentTypeID = @configurationComponentTypeId)
	BEGIN
		SET @existingComponentId = (SELECT CCM.ConfigurationComponentID FROM tblConfigurationComponentsMap CCM
		INNER JOIN tblConfigurationComponents CC ON CC.[ConfigurationComponentID] = CCM.ConfigurationComponentID
		INNER JOIN tblConfigurationComponentType CCT ON CCT.ConfigurationComponentTypeID = CC.ConfigurationComponentTypeID
		WHERE CCM.ConfigurationID = @configurationId AND CC.ConfigurationComponentTypeID = @configurationComponentTypeId)

		EXEC SP_ConfigManagement_HandleUpdate @configurationId, 'tblConfigurationComponents', @existingComponentId, @newComponentID OUTPUT

		IF (@url != 'error')
		BEGIN
			UPDATE CC
				SET Path = @url, ErrorLog = ''
				FROM tblConfigurationComponents CC
				INNER JOIN tblConfigurationComponentsMap CCM ON CC.[ConfigurationComponentID] = CCM.ConfigurationComponentID
				WHERE CC.ConfigurationComponentTypeID = @configurationComponentTypeId AND CCM.ConfigurationID = @configurationId
				AND CC.ConfigurationComponentID = @newComponentID
		END
		ELSE
		BEGIN
			UPDATE CC
				SET Path = '', ErrorLog = @errorMessage
				FROM tblConfigurationComponents CC
				INNER JOIN tblConfigurationComponentsMap CCM ON CC.[ConfigurationComponentID] = CCM.ConfigurationComponentID
				WHERE CC.ConfigurationComponentTypeID = @configurationComponentTypeId AND CCM.ConfigurationID = @configurationId
				AND CC.ConfigurationComponentID = @newComponentID			
		END
		UPDATE CCM
				SET Action = 'Updated', LastModifiedBy = @userName, LastModifiedDate = GETDATE()
				FROM tblConfigurationComponentsMap CCM
				INNER JOIN tblConfigurationComponents CC ON CC.[ConfigurationComponentID] = CCM.ConfigurationComponentID
				WHERE ConfigurationID = @configurationId AND CC.ConfigurationComponentTypeID = @configurationComponentTypeId
				AND CCM.ConfigurationComponentID = @newComponentID
	END
	ELSE
	BEGIN
		IF (@url != 'true')
		BEGIN
			INSERT INTO tblConfigurationComponents (Path, ConfigurationComponentTypeID, Name, ErrorLog) 
			VALUES (@url, @configurationComponentTypeId, @pageName, '')
			SET @configurationComponentId = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			INSERT INTO tblConfigurationComponents (Path, ConfigurationComponentTypeID, Name, ErrorLog) 
			VALUES ('', @configurationComponentTypeId, @pageName, @errorMessage)
			SET @configurationComponentId = SCOPE_IDENTITY()
		END

		EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblConfigurationComponents', @configurationComponentId

		UPDATE CCM
				SET LastModifiedBy = @userName, LastModifiedDate = GETDATE()
				FROM tblConfigurationComponentsMap CCM
				INNER JOIN tblConfigurationComponents CC ON CC.[ConfigurationComponentID] = CCM.ConfigurationComponentID
				WHERE ConfigurationID = @configurationId AND CCM.ConfigurationComponentID = @configurationComponentId
	END
END

GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/30/2022
-- Description:	updates table fontfileselectionmap based on condition
-- Sample: EXEC [dbo].[SP_UpdateFontSelectionMapping] 3,2,'4dbed025-b15f-4760-b925-34076d13a10a',1
-- =============================================
IF OBJECT_ID('[dbo].[SP_UpdateFontSelectionMapping]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_UpdateFontSelectionMapping]
END
GO

CREATE PROCEDURE [dbo].[SP_UpdateFontSelectionMapping]
		@previousFontFileSelectionID INT,
        @fontFileSelectionID INT,
		@lastModifiedBy NVARCHAR(300),
		@configurationId INT
AS

BEGIN

      DECLARE @updateKey int
      EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblFontFileSelection',@fontFileSelectionID,@updateKey out
      UPDATE dbo.tblFontFileSelectionMap SET PreviousFontFileSelectionID = @previousFontFileSelectionID,FontFileSelectionID = @updateKey,
      LastModifiedBy = @lastModifiedBy  WHERE dbo.tblFontFileSelectionMap.ConfigurationID =  @configurationId 
	 
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 09/14/2022
-- Description:	Get data to build modlist JSON file
-- Sample EXEC [dbo].[SP_UpdateModlistData] '1499,2956,1496,2953'
-- =============================================

IF OBJECT_ID('[dbo].[SP_UpdateModlistData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_UpdateModlistData]
END
GO

CREATE PROCEDURE [dbo].[SP_UpdateModlistData]
	@configurationId INT,
	@modlistData [Type_ModListJson] READONLY
AS
BEGIN
	DECLARE @modListTable TABLE(ID INT, FileJSON NVARCHAR(MAX), Row INT, Col INT, Resolution INT)
	DECLARE @id INT, @row INT, @col INT, @resolution INT, @fileJSON NVARCHAR(MAX), @maxModListId INT

	INSERT INTO @modListTable SELECT * FROM @modlistData
	
	SET NOCOUNT OFF
	WHILE (SELECT COUNT(*) FROM @modListTable) > 0
	BEGIN
		SET @id = (SELECT TOP 1 ID FROM @modListTable)
		SET @resolution = (SELECT Resolution FROM @modListTable WHERE ID = @id)
		SET @row = (SELECT Row FROM @modListTable WHERE ID = @id)
		SET @col = (SELECT Col FROM @modListTable WHERE ID = @id)
		SET @fileJSON = (SELECT FileJSON FROM @modListTable WHERE ID = @id)

		IF EXISTS (SELECT 1 FROM tblModList M INNER JOIN tblModListMap MM ON M.ModlistID = MM.ModlistID WHERE M.Row = @row AND M.Col = @col AND M.Resolution = @resolution AND MM.ConfigurationID = @configurationId)
		BEGIN
			UPDATE M 
			SET FileJSON = @fileJSON, M.isDirty = 0 
			FROM tblModList M INNER JOIN tblModListMap MM ON M.MODLISTiD = MM.MODLISTID
			WHERE M.Row = @ROW AND M.Col = @COL AND M.Resolution = @resolution AND MM.ConfigurationID = @configurationId
		END
		ELSE
		BEGIN
			INSERT INTO tblModList(FileJSON, Row, Col, Resolution, isDirty) VALUES (@fileJSON, @row, @col, @resolution, 0)
			SET @maxModListId = (SELECT MAX(ModlistID) FROM tblModList)
            EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblModList',@maxModListId
		END

		DELETE FROM @modListTable WHERE ID = @id
	END
END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa,Brinda,Chindamada
-- Create date: 26/5/2022
-- Description:	Update the old language based on conditions
-- Sample: EXEC [dbo].[SP_UpdateOldLanguage] 36,4,'EN'
-- =============================================
IF OBJECT_ID('[dbo].[SP_UpdateOldLanguage]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_UpdateOldLanguage]

END

GO
CREATE PROCEDURE [dbo].[SP_UpdateOldLanguage]
                        @configurationId INT,
                        @scriptId INT,
						@twoLetterlanguageCodes NVARCHAR(100)
                       

AS

BEGIN        
         DECLARE @sql NVARCHAR(Max),@updateKey Int,@scriptDefId INT
		  DECLARE @params NVARCHAR(4000) = '@configurationId Int,@updateKey Int,@scriptParamId Int'
		   SELECT @scriptDefId=ScriptDefID FROM cust.tblScriptDefsMap WHERE ConfigurationID =  @configurationId
		  EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblScriptDefs',@scriptDefId,@updateKey out
         SET @sql=('UPDATE [cust].[tblScriptDefs]
                SET ScriptDefs.modify(''replace value of (/script_defs/script/@forced_langs)[../@id='+CAST(@scriptId as varchar)+'][1] with  "'+ @twoLetterlanguageCodes +'"'')
                FROM cust.tblScriptDefs b INNER JOIN[cust].tblScriptDefsMap c on c.ScriptDefID = b.ScriptDefID
                CROSS APPLY b.ScriptDefs.nodes(''/script_defs/script'') Nodes(item) WHERE ISNULL(Nodes.item.value(''(./@id)[1]'', ''int''), '''') =@scriptParamId AND ConfigurationID = @configurationId AND b.ScriptDefID = @updateKey ')
		 EXEC sys.Sp_executesql @sql,@params,@configurationId = @configurationId,@updateKey=@updateKey,@scriptParamId = @scriptId
		 
END

GO

GO

IF OBJECT_ID('[dbo].[SP_UpdateTask]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_UpdateTask]
END
GO

CREATE PROCEDURE [dbo].[SP_UpdateTask] 	
	 @TaskId  uniqueidentifier,		
	 @TaskStatusId  int,
	 @PercentageComplete float,
	 @DetailedStatus  nvarchar	 
AS
BEGIN
	DECLARE
		@LASTID   uniqueidentifier
		DECLARE @ReturnValue int
	BEGIN		
		SET @ReturnValue = 1;
		 Update [dbo].[tblTasks] SET TaskStatusID = @TaskStatusId
           ,DateLastUpdated = GETDATE(),PercentageComplete = @PercentageComplete,DetailedStatus = @DetailedStatus
				WHERE ID = @TaskId	  
		 select tblTasks.ID, tblTasks.TaskStatusID, tblTasks.DetailedStatus from tblTasks where tblTasks.ID = @TaskId;
		  return @ReturnValue
	END	
END

GO
GO

-- =============================================
-- Author:		Sathya
-- Create date: 06/24/2022
-- Description:	Update the task status by its id to give status id with percentage completion.
-- =============================================

GO
IF OBJECT_ID('[dbo].[SP_updateTaskStatus]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_updateTaskStatus]
END
GO

CREATE PROC SP_updateTaskStatus  
@taskId UNIQUEIDENTIFIER, 
@percentage FLOAT,
@taskStatus INT
AS  
BEGIN  
  
  UPDATE tblTasks SET TaskStatusID=@taskStatus,PercentageComplete=@percentage, DateLastUpdated=GETDATE() WHERE ID=@taskId;  
  
END

GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	Get the font based on configurationID
-- Sample: EXEC [cust].[SP_UpdateXML] 39 ,'webmain',''
-- =============================================
IF OBJECT_ID('[cust].[SP_UpdateXML]','P') IS NOT NULL

BEGIN
        DROP PROC [cust].[SP_UpdateXML]
END
GO

CREATE PROCEDURE [cust].[SP_UpdateXML]
	@configurationId INT,
    @section NVARCHAR(250),
    @xmlValue xml
AS
BEGIN
	DECLARE @updateKey INT

	IF (@section = 'flyoveralerts')
	BEGIN
		IF EXISTS (SELECT 1 FROM config_tblFlyOverAlert(@configurationId))
		BEGIN
			DECLARE @flyOverAlertID NVARCHAR(Max)
			SET @flyOverAlertID = (SELECT cust.tblFlyOverAlertMap.FlyOverAlertID FROM cust.tblFlyOverAlertMap WHERE cust.tblFlyOverAlertMap.ConfigurationID =  @configurationId)
			EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblFlyOverAlert',@flyOverAlertID,@updateKey out
			UPDATE cust.tblFlyOverAlert
			SET FlyOverAlert = @xmlValue
			WHERE cust.tblFlyOverAlert.FlyOverAlertID IN (
						SELECT distinct cust.tblFlyOverAlertMap.FlyOverAlertID FROM cust.tblFlyOverAlertMap
						WHERE cust.tblFlyOverAlertMap.ConfigurationID = @configurationId AND cust.tblFlyOverAlertMap.FlyOverAlertID = @updateKey
						)
		END
		ELSE
		BEGIN
			INSERT INTO cust.tblFlyOverAlert (FlyOverAlert) VALUES(@xmlValue)
			SET @flyOverAlertID = (SELECT MAX(FlyOverAlertID) FROM cust.tblFlyOverAlert)

			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblFlyOverAlert', @flyOverAlertID 
		END
	END
    ELSE IF (@section = 'webmain')
	BEGIN
	    
		IF EXISTS (SELECT 1 FROM cust.config_tblWebmain(@configurationId))
		BEGIN
		     DECLARE @WebmainID NVARCHAR(Max)
		SET @WebmainID = (SELECT cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap WHERE cust.tblWebMainMap.ConfigurationID = @configurationId)
		EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWebMain',@WebmainID,@updateKey out
        UPDATE cust.tblWebMain
        SET WebMainItems = @xmlValue
        WHERE cust.tblWebMain.WebMainID IN (
	                SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap
	                WHERE cust.tblWebMainMap.ConfigurationID = @configurationId AND cust.tblWebMainMap.WebMainID = @updateKey
	                )
    END
	ELSE
		BEGIN
			INSERT INTO cust.tblWebMain (WebMainItems) VALUES(@xmlValue)
			SET @WebmainID= (SELECT MAX(WebMainID ) FROM cust.tblWebMain)
			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblWebMain',@WebmainID
		END
	END
    ELSE IF (@section = 'global')
	BEGIN
    
        UPDATE cust.tblGlobal
        SET cust.tblGlobal.Global = @xmlValue
        WHERE cust.tblGlobal.CustomID IN (
	                SELECT distinct cust.tblGlobalMap.CustomID FROM cust.tblGlobalMap
	                WHERE cust.tblGlobalMap.ConfigurationID = @configurationId AND cust.tblGlobalMap.CustomID = @updateKey
	                )
    END
    ELSE IF (@section = 'maps')
	BEGIN
		IF EXISTS (SELECT 1 FROM config_tblMaps(@configurationId))
		BEGIN
			DECLARE @MapID NVARCHAR(Max)
				 SET @MapID = (SELECT cust.tblMapsMap.MapID FROM cust.tblMapsMap WHERE cust.tblMapsMap.ConfigurationID =  @configurationId)
				EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMaps',@MapID,@updateKey out
			UPDATE cust.tblMaps
			SET MapItems = @xmlValue
			WHERE cust.tblMaps.MapID IN (
						SELECT distinct cust.tblMapsMap.MapID FROM cust.tblMapsMap
						WHERE cust.tblMapsMap.ConfigurationID = @configurationId AND MapID = @updateKey
						)
		END
		ELSE
		BEGIN
			INSERT INTO cust.tblMaps (MapItems) VALUES(@xmlValue)
			SET @mapID = (SELECT MAX(mapID) FROM cust.tblMaps)

			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblMaps', @mapID 

		END
    END
    ELSE IF(@section = 'layers')
    BEGIN
        UPDATE cust.tblMenu
        SET Layers = @xmlValue
        WHERE cust.tblMenu.MenuID IN (
	                SELECT distinct cust.tblMenuMap.MenuID FROM cust.tblMenuMap
	                WHERE cust.tblMenuMap.ConfigurationID = @configurationId
	                )
    END
END

GO

DROP PROC IF EXISTS sp_update_partnumer_from_temp;
GO
CREATE PROC sp_update_partnumer_from_temp
@aircraftId UNIQUEIDENTIFIER
AS
BEGIN

DECLARE @aricraftDefinitionId INT=0,@tailNumber NVARCHAR(100)
SELECT @aricraftDefinitionId=ISNULL(AD.ConfigurationDefinitionID,0),@tailNumber=AC.TailNumber FROM dbo.tblConfigurationDefinitions CD 
		INNER JOIN tblAircraftConfigurationMapping AD ON AD.ConfigurationDefinitionID=CD.ConfigurationDefinitionID
		INNER JOIN Aircraft AC ON AD.AircraftID=AC.Id WHERE AC.Id=@aircraftId

		IF @aricraftDefinitionId!=0
		BEGIN
		INSERT INTO tblConfigurationDefinitionPartNumber (ConfigurationDefinitionID, PartNumberID,Value) 
		SELECT @aricraftDefinitionId,PartnumberId,Value FROM tblTempAircraftPartnumber WHERE TailNumber=@tailNumber
		END

		DELETE FROM tblTempAircraftPartnumber WHERE TailNumber=@tailNumber;

END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
The procedure is used to get errors logged for file upload in Collins Admin feature
*/
IF OBJECT_ID('[dbo].[SP_GetFileUploadErrorLogs]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetFileUploadErrorLogs]
END
GO

CREATE PROCEDURE [dbo].[SP_GetFileUploadErrorLogs]
	@configurationId INT,
	@pageName NVARCHAR(500)
AS
BEGIN
	IF (@pageName = 'populations' OR @pageName = 'airports' OR @pageName = 'world guide cities')
	BEGIN
		SELECT TOP 1 errorlog FROM tbltasks WHERE ConfigurationID = @configurationId ORDER BY DateLastUpdated DESC
	END
	ELSE
	BEGIN
		SELECT TOP 1 CC.ErrorLog FROM tblConfigurationComponents CC
		INNER JOIN tblConfigurationComponentsMap CCM ON CC.ConfigurationComponentTypeID = CCM.ConfigurationComponentID AND CCM.ConfigurationID = @configurationId
	END
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Updates enable status to false for that view
-- Sample EXEC [dbo].[SP_Views_UpdateSelectedView] 18, 'Landscape', 'false'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Views_DisableSelectedView]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Views_DisableSelectedView]
END
GO

CREATE PROCEDURE [dbo].[SP_Views_DisableSelectedView]
@configurationId INT,
@viewName NVARCHAR(500),
@updateValue NVARCHAR(200)
AS
BEGIN
	declare @mappedMenuId int	
	declare @updateKey int

	 set @mappedMenuId = (select MenuID from cust.tblMenuMap where configurationId = @configurationId)
	if not @mappedMenuId is null
	begin

		exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMenu', @mappedMenuId, @updateKey out

		UPDATE M
		SET Perspective.modify('replace value of (/category/item[@label = sql:variable("@viewName")]/@enable)[1] with sql:variable("@updateValue")')
		FROM cust.config_tblMenu(@configurationId) as M
		WHERE Perspective.exist('/category/item[@label = sql:variable("@viewName")]') = 'true' and M.MenuID = @updateKey

		UPDATE M
		SET Perspective.modify('replace value of (/category/item[@label = sql:variable("@viewName")]/@quick_select)[1] with sql:variable("@updateValue")')
		FROM cust.config_tblMenu(@configurationId) as M
		WHERE Perspective.exist('/category/item[@label = sql:variable("@viewName")]') = 'true' and M.MenuID = @updateKey
	end	
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Gets all views for configuration ID
-- Sample EXEC [dbo].[SP_Views_GetAllViewDetails] 223, 'all'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Views_GetAllViewDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Views_GetAllViewDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Views_GetAllViewDetails]
@configurationId INT,
@type NVARCHAR(100)
AS
BEGIN

	DECLARE @tblViewsMenu TABLE (name NVARCHAR(100), preset NVARCHAR(50))
	DECLARE @viewsMenu NVARCHAR(500),@featureset NVARCHAR(500)
	--todo get featureset id from configurationdefnitiontable based on configurationID
	SET @featureset = (SELECT DISTINCT dbo.tblFeatureSet.FeatureSetID 
					   FROM dbo.tblFeatureSet INNER JOIN dbo.tblConfigurationDefinitions ON dbo.tblFeatureSet.FeatureSetID = dbo.tblConfigurationDefinitions.FeatureSetID 
					   INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionID
						AND dbo.tblConfigurations.ConfigurationID = @configurationId )
	
	SET @viewsMenu = (SELECT Value FROM tblFeatureSet WHERE Name = 'CustomConfig-ViewsDisplayList' AND FeatureSetID = @featureset)
	 


	IF (@type = 'all')
	BEGIN
		INSERT INTO @tblViewsMenu
			SELECT ISNULL(Nodes.item.value('(./@name)[1]', 'varchar(max)'), '') AS name,
			ISNULL(Nodes.item.value('(./@quick_select)[1]', 'varchar(max)'), '') AS preset
			FROM cust.config_tblMenu(@configurationId) as M
			CROSS APPLY M.Perspective.nodes('//item') AS Nodes(item)
			WHERE Nodes.item.value('(./@enable)[1]', 'varchar(max)') = 'true'
	END
	ELSE IF (@type = 'disabled')
	BEGIN
		INSERT INTO @tblViewsMenu
			SELECT ISNULL(Nodes.item.value('(./@name)[1]', 'varchar(max)'), '') AS name,
			ISNULL(Nodes.item.value('(./@quick_select)[1]', 'varchar(max)'), '') AS preset
			FROM cust.config_tblMenu(@configurationId) as M
			CROSS APPLY M.Perspective.nodes('//item') AS Nodes(item)
			WHERE Nodes.item.value('(./@enable)[1]', 'varchar(max)') = 'false'


		INSERT INTO @tblViewsMenu
			SELECT value, 'false' FROM STRING_SPLIT(@viewsMenu, ',') AS names WHERE value NOT IN
			(SELECT ISNULL(Nodes.item.value('(./@name)[1]', 'varchar(max)'), '') AS name
			FROM cust.config_tblMenu(@configurationId) as M
			CROSS APPLY M.Perspective.nodes('//item') AS Nodes(item))
	END

	SELECT name,preset FROM @tblViewsMenu
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Gets different locations for view type
-- Sample EXEC [dbo].[SP_Views_GetLocationForSelectedView] 35,'worldclock'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Views_GetLocationForSelectedView]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Views_GetLocationForSelectedView]
END
GO

CREATE PROCEDURE [dbo].[SP_Views_GetLocationForSelectedView]
@configurationId INT,
@viewName NVARCHAR(500)
AS
BEGIN
	DECLARE @cityXML XML, @DestinationXML XML, @DepartureXML XML, @ClosestXML XML, @Location1XML XML, @Location2XML XML, @defaultXML XML
	DECLARE @tmpTable Table(geoRefId INT, Descriptions NVARCHAR(500))
	
	IF (@viewName = 'compass')
	BEGIN

		--SET @Location1XML = (SELECT R.Rli
		--				FROM cust.config_tblRLI(@configurationId) as R
		--				WHERE R.Rli.exist('/rli/location1[@name = "Closest Location"]') = 1)
		--SET @Location2XML = (SELECT R.Rli
		--				FROM cust.config_tblRLI(@configurationId) as R
		--				WHERE R.Rli.exist('/rli/location2[@name = "Closest Location"]') = 1)

		--IF (@Location1XML IS NULL AND @Location2XML IS NULL)
		--BEGIN
			INSERT INTO @tmpTable VALUES (-3, 'Closest Location')
		--END

		--SET @Location1XML = (SELECT R.Rli
		--				FROM cust.config_tblRLI(@configurationId) as R
		--				WHERE R.Rli.exist('/rli/location1[@name = "Departure"]') = 1)
		--SET @Location2XML = (SELECT R.Rli
		--				FROM cust.config_tblRLI(@configurationId) as R
		--				WHERE R.Rli.exist('/rli/location2[@name = "Departure"]') = 1)

		--IF (@Location1XML IS NULL AND @Location2XML IS NULL)
		--BEGIN
			INSERT INTO @tmpTable VALUES (-1, 'Departure')
		--END

		--SET @Location1XML = (SELECT R.Rli
		--				FROM cust.config_tblRLI(@configurationId) as R
		--				WHERE R.Rli.exist('/rli/location1[@name = "Destination"]') = 1)
		--SET @Location2XML = (SELECT R.Rli
		--				FROM cust.config_tblRLI(@configurationId) as R
		--				WHERE R.Rli.exist('/rli/location2[@name = "Destination"]') = 1)

		--IF (@Location1XML IS NULL AND @Location2XML IS NULL)
		--BEGIN
			INSERT INTO @tmpTable VALUES (-2, 'Destination')
		--END

		INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.config_tblGeoRef(@configurationId) AS GR
		WHERE GR.isRliPoi = 1 AND GR.GeoRefID NOT IN (
				SELECT ISNULL(WC.V.value('text()[1]', 'nvarchar(max)'), '') AS city
				FROM cust.config_tblRLI(@configurationId) as R
				OUTER APPLY R.Rli.nodes('rli/location1')  AS WC(V))
		AND GR.GeoRefID NOT IN(
				SELECT ISNULL(WC.V.value('text()[1]', 'nvarchar(max)'), '') AS city
				FROM cust.config_tblRLI(@configurationId) as R
				OUTER APPLY R.Rli.nodes('rli/location2')  AS WC(V))
	END
	ELSE IF (@viewName = 'timezone')
	BEGIN
		INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.config_tblGeoRef(@configurationId) AS GR
		WHERE GR.isTimeZonePoi = 1 AND 
		GR.GeoRefID NOT IN (SELECT ISNULL(TZV.V.value('text()[1]', 'nvarchar(max)'), '') AS city
       						FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ
            				OUTER APPLY TZ.PlaceNames.nodes('world_timezone_placenames/city') AS TZV(V))
	END
	ELSE IF (@viewName = 'worldclock')
	BEGIN

		--SET @DepartureXML	= (SELECT WC.WorldClockCities
		--				FROM cust.config_tblWorldClockCities(@configurationId) as WC
		--				WHERE WC.WorldClockCities.exist('/worldclock_cities/city[@name = "Departure"]') = 1)
		--SET @DestinationXML = (SELECT WC.WorldClockCities
		--						FROM cust.config_tblWorldClockCities(@configurationId) as WC
		--						WHERE WC.WorldClockCities.exist('/worldclock_cities/default_city[@name = "Departure"]') = 1)

		--IF (@DepartureXML IS NULL AND @DestinationXML IS NULL)
		--BEGIN
			INSERT INTO @tmpTable VALUES (-1, 'Departure')
		--END

		--SET @DepartureXML	= (SELECT WC.WorldClockCities
		--			FROM cust.config_tblWorldClockCities(@configurationId) as WC
		--			WHERE WC.WorldClockCities.exist('/worldclock_cities/city[@name = "Destination"]') = 1)
		--SET @DestinationXML	= (SELECT WC.WorldClockCities
		--			FROM cust.config_tblWorldClockCities(@configurationId) as WC
		--			WHERE WC.WorldClockCities.exist('/worldclock_cities/default_city[@name = "Destination"]') = 1)

		--IF (@DepartureXML IS NULL AND @DestinationXML IS NULL)
		--BEGIN
			INSERT INTO @tmpTable VALUES (-2, 'Destination')
		--END

		SET @cityXML = (SELECT WC.WorldClockCities
						FROM cust.config_tblWorldClockCities(@configurationId) as WC
						WHERE WC.WorldClockCities.exist('/worldclock_cities/city') = 1)
		SET @defaultXML = (SELECT WC.WorldClockCities
						FROM cust.config_tblWorldClockCities(@configurationId) as WC
						WHERE WC.WorldClockCities.exist('/worldclock_cities/default_city') = 1)

		IF (@defaultXML IS NULL AND @cityXML IS NULL)
		BEGIN
			INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.config_tblGeoRef(@configurationId) AS GR
			WHERE GR.isWorldClockPoi = 1
		END
		ELSE IF (@cityXML IS NULL AND @defaultXML IS NOT NULL)
		BEGIN
			INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.config_tblGeoRef(@configurationId) AS GR
			WHERE GR.isWorldClockPoi = 1 AND
			GeoRefId NOT IN (SELECT
				WCL.V.value('@geoRef', 'nvarchar(max)') AS city
				FROM cust.config_tblWorldClockCities(@configurationId) as WC
				OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/default_city') AS WCL(V))
		END
		ELSE IF (@cityXML IS NOT NULL AND @defaultXML IS NULL)
		BEGIN
			INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.config_tblGeoRef(@configurationId) AS GR
			WHERE GR.isWorldClockPoi = 1 AND
			GeoRefId NOT IN (SELECT
				WCL.V.value('@geoRef', 'nvarchar(max)') AS city
				FROM cust.config_tblWorldClockCities(@configurationId) as WC
				OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V))
		END
		ELSE IF (@cityXML IS NOT NULL AND @defaultXML IS NOT NULL)
		BEGIN
			INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.config_tblGeoRef(@configurationId) AS GR
			WHERE GR.isWorldClockPoi = 1 AND
			GR.GeoRefID NOT IN (SELECT
				ISNULL(WCL.V.value('@geoRef', 'nvarchar(max)'), '') AS city
				FROM cust.config_tblWorldClockCities(@configurationId) as WC
				OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/default_city') AS WCL(V)) AND
			GR.GeoRefID NOT IN (SELECT
				ISNULL(WCL.V.value('@geoRef', 'nvarchar(max)'), '') AS city
				FROM cust.config_tblWorldClockCities(@configurationId) as WC
				OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V))
		END
	END

	SELECT * FROM @tmpTable
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Select and Update command to move particular view location
-- Sample EXEC [dbo].[SP_Views_MoveSelectedView] 223, 'update'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Views_MoveSelectedView]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Views_MoveSelectedView]
END
GO

CREATE PROCEDURE [dbo].[SP_Views_MoveSelectedView]
@configurationId INT,
@type NVARCHAR(150),
@xmlValue XML = NULL
AS
BEGIN
	IF (@type = 'get')
		BEGIN
			SELECT M.perspective as xmlData
			FROM cust.config_tblMenu(@configurationId) as M

		END
	ELSE IF (@type = 'update')
		BEGIN
			declare @mappedMenuId int	
			declare @updateKey int
			set @mappedMenuId = (select MenuID from cust.tblMenuMap where configurationId = @configurationId)
			if not @mappedMenuId is null
			begin
				print 'inside'
				exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMenu', @mappedMenuId, @updateKey out
				--UPDATE M
				--SET perspective = @xmlValue FROM  cust.tblMenu as M WHERE M.MenuID = @updateKey
				update cust.tblMenu set perspective = @xmlValue WHERE MenuID = @updateKey
				SELECT 1 AS returnValue
			end	
		END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Updates selected view enable status
-- Sample EXEC EXEC [dbo].[SP_Views_UpdateSelectedView] 18, 'Landscape', 'true'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Views_UpdateSelectedView]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Views_UpdateSelectedView]
END
GO

CREATE PROCEDURE [dbo].[SP_Views_UpdateSelectedView]
@configurationId INT,
@viewName NVARCHAR(500),
@updateValue NVARCHAR(200)
AS
BEGIN
	DECLARE @count INT, @xmlData INT
	declare @mappedMenuId int	
	declare @updateKey int

	SET @count = (SELECT CONVERT (INT, CONVERT(VARCHAR(MAX),FS.Value)) FROM tblFeatureSet FS 
        INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
        INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
        WHERE FS.Name = 'CustomConfig-ViewsMaxPresets' AND C.ConfigurationID = @configurationId)

    SELECT @xmlData = COUNT(ISNULL(Nodes.item.value('(./@quick_select)[1]', 'varchar(max)'), ''))
		FROM cust.config_tblMenu(@configurationId) as M
        CROSS APPLY M.Perspective.nodes('//item') AS Nodes(item)
        WHERE Nodes.item.value('(./@quick_select)[1]', 'varchar(max)') = 'true'
	IF (@updateValue = 'true')
	BEGIN
		IF (@count > @xmlData)
		BEGIN
			 set @mappedMenuId = (select MenuID from cust.tblMenuMap where configurationId = @configurationId)
			if not @mappedMenuId is null
			begin
				
				exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMenu', @mappedMenuId, @updateKey out

				UPDATE M 
				SET Perspective.modify('replace value of (/category/item[@label = sql:variable("@viewName")]/@quick_select)[1] with sql:variable("@updateValue")') 
				FROM cust.config_tblMenu(@configurationId) as M
				WHERE Perspective.exist('/category/item[@label = sql:variable("@viewName")]') = 'true' and M.MenuID = @updateKey
			end
			SELECT 1 AS returnValue
		END
		ELSE
		BEGIN
			SELECT 2 AS returnValue
		END
	END
	ELSE
	BEGIN
	
		 set @mappedMenuId  = (select MenuID from cust.tblMenuMap where configurationId = @configurationId)
		if not @mappedMenuId is null
		begin
			exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMenu', @mappedMenuId, @updateKey out

			UPDATE M 
			SET Perspective.modify('replace value of (/category/item[@label = sql:variable("@viewName")]/@quick_select)[1] with sql:variable("@updateValue")') 
			FROM cust.config_tblMenu(@configurationId) as M
			WHERE Perspective.exist('/category/item[@label = sql:variable("@viewName")]') = 'true' and M.MenuID = @updateKey
		end
		SELECT 1 AS returnValue
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Add new alternate world clock locations
-- Sample EXEC [dbo].[SP_WorldClock_AddAlternateWorldClockCity] 18, '9', 'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_WorldClock_AddAlternateWorldClockCity]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_WorldClock_AddAlternateWorldClockCity]
END
GO

CREATE PROCEDURE [dbo].[SP_WorldClock_AddAlternateWorldClockCity]
@configurationId INT,
@inputGeoRefId NVARCHAR(500),
@type NVARCHAR(150),
@xmlValue xml = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		DECLARE @cityName NVARCHAR(250), @worldClockCities XML, @cityXML XML, @defaultXML XML
		DECLARE @temp TABLE(xmlData XML, cityName NVARCHAR(250))

		IF (@inputGeoRefId = '-1')
		BEGIN
			SET @cityName = 'Departure'
		END
		ELSE IF (@inputGeoRefId = '-2')
		BEGIN
			SET @cityName = 'Destination'
		END
		ELSE
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM cust.config_tblWorldClockCities(@configurationId))
			BEGIN
				SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) as GR
				WHERE GR.isworldclockpoi = 1 AND  GR.GeoRefId = @inputGeoRefId)
			END
			ELSE
			BEGIN
				SET @cityXML = (SELECT GR.Description FROM dbo.config_tblGeoRef(@configurationId) as GR
					WHERE GR.isWorldclockpoi = 1 AND  GR.GeoRefId in (@inputGeoRefId)
					AND GR.Description NOT IN (
						SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
						FROM cust.config_tblWorldClockCities(@configurationId) as WC
						OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)))

				SET @defaultXML = (SELECT GR.Description FROM dbo.config_tblGeoRef(@configurationId) as GR
					WHERE GR.isWorldclockpoi = 1 AND  GR.GeoRefId in (@inputGeoRefId)
					AND GR.Description NOT IN (
						SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
						FROM cust.config_tblWorldClockCities(@configurationId) as WC
						OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/default_city') AS WCL(V)))

				IF (@cityXML IS NULL AND @defaultXML IS NULL)
				BEGIN
					SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) as GR
					WHERE GR.isworldclockpoi = 1 AND  GR.GeoRefId = @inputGeoRefId)
				END
				ELSE IF (@cityXML IS NULL)
				BEGIN
					SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) as GR
					WHERE GR.isworldclockpoi = 1 AND  GR.GeoRefId = @inputGeoRefId
					AND GR.Description not IN (
						SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
						FROM cust.config_tblWorldClockCities(@configurationId) as WC
						OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/default_city') AS WCL(V)))
				END
				ELSE IF (@defaultXML IS NULL)
				BEGIN
					SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) as GR
					WHERE GR.isworldclockpoi = 1 AND  GR.GeoRefId = @inputGeoRefId
					AND GR.Description not IN (
						SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
						FROM cust.config_tblWorldClockCities(@configurationId) as WC
						OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)))
				END
				ELSE
				BEGIN
					SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) as GR
					WHERE GR.isworldclockpoi = 1 AND  GR.GeoRefId = @inputGeoRefId
					AND GR.Description not IN (
						SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
						FROM cust.config_tblWorldClockCities(@configurationId) as WC
						OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)) 
					AND GR.Description not IN(
						SELECT WC.V.value('@name', 'nvarchar(max)') AS city
						FROM cust.config_tblWorldClockCities(@configurationId) as W
						OUTER APPLY W.WorldClockCities.nodes('worldclock_cities/default_city')  AS WC(V)))
				END
			END
		END

		IF (@cityName IS NOT NULL AND @cityName != '')
		BEGIN
			SET @worldClockCities =(SELECT WC.WorldClockCities AS xmlData 
            FROM cust.config_tblWorldClockCities(@configurationId) as WC)

			INSERT INTO @temp VALUES (@worldClockCities, @cityName)

			SELECT * FROM @temp
		END
	END
	ELSE IF (@type = 'update')
	BEGIN

		IF EXISTS (SELECT 1 FROM cust.config_tblWorldClockCities(@configurationId))
		BEGIN
			DECLARE @mappedWorldClockCityID INT	
    		DECLARE @updateKey INT
			SET @mappedWorldClockCityID = (SELECT WorldClockCityID FROM cust.config_tblWorldClockCities(@configurationId))
			IF NOT @mappedWorldClockCityID IS NULL
       			BEGIN	
			   
			   		EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWorldClockCities', @mappedWorldClockCityID, @updateKey OUT
					UPDATE WC
					SET WorldClockCities = @xmlValue FROM cust.config_tblWorldClockCities(@configurationId) AS WC WHERE WC.WorldClockCityID = @updateKey
				END
		END
		ELSE
		BEGIN
			DECLARE @worldClockId INT
			INSERT INTO CUST.tblWorldClockCities(WorldClockCities) VALUES (@xmlValue)

			SET @worldClockId = (SELECT MAX(WorldClockCityID) FROM cust.tblWorldClockCities)
			EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblWorldClockCities',@worldClockId
		END
		SELECT 1 AS retValue
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get availavle and alternate world clock locations
-- Sample EXEC [dbo].[SP_WorldClock_GetAvailableAndAlternateWorldClockLocations] 18, 'alternate'
-- =============================================

IF OBJECT_ID('[dbo].[SP_WorldClock_GetAvailableAndAlternateWorldClockLocations]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_WorldClock_GetAvailableAndAlternateWorldClockLocations]
END
GO

CREATE PROCEDURE [dbo].[SP_WorldClock_GetAvailableAndAlternateWorldClockLocations]
@configurationId INT,
@type NVARCHAR(150)
AS
BEGIN
	IF (@type = 'available')
	BEGIN
		SELECT WCL.V.value('@name', 'nvarchar(max)') AS city,
        WCL.V.value('@geoRef', 'INT') AS geoRefId
        FROM cust.config_tblWorldClockCities(@configurationId) as WC
        OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)
	END
	
	ELSE IF (@type = 'alternate')
	BEGIN
		SELECT WCL.V.value('@name', 'nvarchar(max)') AS city,
        WCL.V.value('@geoRef', 'INT') AS geoRefId
        FROM cust.config_tblWorldClockCities(@configurationId) as WC
        OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/default_city') AS WCL(V)
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get and update the xml data for the Worldclock
-- Sample EXEC [dbo].[SP_WorldClock_MoveWorldclockLocation] 18, 'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_WorldClock_MoveWorldclockLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_WorldClock_MoveWorldclockLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_WorldClock_MoveWorldclockLocation]
@configurationId INT,
@type NVARCHAR(150),
@xmlData XML = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		SELECT WC.WorldClockCities AS xmlData 
        FROM cust.config_tblWorldClockCities(@configurationId) as WC
	END
	ELSE IF (@type = 'update' AND @xmlData IS NOT NULL)
	BEGIN
		BEGIN TRY
			declare @mappedWorldClockCityID int	
        	declare @updateKey int

        	set @mappedWorldClockCityID = (select WorldClockCityID from cust.tblWorldClockCitiesMap where configurationId = @configurationId)
        	if not @mappedWorldClockCityID is null
       		 BEGIN
		    	exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWorldTimeZonePlaceNames', @mappedWorldClockCityID, @updateKey out
				UPDATE WC
				SET WorldClockCities = @xmlData FROM cust.config_tblWorldClockCities(@configurationId) as WC WHERE WC.WorldClockCityID = @updateKey
			END
			SELECT 1 AS retValue
		END TRY
		BEGIN CATCH
			SELECT 0 AS retValue
		END CATCH
	END
	ELSE
	BEGIN
		SELECT 0 AS retValue
	END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Add or remove available world clock locations
-- Sample EXEC [dbo].[SP_WorldClock_UpdateWorldclockLocation] 18, '9,25', 'add'
-- =============================================

IF OBJECT_ID('[dbo].[SP_WorldClock_UpdateWorldclockLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_WorldClock_UpdateWorldclockLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_WorldClock_UpdateWorldclockLocation]
@configurationId INT,
@InputList NVARCHAR(500),
@type NVARCHAR(150)
AS
BEGIN
	DECLARE @tmpTable Table(Descriptions NVARCHAR(500), id INT)
	DECLARE @xmlData XML, @tmpxml XML, @currentXML XML, @data NVARCHAR(250), @geoRefID NVARCHAR(150)
	DECLARE @retTable TABLE (id INT)
	DECLARE @cityXML XML, @mappedWorldClockCityID int, @updateKey int, @newWordClockCityID INT, @newRecord BIT = 0
	set @mappedWorldClockCityID = (select WorldClockCityID from cust.config_tblWorldClockCities(@configurationId))

	SET @xmlData = (SELECT WorldClockCities as xmlData  FROM cust.config_tblWorldClockCities(@configurationId) as WC)

	IF (@type = 'add')
	BEGIN
		SET @cityXML = (SELECT GR.Description FROM dbo.config_tblGeoRef(@configurationId) as GR
		WHERE GR.isWorldclockpoi = 1 AND  GR.GeoRefId in (SELECT * FROM STRING_SPLIT(@InputList, ','))
		AND GR.Description NOT IN (
			SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
			FROM cust.config_tblWorldClockCities(@configurationId) as WC
			OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)))
			
		IF (@cityXML IS NULL)
		BEGIN
			INSERT INTO @tmpTable  SELECT GR.Description, GR.GeoRefId  FROM dbo.config_tblGeoRef(@configurationId) as GR
			WHERE GR.isWorldclockpoi = 1 AND  GR.GeoRefId in (SELECT * FROM STRING_SPLIT(@InputList, ','))
		END
		ELSE IF (@cityXML IS NOT NULL)
		BEGIN
			INSERT INTO @tmpTable  SELECT GR.Description, GR.GeoRefId FROM dbo.config_tblGeoRef(@configurationId) as GR 
			WHERE GR.isWorldclockpoi = 1 AND  GR.GeoRefId in (SELECT * FROM STRING_SPLIT(@InputList, ','))
			AND GR.Description NOT IN (
				SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
				FROM cust.config_tblWorldClockCities(@configurationId) as WC
				OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)) 
		END
	END
	ELSE IF (@type = 'remove')
	BEGIN
		INSERT INTO @tmpTable  SELECT GR.Description, GR.GeoRefId FROM dbo.config_tblGeoRef(@configurationId) as GR
		WHERE GR.isWorldClockPoi = 1 AND  GR.GeoRefId IN (SELECT * FROM STRING_SPLIT(@InputList, ','))
		AND GR.Description IN (
			SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
			FROM cust.config_tblWorldClockCities(@configurationId) as WC
			OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)) 
	END

	SET @currentXML = (SELECT W.WorldClockCities FROM cust.config_tblWorldClockCities(@configurationId) as W)

	IF (@type = 'all')
	BEGIN
		SET @currentXML.modify('delete /worldclock_cities/city')
        	
				BEGIN TRY
				if not @mappedWorldClockCityID is null
       		 	BEGIN

					exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWorldClockCities', @mappedWorldClockCityID, @updateKey out
					UPDATE W
					SET W.WorldClockCities = @currentXML
					FROM cust.config_tblWorldClockCities(@configurationId) as W WHERE W.WorldClockCityID = @updateKey
					INSERT INTO @retTable(id) VALUES (1)
				END
				END TRY
		BEGIN CATCH
				INSERT INTO @retTable(id) VALUES (0)
		END CATCH
	END

	IF CHARINDEX('-1', @InputList) > 0
	BEGIN
		INSERT INTO @tmpTable (id, Descriptions) VALUES('-1', 'Departure')
	END
	IF CHARINDEX('-2', @InputList) > 0
	BEGIN
		INSERT INTO @tmpTable (id, Descriptions) VALUES('-2', 'Destination')
	END

	WHILE (SELECT Count(*) FROM @tmpTable) > 0
	BEGIN
		SET @data = (SELECT TOP 1 Descriptions FROM @tmpTable)
		SET @geoRefID = (SELECT TOP 1 id FROM @tmpTable)
		
		IF (@type = 'add')
		BEGIN
			IF (@currentXML IS NULL)
			BEGIN
				SET @currentXML = ('<worldclock_cities><city name="'+ @data +'" geoRef="'+ @geoRefID +'" /></worldclock_cities>')
				SET @newRecord = (1)
			END
			ELSE
			BEGIN
				SET @tmpxml = ('<city name="'+ @data +'" geoRef="'+ @geoRefID +'" />')
				SET @currentXML.modify('insert sql:variable("@tmpxml")into (worldclock_cities)[1]')
			END
		END
		ELSE IF (@type = 'remove')
		BEGIN
			SET @currentXML.modify('delete /worldclock_cities/city[@geoRef = sql:variable("@geoRefID")]')
		END
		BEGIN TRY
			IF (@newRecord = 1)
			BEGIN
				INSERT INTO cust.tblWorldClockCities(WorldClockCities) VALUES (@currentXML)
				SET @newWordClockCityID = (SELECT MAX(WorldClockCityID) FROM cust.tblWorldClockCities)
				EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblWorldClockCities',@newWordClockCityID
			END
			ELSE
			BEGIN
				IF NOT @mappedWorldClockCityID IS NULL
				BEGIN
					exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWorldClockCities', @mappedWorldClockCityID, @updateKey out
					UPDATE W
					SET W.WorldClockCities = @currentXML
					FROM cust.config_tblWorldClockCities(@configurationId) as W WHERE W.WorldClockCityID = @updateKey
					INSERT INTO @retTable(id) VALUES (1) 
				END
			END
		END TRY
		BEGIN CATCH
				INSERT INTO @retTable(id) VALUES (0)
		END CATCH
		DELETE @tmpTable WHERE Id = @geoRefID
	END
	SELECT id FROM @retTable
END
GO
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada	
-- Create date: 5/25/2022
-- Description:	it will insert 
-- Sample: EXEC [dbo].[SP_XmlInsertSaveScript] 36,34
-- =============================================

IF OBJECT_ID('[dbo].[SP_XmlInsertSaveScript]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_XmlInsertSaveScript]
END
GO

CREATE PROCEDURE [dbo].[SP_XmlInsertSaveScript]
        @configId INT,
		@scriptDefId  INT
       
AS

BEGIN
        
		  
		   EXEC dbo.SP_ConfigManagement_HandleAdd @configId, 'tblScriptDefs',@ScriptDefID
		
		  

    
END
GO

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada
-- Create date: 5/25/2022
-- Description:	inserting xml into tblscriptdefs
-- sample: EXEC [dbo].[SP_XmlSaveScript]'ENGLISH' 
-- =============================================

IF OBJECT_ID('[dbo].[SP_XmlSaveScript]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_XmlSaveScript]
END
GO

CREATE PROCEDURE [dbo].[SP_XmlSaveScript]
        @xml NVARCHAR(100)
       
AS

BEGIN

       INSERT INTO [cust].[tblScriptDefs] VALUES(@xml)
	   SELECT SCOPE_IDENTITY()
	   
END

GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 3/15/2022
-- Description:	Gets XML value from different custom tables
-- Sample EXEC [cust].[SP_GetXML] 18 , 'webmain'
-- =============================================

IF OBJECT_ID('[cust].[SP_GetXML]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_GetXML]
END
GO

CREATE PROCEDURE [cust].[SP_GetXML]
	@configurationId INT,
    @section NVARCHAR(250)
AS
BEGIN

	IF (@section = 'flyoveralerts')
	BEGIN
		SELECT FlyOverAlert as XMLValue
        FROM cust.tblFlyOverAlert
        INNER JOIN cust.tblFlyOverAlertMap ON cust.tblFlyOverAlertMap.FlyOverAlertID = cust.tblFlyOverAlert.FlyOverAlertID
        WHERE cust.tblFlyOverAlertMap.ConfigurationID = @configurationId
	END
    ELSE IF (@section = 'webmain')
	BEGIN
        SELECT WebMainItems as XMLValue
        FROM cust.tblWebMain
        INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = cust.tblWebMain.WebMainID
        WHERE cust.tblWebMainMap.ConfigurationID = @configurationId
    END
    ELSE IF (@section = 'global')
	BEGIN
        SELECT cust.tblGlobal.Global as XMLValue
        FROM cust.tblGlobal
        INNER JOIN cust.tblGlobalMap ON cust.tblGlobalMap.CustomID = cust.tblGlobal.CustomID
        WHERE cust.tblGlobalMap.ConfigurationID = @configurationId
    END
    ELSE IF (@section = 'maps')
	BEGIN
        SELECT MapItems as XMLValue
        FROM cust.tblMaps
        INNER JOIN cust.tblMapsMap ON cust.tblMapsMap.MapID = cust.tblMaps.MapID
        WHERE cust.tblMapsMap.ConfigurationID = @configurationId
    END
    ELSE IF (@section = 'layers')
	BEGIN
        SELECT Layers as XMLValue
        FROM cust.tblMenu as Menu 
        INNER JOIN cust.tblMenuMap ON cust.tblMenuMap.MenuID = Menu.MenuID 
        WHERE cust.tblMenuMap.ConfigurationID = @configurationId
    END
END
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 1/28/2022
-- Description:	Populates tblASXiInsetMap table based on the data present in dbo.tblMapInsets and dbo.tblASXiInset.
-- Scans the Temdescription.xml. For every inset in the xml, tries to finds a match in the inset catalog in dbo.tblASXiInset. If one found, creates the mapping in the dbo.tblMapInsetsMap. 
-- If not, creates a new entry in the inset catalog before updating the dbo.tblMapInsetsMap. 
-- Parameters: ConfigurationId
-- Sample EXEC [dbo].[SP_Inset_InsertInsetsIntoASXiInsetMap] 1
-- =============================================


IF OBJECT_ID('[dbo].[SP_Inset_InsertInsetsIntoASXiInsetMap]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Inset_InsertInsetsIntoASXiInsetMap]
END
GO

CREATE PROCEDURE [dbo].[SP_Inset_InsertInsetsIntoASXiInsetMap]
	@configurationId int

AS
BEGIN

    -- Get the current MapPackageType from custom.xml in the cust.tblMaps table.
    DECLARE  @resolution FLOAT,
    @mapPackagetype VARCHAR(20)
    SET @mapPackagetype =  (SELECT 
                            CASE WHEN LOWER(MapTable.MapPackageType) = 'temlandsat7' THEN 'landsat7' 
                                WHEN LOWER(MapTable.MapPackageType) = 'temnaturalvue' THEN 'landsat8' 
                            END as MapPackageType
                            FROM
                            (   SELECT
                                MapItems.value('(/maps/map_package/text())[1]', 'varchar(max)') as MapPackageType
                                FROM cust.tblMaps 
                                INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
                                AND cust.tblMapsMap.ConfigurationID = @configurationId
                            ) as MapTable
                            );

       

    -- Delete the existing entries in the dbo.tblASXiInsetMap table for the configuration id to avoid duplicate inserts.
    BEGIN TRANSACTION
        DELETE FROM dbo.tblASXiInsetMap
        WHERE dbo.tblASXiInsetMap.ConfigurationID = @configurationId;
    COMMIT

    -- use the "res" attribute from TemDescription.xml file as cursor to scan through the insets in the xml.
    DECLARE cursor_res CURSOR
    FOR
    SELECT 
    isnull(Nodes.Insets.value('(./@res)[1]', 'varchar(max)'),'') as Resolution
    FROM dbo.tblMapInsets as M
    cross apply M.MapInsets.nodes('/tem_map_package/tem') as Nodes(Insets)
    INNER JOIN dbo.tblMapInsetsMap ON dbo.tblMapInsetsMap.MapInsetsID = M.MapInsetsID
    WHERE dbo.tblMapInsetsMap.ConfigurationID = @configurationId;


    OPEN cursor_res;

    FETCH NEXT FROM cursor_res INTO @resolution;

    WHILE @@FETCH_STATUS = 0

        BEGIN

            -- Find the insets in the xml which do not match any row in Original inset catalog from dbo.tblASXiInset.
            -- For those insets which do not have a match, insert the inset data onto the dbo.tblASXiInset table before creating a mapping in dbo.tblASXiInsetMap.
            BEGIN TRANSACTION

                MERGE dbo.tblASXiInset AS ASXiInset

                USING ( SELECT M.MapInsetsID,
                isnull(Nodes.Insets.value('(./@name)[1]', 'varchar(max)'),'') as InsetName,
                @resolution as Zoom,
                null as Path,/* considered path as null for now.*/
                @mapPackagetype as MapPackageType,
                isnull(Nodes.Insets.value('(./@row_st)[1]', 'varchar(max)'),'') as RowStart,
                isnull(Nodes.Insets.value('(./@row_end)[1]', 'varchar(max)'),'') as RowEnd,
                isnull(Nodes.Insets.value('(./@col_st)[1]', 'varchar(max)'),'') as ColStart,
                isnull(Nodes.Insets.value('(./@col_end)[1]', 'varchar(max)'),'') as ColEnd,
                isnull(Nodes.Insets.value('(./@lat_st)[1]', 'varchar(max)'),'') as LatStart,
                isnull(Nodes.Insets.value('(./@lat_end)[1]', 'varchar(max)'),'') as LatEnd,
                isnull(Nodes.Insets.value('(./@lon_st)[1]', 'varchar(max)'),'') as LongStart,
                isnull(Nodes.Insets.value('(./@lon_end)[1]', 'varchar(max)'),'') as LongEnd,
                CASE WHEN Nodes.Insets.value('(./@is_hf)[1]', 'varchar(max)') = 'true' THEN 1 ELSE 0 END AS IsHf,
                isnull(Nodes.Insets.value('(./@partNum)[1]', 'varchar(max)'),'') as PartNumber,
                isnull(Nodes.Insets.value('(./text())[1]', 'varchar(max)'),'') as Cdata
                FROM dbo.tblMapInsets as M
                cross apply M.MapInsets.nodes('/tem_map_package/tem[@res =  sql:variable("@resolution")]/insets/inset') as Nodes(Insets) 
                INNER JOIN dbo.tblMapInsetsMap ON dbo.tblMapInsetsMap.MapInsetsID = M.MapInsetsID
                WHERE dbo.tblMapInsetsMap.ConfigurationID = @configurationId)	AS MapInset

                ON (
                        (ASXiInset.ColStart = MapInset.ColStart AND
                        ASXiInset.ColEnd = MapInset.ColEnd AND
                        ASXiInset.RowStart = MapInset.RowStart AND
                        ASXiInset.RowEnd = MapInset.RowEnd)
                    OR 
                        (ASXiInset.LatStart = MapInset.LatStart AND
                        ASXiInset.LatEnd = MapInset.LatEnd AND
                        ASXiInset.LongStart = MapInset.LongStart AND
                        ASXiInset.LongEnd = MapInset.LongEnd)
                    OR 
                        (LOWER(ASXiInset.InsetName) = LOWER(MapInset.InsetName))

                )
                WHEN NOT MATCHED BY TARGET THEN
                    INSERT (InsetName,Zoom, Path,MapPackageType,RowStart,RowEnd,ColStart,ColEnd,LatStart,LatEnd,LongStart,LongEnd,IsHf,PartNumber,Cdata) 
                    VALUES (InsetName,Zoom, Path,MapPackageType,RowStart,RowEnd,ColStart,ColEnd,LatStart,LatEnd,LongStart,LongEnd,IsHf,PartNumber,Cdata);



            -- Insert the ConfigurationID and ASXiInsetID From dbo.tblASXiInset onto dbo.tblASXiInsetMap table to create the mapping.
            -- considered Zoomlevel/resolution and map packge type to Match the correct inset along with Data of Column, Row, Lattitude, Longitude  and Inset Name, in the same order.

                INSERT INTO dbo.tblASXiInsetMap (ConfigurationID,ASXiInsetID,PreviousASXiInsetID,IsDeleted,LastModifiedBy,Action)
                SELECT dbo.tblMapInsetsMap.ConfigurationID as ConfigurationID,
                ASXiInset.ASXiInsetID as ASXiInsetID,
                null as PreviousASXiInsetID,
                0 as IsDeleted,
                null as LastModifiedBy,
                null as Action

                FROM 
                dbo.tblASXiInset as ASXiInset
                INNER JOIN 
                (SELECT M.MapInsetsID,
                isnull(Nodes.Insets.value('(./@name)[1]', 'varchar(max)'),'') as Name,
                isnull(Nodes.Insets.value('(./@col_end)[1]', 'varchar(max)'),'') as ColumnEnd,
                isnull(Nodes.Insets.value('(./@col_st)[1]', 'varchar(max)'),'') as ColumnStart,
                isnull(Nodes.Insets.value('(./@row_end)[1]', 'varchar(max)'),'') as RowEnd,
                isnull(Nodes.Insets.value('(./@row_st)[1]', 'varchar(max)'),'') as RowStart,
                isnull(Nodes.Insets.value('(./@lat_st)[1]', 'varchar(max)'),'') as LatStart,
                isnull(Nodes.Insets.value('(./@lat_end)[1]', 'varchar(max)'),'') as LatEnd,
                isnull(Nodes.Insets.value('(./@lon_st)[1]', 'varchar(max)'),'') as LonStart,
                isnull(Nodes.Insets.value('(./@lon_end)[1]', 'varchar(max)'),'') as LonEnd
                FROM dbo.tblMapInsets as M
                cross apply M.MapInsets.nodes('/tem_map_package/tem[@res =  sql:variable("@resolution")]/insets/inset') as Nodes(Insets) 
                INNER JOIN dbo.tblMapInsetsMap ON dbo.tblMapInsetsMap.MapInsetsID = M.MapInsetsID
                WHERE dbo.tblMapInsetsMap.ConfigurationID = @configurationId
                ) as MapInset 
                ON (
                        (ASXiInset.ColStart = MapInset.ColumnStart AND
                        ASXiInset.ColEnd = MapInset.ColumnEnd AND
                        ASXiInset.RowStart = MapInset.RowStart AND
                        ASXiInset.RowEnd = MapInset.RowEnd)
                    OR 
                        (ASXiInset.LatStart = MapInset.LatStart AND
                        ASXiInset.LatEnd = MapInset.LatEnd AND
                        ASXiInset.LongStart = MapInset.LonStart AND
                        ASXiInset.LongEnd = MapInset.LonEnd)
                    OR 
                        (LOWER(ASXiInset.InsetName) = LOWER(MapInset.Name))

                )
                INNER JOIN dbo.tblMapInsetsMap ON MapInset.MapInsetsID = dbo.tblMapInsetsMap.MapInsetsID
                INNER JOIN (SELECT 
                            CASE WHEN LOWER(MapTable.MapPackageType) = 'temlandsat7' THEN 'landsat7' 
                                WHEN LOWER(MapTable.MapPackageType) = 'temnaturalvue' THEN 'landsat8' 
                            END as MapPackageType
                            FROM
                            (   SELECT
                                MapItems.value('(/maps/map_package/text())[1]', 'varchar(max)') as MapPackageType
                                FROM cust.tblMaps 
                                INNER JOIN cust.tblMapsMap ON cust.tblMaps.MapID = cust.tblMapsMap.MapID 
                                AND cust.tblMapsMap.ConfigurationID = @configurationId
                            ) as MapTable)  as Map ON LOWER(Map.MapPackageType) = LOWER(ASXiInset.MapPackageType)
                WHERE ASXiInset.Zoom = @resolution AND dbo.tblMapInsetsMap.ConfigurationID = @configurationId;
            COMMIT


            FETCH NEXT FROM cursor_res INTO  @resolution;

        END;
    CLOSE cursor_res;
    DEALLOCATE cursor_res;	
END
GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/14/2022
-- Description:	Adds a trigger record to the specified configuration.
-- =============================================
IF OBJECT_ID('[cust].[SP_Trigger_Add]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Trigger_Add]
END
GO

CREATE PROCEDURE [cust].[SP_Trigger_Add]
	@configurationId int,
	@name varchar(max),
	@type varchar(max),
	@condition varchar(max),
	@default varchar(max)
AS
BEGIN
	set nocount on

	-- check for and  create a trigger record if one is not present for the configuration
	-- this should never occur because the flow down from the global configuration should always have a record,
	-- but just in case!!!
    declare @triggerId int
	declare @id int

	set @triggerId = (select triggerId from tblTriggerMap where ConfigurationID = @configurationId)

	if @triggerId is null
	begin
		exec cust.SP_Trigger_New @triggerId = @triggerId output
		exec dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblTrigger', @triggerId
	end

	-- create and add the trigger node to the configuration
	--
	set @id = ( select MAX(Nodes.TriggerValues.value('(./@id)[1]','int'))
				from 
				cust.tblTrigger as TriggerTable
				cross apply TriggerTable.TriggerDefs.nodes('trigger_defs/trigger') as Nodes(TriggerValues)
				inner join cust.tblTriggerMap ON cust.tblTriggerMap.TriggerID = TriggerTable.TriggerID 
				and cust.tblTriggerMap.ConfigurationID = @configurationId AND cust.tblTriggerMap.IsDeleted = 0)
	if @id is null
	begin
        set @id = 0
	end

	declare @triggerDefinition varchar(max) =
		'<trigger condition="' + @condition + '" default="' + @default + '" id="' + cast((@id + 1) as varchar) + '" name="' + @name + '" type="' + @type + '"/>'
	declare @triggerNode xml = cast(@triggerDefinition as xml)

	set nocount off
	update cust.tblTrigger
	set TriggerDefs.modify('insert sql:variable("@triggerNode") into /trigger_defs[1]')
	where cust.tblTrigger.TriggerID = @triggerId;

END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/17/2022
-- Description:	Removes a trigger from the trigger configuration associated with the specified
--   configuration id. If no trigger record is present, then no action is taken.
-- =============================================
IF OBJECT_ID('[cust].[SP_Trigger_Delete]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Trigger_Delete]
END
GO

CREATE PROCEDURE [cust].[SP_Trigger_Delete]
	@configurationId int,
	@triggerId int
AS
BEGIN
	set nocount on
	declare @mappedTriggerId int = (select triggerId from tblTriggerMap where configurationId = @configurationId)

	-- if there is a trigger defined for this configuration then attempt to remove the specified
	-- trigger
	if not @mappedTriggerId is null
	begin
		declare @updateKey int
		exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblTrigger', @mappedTriggerId, @updateKey out

		set nocount off
		update cust.tblTrigger
		set TriggerDefs.modify('delete /trigger_defs/trigger[@id = sql:variable("@triggerId")]')
		where TriggerID = @updateKey
	end
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/14/2022
-- Description:	Returns a single trigger from a configuration. The XML is decomposed in to individual fields of a record.
-- =============================================
IF OBJECT_ID('[cust].[SP_Trigger_Get]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Trigger_Get]
END
GO

CREATE PROCEDURE [cust].[SP_Trigger_Get]
	@configurationId int,
	@triggerId int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT
		isnull(Nodes.TriggerItem.value('(./@name)[1]', 'varchar(max)'),'') as Name, 
		isnull(Nodes.TriggerItem.value('(./@condition)[1]', 'varchar(max)'),'') as Condition, 
		isnull(Nodes.TriggerItem.value('(./@id)[1]', 'varchar(max)'),'') as Id, 
		isnull(Nodes.TriggerItem.value('(./@type)[1]', 'varchar(max)'),'') as Type, 
		isnull(Nodes.TriggerItem.value('(./@default)[1]', 'varchar(max)'),'false') as IsDefault 
	FROM cust.tblTrigger as T 
		cross apply T.TriggerDefs.nodes('/trigger_defs/trigger[@id = sql:variable("@triggerId")]') as Nodes(TriggerItem)
		INNER JOIN cust.tblTriggerMap ON cust.tblTriggerMap.TriggerID = T.TriggerID AND cust.tblTriggerMap.ConfigurationID = @configurationId and cust.tblTriggerMap.IsDeleted = 0
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/14/2022
-- Description:	Retrieves all triggers in the trigger xml element for a specific configuration.
--   Each trigger element is returned as a separate record
-- =============================================
IF OBJECT_ID('[cust].[SP_Trigger_GetAll]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Trigger_GetAll]
END
GO
CREATE PROCEDURE [cust].[SP_Trigger_GetAll]
	@configurationId int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT
		isnull(Nodes.TriggerItem.value('(./@name)[1]', 'varchar(max)'),'') as Name,
		isnull(Nodes.TriggerItem.value('(./@condition)[1]', 'varchar(max)'),'') as Condition,
		isnull(Nodes.TriggerItem.value('(./@id)[1]', 'varchar(max)'),'') as Id,
		isnull(Nodes.TriggerItem.value('(./@type)[1]', 'varchar(max)'),'') as Type,
		isnull(Nodes.TriggerItem.value('(./@default)[1]', 'varchar(max)'),'false') as IsDefault
	FROM cust.tblTrigger as T
		cross apply T.TriggerDefs.nodes('/trigger_defs/trigger') as Nodes(TriggerItem)
		inner join cust.tblTriggerMap ON cust.tblTriggerMap.TriggerID = T.TriggerID 
			and cust.tblTriggerMap.ConfigurationID = @configurationId
			and cust.tblTriggerMap.IsDeleted = 0
END

GO
GO

-- =============================================
-- Author:		Alan Hagemeier
-- Create date: 1/14/2022
-- Description:	Creates a new trigger record with the default trigger xml element in place.
--   The newly created trigger id is returned as an output parameter
-- =============================================
IF OBJECT_ID('[cust].[SP_Trigger_New]', 'P') IS NOT NULL
BEGIN
	DROP PROC [cust].[SP_Trigger_New]
END
GO

CREATE PROCEDURE [cust].[SP_Trigger_New]
	@triggerId int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @triggerIds table (TriggerId int)
    INSERT INTO cust.tblTrigger
		(TriggerDefs)
	OUTPUT inserted.TriggerId into @triggerIds
	VALUES('<trigger_defs/>')

	set @triggerId = scope_identity()
END

GO

GO

