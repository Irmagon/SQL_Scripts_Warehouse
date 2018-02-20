DECLARE
@string AS VARCHAR(4000)
SET @string = '<span class="p-title">Âåñ </span><span class="p-value"> 140</li>          <li><span>Area di stampa </span>65</li>          <li><span>Misura</span> 50</li>'
SELECT
  @string

WHILE @string LIKE '%  %'
  SET @string = REPLACE(@string, '  ', ' ')

SELECT
  @string
