--This will all the Manual change we have done so far in the Production DATABASE

--Remove  the time stamp data type from DataTables (Match with Access DB)

--tblAirportInfo
Alter table dbo.tblAirportInfo
Drop Column ModifyDate 

Alter table dbo.tblAirportInfo
ADD  ModifyDate DATE NULL

--tblSpelling
Alter table dbo.tblSpelling
Drop Column TimeStampModified 

Alter table dbo.tblSpelling
ADD  TimeStampModified DATE NULL

--tblCoverageSegment
Alter table dbo.tblCoverageSegment
Drop Column LastModifiedTime 

Alter table dbo.tblCoverageSegment
ADD  LastModifiedTime DATE NULL

--tblCityPopulation
Alter table dbo.tblCityPopulation
Drop Column TimeStampModified 

Alter table dbo.tblCityPopulation
ADD  TimeStampModified DATE NULL


--Changes are from Jason as these are not correct in the Master BB and Access DB.
update tblSpelling
set UnicodeStr = N'سنشري سيتي'
where LanguageID = 12 and GeoRefID = 310297

update tblCoverageSegment 
set SegmentID = 1 where SegmentID = 21 and GeoRefID = 108034

update tblCoverageSegment 
set SegmentID = 2 where SegmentID = 22 and GeoRefID = 108034

update tblCoverageSegment 
set SegmentID = 3 where SegmentID = 23 and GeoRefID = 108034
