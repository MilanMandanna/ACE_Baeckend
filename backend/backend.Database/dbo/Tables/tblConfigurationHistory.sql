CREATE TABLE [dbo].[tblConfigurationHistory] (
    [ConfigurationHistoryID] INT            IDENTITY (1, 1) NOT NULL,
    [ConfigurationID]        INT            NULL,
    [UserComments]           NVARCHAR (MAX) NULL,
    [TimeStampCommentAdded]  ROWVERSION     NOT NULL,
    [CommentAddedBy]         NVARCHAR (50)  NULL,
    [Action]                 NVARCHAR (50)  NULL,
    [ContentType]            NVARCHAR (50)  NULL,
    [DateModified] DATETIME NULL, 
    [TaskId] UNIQUEIDENTIFIER NULL, 
    CONSTRAINT [PK_tblConfigurationHistory] PRIMARY KEY CLUSTERED ([ConfigurationHistoryID] ASC)
);

