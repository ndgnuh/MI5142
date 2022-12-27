GO
CREATE OR ALTER VIEW
  view_student_by_qualification AS
SELECT
  *,
  (
    CASE
      WHEN cpa >= 3.6 THEN 'Excellent'
      WHEN cpa >= 3.2 THEN 'Very good'
      WHEN cpa >= 2.5 THEN 'Good'
      WHEN cpa >= 2 THEN 'Average'
      WHEN cpa >= 1 THEN 'Weak'
      ELSE 'Very weak'
    END
  ) AS qualification
FROM
  view_cpa GO
SELECT
  *
FROM
  view_student_by_qualification
