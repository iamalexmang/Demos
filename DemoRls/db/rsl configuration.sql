-- Default the UserId column in the Customer table to the currently logged in user
--	ALTER TABLE SalesLT.Customer ADD UserId nvarchar(128) DEFAULT CAST(SESSION_CONTEXT(N'UserId') AS nvarchar(128))
	
-- Reset the demo
DROP SECURITY POLICY IF EXISTS [Security].[userSecurityPolicy]
DROP FUNCTION IF EXISTS [Security].[userAccessPredicate]
DROP SCHEMA IF EXISTS [Security]

-- Configure a bunch of customers to the newly registered sales person
UPDATE TOP (5) c
	SET SalesPerson = 'new_username_goes_here'
	FROM SalesLT.Customer c

-- Create a separate schema for RLS related stuff
CREATE SCHEMA Security
go

-- Create a predicate function for RLS
-- --> this determines which users can access which rows
CREATE FUNCTION Security.userAccessPredicate(@SalesPerson nvarchar(128))
    RETURNS TABLE
    WITH SCHEMABINDING
AS
    RETURN SELECT 1 AS accessResult
    WHERE @SalesPerson = CAST(SESSION_CONTEXT(N'Username') AS nvarchar(128))
																																																									--		OR SYSTEM_USER like 'alex'		
go

-- Create the policy
-- --> filters are to limit read access to rows
-- --> blocks prevent users to add rows not associated to them
CREATE SECURITY POLICY [Security].[userSecurityPolicy]
    ADD FILTER PREDICATE [Security].[userAccessPredicate](SalesPerson) ON SalesLT.Customer,
    ADD BLOCK PREDICATE [Security].[userAccessPredicate](SalesPerson) ON SalesLT.Customer
go

SELECT *
	FROM SalesLT.Customer c

	