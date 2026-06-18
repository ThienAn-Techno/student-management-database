--Hien thi thong tin hoc sinh kem lop va nam hoc
SELECT 
    s.StudentID,
    s.Name AS StudentName,
    c.ClassName,
    ay.YearName AS AcademicYear
FROM Student s
JOIN Class c 
ON s.ClassID = c.ClassID
JOIN AcademicYear ay 
ON c.AcademicYearID = ay.AcademicYearID;

--Hien thi bang diem chi tiet cua hoc sinh theo mon va hoc ki
SELECT 
    s.Name AS StudentName,
    sub.SubjectName,
    se.SemesterName,
    r.OralScore,
    r.Score15Minutes,
    r.Score1Period,
    r.FinalExamScore
FROM Result r
JOIN Student s 
ON r.StudentID = s.StudentID
JOIN Subject sub 
ON r.SubjectID = sub.SubjectID
JOIN Semester se 
ON r.SemesterID = se.SemesterID

--Tinh diem trung binh mon cua hoc sinh theo hoc ki
SELECT 
    s.Name AS StudentName,
    sub.SubjectName,
    se.SemesterName,
    ROUND(
        r.OralScore * 0.1 +
        r.Score15Minutes * 0.2 +
        r.Score1Period * 0.3 +
        r.FinalExamScore * 0.4
    , 2) AS AverageScore
FROM Result r
JOIN Student s 
ON r.StudentID = s.StudentID
JOIN Subject sub 
ON r.SubjectID = sub.SubjectID
JOIN Semester se 
ON r.SemesterID = se.SemesterID

--Danh sach hoc sinh lop 12 nam 2025-2026
SELECT 
    s.StudentID, s.Name, c.ClassName, ay.YearName
FROM Student s
JOIN Class c 
ON s.ClassID = c.ClassID
JOIN AcademicYear ay 
ON c.AcademicYearID = ay.AcademicYearID
WHERE c.Grade = 12
  AND ay.YearName = '2025-2026';

-- GVCN cua tung lop
SELECT 
    c.ClassName, ay.YearName, t.FullName AS HomeroomTeacher
FROM Class c
JOIN Teacher t 
ON c.TeacherID = t.TeacherID
JOIN AcademicYear ay 
ON c.AcademicYearID = ay.AcademicYearID
ORDER BY ay.YearName, c.ClassName;

--Top 10 hoc sinh co diem mon hoa cao nhat
SELECT TOP 10
    s.StudentID, s.Name, c.ClassName, ROUND( r.OralScore * 0.1 + r.Score15Minutes * 0.2 + r.Score1Period * 0.3 + r.FinalExamScore * 0.4 , 2) AS AverageScore
FROM Result r
JOIN Student s 
ON r.StudentID = s.StudentID
JOIN Class c 
ON s.ClassID = c.ClassID
JOIN Subject sub 
ON r.SubjectID = sub.SubjectID
WHERE sub.SubjectName = 'Chemistry'
ORDER BY AverageScore DESC

--Danh sach giao vien day tung lop theo mon va nam hoc
SELECT
    c.ClassName,
    t.FullName AS TeacherName,
    sub.SubjectName,
    ay.YearName
FROM Teaching teach
JOIN Class c ON teach.ClassID = c.ClassID
JOIN Teacher t ON teach.TeacherID = t.TeacherID
JOIN Subject sub ON teach.SubjectID = sub.SubjectID
JOIN AcademicYear ay ON teach.AcademicYearID = ay.AcademicYearID
ORDER BY ay.YearName, c.ClassName, sub.SubjectName;

--Thong ke so hoc sinh thoe tung lop
SELECT
    c.ClassName,
    c.Grade,
    ay.YearName,
    COUNT(s.StudentID) AS TotalStudents
FROM Class c
LEFT JOIN Student s ON c.ClassID = s.ClassID
JOIN AcademicYear ay ON c.AcademicYearID = ay.AcademicYearID
GROUP BY c.ClassID, c.ClassName, c.Grade, ay.YearName
ORDER BY ay.YearName, c.Grade, c.ClassName;

--Trigger kiem tr diem hop le (0 – 10)
CREATE TRIGGER trg_CheckScore
ON Result
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT *
        FROM inserted
        WHERE OralScore < 0 OR OralScore > 10
           OR Score15Minutes < 0 OR Score15Minutes > 10
           OR Score1Period < 0 OR Score1Period > 10
           OR FinalExamScore < 0 OR FinalExamScore > 10
    )
    BEGIN
        PRINT N'Diem phai nam trong khoan tu 0 den 10'
        ROLLBACK TRANSACTION
    END
END

INSERT INTO Result
VALUES (1,2,1,7,8,9,8);

SELECT *
FROM Result
WHERE StudentID = 1

DELETE FROM Result
WHERE StudentID = 1
AND SubjectID = 2
AND SemesterID = 1;

--Tim hoc sinh co diem trung binh cao nhat lop 
CREATE OR ALTER PROCEDURE sp_TopStudentInClass
    @ClassID INT
AS
BEGIN
    SELECT TOP 1 s.StudentID, s.Name,
           AVG((OralScore + Score15Minutes + Score1Period + FinalExamScore)/4.0) AS AvgScore
    FROM Student s
    JOIN Result r ON s.StudentID = r.StudentID
    WHERE s.ClassID = @ClassID
    GROUP BY s.StudentID, s.Name
    ORDER BY AvgScore DESC
END

EXEC sp_TopStudentInClass 1;

--Cap nhat so dien thoai hoc sinh
-- Update phone number of student with StudentID = 1
UPDATE Student
SET PhoneNumber = '0999999999'
WHERE StudentID = 1;

-- Verify the update
SELECT StudentID, Name, PhoneNumber
FROM Student
WHERE StudentID = 1;

--Function tinh diem trung binh tat ca mon cua hoc sinh
CREATE FUNCTION fn_AvgStudentScore
(
    @StudentID INT
)
RETURNS DECIMAL(4,2)
AS
BEGIN
    DECLARE @AvgScore DECIMAL(4,2)

    SELECT @AvgScore = AVG((OralScore + Score15Minutes + Score1Period + FinalExamScore)/4.0)
    FROM Result
    WHERE StudentID = @StudentID

    RETURN @AvgScore
END

SELECT dbo.fn_AvgStudentScore(5) AS 'AVG_Score'