GO
DROP FUNCTION IF EXISTS dbo.config_tblCoverageSegment
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
-- Author:		Lakshmikanth G R
-- Create date: 28/06/2022
-- Description:	Function returns the CoverageSegment data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblCoverageSegment
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblCoverageSegment.*
	from tblCoverageSegment 
		inner join tblCoverageSegmentMap on tblCoverageSegmentMap.CoverageSegmentID = tblCoverageSegment.ID
	where tblCoverageSegmentMap.ConfigurationID = @configurationId
		and tblCoverageSegmentMap.isDeleted = 0
)
GO
