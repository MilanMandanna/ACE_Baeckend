
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
