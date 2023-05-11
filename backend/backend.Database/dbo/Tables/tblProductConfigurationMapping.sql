CREATE TABLE [dbo].[tblProductConfigurationMapping]
(
	[ProductID] int NULL,
	[ConfigurationDefinitionID] int NULL
)
GO
ALTER TABLE [dbo].[tblProductConfigurationMapping] ADD CONSTRAINT [FK_tblProductConfigurationMapping_tblConfigurationDefinitions]
	FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[tblProductConfigurationMapping] ADD CONSTRAINT [FK_tblProductConfigurationMapping_tblProducts]
	FOREIGN KEY ([ProductID]) REFERENCES [dbo].[tblProducts] ([ProductID]) ON DELETE Cascade ON UPDATE No Action