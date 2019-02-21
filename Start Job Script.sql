--this should be the report parameters
DECLARE			 @UserId dbo.dtUserId
				,@StartJobAtStep VARCHAR(100)
				,@<MyParameter1, VARCHAR(255), NULL>;
--use this script to add a Start Job option to your SSRS Report
		-- the following set of variables support the job processing
DECLARE			@JobListTable dbo.job_list_table_type
			   ,@ParameterListTable dbo.parameter_list_table_type
			   ,@JobName VARCHAR(255);


SET @JobName = '<NameOfJobToRun, VARCHAR(255), NULL>';

				INSERT INTO @JobListTable (JobName)
				VALUES
				('<NameOfJobToRun, VARCHAR(255), NULL>')
			   ,('<JobWithConflict, VARCHAR(255), NULL>');

				INSERT INTO @ParameterListTable
						(ParameterName
						,ParameterValue)
				VALUES  ('<ParameterName1, VARCHAR(50), NULL>'
						,@<MyParameter1, VARCHAR(255), NULL>);

				EXEC dbo.usp_run_job @JobListTable = @JobListTable
									,@JobName = @JobName
									,@ParameterListTable = @ParameterListTable
									,@UserId = @UserId
									,@StartJobAtStep = @StartJobAtStep;
