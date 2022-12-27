GO
CREATE OR ALTER VIEW
  view_student_by_level AS
SELECT
  id,
  CASE
    WHEN tot_cred < 32 THEN 1
    WHEN tot_cred < 64 THEN 2
    WHEN tot_cred < 96 THEN 3
    WHEN tot_cred < 128 THEN 4
    ELSE 128
  END AS LEVEL
FROM
  student GO
SELECT
  *
FROM
  view_student_by_level
