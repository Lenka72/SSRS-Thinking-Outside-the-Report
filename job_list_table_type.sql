USE [RandomActsOfSQL]
GO

/****** Object:  UserDefinedTableType [dbo].[]    Script Date: 2/19/2019 10:41:20 PM ******/
DROP TYPE IF EXISTS [dbo].[job_list_table_type]job_list_table_type
GO

/****** Object:  UserDefinedTableType [dbo].[job_list_table_type]    Script Date: 2/19/2019 10:41:20 PM ******/
CREATE TYPE [dbo].[job_list_table_type] AS TABLE(
	[JobName] [varchar](255) NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[JobName] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
