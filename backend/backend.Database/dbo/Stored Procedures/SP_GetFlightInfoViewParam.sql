
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
