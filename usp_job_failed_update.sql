USE [RandomActsOfSQL]
GO

/****** Object:  StoredProcedure [dbo].[usp_job_failed_update]    Script Date: 2/19/2019 11:19:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_job_failed_update]
GO

/****** Object:  StoredProcedure [dbo].[usp_job_failed_update]    Script Date: 2/19/2019 11:19:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:			Elaena Bakman
-- Create date:		12/02/2014
-- Description:		Update the Process table 
-- WITH "Failed" step in the Valuation jobs
-- Updates:			75209 - E. Bakman 07/02/2015
--					2016 Upgrade
-- =============================================
CREATE PROCEDURE [dbo].[usp_job_failed_update] (
        @ProcessName VARCHAR(150))
AS
BEGIN
        SET NOCOUNT ON;
        WITH MostRecent AS (SELECT      P.ProcessId
                                       ,P.ProcessCompleted
                                       ,P.Status
                                       ,P.ErrorMessage
                                       ,dbo.fn_get_job_failed_error_message(@ProcessName)  AS GetErrorMessage
                                       ,ROW_NUMBER() OVER (ORDER BY P.ProcessStarted DESC) AS Priority
                            FROM        dbo.process P WITH (NOLOCK)
                            WHERE       P.ProcessCompleted IS NULL
                                        AND     P.ProcessName = @ProcessName)
        UPDATE  MostRecent
        SET     MostRecent.ProcessCompleted = GETDATE ()
               ,MostRecent.Status = 'Failed'
               ,MostRecent.ErrorMessage = MostRecent.GetErrorMessage
        WHERE   MostRecent.Priority = 1;
END;



GO

