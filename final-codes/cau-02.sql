go
create or alter view view_loc_du_lieu as
select
student.id as student_id,
student.name as student,
section.year,
section.semester,
course.title as course,
concat(
   time_slot.start_hr, ':', time_slot.start_min,'-',
   time_slot.end_hr, ':', time_slot.end_min
) as time,
classroom.room_number as room,
instructor.name as instructor,
course.dept_name
from student
inner join takes on student.id = takes.id
inner join section on section.sec_id = takes.sec_id -- info
inner join course on section.course_id = course.course_id
inner join teaches on section.course_id = teaches.course_id
inner join instructor on teaches.id = instructor.id
inner join classroom on section.building = classroom.building
inner join time_slot on section.time_slot_id = time_slot.time_slot_id

go
create procedure sp_loc_du_lieu
@query nvarchar(50), @value nvarchar(50) as
begin
   declare @sql nvarchar(100);
   set @sql = concat(
      'select * from view_loc_du_lieu where ',
      @query, ' = ',
      '''',
      @value,
      ''''
   );
   print(@sql)
   exec(@sql);
end

go
exec sp_loc_du_lieu 'student', 'colin'
exec sp_loc_du_lieu 'student_id','1018'
exec sp_loc_du_lieu 'year','2006'
