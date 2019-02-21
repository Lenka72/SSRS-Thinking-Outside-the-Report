USE [RandomActsOfSQL]
GO

/****** Object:  StoredProcedure [dbo].[usp_run_job]    Script Date: 2/19/2019 10:58:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ================================================
-- Author:		Elaena Bakman 
-- Create date: 05/13/2016
-- Description:	This stored procedure will use the 
-- @JobList to check for any relevant jobs that may be 
-- running, and kick off the job (@JobName).  Any 
-- parameters for the job we are kicking off should 
-- be supplied through the @ParameterList table.
-- Update:		
-- ================================================

CREATE PROCEDURE [dbo].[usp_run_job] (
        @JobListTable job_list_table_type READONLY
       ,@JobName VARCHAR(255)
       ,@ParameterListTable parameter_list_table_type READONLY
       ,@UserId VARCHAR(25)
       ,@StartJobAtStep VARCHAR(100) = NULL)
AS
BEGIN
        SET NOCOUNT ON;

        DECLARE @CheckJobName VARCHAR(255)
               ,@IsRunning BIT
               ,@Result INT
               ,@ProcessId INT
               ,@ErrorMessage VARCHAR(500)
               ,@ErrorSeverity INT;

        IF RTRIM(@StartJobAtStep) = ''
                SET @StartJobAtStep = NULLIF(RTRIM(@StartJobAtStep), '');

        DECLARE JobList CURSOR LOCAL FAST_FORWARD
        FOR
        SELECT  JLT.JobName
        FROM    @JobListTable JLT;

        OPEN JobList;

        FETCH NEXT FROM JobList
        INTO    @CheckJobName;

        WHILE @@FETCH_STATUS = 0
        BEGIN
                SELECT  @IsRunning = dbo.fn_is_job_running(@CheckJobName);

                IF @IsRunning = 1
                        GOTO CloseCursor;

                FETCH NEXT FROM JobList
                INTO    @CheckJobName;
        END;

        CloseCursor:
        CLOSE JobList;
        DEALLOCATE JobList;

        IF @IsRunning = 0
        BEGIN
                --try to kick off the job
                EXEC @Result = msdb.dbo.sp_start_job @job_name = @JobName
                                                    ,@step_name = @StartJobAtStep;

                --add the process to the process table
                IF @Result = 0
                BEGIN
                        EXECUTE dbo.usp_add_job_to_log @JobName = @JobName
                                                      ,@UserId = @UserId
                                                      ,@ParameterListTable = @ParameterListTable;
                END;
                ELSE
                BEGIN
                        SET @ErrorMessage = 'There was an issue kicking off the job ' + @JobName + '.  Returned: ' + CAST(@Result AS VARCHAR) + '.';

                        RAISERROR(@ErrorMessage, 16, 1);

                        RETURN;
                END;
        END;
        ELSE IF @IsRunning = 1
        BEGIN
                SET @ErrorMessage = 'The job ' + @JobName + ' is already running!';

                RAISERROR(@ErrorMessage, 16, 1);

                RETURN;
        END;
        ELSE IF @@ERROR != 0
        BEGIN
                SET @ErrorMessage =
                (SELECT ERROR_NUMBER() + ' ' + ERROR_MESSAGE());
                SET @ErrorSeverity =
                (SELECT ERROR_SEVERITY());

                RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
        END;
END;
GO


