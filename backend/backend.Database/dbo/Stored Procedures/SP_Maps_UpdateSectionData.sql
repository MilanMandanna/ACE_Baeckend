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