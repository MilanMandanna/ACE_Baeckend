GO
DROP FUNCTION IF EXISTS [dbo].[config_tblImage]
GO
/****** Object:  UserDefinedFunction [dbo].[config_tblImage] */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 28/05/2022
-- Description:	Function returns the image data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblImage
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select
		tblImage.*
	from tblImage	
		inner join tblImageMap on tblImageMap.ImageId = tblImage.ImageId
	where tblImageMap.ConfigurationID = @configurationId
		and tblImageMap.isdeleted = 0
)
