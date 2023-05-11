drop function if exists config_tblInfoSpelling
go
CREATE FUNCTION config_tblInfoSpelling
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
		inner join tblInfoSpellingMap on tblInfoSpellingMap.InfoSpellingId = tblInfoSpelling.InfoSpellingId
	where tblInfoSpellingMap.ConfigurationID = @configurationId
		and tblInfoSpellingmap.isDeleted = 0
)
GO