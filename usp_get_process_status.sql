USE [RandomActsOfSQL]
GO

/****** Object:  StoredProcedure [dbo].[usp_get_process_status]    Script Date: 2/3/2019 9:01:22 PM ******/
DROP PROCEDURE [dbo].[usp_get_process_status]
GO

/****** Object:  StoredProcedure [dbo].[usp_get_process_status]    Script Date: 2/3/2019 9:01:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











-- =============================================
-- Author:		Elaena Bakman
-- Create date: 06/25/2014
-- Description:	Get the status of the processes 
-- based on the list of process names passed in.
-- Type:		0 - Report Only
--				1 - Tag as Cancelled
-- Update:		
-- =============================================
CREATE PROCEDURE [dbo].[usp_get_process_status]
    (
     @ProcessList VARCHAR(MAX) = NULL
    ,@Type INT = 0
    ,@ProcessId INT = NULL
    ,@ProcessName VARCHAR(150) = NULL
    )
AS
    BEGIN
        SET NOCOUNT ON; 

-- =============================================
-- un-comment this section for testing
--        IF OBJECT_ID('tempdb..#ProcessList') IS NOT NULL
--            DROP TABLE #ProcessList;
-- =============================================
        DECLARE @Delimiter CHAR(1) = ','
           ,@ErrorMessage NVARCHAR(4000)
           ,@ErrorSeverity INT
           ,@ErrorState INT
           ,@JobId NVARCHAR(150)
           ,@ReportDate DATE;

        SET @ReportDate = EOMONTH(GETDATE(), -1);

        IF @Type = 1
            BEGIN 
                IF @ProcessId IS NULL
                    BEGIN
                        SET @ErrorMessage = 'Process Id was missing from the request.  Please use the Cancelled "button" on the report to submit the request.';
                        RAISERROR (@ErrorMessage, 16, 1);
                        RETURN;
                    END;
                IF @ProcessName IS NULL
                    BEGIN
                        SET @ErrorMessage = 'Process Name was missing from the request.  Please use the Cancelled "button" on the report to submit the request.';
                        RAISERROR (@ErrorMessage, 16, 1);
                        RETURN;
                    END;
                ELSE
                    BEGIN					
                        IF (SELECT  dbo.fn_is_job_running(@ProcessName)
                           ) = 1
                            BEGIN 
                                EXEC msdb.dbo.sp_stop_job @job_name = @ProcessName;
                            END; 
                        BEGIN 
                            BEGIN TRY
                                BEGIN TRAN; 
                                UPDATE  dbo.processes
                                SET     Status = 'Cancelled'
                                       ,ProcessCompleted = GETDATE()
                                WHERE   ProcessId = @ProcessId
                                        AND NULLIF(RTRIM(LTRIM(Status)), '') IS NULL;

                                COMMIT TRAN; 
                            END TRY
                            BEGIN CATCH
                                IF @@TRANCOUNT > 0
                                    ROLLBACK TRAN;

                                SELECT  @ErrorMessage = ERROR_MESSAGE()
                                       ,@ErrorSeverity = ERROR_SEVERITY()
                                       ,@ErrorState = ERROR_STATE();

                                RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
                            END CATCH;
                        END;
                    END;
            END; 
        CREATE TABLE #ProcessList
            (
             ProcessName VARCHAR(150)
            );

        IF NOT EXISTS ( SELECT  1
                        FROM    [dbo].[fn_split](@ProcessList, @Delimiter) )
            INSERT  INTO #ProcessList
                    (ProcessName
                    )
            SELECT DISTINCT
                    ProcessName
            FROM    dbo.process;
        ELSE
            INSERT  INTO #ProcessList
                    (ProcessName
                    )
            SELECT  Value
            FROM    [dbo].[fn_split](@ProcessList, @Delimiter);

        WITH    MostRecent
                  AS (SELECT    P.[ProcessId]
                               ,P.[ProcessName] + COALESCE('(' + ParameterName + ': ' + RTRIM(ParameterValue) + ')', '') AS [ProcessName]
                               ,P.[ProcessStarted]
                               ,P.[ProcessCompleted]
                               ,P.[Status]
                               ,ROW_NUMBER() OVER (PARTITION BY P.[ProcessName] ORDER BY P.[ProcessStarted] DESC) AS Priority
                      FROM      [dbo].[process] P
                      CROSS APPLY (SELECT   ProcessName
                                   FROM     #ProcessList
                                   WHERE    ProcessName = P.ProcessName
                                  ) PL (ProcessName)
                      LEFT OUTER JOIN dbo.process_parameter PP
                      ON        PP.ProcessId = P.ProcessId
                     )
            SELECT  [ProcessId]
                   ,[ProcessName]
                   ,[ProcessStarted]
                   ,[ProcessCompleted]
                   ,Status
            FROM    MostRecent
            WHERE   [Priority] = 1
            ORDER BY [ProcessStarted] DESC;


    END;



GO


