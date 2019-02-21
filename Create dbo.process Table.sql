USE RandomActsOfSQL;
GO

DROP TABLE IF EXISTS dbo.process_parameter;
GO

DROP TABLE IF EXISTS process;
GO

CREATE TABLE dbo.process (ProcessId INT IDENTITY(1, 1) NOT NULL
                         ,ProcessName VARCHAR(150) NOT NULL
                         ,ProcessStarted DATETIME NOT NULL
                         ,ProcessCompleted DATETIME NULL
                         ,UserId VARCHAR(25) NULL
                         ,Status VARCHAR(10) NULL
                         ,ErrorMessage NVARCHAR(4000) NULL
                         ,Scheduled BIT NULL
                         ,CONSTRAINT PK_process PRIMARY KEY CLUSTERED (ProcessId ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]) ON [PRIMARY];
GO

ALTER TABLE dbo.process
ADD     CONSTRAINT DF_process_ProcessStarted DEFAULT (GETDATE ()) FOR ProcessStarted;
GO

CREATE TABLE dbo.process_parameter (ProcessParameterId INT IDENTITY(1, 1) NOT NULL
                                   ,ProcessId INT NOT NULL
                                   ,ParameterName VARCHAR(50) NOT NULL
                                   ,ParameterValue VARCHAR(255) NOT NULL
                                   ,CONSTRAINT PK_process_parameter PRIMARY KEY CLUSTERED (ProcessParameterId ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]) ON [PRIMARY];
GO

ALTER TABLE dbo.process_parameter WITH CHECK
ADD     CONSTRAINT FK_process_parameter_process FOREIGN KEY (ProcessId) REFERENCES dbo.process (ProcessId) ON DELETE CASCADE;
GO

ALTER TABLE dbo.process_parameter CHECK CONSTRAINT FK_process_parameter_process;
GO
