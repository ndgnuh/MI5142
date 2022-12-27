-- GRADE TO NUMERIC
GO
create or alter function dbo.grade_to_numeric(@grade char(2))
returns real as 
begin
    return (
    case
      WHEN @grade='A'  THEN 4.0
      WHEN @grade='A-' THEN 4.0
      WHEN @grade='A+' THEN 4.5
      WHEN @grade='B'  THEN 3.0
      WHEN @grade='B-' THEN 3.0
      WHEN @grade='B+' THEN 3.5
      WHEN @grade='C'  THEN 2.0
      WHEN @grade='C-' THEN 2.0
      WHEN @grade='C+' THEN 2.5
      WHEN @grade='D'  THEN 1.0
      WHEN @grade='D-' THEN 1.0
      WHEN @grade='D+' THEN 1.5
      WHEN @grade='F'  THEN 0 
      ELSE 0
    END
    )
end

-- get cpa
-- see 06.sql for the views
go
create or alter function dbo.get_cpa_of(@student_id int) returns real as 
begin
    return (select cpa from view_cpa where id = @student_id)
end

go
create or alter function dbo.can_graduate(@student_id int) returns bit as
begin
    return (
        select (case
            when student.tot_cred >= 128 and dbo.get_cpa_of(@student_id) > 1.0 then 1
            else 0
        end)
        from student where id = @student_id
    )
end

GO
print concat('A = ', str(dbo.grade_to_numeric('A')))
print concat('A+ = ', str(dbo.grade_to_numeric('A+')))
print concat('B = ', str(dbo.grade_to_numeric('B')))
print concat('B- = ', str(dbo.grade_to_numeric('B-')))
print concat('B+ = ', str(dbo.grade_to_numeric('B+')))
print concat('C = ', str(dbo.grade_to_numeric('C')))
print concat('C- = ', str(dbo.grade_to_numeric('C-')))
print concat('C+ = ', str(dbo.grade_to_numeric('C+')))
print concat('D = ', str(dbo.grade_to_numeric('D')))
print concat('D- = ', str(dbo.grade_to_numeric('D-')))
print concat('D+ = ', str(dbo.grade_to_numeric('D+')))
print concat('F = ', str(dbo.grade_to_numeric('F')))

