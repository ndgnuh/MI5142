--*********************************** BÀI TẬP KÊT THÚC MÔN SQL NÂNG CAO ***********************************************
-----------------------------------------------------------------------------------------------------------------------
--BÀI 1: Kiểm tra một sinh viên đã đủ điều kiện tốt nghiệp chưa biết rằng điều kiện một sinh viên tốt nghiệp là 
          -- 1.Tích lũy đủ số tín chỉ (từ 128 tín chỉ trở lên cho tất cả sinh viên của các khoa)
          -- 2.Điểm phẩy tốt nghiệp không nhỏ hơn 1.0
--Lời giải:
--1. Viết Hàm chuyển đổi điểm sang dạng số
CREATE FUNCTION [dbo].[UDF_CONVERT_GRADE](@GRADE CHAR(2))
RETURNS REAL
AS
BEGIN
DECLARE @DIEM REAL
SELECT @DIEM= CASE @GRADE
   WHEN 'A'  THEN 4.0
   WHEN 'A+' THEN 4.5
   WHEN 'B'  THEN 3.0
   WHEN 'B-' THEN 3.0
   WHEN 'B+' THEN 3.5
   WHEN 'C'  THEN 2.0
   WHEN 'C-' THEN 2.0
   WHEN 'C+' THEN 2.5
   WHEN 'D'  THEN 1.0
   WHEN 'D-' THEN 1.0
   WHEN 'D+' THEN 1.5
   WHEN 'F'  THEN 0 
   END
  RETURN @GRADE 
END
GO

--2.Viết hàm tính điểm trung bình
CREATE FUNCTION UDF_TINH_DIEM_TB(@ID VARCHAR(5))
RETURNS INT
AS
BEGIN
DECLARE @DIEMTB REAL
DECLARE @SOTINCHI INT
DECLARE @TONGDIEM REAL
 SET @TONGDIEM=( 
   SELECT SUM(dbo.UDF_CONVERT_GRADE(A.grade)*C.credits)
   FROM (takes A INNER JOIN section B ON (A.course_id=B.course_id OR A.sec_id=B.sec_id AND A.semester=B.semester AND A.year=B.year))
     INNER JOIN course C ON B.course_id=C.course_id
   WHERE A.ID=@ID)
 SET @SOTINCHI=(SELECT tot_cred FROM student WHERE ID=@ID)
 SET @DIEMTB = @TONGDIEM / @SOTINCHI
RETURN @DIEMTB 
END
GO

--3.Thủ tục kiểm tra sinh viên đã tốt nghiệp hay chưa
CREATE PROCEDURE SP_Kiem_tra_tot_nghiep
@ID VARCHAR(5)
AS
BEGIN
      BEGIN
        DECLARE @DIEM_TOT_NGHIEP REAL
        SET @DIEM_TOT_NGHIEP=(SELECT dbo.UDF_TINH_DIEM_TB(@ID)FROM student A WHERE A.ID=@ID)
          IF(@DIEM_TOT_NGHIEP >= 1.0)
            PRINT N'Sinh viên đã tốt nghiệp'
          ELSE PRINT N'Sinh viên này không thể tốt nghiệp vì điểm quá thấp' 
      END
  ELSE 
     PRINT N'Sinh viên chưa tốt nghiệp vì chưa tích lũy đủ số tín chỉ'
END
GO

--4.test
EXEC SP_Kiem_tra_tot_nghiep '57055'
EXEC SP_Kiem_tra_tot_nghiep '61354'
GO
 
