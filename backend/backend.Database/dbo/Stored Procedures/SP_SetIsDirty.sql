-- =============================================
-- Author:		Abhishek PM
-- Create date: 9/19/2022
-- Description:	updates the isdirty flag =1
-- =============================================


IF OBJECT_ID('[dbo].[SP_SetIsDirty]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_SetIsDirty]
END
GO

CREATE PROCEDURE [dbo].[SP_SetIsDirty]
@configurationId INT,
@modlistinfo [ModListTable] READONLY
AS
BEGIN
DECLARE @TempModListTable TABLE( Id INT,Row INT, Columns INT,Resolution INT)
	INSERT into @TempModListTable SELECT * from @modlistinfo
	DECLARE @Id int , @Row int,@Columns int,@Resolution int
	
	WHILE (SELECT COUNT(*) FROM @TempModListTable) > 0
	BEGIN
	 SET @Id = (SELECT TOP 1 Id from @TempModListTable)
	 SET @Row = (SELECT  Row  from @TempModListTable WHERE Id =@Id)
	 SET @Columns = (SELECT  Columns  from @TempModListTable WHERE Id =@Id)
	 SET @Resolution = (SELECT  Resolution  from @TempModListTable WHERE Id =@Id)
	 
	 IF EXISTS(SELECT 1 FROM tblModList m INNER JOIN tblModListMap mm on m.ModlistId = mm.ModlistID where m.Row = @row and m.Col = @columns and m.resolution = @resolution and mm.ConfigurationID = @configurationId)
	 begin
	 update m 
	 set isdirty = 1 
	 from tblmodlist m inner join tblmodlistmap mm on m.modlistid = mm.modlistid 
	 where  m.Row = @row and m.col = @columns and m.resolution = @resolution and mm.ConfigurationID = @configurationId
	 end

	 DELETE FROM @TempModListTable WHERE Id =@Id
	END
END

GO