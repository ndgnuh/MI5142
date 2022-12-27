GO
CREATE OR ALTER VIEW
  dbo.view_takes_numeric_score AS
SELECT
  id,
  takes.course_id,
  sec_id,
  (
    CASE
      WHEN semester = 'Spring' THEN 2
      WHEN semester = 'Fall' THEN 1
    END + YEAR * 10
  ) AS term,
  semester,
  YEAR,
  COALESCE(dbo.grade_to_numeric (grade), 0) AS grade,
  course.credits
FROM
  takes
  INNER JOIN course ON takes.course_id = course.course_id GO
CREATE OR ALTER VIEW
  dbo.view_takes_numeric_score_latest AS
SELECT
  id,
  course_id,
  sec_id,
  MAX(grade) AS grade,
  credits
FROM
  dbo.view_takes_numeric_score
GROUP BY
  id,
  course_id,
  sec_id,
  credits GO
CREATE OR ALTER VIEW
  view_gpa AS
SELECT
  id,
  YEAR,
  semester,
  term,
  SUM(grade * credits) / SUM(credits) AS gpa
FROM
  dbo.view_takes_numeric_score
GROUP BY
  id,
  YEAR,
  semester,
  term GO
CREATE OR ALTER VIEW
  view_cpa AS
SELECT
  id,
  SUM(grade * credits) / SUM(credits) AS cpa
FROM
  dbo.view_takes_numeric_score_latest
GROUP BY
  id GO
CREATE OR ALTER VIEW
  view_gpa_cpa AS
SELECT
  id,
  term,
  YEAR,
  semester,
  gpa,
  (
    SELECT
      SUM(grade * credits) / SUM(credits)
    FROM
      (
        SELECT
          id,
          course_id,
          credits,
          MAX(grade) AS grade
        FROM
          view_takes_numeric_score
        WHERE
          term <= P.term
        GROUP BY
          course_id,
          id,
          credits
      ) AS C
    WHERE
      term <= P.term
      AND P.id = C.id
    GROUP BY
      C.id
  ) AS cpa
FROM
  view_gpa AS P GO CREATE
  OR ALTER
PROCEDURE get_gpa_cpa @id INT AS BEGIN
SELECT
  student.name,
  view_gpa_cpa.*
FROM
  view_gpa_cpa
  INNER JOIN student ON view_gpa_cpa.id = student.id
WHERE
  student.id = @id
ORDER BY
  term END GO EXEC get_gpa_cpa 1018 GO
SELECT
  *
FROM
  view_gpa_cpa
