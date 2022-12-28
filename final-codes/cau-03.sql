go
create or alter procedure sp_loc_du_lieu2 
@tbl varchar(50)
as 
begin
    declare @conditions TABLE (field_name nvarchar(50), value nvarchar(50))
    declare @sql varchar(500);
    declare @condition varchar(500)
    
    -- create condition string
    set @sql = concat('select * from ', @tbl);
    insert into @conditions exec(@sql)
    select 
        @condition = coalesce(
            @condition + ' AND ' + concat(field_name, '=', '''', value, ''''), 
            concat('and ', field_name, '=', '''', value, '''')) 
    from @conditions
    
    -- filter
    -- print(@condition)
    set @sql = concat('select * from VIEW_LOC_DU_LIEU where 1=1 ', @condition)
    print (@sql)
    exec(@sql)
end

go
drop table if exists conditions
create table conditions (field_name nvarchar(50), value nvarchar(50))
insert into conditions values ('student', 'colin')
insert into conditions values ('instructor', 'Dale')
insert into conditions values ('roomt', '134')

exec sp_loc_du_lieu2 conditions
drop table conditions
