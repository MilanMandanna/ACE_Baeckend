drop proc if exists sp_infoSpelling_getInfoSpelling
go
CREATE PROC sp_infoSpelling_getInfoSpelling  
@configurationId INT,
@languages VARCHAR(MAX)
AS  
BEGIN  

DECLARE @sql NVARCHAR(MAX);

SET @sql= 'select * from (
select infoid,ISNULL(spelling,'''') AS spelling, tbllanguages.[Name] as Language    
from tblinfospelling 
inner join tblinfospellingmap on tblinfospellingmap.infospellingid = tblinfospelling.infospellingid
inner join tbllanguages on tbllanguages.languageid = tblinfospelling.languageid 
inner join tbllanguagesmap on tbllanguagesmap.languageid = tbllanguages.ID 
where tblinfospellingmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' 
and tbllanguagesmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' 
) as sourcetable 
pivot ( 
max(spelling) 
for Language in ('+@languages+') 
) as pivottable 
order by infoid'

EXECUTE sp_executesql @sql;

END
GO