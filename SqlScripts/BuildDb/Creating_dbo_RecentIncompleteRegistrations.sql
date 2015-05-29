
CREATE FUNCTION [dbo].[RecentIncompleteRegistrations]
(	
	@prog INT
	,@div INT 
	,@org INT 
	,@begdt DATETIME
	,@enddt DATETIME
)
RETURNS 
@t TABLE 
(
	PeopleId INT,
	OrgId INT,
	Stamp DATETIME
)
AS
BEGIN
	DECLARE @tt TABLE (oid INT, pid1 INT, pid2 INT, pid3 INT, pid4 INT, stamp DATETIME, completed BIT)

	INSERT @tt ( oid , pid1 , pid2 , pid3 , pid4 , stamp , completed )
	SELECT r.OrganizationId, PeopleId1, PeopleId2, PeopleId3, PeopleId4, Stamp, completed
	FROM dbo.RegistrationList r
	JOIN dbo.Organizations o ON o.OrganizationId = r.OrganizationId
	WHERE expired = 0
	AND r.OrganizationId IS NOT NULL
	
	AND (ISNULL(@prog, 0) = 0
		OR EXISTS(SELECT NULL 
					FROM dbo.DivOrg di
					JOIN dbo.ProgDiv pp ON pp.DivId = di.DivId
					WHERE di.OrgId = o.OrganizationId AND pp.ProgId = @prog))
					
	AND (ISNULL(@div, 0) = 0
		OR EXISTS(SELECT NULL 
					FROM dbo.DivOrg dd
					WHERE dd.OrgId = o.OrganizationId AND dd.DivId = @div))

	AND (ISNULL(@org, 0) = 0 OR o.OrganizationId = @org)

	;WITH registrations AS (
		SELECT r.oid, r.pid1 pid, stamp, r.completed 
		FROM @tt r
		WHERE r.pid1 IS NOT NULL
		UNION
		SELECT r.oid, r.pid2, stamp, r.completed 
		FROM @tt r
		WHERE r.pid2 IS NOT NULL
		UNION
		SELECT r.oid, r.pid3, stamp, r.completed 
		FROM @tt r
		WHERE r.pid3 IS NOT NULL
		UNION
		SELECT r.oid, r.pid4, stamp, r.completed 
		FROM @tt r
		WHERE r.pid4 IS NOT NULL
	), 
	oidpids AS (
		SELECT oid, pid, MAX(stamp) stamp
		FROM registrations r
		GROUP BY oid, pid
		HAVING MAX(CAST(ISNULL(completed, 0) AS INT)) = 0
	)
	INSERT @t
	        ( PeopleId, OrgId, Stamp )
	SELECT pid, oid, stamp
	FROM oidpids op
	WHERE op.stamp >= @begdt AND op.stamp <= @enddt
	RETURN 
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
