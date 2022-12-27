go
create or alter procedure sp_register
  @id varchar(5),
  @course_id varchar(8),
  @room_number varchar(7),
  @building varchar(15),
  @time_slot_id varchar(4),
  @year numeric,
  @semester varchar(6)
as
begin
    begin transaction txn
    
    if not exists(select sec_id from section where room_number = @room_number and course_id = @course_id and building = @building and time_slot_id = @time_slot_id and year = @year and semester = @semester) begin
        raiserror('no such class', 15, 1)
        rollback tran txn
        return
    end
    
    -- FIND @sec_id
    declare @sec_id varchar(8);
    select @sec_id = sec_id from section where room_number = @room_number and course_id = @course_id and building = @building and time_slot_id = @time_slot_id and year = @year and semester = @semester

    -- CHECK IF ALREADY REGISTERED
    if exists(select id from takes where id = @id and course_id = @course_id and year = @year and semester = @semester) begin
        raiserror('already registered', 15, 1)
        rollback tran txn
        return
    end
        
    -- REGISTER
    insert into takes
        (id, course_id, year, semester, sec_id) 
    values
        (@id, @course_id, @year, @semester, @sec_id)
        
    -- NO SUCH STUDENT
    if not exists(select id from student where id = @id)
    begin
        raiserror('bad student id', 15, 1)
        rollback tran txn
        return
    end
    
    -- NO SUCH COURSE
    else if not exists(select course_id from course where course_id = @course_id)
    begin
        raiserror('bad course id', 15, 1)
        rollback tran txn
        return
    end
    
    -- OK
    commit tran txn
end


exec sp_register '41973', '200', '180', 'Saucon', 'D', '2007', 'Spring'
DELETE FROM takes WHERE ID=41973 AND course_id=200 

go
select * from section where course_id = 313 

