GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportWGTextForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportWGTextForConfig]
END
GO
CREATE PROC sp_GetExportWGTextForConfig
@configurationId INT
AS
BEGIN

select 
	[TextID],
	[Text_EN],
	[Text_FR],
	[Text_DE],
	[Text_ES],
	[Text_NL],
	[Text_IT],
	[Text_EL],
	[Text_JA],
	[Text_ZH],
	[Text_KO],
	[Text_ID],
	[Text_AR],
	[Text_TR],
	[Text_MS],
	[Text_FI],
	[Text_HI],
	[Text_RU],
	[Text_PT],
	[Text_TH],
	[Text_RO],
	[Text_SR],
	[Text_SV],
	[Text_HU],
	[Text_HE],
	[Text_PL],
	[Text_HK],
	[Text_SM],
	[Text_TO],
	[Text_CS],
	[Text_DA],
	[Text_IS],
	[Text_VI]
from tblwgtext
	inner join tblwgtextmap on tblwgtextmap.WGtextID = tblwgtext.WGtextID
where
	tblwgtextmap.ConfigurationID = @configurationId
order by textid

END

GO