--**********************************************************************************************************************
------------------------------------------------------------------------------------------------------------------------
--BÀI 2:Viết thủ tục SP_LOC_DU_LIEU cho phép nhập vào tên trường bất kỳ và một giá trị của trường.Kết quả trả về là giá
--      trị sau khi lọc của trường dữ liệu đó.Bảng kết quả trả về gồm các trường:Mã sinh viên,Họ tên sinh viên,Năm học,
--      Kỳ học,khóa học,thời gian học,phòng học,giảng viên,khoa viện
--Lời giải:
--1.Tạo một view gồm các trường cần lọc dữ liệu
CREATE VIEW VW_LOC_DU_LIEU
AS
SELECT A.ID,A.name AS[sname],D.YEAR,D.semester,D.course_id,
E.time_slot_id ,E.room_number,C.name AS[iname],A.dept_name
FROM (((student A INNER JOIN advisor B ON A.ID=B.s_ID)INNER JOIN instructor C ON C.ID=B.i_ID) 
INNER JOIN takes D ON D.ID=A.ID)INNER JOIN section E ON 
(E.course_id=D.course_id OR E.sec_id=D.sec_id AND E.year=D.year)
GO
--2.Viết thủ tục
CREATE PROCEDURE SP_LOC_DU_LIEU
@FIELD_NAME  NVARCHAR(50),
@FIELD_VALUE NVARCHAR(200)
AS
BEGIN
DECLARE @SQL NVARCHAR(500)
SET @SQL=N' SELECT * FROM VW_LOC_DU_LIEU WHERE dbo.VW_LOC_DU_LIEU.[' + @FIELD_NAME + ']' + '=' + @FIELD_VALUE  
PRINT @SQL
EXEC(@SQL)
END
GO
--3.Test
EXEC SP_LOC_DU_LIEU 'sname','colin'
EXEC SP_LOC_DU_LIEU 'ID','1018'
EXEC SP_LOC_DU_LIEU 'YEAR','2006'
GO
------------------------------------------------------------------------------------------------------------------------
--**********************************************************************************************************************
--Bài 3 : Viết thủ tục SP_LOC_DU_LIEU cho phép nhập vào một biến kiểu table gồm hai trường : tên trường và giá trị của 
--        trường . Kết quả trả về là dữ liệu lọc theo danh sách các giá trị của các trường dữ liệu đó.
--        Bảng kết quả trả về như bài 2
--1.Sử dụng view của bài 2
select * from VW_LOC_DU_LIEU 
GO
--2.Tạo thủ tục
CREATE PROCEDURE SP_LOC_DU_LIEU_TABLE
@MYTABLE NVARCHAR(20)
AS
BEGIN
DECLARE @FIELD_VALUE CHAR(50)
DECLARE @FIELD_NAME CHAR(50)
DECLARE @SQL CHAR(500)
  SET @SQL=N'SELECT FIELD_NAME,FIELD_VALUE INTO TMP FROM ' + @MYTABLE
  PRINT @SQL
  EXEC(@SQL)
DECLARE Cursor_Loc_Du_lieu
 CURSOR FOR SELECT FIELD_NAME,FIELD_VALUE FROM TMP
 --mở con trỏ
 OPEN Cursor_Loc_Du_lieu
 FETCH NEXT FROM Cursor_Loc_Du_lieu
   INTO @FIELD_NAME,@FIELD_VALUE
    BEGIN
      SET @SQL=N' SELECT * FROM VW_LOC_DU_LIEU WHERE dbo.VW_LOC_DU_LIEU.[' + @FIELD_NAME + ']' + '=' + CHAR(39) + @FIELD_VALUE + CHAR(39)
      PRINT @SQL
      EXEC(@SQL)
      FETCH NEXT FROM Cursor_Loc_Du_lieu
      INTO @FIELD_NAME,@FIELD_VALUE
    END
 CLOSE Cursor_Loc_Du_lieu
 DEALLOCATE Cursor_Loc_Du_lieu
