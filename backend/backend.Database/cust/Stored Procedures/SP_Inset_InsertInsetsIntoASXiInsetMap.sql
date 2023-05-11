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