GO
DROP FUNCTION IF EXISTS [dbo].[config_tblInfoSpelling]
GO
-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Lakshmikanth G R  
-- Create date: 20/07/2022  
-- Description: Function returns the tblInfoSpelling data for given configuration id  
-- =============================================  
CREATE FUNCTION dbo.config_tblInfoSpelling  
(   
 @configurationId int  
)  
RETURNS TABLE   
AS  
RETURN   
(  
 -- Add the SELECT statement with parameter references here  
 select   
  tblInfoSpelling.*  
 from tblInfoSpelling   
  inner join tblInfoSpellingMap on tblInfoSpellingMap.InfoSpellingID = tblInfoSpelling.InfoSpellingId  
 where tblInfoSpellingMap.ConfigurationID = @configurationId  
  and tblInfoSpellingMap.isDeleted = 0  
) 
GO 