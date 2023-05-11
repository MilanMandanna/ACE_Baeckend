CREATE TABLE [dbo].[UserRoleAssignments]
(
	[ID] uniqueidentifier NOT NULL,
	[UserID] uniqueidentifier NOT NULL,
	[RoleID] uniqueidentifier NULL
)