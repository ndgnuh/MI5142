GO CREATE
OR ALTER
PROCEDURE sp_register @id VARCHAR(5),
@course_id VARCHAR(8),
@room_number VARCHAR(7),
@building VARCHAR(15),
@time_slot_id VARCHAR(4),
@year NUMERIC,
@semester VARCHAR(6) AS BEGIN BEGIN TRANSACTION txn IF NOT EXISTS (
  SELECT
    sec_id
  FROM
    SECTION
  WHERE
    room_number = @room_number
    AND course_id = @course_id
    AND building = @building
    AND time_slot_id = @time_slot_id
    AND YEAR = @year
    AND semester = @semester
) BEGIN RAISERROR ('no such class', 15, 1) ROLLBACK TRAN txn RETURN END
-- FIND @sec_id
DECLARE @sec_id VARCHAR(8);


SELECT
  @sec_id = sec_id
FROM
  SECTION
WHERE
  room_number = @room_number
  AND course_id = @course_id
  AND building = @building
  AND time_slot_id = @time_slot_id
  AND YEAR = @year
  AND semester = @semester
  -- CHECK IF ALREADY REGISTERED
  IF EXISTS (
    SELECT
      id
    FROM
      takes
    WHERE
      id = @id
      AND course_id = @course_id
      AND YEAR = @year
      AND semester = @semester
  ) BEGIN RAISERROR ('already registered', 15, 1) ROLLBACK TRAN txn RETURN END
  -- REGISTER
INSERT INTO
  takes (id, course_id, YEAR, semester, sec_id)
VALUES
  (@id, @course_id, @year, @semester, @sec_id)
  -- NO SUCH STUDENT
  IF NOT EXISTS (
    SELECT
      id
    FROM
      student
    WHERE
      id = @id
  ) BEGIN RAISERROR ('bad student id', 15, 1) ROLLBACK TRAN txn RETURN END
  -- NO SUCH COURSE
  ELSE IF NOT EXISTS (
    SELECT
      course_id
    FROM
      course
    WHERE
      course_id = @course_id
  ) BEGIN RAISERROR ('bad course id', 15, 1) ROLLBACK TRAN txn RETURN END
  -- OK
  COMMIT TRAN txn END EXEC sp_register '41973',
  '200',
  '180',
  'Saucon',
  'D',
  '2007',
  'Spring'
DELETE FROM takes
WHERE
  ID = 41973
  AND course_id = 200 GO
SELECT
  *
FROM
  SECTION
WHERE
  course_id = 313
