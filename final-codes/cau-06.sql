go
create or alter view dbo.view_takes_numeric_score as 
select
    id, 
    takes.course_id, 
    sec_id, 
    (case 
        when semester = 'Spring' then 2
        when semester = 'Fall' then 1
    end + year * 10) as term,
    semester,
    year,
    coalesce(dbo.grade_to_numeric(grade), 0) as grade,
    course.credits
from takes
inner join course on takes.course_id = course.course_id

go
create or alter view dbo.view_takes_numeric_score_latest as 
select
    id, 
    course_id, 
    sec_id, 
    max(grade) as grade,
    credits
from dbo.view_takes_numeric_score
group by id, course_id, sec_id, credits

go
create or alter view view_gpa as
select
    id, year, semester, term,
    sum(grade * credits) / sum(credits) as gpa
from dbo.view_takes_numeric_score
group by id, year, semester, term

go
create or alter view view_cpa as
select
    id,
    sum(grade * credits) / sum(credits) as cpa
from dbo.view_takes_numeric_score_latest
group by id

go
create or alter view view_gpa_cpa
as
select 
    id,
    term,
    year,
    semester,
    gpa,
    (
    
        select sum(grade * credits) / sum(credits)
        from (
            select 
                id, 
                course_id, 
                credits,
                max(grade) as grade
            from view_takes_numeric_score where term <= P.term
            group by course_id, id, credits
        ) as C
        where term <= P.term and P.id = C.id
        group by C.id
    ) as cpa
from view_gpa as P


go
create or alter procedure get_gpa_cpa @id int
as 
begin
    select
        student.name, view_gpa_cpa.*
    from view_gpa_cpa inner join student
    on view_gpa_cpa.id = student.id
    where student.id = @id
    order by term
end

go
exec get_gpa_cpa 1018

go
select * from view_gpa_cpa
