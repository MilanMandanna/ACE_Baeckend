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