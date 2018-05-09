EXEC [dbo].[DropProcedureIfExists] 'Integration', 'CreateLineage'

PRINT 'Creating procedure [Integration].[CreateLineage]'
GO

CREATE PROCEDURE [Integration].[CreateLineage]
(
  @TableName varchar(30),
  @SystemCutOffTime datetime2(7),
  @DataLoadStartTime datetime2(7)
)
AS
BEGIN

  INSERT INTO [integration].[Lineage] (TableName,DataLoadStartTime,DataLoadEndTime,SystemCutoffTime)
	Values (@TableName,@DataLoadStartTime,NULL,@SystemCutOffTime)
END