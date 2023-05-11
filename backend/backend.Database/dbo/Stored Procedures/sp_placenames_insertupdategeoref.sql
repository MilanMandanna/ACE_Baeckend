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