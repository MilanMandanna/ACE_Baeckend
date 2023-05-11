/****** Object:  StoredProcedure [dbo].[SP_MergeConflicts_UpdateSelection]    Script Date: 10/25/2022 11:03:23 AM ******/
IF OBJECT_ID('[dbo].[SP_MergeConflicts_UpdateSelection]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_MergeConflicts_UpdateSelection]
END
GO
/****** Object:  StoredProcedure [dbo].[SP_MergeConflicts_UpdateSelection]    Script Date: 10/25/2022 11:03:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_MergeConflicts_UpdateSelection]
	@taskId UNIQUEIDENTIFIER,
	@collinsContentIds NVARCHAR(MAX) = NULL, --'1,2,3'
	@childContentIds NVARCHAR(MAX) = NULL, --'1,2,3'
	@status INT = NULL
AS
BEGIN

	IF @CollinsContentIds IS NOT NULL
	BEGIN
		UPDATE tblMergeDetails SET SelectedKey = ParentKey, MergeChoice = @status WHERE TaskId = @taskId AND
			ID IN (select value from STRING_SPLIT(@collinsContentIds, ','))
	END
	IF @ChildContentIds IS NOT NULL
	BEGIN
		UPDATE tblMergeDetails SET SelectedKey = ChildKey, MergeChoice = @status WHERE TaskId = @taskId AND 
			ID IN (select value from STRING_SPLIT(@childContentIds, ','))
	END
END