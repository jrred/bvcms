CREATE TABLE [dbo].[DuplicatesRun]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[started] [datetime] NULL,
[count] [int] NULL,
[processed] [int] NULL,
[found] [int] NULL,
[completed] [datetime] NULL,
[error] [nvarchar] (200) NULL,
[running] AS (case  when [completed] IS NULL AND [error] IS NULL AND datediff(minute,[started],getdate())<(120) then (1) else (0) end)
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
