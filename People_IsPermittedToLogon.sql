USE RandomActsOfSQL
GO

/****** Object:  Table [dbo].[People_IsPermittedToLogon]    Script Date: 2/2/2019 7:16:35 PM ******/
DROP TABLE IF EXISTS [dbo].[People_IsPermittedToLogon]
GO

/****** Object:  Table [dbo].[People_IsPermittedToLogon]    Script Date: 2/2/2019 7:16:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[People_IsPermittedToLogon](
	[CreateDateTime] DATETIME NOT NULL,
	[FullName] [nvarchar](50) NOT NULL,
	[PreferredName] [nvarchar](50) NOT NULL,
	[IsPermittedToLogon] [bit] NOT NULL,
	[LogonName] [nvarchar](50) NULL,
	[IsExternalLogonProvider] [bit] NOT NULL,
	[HashedPassword] [varbinary](max) NULL,
	[IsSystemUser] [bit] NOT NULL,
	[IsEmployee] [bit] NOT NULL,
	[IsSalesperson] [bit] NOT NULL,
	[UserPreferences] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](20) NULL,
	[FaxNumber] [nvarchar](20) NULL,
	[EmailAddress] [nvarchar](256) NULL,
	[Photo] [varbinary](max) NULL,
	[CustomFields] [nvarchar](max) NULL,
	[LastEditedBy] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


