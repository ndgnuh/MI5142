GO DROP VIEW IF EXISTS view_loc_du_lieu;


DROP
PROCEDURE IF EXISTS sp_loc_du_lieu GO
CREATE VIEW
  VIEW_LOC_DU_LIEU AS
SELECT
  student.id AS student_id,
  student.name AS student,
  SECTION.year,
  SECTION.semester,
  course.title AS course,
  CONCAT(
    time_slot.start_hr,
    ':',
    time_slot.start_min,
    '-',
    time_slot.end_hr,
    ':',
    time_slot.end_min
  ) AS TIME,
  classroom.room_number AS room,
  instructor.name AS instructor,
  course.dept_name
FROM
  student
  INNER JOIN takes ON student.id = takes.id
  INNER JOIN SECTION ON SECTION.sec_id = takes.sec_id -- info
  INNER JOIN course ON SECTION.course_id = course.course_id
  INNER JOIN teaches ON SECTION.course_id = teaches.course_id
  INNER JOIN instructor ON teaches.id = instructor.id
  INNER JOIN classroom ON SECTION.building = classroom.building
  INNER JOIN time_slot ON SECTION.time_slot_id = time_slot.time_slot_id GO CREATE
PROCEDURE sp_loc_du_lieu @query NVARCHAR(50),
@value NVARCHAR(50) AS BEGIN DECLARE @sql NVARCHAR(100);


SET
  @sql = CONCAT(
    'select * from view_loc_du_lieu where ',
    @query,
    ' = ',
    '''',
    @value,
    ''''
  );


PRINT (@sql) EXEC (@sql);


END GO EXEC sp_loc_du_lieu 'student',
'colin' EXEC sp_loc_du_lieu 'student_id',
'1018' EXEC sp_loc_du_lieu 'year',
'2006'
