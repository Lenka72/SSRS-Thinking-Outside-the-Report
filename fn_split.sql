USE RandomActsOfSQL
GO

/****** Object:  UserDefinedFunction [dbo].[fn_split]    Script Date: 2/2/2019 5:51:31 PM ******/
DROP FUNCTION [dbo].[fn_split]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_split]    Script Date: 2/2/2019 5:51:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		Elaena Bakman
-- Create date: 6/5/2013
-- Description: This fucntion splits a delimited string and returns a table. 
-- Example: 
-- DECLARE @InputString AS VARCHAR(MAX),
--		   @Delimiter AS VARCHAR(10)
-- SET @InputString = 'A, B, C, D, E, F, G'; 
-- SET @Delimiter = ',';

-- SELECT * FROM dbo.fn_split(@InputString, @Delimiter)
-- =============================================
CREATE FUNCTION [dbo].[fn_split] 
(
	@InputString AS VARCHAR(MAX),
	@Delimiter AS VARCHAR(10)
)
RETURNS @SplitData TABLE 
(
	Value VARCHAR(255)
)
AS
BEGIN
	
DECLARE @XML AS XML

SET @XML = CAST(('<X>' + REPLACE(@InputString, @Delimiter, '</X><X>') + '</X>') AS XML);
	
	INSERT INTO @SplitData 
	SELECT RTRIM(LTRIM(N.value('.', 'varchar(255)'))) AS Value 
	FROM @XML.nodes('X') AS T(N)
	
	RETURN 
END





GO

