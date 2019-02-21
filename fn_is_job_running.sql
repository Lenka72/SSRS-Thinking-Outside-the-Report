USE [RandomActsOfSQL]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_is_job_running]    Script Date: 2/19/2019 11:06:00 PM ******/
DROP FUNCTION IF EXISTS [dbo].[fn_is_job_running]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_is_job_running]    Script Date: 2/19/2019 11:06:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		Elaena Bakman
-- Create date: 11/25/2013
-- Description:	Check to see if a job is running
-- =============================================
CREATE FUNCTION [dbo].[fn_is_job_running]
(
	@JobName NVARCHAR(128)
)
RETURNS BIT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @StartExecutionDate DATETIME,
			@StopExecutionDate DATETIME,	
			@IsRunning BIT;

	SELECT @StartExecutionDate = start_execution_date
		,@StopExecutionDate = stop_execution_date 
	FROM msdb.dbo.sysjobs SJ
	INNER JOIN msdb.dbo.sysjobactivity JA
	ON SJ.job_id = JA.job_id
	LEFT OUTER JOIN msdb.dbo.sysjobhistory JH
	ON SJ.job_id = JH.job_id
	AND JA.job_history_id = JH.instance_id
	AND JH.step_name = '(Job outcome)'
	WHERE SJ.name = @JobName;
	
	IF @@ROWCOUNT = 0 
		SET @IsRunning = 0;
	ELSE
		IF @StartExecutionDate IS NOT NULL AND @StopExecutionDate IS NULL
			SET @IsRunning = 1;
		ELSE
			SET @IsRunning = 0;
	-- Return the result of the function
	RETURN @IsRunning

END



GO


