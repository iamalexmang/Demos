-- CREATE USER ddm WITH PASSWORD = '123!@#qweQWE'
-- grant select on saleslt.customer to ddm


SELECT * FROM SalesLT.Customer


ALTER TABLE SalesLT.Customer ALTER COLUMN FirstName ADD MASKED WITH (FUNCTION = 'partial(1, "***", 0)')
ALTER TABLE SalesLT.Customer ALTER COLUMN EmailAddress ADD MASKED WITH (FUNCTION = 'default()') -- ssn()   email()   random(1,20000)   partial (2,"xxx",2)



GRANT UNMASK TO ddm



SELECT * FROM SalesLT.Customer



ALTER TABLE SalesLT.Customer ALTER COLUMN FirstName DROP MASKED
ALTER TABLE SalesLT.Customer ALTER COLUMN EmailAddress ADD MASKED WITH (FUNCTION = 'default()')