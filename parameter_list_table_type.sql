USE [RandomActsOfSQL]
GO

/****** Object:  UserDefinedTableType [dbo].[parameter_list_table_type]    Script Date: 2/19/2019 10:42:36 PM ******/
DROP TYPE IF EXISTS [dbo].[parameter_list_table_type]
GO

/****** Object:  UserDefinedTableType [dbo].[parameter_list_table_type]    Script Date: 2/19/2019 10:42:36 PM ******/
CREATE TYPE [dbo].[parameter_list_table_type] AS TABLE(
	[ParameterName] [varchar](50) NOT NULL,
	[ParameterValue] [varchar](255) NOT NULL
)
GO

