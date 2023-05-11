GO
DROP FUNCTION IF EXISTS [dbo].[config_tblLanguage]
GO
CREATE FUNCTION [dbo].[config_tblLanguage]
(@configurationId int  )
RETURNS TABLE
AS
RETURN
(
select  
  tblLanguages.*  
 from tblLanguages   
  inner join tblLanguagesMap on tblLanguagesMap.LanguageID = tblLanguages.LanguageID  
 where tblLanguagesMap.ConfigurationID = @configurationId  
  and tblLanguagesMap.isdeleted = 0 
)
GO