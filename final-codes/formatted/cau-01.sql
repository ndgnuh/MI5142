-- GRADE TO NUMERIC
GO CREATE
OR ALTER
FUNCTION dbo.grade_to_numeric (@grade CHAR(2)) returns REAL AS BEGIN RETURN (
  CASE
    WHEN @grade = 'A' THEN 4.0
    WHEN @grade = 'A-' THEN 4.0
    WHEN @grade = 'A+' THEN 4.5
    WHEN @grade = 'B' THEN 3.0
    WHEN @grade = 'B-' THEN 3.0
    WHEN @grade = 'B+' THEN 3.5
    WHEN @grade = 'C' THEN 2.0
    WHEN @grade = 'C-' THEN 2.0
    WHEN @grade = 'C+' THEN 2.5
    WHEN @grade = 'D' THEN 1.0
    WHEN @grade = 'D-' THEN 1.0
    WHEN @grade = 'D+' THEN 1.5
    WHEN @grade = 'F' THEN 0
    ELSE 0
  END
) END
-- get cpa
-- see 06.sql for the views
GO CREATE
OR ALTER
FUNCTION dbo.get_cpa_of (@student_id INT) returns REAL AS BEGIN RETURN (
  SELECT
    cpa
  FROM
    view_cpa
  WHERE
    id = @student_id
) END GO CREATE
OR ALTER
FUNCTION dbo.can_graduate (@student_id INT) returns BIT AS BEGIN RETURN (
  SELECT
    (
      CASE
        WHEN student.tot_cred >= 128
        AND dbo.get_cpa_of (@student_id) > 1.0 THEN 1
        ELSE 0
      END
    )
  FROM
    student
  WHERE
    id = @student_id
) END 


PRINT CONCAT('A = ', STR(dbo.grade_to_numeric('A')))
PRINT CONCAT('A+ = ', STR(dbo.grade_to_numeric('A+')))
PRINT CONCAT('B = ', STR(dbo.grade_to_numeric('B')))
PRINT CONCAT('B- = ', STR(dbo.grade_to_numeric('B-')))
PRINT CONCAT('B+ = ', STR(dbo.grade_to_numeric('B+')))
PRINT CONCAT('C = ', STR(dbo.grade_to_numeric('C')))
PRINT CONCAT('C- = ', STR(dbo.grade_to_numeric('C-')))
PRINT CONCAT('C+ = ', STR(dbo.grade_to_numeric('C+')))
PRINT CONCAT('D = ', STR(dbo.grade_to_numeric('D')))
PRINT CONCAT('D- = ', STR(dbo.grade_to_numeric('D-')))
PRINT CONCAT('D+ = ', STR(dbo.grade_to_numeric('D+')))
PRINT CONCAT('F = ', STR(dbo.grade_to_numeric('F')))

