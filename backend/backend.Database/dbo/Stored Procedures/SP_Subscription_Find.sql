
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Mohan,Abhishek Padinarapurayil>
-- Create date: <5/23/2022>
--description: returns rows from tblSubscriptionFeatureAssignment based on SubscriptionId provided
--Sample EXEC:exec [dbo].[SP_Subscription_Find] 'AC5A159E-4519-455E-BBAC-DF0A568E01FB'
-- =============================================
IF OBJECT_ID('[dbo].[SP_Subscription_Find]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_Subscription_Find]
END
GO
CREATE PROCEDURE [dbo].[SP_Subscription_Find]
			@subscriptionId  uniqueidentifier
AS
BEGIN
		
		select * FROM dbo.tblSubscriptionFeatureAssignment WHERE subscriptionId = @subscriptionId
		
END
GO