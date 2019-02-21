USE RandomActsOfSQL
GO 

DROP PROCEDURE IF EXISTS dbo.usp_permitted_to_login_demo_report;
GO 

-- ================================================
-- Author:		Elaena Bakman		 
-- Create date: 02/10/2019
-- Description:	This is just to dhow the data for a demo load.
-- Update:		
-- ================================================
CREATE PROCEDURE dbo.usp_permitted_to_login_demo_report
AS
BEGIN
        SET NOCOUNT ON;

        SELECT          'Not Permitted to Logon' AS SourceName
                       ,CreateDateTime
                       ,COUNT(*)                 AS RecordCountPerTablePerRun
        FROM            dbo.People_IsNotPermittedToLogon
        GROUP BY        CreateDateTime
        UNION
        SELECT          'Permitted to Logon' AS SourceName
                       ,CreateDateTime
                       ,COUNT(*)             AS RecordCountPerTablePerRun
        FROM            dbo.People_IsPermittedToLogon
        GROUP BY        CreateDateTime;
END;
