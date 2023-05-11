CREATE TABLE [dbo].[UserRoleClaims]
(
	[ID] uniqueidentifier NOT NULL,
	[RoleID] uniqueidentifier NULL,
	[ClaimID] uniqueidentifier NULL,
	[AircraftID] uniqueidentifier NULL,
	[UserRoleID] uniqueidentifier NULL,
	[ConfigurationID] int NULL,
	[ConfigurationDefinitionID] int NULL,
	[OperatorID] uniqueidentifier NULL,
	[ServiceID] uniqueidentifier NULL,
	[ProductTypeID] int NULL
)
GO
ALTER TABLE [dbo].[UserRoleClaims] ADD CONSTRAINT [FK_UserRoleClaims_tblConfigurationDefinitions]
	FOREIGN KEY ([ConfigurationDefinitionID]) REFERENCES [dbo].[tblConfigurationDefinitions] ([ConfigurationDefinitionID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[UserRoleClaims] ADD CONSTRAINT [FK_UserRoleClaims_Aircraft]
	FOREIGN KEY ([AircraftID]) REFERENCES [dbo].[Aircraft] ([Id]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[UserRoleClaims] ADD CONSTRAINT [FK_UserRoleClaims_Operator]
	FOREIGN KEY ([OperatorID]) REFERENCES [dbo].[Operator] ([Id]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[UserRoleClaims] ADD CONSTRAINT [FK_UserRoleClaims_tblConfigurations]
	FOREIGN KEY ([ConfigurationID]) REFERENCES [dbo].[tblConfigurations] ([ConfigurationID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[UserRoleClaims] ADD CONSTRAINT [FK_UserRoleClaims_tblProductType]
	FOREIGN KEY ([ProductTypeID]) REFERENCES [dbo].[tblProductType] ([ProductTypeID]) ON DELETE No Action ON UPDATE No Action
GO
ALTER TABLE [dbo].[UserRoleClaims] 
 ADD CONSTRAINT [PK_UserRoleClaims]
	PRIMARY KEY CLUSTERED ([ID] ASC)