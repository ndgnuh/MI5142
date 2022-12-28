go
create or alter view view_student_by_qualification
as
select
    *,
    (case
        when cpa >= 3.6 then 'Excellent'
        when cpa >= 3.2 then 'Very good'
        when cpa >= 2.5 then 'Good'
        when cpa >= 2 then 'Average'
        when cpa >= 1 then 'Weak'
        else 'Very weak'
    end) as qualification
from view_cpa

go
create or alter function get_student_qualification(@id int)
returns varchar(10) as
begin
    declare @qual varchar(10)
    select @qual = qualification from view_student_by_qualification where id = @id
    return @qual
end

go
print dbo.get_student_qualification(1018)
