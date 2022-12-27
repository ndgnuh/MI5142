go
create or alter view view_register as
select
    takes.id,
    takes.course_id,
    section.room_number,
    section.building,
    section.time_slot_id,
    takes.year,
    takes.semester,
    takes.sec_id
from takes inner join section on takes.course_id = section.course_id 
    and takes.sec_id = section.sec_id
    and takes.semester = section.semester
    and takes.year = section.year
    
go
select * from view_register

go
create or alter procedure sp_register
  @id varchar(5),
  @course_id varchar(8),
  @building varchar(15),
  @room_number varchar(7),
  @time_slot_id varchar(4),
  @year numeric,
  @semester varchar(6)
as
begin
    declare @sec_id varchar(8)
    (select @sec_id = sec_id from section where 
        building = @building and
        room_number = @room_number and
        time_slot_id = @time_slot_id and
        year = @year and
        semester = @semester)
    
    begin transaction txn
    
        
    if not exists(select id from student where id = @id)
    begin
        raiserror('bad student id', 15, 1)
        rollback tran txn
    end
    else if not exists(select course_id from course where course_id = @course_id)
    begin
        raiserror('bad course id', 15, 1)
        rollback tran txn
    end
    else if not exists(select sec_id from section where 
        building = @building and
        room_number = @room_number and
        time_slot_id = @time_slot_id and
        year = @year and
        semester = @semester)
    begin
        raiserror('bad class time', 15, 1)
        rollback tran txn
    end
    else begin
        insert into takes
            (id, course_id, year, semester, sec_id) 
        values
            (@id, @course_id, @year, @semester, @sec_id)
        commit
    end
end

GO
create or alter trigger maximum_student_registered on takes
after insert 
as begin
    declare @cap int;
    declare @building varchar(15);
    declare @sec_id int;
    declare @course_id @course_id varchar(8);
    declare @semester @semester varchar(6);
    declare @year int;
    declare @cnt int;
    declare @room_number varchar(7);
    declare @time_slot_id varchar(4);
  
    
    -- get info
    -- select
    --     @sec_id = sec_id,
    --     @course_id = course_id,
    --     @semester = semester,
    --     @year = year
    -- from inserted
    
    -- -- get building
    -- select top 1 @building = building from section 
    -- where sec_id = @sec_id 
    --     and course_id = @course_id
    --     and semester = @semester
    --     and year = @year
    
        
    -- --  get current capacity
    -- select @cnt = count(id) from takes
    -- where sec_id = @sec_id 
    --     and course_id = @course_id
    --     and semester = @semester
    --     and year = @year
    
    -- -- find room max capacity
    -- select @cap = capacity from classroom where building = @building
    
    -- -- check caps
    -- if (@cnt > @cap)
    -- begin
    --     raiserror('Phòng quá sức chứa', 1, 1)
    --     rollback transaction;  
    -- end
    -- return ;
end


go
-- drop trigger maximum_student_registered
--   @id varchar(5),
--   @course_id varchar(8),
--   @building varchar(15),
--   @room_number varchar(7),
--   @time_slot_id varchar(4),
--   @year numeric,
--   @semester varchar(6)
exec sp_register '10012320', '200', 'Saucon', '180', 'D', '2007', 'Spring'
