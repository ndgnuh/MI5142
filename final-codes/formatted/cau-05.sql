-- DEPENDS ON CAU-10.SQL
GO CREATE
OR ALTER
TRIGGER TRIG_MAX_ROOM_CAPACITY ON TAKES AFTER
INSERT
  AS BEGIN DECLARE @CAP INT;


DECLARE @BUILDING VARCHAR(15);


DECLARE @SEC_ID INT;


DECLARE @COURSE_ID INT;


DECLARE @SEMESTER VARCHAR(8);


DECLARE @YEAR INT;


DECLARE @CNT INT;


-- GET INFO
SELECT
  @SEC_ID = SEC_ID,
  @COURSE_ID = COURSE_ID,
  @SEMESTER = SEMESTER,
  @YEAR = YEAR
FROM
  INSERTED
  -- GET BUILDING
SELECT
  TOP 1 @BUILDING = BUILDING
FROM
  SECTION
WHERE
  SEC_ID = @SEC_ID
  AND COURSE_ID = @COURSE_ID
  AND SEMESTER = @SEMESTER
  AND YEAR = @YEAR
  --  GET CURRENT CAPACITY
SELECT
  @CNT = COUNT(ID)
FROM
  TAKES
WHERE
  SEC_ID = @SEC_ID
  AND COURSE_ID = @COURSE_ID
  AND SEMESTER = @SEMESTER
  AND YEAR = @YEAR
  -- FIND ROOM MAX CAPACITY
SELECT
  @CAP = CAPACITY
FROM
  CLASSROOM
WHERE
  BUILDING = @BUILDING
  -- CHECK CAPS
  IF (@CNT > @CAP) BEGIN RAISERROR ('PHÒNG QUÁ SỨC CHỨA', 1, 1) ROLLBACK TRANSACTION;


END RETURN;


END GO
CREATE OR ALTER VIEW
  VW_CAPACITY AS
SELECT
  SECTION.SEC_ID,
  SECTION.BUILDING,
  SECTION.ROOM_NUMBER,
  SECTION.YEAR,
  SECTION.SEMESTER,
  TIME_SLOT_ID,
  CLASSROOM.CAPACITY,
  SECTION.COURSE_ID,
  COUNT(DISTINCT TAKES.ID) AS TOTAL
FROM
  CLASSROOM
  INNER JOIN SECTION ON CLASSROOM.BUILDING = SECTION.BUILDING
  AND SECTION.ROOM_NUMBER = CLASSROOM.ROOM_NUMBER
  INNER JOIN TAKES ON TAKES.SEC_ID = SECTION.SEC_ID
  AND TAKES.COURSE_ID = SECTION.COURSE_ID
GROUP BY
  TAKES.COURSE_ID,
  SECTION.SEC_ID,
  SECTION.BUILDING,
  SECTION.ROOM_NUMBER,
  SECTION.YEAR,
  SECTION.SEMESTER,
  SECTION.TIME_SLOT_ID,
  SECTION.COURSE_ID,
  CLASSROOM.CAPACITY GO
SELECT
  *
FROM
  VW_CAPACITY
ORDER BY
  TOTAL GO
UPDATE CLASSROOM
SET
  CAPACITY = 270
WHERE
  BUILDING = 'CHANDLER'
  AND ROOM_NUMBER = 804 GO
SELECT
  *
FROM
  VW_CAPACITY
WHERE
  BUILDING = 'CHANDLER'
  AND ROOM_NUMBER = 804
ORDER BY
  TOTAL GO
DELETE FROM TAKES
WHERE
  ID = 24746
  AND COURSE_ID = '313' GO
  -- ERROR
  -- EXEC SP_REGISTER '24746', '313', '804', 'CHANDLER', 'N', '2010', 'FALL'
  GO
UPDATE CLASSROOM
SET
  CAPACITY = 270
WHERE
  BUILDING = 'CHANDLER'
  AND ROOM_NUMBER = 804 GO
SELECT
  *
FROM
  VW_CAPACITY
WHERE
  BUILDING = 'CHANDLER'
  AND ROOM_NUMBER = 804
ORDER BY
  TOTAL GO
DELETE FROM TAKES
WHERE
  ID = 24746
  AND COURSE_ID = '313' GO EXEC SP_REGISTER '24746',
  '313',
  '804',
  'CHANDLER',
  'N',
  '2010',
  'FALL'
DELETE FROM TAKES
WHERE
  ID = 24746
  AND COURSE_ID = '313'
