DROP
PROCEDURE IF EXISTS sp_loc_du_lieu2 GO CREATE
PROCEDURE sp_loc_du_lieu2 @tbl VARCHAR(50) AS BEGIN DECLARE @conditions
TABLE (field_name NVARCHAR(50), VALUE NVARCHAR(50)) DECLARE @sql VARCHAR(500);


DECLARE @condition VARCHAR(500)
-- create condition string
SET
  @sql = CONCAT('select * from ', @tbl);


INSERT INTO
  @conditions EXEC (@sql)
SELECT
  @condition = COALESCE(
    @condition + ' AND ' + CONCAT(field_name, '=', '''', VALUE, ''''),
    CONCAT('and ', field_name, '=', '''', VALUE, '''')
  )
FROM
  @conditions
  -- filter
  -- print(@condition)
SET
  @sql = CONCAT(
    'select * from VIEW_LOC_DU_LIEU where 1=1 ',
    @condition
  ) PRINT (@sql) EXEC (@sql) END GO
DROP TABLE IF EXISTS conditions
CREATE TABLE
  conditions (field_name NVARCHAR(50), VALUE NVARCHAR(50))
INSERT INTO
  conditions
VALUES
  ('student', 'colin')
INSERT INTO
  conditions
VALUES
  ('student_id', '1018') EXEC sp_loc_du_lieu2 conditions
DROP TABLE conditions
