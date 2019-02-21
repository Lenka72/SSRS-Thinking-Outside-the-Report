USE SSISDB;
GO

DECLARE @folder_id BIGINT;

IF NOT EXISTS (SELECT   1 FROM  catalog.folders F WHERE name = 'Utilities')
BEGIN
        EXEC SSISDB.catalog.create_folder @folder_name = N'Utilities'
                                         ,@folder_id = @folder_id OUTPUT;
        SELECT  @folder_id;
        EXEC SSISDB.catalog.set_folder_description @folder_name = N'Utilities'
                                                  ,@folder_description = N'This is to avoid confusing our Demo folder and our Utility folder.  We will drop the demo folder for the demo, but not the Utility folder. ';
END;
GO

IF NOT EXISTS (SELECT   1 FROM  catalog.environments WHERE      name = 'Utility')
        EXEC SSISDB.catalog.create_environment @environment_name = N'Utility'
                                              ,@environment_description = N'Use this to store values needed for processing and other items.'
                                              ,@folder_name = N'Utilities';

GO

IF NOT EXISTS
        (SELECT         1
         FROM           catalog.environment_variables
         WHERE          name = 'ProductionServerName')
BEGIN
        DECLARE @var SQL_VARIANT = N'THOR';
        EXEC SSISDB.catalog.create_environment_variable @variable_name = N'ProductionServerName'
                                                       ,@sensitive = False
                                                       ,@description = N'Name of the production Server'
                                                       ,@environment_name = N'Utility'
                                                       ,@folder_name = N'Utilities'
                                                       ,@value = @var
                                                       ,@data_type = N'String';
END;
GO

IF NOT EXISTS
        (SELECT         1
         FROM           catalog.environment_variables
         WHERE          name = 'EnvironmentName')
BEGIN
        DECLARE @var SQL_VARIANT = N'Production';
		EXEC SSISDB.catalog.create_environment_variable @variable_name = N'EnvironmentName'
													   ,@sensitive = False
													   ,@description = N'The name of the current environment'
													   ,@environment_name = N'Utility'
													   ,@folder_name = N'Utilities'
													   ,@value = @var
													   ,@data_type = N'String';
END
GO

IF NOT EXISTS
        (SELECT         1
         FROM           catalog.environment_variables
         WHERE          name = 'NotifyUserCC')
BEGIN
        DECLARE @var SQL_VARIANT = N'Open.Seseme@outlook.com';
		EXEC SSISDB.catalog.create_environment_variable @variable_name = N'NotifyUserCC'
													   ,@sensitive = False
													   ,@description = N'The email used to CC. Can be a list.'
													   ,@environment_name = N'Utility'
													   ,@folder_name = N'Utilities'
													   ,@value = @var
													   ,@data_type = N'String';
END
GO

IF NOT EXISTS
        (SELECT         1
         FROM           catalog.environment_variables
         WHERE          name = 'ScheduledProcessNotification')
BEGIN
        DECLARE @var SQL_VARIANT = N'elaena.bakman@gmail.com';
		EXEC SSISDB.catalog.create_environment_variable @variable_name = N'ScheduledProcessNotification'
													   ,@sensitive = False
													   ,@description = N'The email used to notify someone in case of a failure of a scheduled process'
													   ,@environment_name = N'Utility'
													   ,@folder_name = N'Utilities'
													   ,@value = @var
													   ,@data_type = N'String';
END
GO
