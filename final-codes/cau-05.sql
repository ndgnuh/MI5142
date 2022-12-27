create or alter trigger maximum_student_registered on takes
after insert 
as begin
    declare @cap int;
    declare @building int;
    declare @sec_id int;
    declare @course_id int;
    declare @semester int;
    declare @year int;
    declare @cnt int;
    
    -- get info
    select
        @sec_id = sec_id,
        @course_id = course_id,
        @semester = semester,
        @year = year
    from inserted
    
    -- get building
    select top 1 @building = building from section 
    where sec_id = @sec_id 
        and course_id = @course_id
        and semester = @semester
        and year = @year
    
        
    --  get current capacity
    select @cnt = count(id) from takes
    where sec_id = @sec_id 
        and course_id = @course_id
        and semester = @semester
        and year = @year
    
    -- find room max capacity
    select @cap = capacity from classroom where building = @building
    
    -- check caps
    if (@cnt > @cap)
    begin
        raiserror('Phòng quá sức chứa', 1, 1)
        rollback transaction;  
    end
    return ;
end
