DROP
FUNCTION IF EXISTS resolve_course_id DROP
FUNCTION IF EXISTS search_prereq GO CREATE
FUNCTION resolve_course_id (@id INT) returns @deps
TABLE (pid INT) AS BEGIN DECLARE @dep_count INT;


-- find direct deps
INSERT INTO
  @deps
SELECT
  prereq_id
FROM
  prereq
WHERE
  course_id = @id;


SELECT
  @dep_count = COUNT(pid)
FROM
  @deps
GROUP BY
  pid IF @dep_count = 0 RETURN ELSE DECLARE row_cursor CURSOR FOR
SELECT
  pid
FROM
  @deps;


DECLARE @pid INT;


OPEN row_cursor;


WHILE @@FETCH_STATUS = 0 BEGIN
FETCH NEXT
FROM
  row_cursor INTO @pid
INSERT INTO
  @deps
SELECT
  *
FROM
  resolve_course_id (@pid) END CLOSE row_cursor DEALLOCATE row_cursor RETURN END GO CREATE
FUNCTION search_prereq (@title VARCHAR(50)) returns @result
TABLE (
  course_id INT,
  title VARCHAR(50),
  dept_name VARCHAR(20),
  credits NUMERIC
) AS BEGIN DECLARE @pids
TABLE (pid INT);


DECLARE @id INT;


DECLARE id_cursor CURSOR FOR
SELECT
  course_id
FROM
  course
WHERE
  title LIKE @title
  -- get all pids
  OPEN id_cursor WHILE @@FETCH_STATUS = 0 BEGIN
FETCH NEXT
FROM
  id_cursor INTO @id
INSERT INTO
  @pids
SELECT
  *
FROM
  resolve_course_id (@id) END CLOSE id_cursor
  -- insert 
INSERT INTO
  @result
SELECT
  *
FROM
  course
WHERE
  course_id IN (
    SELECT
      pid
    FROM
      @pids
  ) RETURN END GO CREATE
  OR ALTER
FUNCTION get_prereq (@pid INT) returns @result
TABLE (
  course_id INT,
  title VARCHAR(50),
  dept_name VARCHAR(20),
  credits NUMERIC
) AS BEGIN
INSERT INTO
  @result
SELECT
  *
FROM
  course
WHERE
  course.course_id IN (
    SELECT
      pid
    FROM
      resolve_course_id (@pid)
  ) RETURN END GO
SELECT
  *
FROM
  search_prereq ('Game Programming')
SELECT
  *
FROM
  get_prereq (359)
SELECT
  *
FROM
  get_prereq (774)
