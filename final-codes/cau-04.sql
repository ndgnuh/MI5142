drop function if exists resolve_course_id
drop function if exists search_prereq

go
create function resolve_course_id(@id int) 
returns @deps table (pid int) 
as
begin
    declare @dep_count int;
    
    -- find direct deps
    insert into @deps select prereq_id from prereq where course_id = @id;
    select @dep_count = count(pid) from @deps group by pid
    
    if @dep_count = 0
        return
    else
        declare row_cursor cursor for select pid from @deps;
        declare @pid int;
        
        open row_cursor;
        while @@FETCH_STATUS = 0 begin
            FETCH NEXT FROM row_cursor into @pid
            insert into @deps SELECT * from resolve_course_id(@pid) 
        end
        close row_cursor
        deallocate row_cursor
    return
end

go
create function search_prereq(@title varchar(50))
returns @result table (
    course_id int, 
    title varchar(50),
    dept_name varchar(20),
    credits numeric
)
as begin
    declare @pids table (pid int);
    declare @id int;
    declare id_cursor cursor for
    select course_id from course where title like @title
    
    -- get all pids
    open id_cursor
    while @@FETCH_STATUS = 0 begin
        FETCH NEXT FROM id_cursor into @id
        insert into @pids SELECT * from resolve_course_id(@id)
    end
    close id_cursor
    
    -- insert 
    insert into @result select * from course where course_id in (select pid from @pids)
    return 
end

go
create or alter function get_prereq(@pid int)
returns @result table (
    course_id int, 
    title varchar(50),
    dept_name varchar(20),
    credits numeric
)
as begin
    insert into @result select * from course 
    where course.course_id in (select pid from resolve_course_id(@pid))
    return 
end
go

select * from search_prereq('Game Programming')
select * from get_prereq(359)
select * from get_prereq(774)
