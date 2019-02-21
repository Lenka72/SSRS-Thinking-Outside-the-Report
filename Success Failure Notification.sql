--===================================================================================
--Use the following script to set up the last three steps of any user-triggered job.   
--Click Sift+Ctrl+M to enter the correct job name into the “placehoder”.  
--===================================================================================

-- "Process Completed"
EXEC dbo.usp_job_succeeded_update '<Job Name, NVARCHAR(500), NULL>';

-- "Job Failed Updated"usp_job_succeeded_update
EXEC dbo.usp_job_failed_update '<Job Name, NVARCHAR(500), NULL>';

-- "Notify User"
EXEC dbo.usp_job_notify_user '<Job Name, NVARCHAR(500), NULL>';
