IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'MFAEnabled'
          AND Object_ID = Object_ID(N'dbo.Users'))
BEGIN
    ALTER TABLE dbo.Users ADD MFAEnabled bit NOT NULL CONSTRAINT DF_Users_MFAEnabled DEFAULT 0
END