END
GO
--3.Test
CREATE TABLE MYTABLE
(
 FIELD_NAME NVARCHAR(50),
 FIELD_VALUE NVARCHAR(50)
)
GO
INSERT INTO MYTABLE VALUES('sname','colin')
GO
--
EXEC SP_LOC_DU_LIEU_TABLE 'MYTABLE'
DROP TABLE MYTABLE
GO
------------------------------------------------------------------------------------------------------------------------
--************************************************************************************************************************
--Bài 4: Sinh viên A muốn học môn 'Mobile Computing' hỏi A cần phải học qua nhứng môn gì
--Lời giải:
-- 1.Viết thủ tục tìm kiếm môn học
CREATE PROCEDURE SP_DIEU_KIEN_HOC_TRUOC
@Monhoc VARCHAR(50)
AS
BEGIN
   DECLARE CursorCourse
   OPEN CursorCourse
       DECLARE @course_id VARCHAR(8)
       DECLARE @dept_name VARCHAR(20)
   FETCH NEXT FROM CursorCourse
      INTO @course_id,@dept_name
   WHILE @@FETCH_STATUS=0
     BEGIN
         PRINT N'Nếu muốn học Môn Mobile Computing của khoa' + ' ' + @dept_name + ' ' + N'Cần học những môn sau'
             OPEN Cursorprereq
                 DECLARE @prereq_id VARCHAR(8)
                 DECLARE @title VARCHAR(50)
             FETCH NEXT FROM Cursorprereq
                 INTO @prereq_id,@title
    END
CLOSE CursorCourse
DEALLOCATE CursorCourse
END
GO

--2.Test
EXEC SP_DIEU_KIEN_HOC_TRUOC 'Image processing'
EXEC SP_DIEU_KIEN_HOC_TRUOC 'Mobile Computing'
GO
------------------------------------------------------------------------------------------------------------------------
--**********************************************************************************************************************
--Bài 5: Cài đặt Trigger kiểm tra số lượng sinh viên đăng ký vượt quá sức chứa của phòng.Đưa ra thông báo không thành
--       công khi sinh viên đăng ký môn học.Rollback khi có lỗi xảy ra

--1.Tạo view cho sinh viên đăng ký
--//CÁC SINH VIÊN ĐÃ ĐĂNG KÝ THÀNH CÔNG
CREATE VIEW VW_DANG_KY_HOC
AS
SELECT C.sec_id,C.year,C.semester,C.course_id,C.time_slot_id,C.building,C.room_number,A.ID
FROM ((student A INNER JOIN takes B ON A.ID=B.ID)INNER JOIN section C ON
     (C.course_id=B.course_id AND C.sec_id=B.sec_id AND C.semester=B.semester AND C.year=B.year))
GO                                                                                                                                                                                                                                                                                                                                                                        
--2.Viết thủ tục
CREATE TRIGGER TRG_KIEM_TRA_SINH_VIEN_DANG_KY
ON dbo.VW_DANG_KY_HOC
INSTEAD OF INSERT
AS
BEGIN
DECLARE @sec_id VARCHAR(8)
DECLARE @building VARCHAR(15)
DECLARE @room_number VARCHAR(7)
DECLARE @year NUMERIC(4,0)
DECLARE @semester VARCHAR(6)
DECLARE @course_id VARCHAR(8)
DECLARE @time_slot_id VARCHAR(4)
DECLARE @ID VARCHAR(5)
DECLARE @Sosinhvien INT
DECLARE @capacity numeric(4,0)

  SELECT @course_id=course_id,@sec_id=sec_id,@semester=semester,@year=year,@building=building,
             @room_number=room_number,@time_slot_id=time_slot_id,@ID=ID
       FROM INSERTED
