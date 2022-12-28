go
create or alter view view_student_by_level as 
select 
    id, 
    case 
        when tot_cred < 32 then 1
        when tot_cred < 64 then 2
        when tot_cred < 96 then 3
        when tot_cred < 128 then 4
        else 128
    end as level
from student

go
create or alter PROCEDURE get_student_level
@id int as 
begin
    select level from view_student_by_level where id = @id
end

go
exec get_student_level 1018
