USE [msdb]
GO

DECLARE @JobId UNIQUEIDENTIFIER;
SET @JobId = (SELECT    job_id
              FROM      dbo.sysjobs
              WHERE     name = 'SSISDB Demo - Random Data Pulls'
             );
IF @JobId IS NOT NULL
	EXEC msdb.dbo.sp_delete_job @job_id = @JobId, @delete_unused_schedule = 1;
GO

/****** Object:  Job [SSISDB Demo - Random Data Pulls]    Script Date: 2/10/2019 2:32:40 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 2/10/2019 2:32:40 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SSISDB Demo - Random Data Pulls', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'THOR\Owner', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Started]    Script Date: 2/10/2019 2:32:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Started', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'PRINT ''Started....'';', 
		@database_name=N'RandomActsOfSQL', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Set Parameter Value]    Script Date: 2/10/2019 2:32:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Set Parameter Value', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=5, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE RandomActsOfSQL
GO 

DECLARE @var SQL_VARIANT;

SET @var =
        (SELECT        CAST(PP.ParameterValue AS INT) AS ParameterValue
         FROM           dbo.process           P
         INNER   JOIN   dbo.process_parameter PP
         ON PP.ProcessId = P.ProcessId
         CROSS   APPLY
                        (SELECT         MAX(P1.ProcessId) AS MaxProcessId
                         FROM           dbo.process P1
                         WHERE          P1.ProcessName = P.ProcessName
                                        AND     P1.ProcessCompleted IS NULL
                                        AND     P1.ProcessName = ''SSISDB Demo - Random Data Pulls'') PM
         WHERE          PP.ParameterName = ''Random Row Count''
                        AND    P.ProcessId = PM.MaxProcessId);

EXECUTE dbo.usp_set_environment_parameter_value @FolderName = N''SSISDB Demo''
                                               ,@EnvironmentName = N''SSISDB Demo Environment''
                                               ,@EnvironmentVariableName = N''RandomRowCount''
                                               ,@ParameterValue = @var;', 
		@database_name=N'RandomActsOfSQL', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run Process]    Script Date: 2/10/2019 2:32:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run Process', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=4, 
		@on_fail_action=4, 
		@on_fail_step_id=5, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\SSISDB Demo\SSISDB Demo\Random Data Pulls.dtsx\"" /SERVER THOR /ENVREFERENCE 1 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'SSISDemoProsy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Process Completed]    Script Date: 2/10/2019 2:32:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Process Completed', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=6, 
		@on_fail_action=4, 
		@on_fail_step_id=5, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.usp_job_succeeded_update ''SSISDB Demo - Random Data Pulls'';
', 
		@database_name=N'RandomActsOfSQL', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Job Failed Updated]    Script Date: 2/10/2019 2:32:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Job Failed Updated', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=6, 
		@on_fail_action=4, 
		@on_fail_step_id=6, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.usp_job_failed_update ''SSISDB Demo - Random Data Pulls'';
', 
		@database_name=N'RandomActsOfSQL', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Notify User]    Script Date: 2/10/2019 2:32:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Notify User', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.usp_job_notify_user ''SSISDB Demo - Random Data Pulls'';
', 
		@database_name=N'RandomActsOfSQL', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


