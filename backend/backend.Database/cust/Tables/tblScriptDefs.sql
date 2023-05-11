CREATE TABLE [cust].[tblScriptDefs]
(
	[ScriptDefID] int NOT NULL IDENTITY (1, 1),
	[ScriptDefs] xml NULL DEFAULT NULL
)
GO
ALTER TABLE [cust].[tblScriptDefs] 
 ADD CONSTRAINT [PK_tblScriptDefs]
	PRIMARY KEY CLUSTERED ([ScriptDefID] ASC)