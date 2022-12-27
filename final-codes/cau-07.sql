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
select * from view_student_by_level