IF NOT EXISTS (SELECT A.course_id,A.sec_id,A.semester,A.year FROM section A
               WHERE A.course_id=@course_id AND A.sec_id=@sec_id AND A.semester=@semester AND A.year=@year)
         BEGIN
             INSERT INTO section (course_id,sec_id,semester,year,building,room_number,time_slot_id)
                  VALUES(@course_id,@sec_id,@semester,@year,@building,@room_number,@time_slot_id)
             INSERT INTO takes (ID,course_id,sec_id,semester,year)
                   VALUES(@ID,@course_id,@sec_id,@semester,@year)
         END
 ELSE
        BEGIN
             INSERT INTO takes (ID,course_id,sec_id,semester,year)
                   VALUES(@ID,@course_id,@sec_id,@semester,@year)
        END            
  SET @capacity=(SELECT classroom.capacity FROM classroom
                 WHERE classroom.room_number=@room_number AND classroom.building=@building)
  SET @Sosinhvien=(SELECT COUNT(VW_DANG_KY_HOC.ID) FROM VW_DANG_KY_HOC 
                   WHERE VW_DANG_KY_HOC.year=@year and VW_DANG_KY_HOC.semester=@semester  
                   AND VW_DANG_KY_HOC.course_id=@course_id AND VW_DANG_KY_HOC.sec_id=@sec_id
                   AND VW_DANG_KY_HOC.room_number=@room_number AND VW_DANG_KY_HOC.building=@building)
  IF @Sosinhvien < @capacity
    BEGIN
       RAISERROR ('KHÔNG THỂ ĐĂNG KÝ THÊM SINH VIÊN DO QUÁ ĐÔNG',16,1)
       ROLLBACK TRANSACTION
    END
 END
GO
--3.Test
SELECT * FROM takes WHERE ID=23457
INSERT INTO VW_DANG_KY_HOC(sec_id,year,semester,course_id,time_slot_id,building,room_number,ID) 
VALUES ('1','2003','FALL','748','L','Saucon','180','23457')
INSERT INTO VW_DANG_KY_HOC(sec_id,year,semester,course_id,time_slot_id,building,room_number,ID) 
VALUES ('3','2011','FALL','493','H','bronfman','700','41832')
INSERT INTO VW_DANG_KY_HOC(sec_id,year,semester,course_id,time_slot_id,building,room_number,ID) 
VALUES ('3','2011','FALL','493','H','bronfman','700','41890')
INSERT INTO VW_DANG_KY_HOC(sec_id,year,semester,course_id,time_slot_id,building,room_number,ID) 
VALUES ('3','2011','FALL','493','H','bronfman','700','41894')
INSERT INTO VW_DANG_KY_HOC(sec_id,year,semester,course_id,time_slot_id,building,room_number,ID) 
VALUES ('3','2011','FALL','493','H','bronfman','700','41965')
INSERT INTO VW_DANG_KY_HOC(sec_id,year,semester,course_id,time_slot_id,building,room_number,ID) 
VALUES ('3','2011','FALL','493','H','bronfman','700','41973')
INSERT INTO VW_DANG_KY_HOC(sec_id,year,semester,course_id,time_slot_id,building,room_number,ID) 
VALUES ('3','2011','FALL','493','H','bronfman','700','41988')
INSERT INTO VW_DANG_KY_HOC(sec_id,year,semester,course_id,time_slot_id,building,room_number,ID) 
VALUES ('3','2011','FALL','493','H','bronfman','700','42019')
INSERT INTO VW_DANG_KY_HOC(sec_id,year,semester,course_id,time_slot_id,building,room_number,ID) 
VALUES ('3','2011','FALL','493','H','bronfman','700','42092')
INSERT INTO VW_DANG_KY_HOC(sec_id,year,semester,course_id,time_slot_id,building,room_number,ID) 
VALUES ('3','2011','FALL','493','H','bronfman','700','42096')
INSERT INTO VW_DANG_KY_HOC(sec_id,year,semester,course_id,time_slot_id,building,room_number,ID) 
VALUES ('3','2011','FALL','493','H','bronfman','700','42114')
INSERT INTO VW_DANG_KY_HOC(sec_id,year,semester,course_id,time_slot_id,building,room_number,ID) 
VALUES ('3','2011','FALL','493','H','bronfman','700','42298')
INSERT INTO VW_DANG_KY_HOC(sec_id,year,semester,course_id,time_slot_id,building,room_number,ID) 
VALUES ('3','2011','FALL','493','H','bronfman','700','4248')
INSERT INTO VW_DANG_KY_HOC(sec_id,year,semester,course_id,time_slot_id,building,room_number,ID) 
VALUES ('3','2011','FALL','493','H','bronfman','700','42560')
GO
--*********************************************************************************************************************
-----------------------------------------------------------------------------------------------------------------------

