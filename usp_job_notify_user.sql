USE [RandomActsOfSQL]
GO

/****** Object:  StoredProcedure [dbo].[usp_job_notify_user]    Script Date: 2/20/2019 9:44:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_job_notify_user]
GO

/****** Object:  StoredProcedure [dbo].[usp_job_notify_user]    Script Date: 2/20/2019 9:44:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		Elaena Bakman
-- Create date: 12/02/2014
-- Description:	Notify User step in the Valuation jobs
-- Updates:		74749 - E. Bakman 06/26/2015
--				163160 - E. Bakman 12/18/2018
-- =============================================

CREATE PROCEDURE [dbo].[usp_job_notify_user] (
        @ProcessName VARCHAR(150)
       ,@ProcessNickname VARCHAR(150) = NULL)
AS
BEGIN
        SET NOCOUNT ON;

        DECLARE @Email                VARCHAR(100)
               ,@CopyEmail            VARCHAR(100)
               ,@Name                 VARCHAR(100)
               ,@Status               VARCHAR(10)
               ,@ProcessCompleted     VARCHAR(20)
               ,@EmailBody            VARCHAR(MAX)
               ,@EmailSubject         VARCHAR(100)
               ,@CrLf                 VARCHAR(2)
               ,@ProcessId            INT
               ,@Scheduled            BIT
               ,@UserId               VARCHAR(50)
               ,@ProductionServerName VARCHAR(4000)
               ,@EnvironmentName      VARCHAR(25)
			   ,@ScheduledProcessNotification VARCHAR(50);

        SET @CrLf = CHAR(10) + CHAR(13);

        SET @ProductionServerName = TRY_CONVERT(VARCHAR(4000), dbo.fn_get_environment_variable_value ('Utilities', 'Utility', 'ProductionServerName'));
        SET @EnvironmentName = TRY_CONVERT(VARCHAR(25), dbo.fn_get_environment_variable_value ('Utilities', 'Utility', 'EnvironmentName'));
		SET @ScheduledProcessNotification = dbo.fn_get_environment_variable_value('Utilities', 'Utility', 'ScheduledProcessNotification');
        -- set notification's email CC list parameter
        SET @CopyEmail = TRY_CONVERT(VARCHAR(4000), dbo.fn_get_environment_variable_value ('Utilities', 'Utility', 'NotifyUserCC'));

        WITH MostRecent AS (SELECT      P.ProcessId
                                       ,P.ProcessStarted
                                       ,P.ProcessCompleted
                                       ,P.Status
                                       ,REPLACE(P.UserId, 'THOR\', '')                    AS UserId
                                       ,ROW_NUMBER() OVER (ORDER BY P.ProcessStarted DESC) AS Priority
                                       ,P.Scheduled
                            FROM        dbo.process P WITH (NOLOCK)
                            WHERE       P.ProcessCompleted IS NOT NULL
                                        AND     P.ProcessName = @ProcessName)
        SELECT  DISTINCT @Email            = IIF(MR.Scheduled = 1,  @ScheduledProcessNotification, DOE.Email)
                        ,@Name             = IIF(MR.Scheduled = 1, 'Support Team', DOE.FirstName)
                        ,@Status           = ISNULL(MR.Status, 'Failed')
                        ,@ProcessCompleted = ISNULL(CONVERT(VARCHAR(20), MR.ProcessCompleted, 0), '')
                        ,@ProcessId        = MR.ProcessId
        FROM    MostRecent                        MR
        OUTER   APPLY
                (SELECT         DOE.Email
                               ,DOE.FirstName
                 FROM           dbo.employee DOE WITH (NOLOCK)
                 WHERE          MR.UserId = DOE.NetworkId) DOE
        WHERE   MR.Priority = 1;

        IF @Email IS NOT NULL
        BEGIN
                IF @Status = 'Failed'
                BEGIN
                        --set the email subject:
                        SET @EmailSubject = CONCAT(@ProcessNickname, ' (', ISNULL(@Status, 'Failed'), ') - ', @ProcessCompleted, ' (Environment: ', @EnvironmentName, ')');

                        --set the email body:
                        SET @EmailBody = CONCAT('Dear ', ISNULL(@Name, 'Client'), ', ', @CrLf, @ProcessNickname, ' processing is completed.  The import status is: ', ISNULL(@Status, 'Failed'), '.', @CrLf);
                        SET @EmailBody = CONCAT(@EmailBody, 'Please try again or contact your developer to address the issue.', @CrLf);
                        SET @EmailBody = CONCAT(@EmailBody,ISNULL(dbo.fn_get_job_failed_error_message(@ProcessName), ''), @CrLf);
                        -- add the ProcessId to the failure notification so that it can be tied to a redline ticket if one needs to be created
                        SET @EmailBody = CONCAT(@EmailBody, @CrLf, 'Process Id: ', ISNULL(LTRIM(CAST(@ProcessId AS VARCHAR(6))), ''), @CrLf);
                        SET @CopyEmail = CONCAT(@CopyEmail, @ScheduledProcessNotification);
                END;
                ELSE IF @Status = 'Succeeded'
                BEGIN
                        --set the email subject:
                        SET @EmailSubject = CONCAT(@ProcessNickname, ' (', ISNULL(@Status, 'Succeeded'), ') - ', @ProcessCompleted, ' (Environment: ', @EnvironmentName, ')');

                        --set the email body:
                        SET @EmailBody = CONCAT('Dear ', ISNULL(@Name, 'Client'), ', ', @CrLf, @ProcessNickname, ' processing is completed.  The import status is: ', ISNULL(@Status, 'Succeeded'), '.', @CrLf);
                END;

                SET @EmailBody = CONCAT(@EmailBody, @CrLf,'Thanks,', @CrLf, 'Development Team');

                SET @CopyEmail = REPLACE(@CopyEmail, @Email, '');

                EXEC msdb.dbo.sp_send_dbmail @recipients = @Email
                                            ,@copy_recipients = @CopyEmail
                                            ,@subject = @EmailSubject
                                            ,@body = @EmailBody;
        END;
END;

GO


