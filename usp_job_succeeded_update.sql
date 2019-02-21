USE [RandomActsOfSQL]
GO

/****** Object:  StoredProcedure [dbo].[usp_job_succeeded_update]    Script Date: 2/19/2019 11:18:56 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_job_succeeded_update]
GO

/****** Object:  StoredProcedure [dbo].[usp_job_succeeded_update]    Script Date: 2/19/2019 11:18:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		Elaena Bakman
-- Create date: 12/02/2014
-- Description:	Update the Process table with 
-- "Succeeded" step in the Valuation jobs
-- Updates:		2016 Upgrade
-- =============================================
CREATE PROCEDURE [dbo].[usp_job_succeeded_update] (
        @ProcessName VARCHAR(150))
AS
BEGIN
        SET NOCOUNT ON;
        WITH MostRecent AS (SELECT      ProcessId
                                       ,ProcessCompleted
                                       ,Status
                                       ,ROW_NUMBER() OVER (ORDER BY ProcessStarted DESC) AS Priority
                            FROM        dbo.process WITH (NOLOCK)
                            WHERE       ProcessCompleted IS NULL
                                        AND     ProcessName = @ProcessName)
        UPDATE  MostRecent
        SET     MostRecent.ProcessCompleted = GETDATE ()
               ,MostRecent.Status = 'Succeeded'
        WHERE   MostRecent.Priority = 1;
END;



GO

