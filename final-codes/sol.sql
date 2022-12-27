drop function IF EXISTS dbo.grade_to_numeric;
drop function if exists  dbo.get_gpa_of
drop function if exists dbo.can_graduate

-- GRADE TO NUMERIC
GO
create function dbo.grade_to_numeric(@grade char(2))
returns real as 
begin
    return (
    case
       WHEN @grade='A'  THEN 4.0
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
    END
    )
end

-- GPA OF A STUDENT
go
create function dbo.get_gpa_of(@student_id int)
returns real as 
begin
    return (select 
        sum(dbo.grade_to_numeric(grade) * course.credits) / sum(credits)
    from takes inner join course on takes.course_id = course.course_id
    where id = @student_id and grade is not null
    group by id)
end

go
create function dbo.can_graduate(@student_id int)
returns bit as
begin
    return (
        select (case
            when student.tot_cred >= 128 and dbo.get_gpa_of(@student_id) > 1.0 then 1
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