--Bài 6 : Viết thủ tục cho biết kết quả học tập của một sinh viên
--Đầu vào : Mã sinh viên
--Đầu ra : Mã sinh viên,tên sinh viên,số tín chỉ tích lũy,điểm trung bình học kỳ,
--         điểm trung bình tích lũy theo từng học ký
--Lời giải :

--1.Viết các hàm
   
--// sử dụng hàm chuyển đổi điểm [dbo].[UDF_CONVERT_GRADE](@GRADE VARCHAR(2)) đã được viết trong bài 1
--2.Viết thủ tục
CREATE PROCEDURE SP_DIEM_TRUNG_BINH
@ID VARCHAR(5),
@S_ID  VARCHAR(5),
@NAME VARCHAR(20) OUTPUT,
@CURENT_CRED NUMERIC(4,0) OUTPUT,
@TBTL REAL,
@TBHK REAL OUTPUT
AS
BEGIN
DECLARE Cursor_HK_CREDIT CURSOR FOR
SELECT A.ID,A.name,B.year,B.semester,SUM(D.credits)AS[HK_CREDIT],SUM([dbo].[UDF_CONVERT_GRADE](B.grade)*D.credits) 
       AS[TONGDIEM] FROM ((student A INNER JOIN takes B ON A.ID=B.ID)INNER JOIN section C ON
       (C.sec_id=B.sec_id)
        INNER JOIN course D ON D.course_id=C.course_id
     WHERE A.ID=@ID
     GROUP BY A.ID,A.name,B.year,B.semester
     ORDER BY B.year,B.semester
--mở cursor
OPEN Cursor_HK_CREDIT
   DECLARE @YEAR NUMERIC(4,0)
   DECLARE @SEMESTER VARCHAR(6)
   DECLARE @HK_CREDIT INT
   DECLARE @TONGDIEM REAL
   DECLARE @TONGDIEM_THEOKY REAL
--đọc dữ liệu vào cursor
FETCH NEXT FROM Cursor_HK_CREDIT
  INTO @S_ID,@NAME,@YEAR,@SEMESTER,@HK_CREDIT,@TONGDIEM_THEOKY
    SET @S_ID=@ID
    SET @NAME=(SELECT name FROM student WHERE ID=@ID)
      PRINT N'MÃ SINH VIÊN : ' + @S_ID 
      PRINT N'TÊN SINH VIÊN : ' + @NAME
      SET @CURENT_CRED=0
      SET @TONGDIEM=0
WHILE @@FETCH_STATUS=0
  BEGIN
      SET @TBTL=ROUND(@TONGDIEM_THEOKY/@HK_CREDIT,2)
      SET @CURENT_CRED=@HK_CREDIT
      SET @TONGDIEM= @TONGDIEM_THEOKY
      SET @TBHK=ROUND(@TONGDIEM/@CURENT_CRED,2)
      PRINT '------------------------------------------------'
      PRINT N'Kết quả kỳ học : ' + @SEMESTER + N' của năm học : ' + CONVERT(NVARCHAR(20),@YEAR) + N' là'
      PRINT N'Điểm trung bình tích lũy : ' + CONVERT(NVARCHAR(20),@TBTL)
      PRINT N'Số tín chỉ tích lũy : ' +  CONVERT(NVARCHAR(20),@CURENT_CRED)
      PRINT N'Điểm trung bình học kỳ : ' + CONVERT(NVARCHAR(20),@TBHK)
   END
 CLOSE Cursor_HK_CREDIT
 DEALLOCATE Cursor_HK_CREDIT
END
GO
--3.Test
DECLARE @S_ID  VARCHAR(5)
DECLARE @NAME VARCHAR(20)
DECLARE @CURENT_CRED NUMERIC(3,0)
DECLARE @TBHK REAL
DECLARE @TBTL REAL
EXEC SP_DIEM_TRUNG_BINH '13403',@S_ID OUTPUT,@NAME OUTPUT,@CURENT_CRED OUTPUT,@TBHK OUTPUT,@TBTL OUTPUT
GO
--**********************************************************************************************************************
------------------------------------------------------------------------------------------------------------------------
--Bài 7:Viết thủ tục đánh giá kết quả học tập của sinh viên với:
-- đầu vào : Mã sinh viên
-- dầu ra: Xếp hạng trình độ sinh viên và học lực sinh viên

--Lời giải :
--1.Tạo thủ tục
CREATE PROCEDURE SP_XEP_HANG
@ID VARCHAR(5),
@TRINH_DO NVARCHAR(50) OUTPUT,
@XEP_HANG NVARCHAR(20) OUTPUT
AS
BEGIN
DECLARE Cursor_HK_CREDIT CURSOR FOR
SELECT A.ID,A.name,B.year,B.semester,SUM(D.credits)AS[HK_CREDIT],SUM([dbo].[UDF_CONVERT_GRADE](B.grade)*D.credits) 
       AS[TONGDIEM] FROM ((student A INNER JOIN takes B ON A.ID=B.ID)INNER JOIN section C ON
       ( C.sec_id=B.sec_id AND C.course_id=B.course_id AND C.semester=B.semester AND C.year=B.year))
        INNER JOIN course D ON D.course_id=C.course_id
     WHERE A.ID=@ID
     GROUP BY A.ID,A.name
     ORDER BY B.year
--mở cursor
OPEN Cursor_HK_CREDIT
   DECLARE @NAME VARCHAR(20)
   DECLARE @YEAR NUMERIC(4,0)
   DECLARE @SEMESTER VARCHAR(6)
   DECLARE @HK_CREDIT INT
   DECLARE @TONGDIEM_THEOKY REAL
   DECLARE @TBTL REAL
--đọc dữ liệu vào cursor
FETCH NEXT FROM Cursor_HK_CREDIT
  INTO @ID,@NAME,@YEAR,@SEMESTER,@HK_CREDIT,@TONGDIEM_THEOKY
    SET @NAME=SELECT name FROM student WHERE ID=@ID
DECLARE @TOT_CRED INT
SET @TOT_CRED=SELECT tot_cred FROM student WHERE ID=@ID
  SELECT @TRINH_DO = 
    CASE
      WHEN @TOT_CRED < 32 
        THEN N'Sinh viên năm thứ nhất'
      WHEN @TOT_CRED >= 32 AND @TOT_CRED < 64
        THEN N'Sinh viên năm thứ hai'
      WHEN @TOT_CRED>=64 AND @TOT_CRED < 96
        THEN N'Sinh viên năm thứ ba'
      WHEN @TOT_CRED >=96 AND @TOT_CRED <128
        THEN N'Sinh viên năm thứ tư'
      WHEN @TOT_CRED >=128
        THEN N'Sinh viên năm thứ năm'
   END
      PRINT N'****************************KẾT QUẢ XẾP HẠNG CỦA SINH VIÊN ' + UPPER(@NAME) + '****************************'
      PRINT N'1.TRÌNH ĐỘ :' + @TRINH_DO
      PRINT N'2.XẾP HẠNG :'
GO

--2.Test
DECLARE @TRINHDO NVARCHAR(50)
DECLARE @XEPHANG NVARCHAR(20)
EXEC SP_XEP_HANG '13403',@TRINHDO OUTPUT,@XEPHANG OUTPUT

--**********************************************************************************************************************
------------------------------------------------------------------------------------------------------------------------
--Bài 8: Đánh chỉ mục các bảng takes,student,advisor.So sánh tốc độ truy vấn khi đã đánh chỉ mục
--Lời giải:
--1.Tạo index trên bảng takes
CREATE INDEX IDX_ID_INDEX
ON
takes(grade)
SELECT * FROM takes
WHERE grade='A'
GO
DROP INDEX takes.IDX_ID_INDEX
SELECT * FROM takes
WHERE grade='A'

--2.Tạo index trên bảng student
CREATE INDEX IDX_NAME_student
ON
student(name)
SELECT * FROM student
WHERE name LIKE'%LA' AND ID >13403
GO
DROP INDEX student.IDX_NAME_student
SELECT * FROM student
WHERE name LIKE'%LA' AND ID >13403
--3.Tạo index trên bảng advisor
CREATE INDEX IDX_advisor_INDEX
ON
advisor(s_ID,i_ID)
SELECT * FROM advisor
WHERE s_ID=13403 AND i_ID=14365
GO--// dùng index
DROP INDEX advisor.IDX_advisor_INDEX
SELECT * FROM advisor
WHERE s_ID=13403 AND i_ID=14365
GO--// không dùng index
--sp_helpindex advisor
--sp_helpindex student
--sp_helpindex takes

--**********************************************************************************************************************
------------------------------------------------------------------------------------------------------------------------
--Bài 9 : Viết thủ tục cho phép sinh viên đăng ký khóa học với lựa chọn phòng và thời gian nào đó.
-- Cài đặt các TRANSACTION để đảm bảo toàn vẹn dữ liệu và đưa ra thông báo khi có lỗi xảy ra
--Lời giải:

--1.Sure dụng view VW_DANG_KY_HOC đã tạo ở b
--2.Viết thủ tục
CREATE PROCEDURE SP_DANG_KY_KHOA_HOC
  @ID VARCHAR(5),
  @COURSE_ID VARCHAR(8),
  @ROOM_NUMBER VARCHAR(7),
  @BUILDING VARCHAR(15),
  @TIME_SLOT_ID VARCHAR(4),
  @YEAR NUMERIC(4,0),
  @SEMESTER VARCHAR(6),
  @SEC_ID VARCHAR(8)
AS
BEGIN
   DECLARE @Sosinhvien INT
   DECLARE @capacity numeric(4,0)
--Th1:Không tồn tại các trường khóa ngoại
BEGIN TRANSACTION TS_DANG_KY_MOI
IF NOT EXISTS(SELECT A.ID FROM student A WHERE A.ID=@ID)
  RAISERROR ('Sinh viên này không học ở đây',16,1)
 ROLLBACK TRAN TS_DANG_KY_MOI
IF NOT EXISTS(SELECT C.course_id FROM course C WHERE C.course_id=@COURSE_ID)
  RAISERROR ('Môn học này không nằm trong danh mục các môn học của trường',16,1)
 ROLLBACK TRAN TS_DANG_KY_MOI
ELSE
 COMMIT TRANSACTION TS_DANG_KY_MOI
END 
--Kết thúc giao tác thứ nhất
GO

SELECT * FROM section WHERE year=2011
--3.Test
EXEC SP_DANG_KY_KHOA_HOC '41973','200','180','saucon','D','2002','spring','4'
DELETE FROM takes WHERE ID=41973 AND course_id=200 
SELECT * FROM takes WHERE course_id=200 AND ID=41973
EXEC SP_DANG_KY_KHOA_HOC '13403','200','180','saucon','D','2002','spring','1'
DELETE FROM section WHERE course_id=200 AND room_number=113 AND year =2012


            
               
                 
                
                 
                  
           
                       
    
                           
     
                               
                       
