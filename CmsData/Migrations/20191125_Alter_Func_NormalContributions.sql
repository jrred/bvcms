ALTER FUNCTION [dbo].[NormalContributions]
(
	@pid INT, 
	@spid INT, 
	@joint BIT, 
	@fromDate DATE,
	@toDate DATE,
	@fundids VARCHAR(MAX),
	@TaxStatusCategorization BIT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		c.ContributionId,
		c.ContributionAmount,
		c.ContributionDate,
		FundName,
		c.CheckNo,
		p.[Name],
		[Description] = CASE WHEN @TaxStatusCategorization = 1 THEN f.FundDescription ELSE c.ContributionDesc END,
		FundDescription,
		f.NonTaxDeductible
	FROM dbo.Contribution c
	JOIN dbo.ContributionFund f ON f.FundId = c.FundId
	JOIN dbo.People p ON p.PeopleId = c.PeopleId
	WHERE 1=1
	AND c.ContributionStatusId = 0 -- Recorded
	AND c.ContributionTypeId NOT IN (6, 7) -- not returned or reversed
	AND c.contributionTypeId NOT IN (10, 20) -- not stock or giftinkind
	AND c.ContributionTypeId NOT IN (8, 9) -- not pledge or nontaxded
	AND ISNULL(f.NonTaxDeductible, 0) = 0
	AND c.ContributionDate >= @fromDate
	AND CONVERT(DATE, c.ContributionDate) <= @toDate
	AND (c.PeopleId = @pid OR (@joint = 1 AND c.PeopleId = @spid))
	AND (@fundids IS NULL OR EXISTS(SELECT NULL FROM dbo.SplitInts(@fundids) WHERE Value = c.FundId))
)
GO