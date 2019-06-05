ALTER TABLE [dbo].[PaymentInfo] DROP CONSTRAINT [PK_PaymentInfo_1] WITH ( ONLINE = OFF )
GO

ALTER TABLE [dbo].[PaymentInfo] ADD  CONSTRAINT [PK_PaymentInfo_1] PRIMARY KEY CLUSTERED 
(
	[PeopleId] ASC,
	[GatewayAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
