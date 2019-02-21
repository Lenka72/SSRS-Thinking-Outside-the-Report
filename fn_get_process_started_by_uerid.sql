USE RandomActsOfSQL
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_process_started_by_uerid]    Script Date: 2/10/2019 9:37:10 PM ******/
DROP FUNCTION IF EXISTS [dbo].[fn_get_process_started_by_uerid]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_process_started_by_uerid]    Script Date: 2/10/2019 9:37:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Elaena Bakman
-- Create date: 05/19/2015
-- Description:	This function will pull the 
-- UserId of the user running the most recent process.
-- The @ProcessList should contain all items for
-- a process.  Example: 'Job 1 Name, Job 2 Name'.
-- Both of the above items run the lar, so in some cases
-- you may want to look at both, in others you know 
-- the specific process (like from a job, you know what job is running).
-- =============================================
CREATE FUNCTION [dbo].[fn_get_process_started_by_uerid]
    (
     @ProcessList VARCHAR(MAX)
    )
RETURNS VARCHAR(25)
AS
    BEGIN
	-- Declare the return variable here
        DECLARE @ProcessStartedByUserId VARCHAR(25)
           ,@MaxProcessId INT;

        SELECT  @MaxProcessId = MAX(ProcessId)
        FROM    dbo.process
        WHERE   ProcessName IN (SELECT  Value
                                FROM    dbo.fn_split(@ProcessList, ','))
                AND ProcessCompleted IS NULL;


        SET @ProcessStartedByUserId = (SELECT   UserId
                                       FROM     dbo.process
                                       WHERE    ProcessId = @MaxProcessId
                                      );

        SET @ProcessStartedByUserId = COALESCE(REPLACE(@ProcessStartedByUserId, 'THOR\', ''),
                                               REPLACE(SUSER_SNAME(), 'THOR\', ''), 'system');
	      
        RETURN @ProcessStartedByUserId;

    END;


GO
