IF OBJECT_ID('[dbo].[FamilyGreetingName]') IS NOT NULL
DROP FUNCTION [dbo].[FamilyGreetingName]
GO
CREATE FUNCTION [dbo].[FamilyGreetingName]
(
	@type int = 0 -- 0 = Formal, 1 = Informal full names, 2 = Informal First Names
	, @peopleId int
)
RETURNS nvarchar(MAX)
AS
BEGIN
	DECLARE @Result nvarchar(MAX) = NULL;

	declare @familyId int
		, @hohId int
		, @spouseId int
		, @hohFirst nvarchar(100)
		, @hohLast nvarchar(100)
		, @hohTitle nvarchar(10)
		, @spouseFirst nvarchar(100)
		, @spouseLast nvarchar(100)
		, @spouseTitle nvarchar(10)
		, @customGreeting nvarchar(MAX)
		, @contributeIndividually int

	select @familyId = p.familyId
		, @hohId=case when p.EnvelopeOptionsId<>2 
			or p.MaritalStatusId<>20
			or p.PositionInFamilyId<>10
			then p.PeopleId
			else hoh.peopleId
			end
		, @spouseId=sp.PeopleId
		, @hohFirst = case when p.EnvelopeOptionsId<>2 
			or p.MaritalStatusId<>20
			or p.PositionInFamilyId<>10
			then p.PreferredName
			else hoh.PreferredName
			end
		, @hohLast = case when p.EnvelopeOptionsId<>2 
			or p.MaritalStatusId<>20
			or p.PositionInFamilyId<>10
			then p.LastName
			else hoh.LastName
			end
		, @hohTitle = case when p.EnvelopeOptionsId<>2 
			or p.MaritalStatusId<>20
			or p.PositionInFamilyId<>10
			then case when (p.GenderId=1 and p.TitleCode is NULL)
						then 'Mr.'
						when (p.GenderId=2 and p.TitleCode is NULL)
						then case when p.MaritalStatusId=20
							then 'Mrs.'
							else 'Ms.'
							end
						when (p.GenderId=0 and p.TitleCode is NULL)
						then NULL
						else p.TitleCode
						end
			else case when (hoh.GenderId=1 and hoh.TitleCode is NULL)
						then 'Mr.'
						when (hoh.GenderId=2 and hoh.TitleCode is NULL)
						then case when hoh.MaritalStatusId=20
							then 'Mrs.'
							else 'Ms.'
							end
						when (hoh.GenderId=0 and hoh.TitleCode is NULL)
						then NULL
						else hoh.TitleCode
						end
				end
		, @spouseFirst = sp.PreferredName
		, @spouseLast = sp.LastName
		, @spouseTitle = case when (sp.GenderId=1 and sp.TitleCode is NULL)
						then 'Mr.'
						when (sp.GenderId=2 and sp.TitleCode is NULL)
						then case when sp.MaritalStatusId=20
							then 'Mrs.'
							else 'Ms.'
							end
						when (sp.GenderId=0 and sp.TitleCode is NULL)
						then NULL
						else sp.TitleCode
						end
		, @customGreeting = fe.[Data]
		, @contributeIndividually = ISNULL(p.EnvelopeOptionsId,0)
	from dbo.People p
		inner join dbo.Families f
			on p.FamilyId=f.FamilyId
		left join dbo.FamilyExtra fe
			on f.FamilyId=fe.FamilyId and fe.Field = 'CoupleName'
		left join dbo.People hoh
			on f.HeadOfHouseholdId=hoh.PeopleId
		left join dbo.People sp
			on f.HeadOfHouseholdSpouseId=sp.PeopleId
	where p.PeopleId=@peopleId;
	

		-- This function will always prefer the CoupleName option
	SELECT @Result = coalesce(@customGreeting,(
		select
			case when @type = 0
				then 
					case 
					WHEN @spouseId is not NULL and @contributeIndividually = 2
					THEN 
						CASE 
						WHEN @hohTitle is not NULL and @spouseTitle is not NULL
						THEN 
							CASE 
							WHEN @hohLast <> @spouseLast
							THEN @hohTitle + ' ' + @hohFirst + ' ' + @hohLast + ' and ' + @spouseTitle + ' ' + @spouseFirst + ' ' + @spouseLast
							ELSE case when @spouseTitle <> 'Mrs.' and @spouseTitle <> 'Ms.'
								then @hohTitle + ' ' + @hohFirst + ' and ' + @spouseTitle + ' ' + @spouseFirst + ' ' + @spouseLast
								else @hohTitle + ' and ' + @spouseTitle + ' ' + @hohFirst + ' ' + @hohLast
								end
							END
						ELSE 
							CASE --This Case is only used if one or both adults have an unknown gender and no title.
							WHEN @hohLast <> @spouseLast
							THEN @hohFirst + ' ' + @hohLast + ' and ' + @spouseFirst + ' ' + @spouseLast 
							Else @hohFirst + ' and ' + @spouseFirst + ' ' + @hohLast
							end
						end
					--WHEN @spouseId is NULL or @contributeIndividually <> 2
					Else case 
						WHEN @hohTitle is not NULL
						THEN @hohTitle + ' ' + @hohFirst + ' ' + @hohLast
						ELSE @hohFirst + ' ' + @hohLast
						END
					
					end
			WHEN @type=1
			THEN case 
				WHEN @spouseId is NULL or @contributeIndividually <> 2
				THEN @hohFirst + ' ' + @hohLast
				WHEN @hohLast <> @spouseLast
				THEN @hohFirst + ' ' + @hohLast + ' and ' + @spouseFirst + ' ' + @spouseLast
				ELSE @hohFirst + ' and ' + @spouseFirst + ' ' + @hohLast
				END
			ELSE CASE
				WHEN @spouseId is NULL or @contributeIndividually <> 2
				THEN @hohFirst
				Else @hohFirst + ' and ' + @spouseFirst 
				END
			end
		))


	-- Return the result of the function
	RETURN @Result

END
GO