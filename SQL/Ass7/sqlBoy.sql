CREATE FUNCTION dbo.GetGradePoint
(@NumericGrade smallmoney)
RETURNS smallmoney

-- Function: dbo.GetGradePoint
-- This takes a students grade from 0-100 and returns the grade points
-- that the student recieves. It does nothing about the +/- scale,
-- working strictly on A/B/C/D/F. each student recieves one grade
-- point for each letter grade.
-- Created by Timothy Schwieg, Economics Department, UCF
-- Last Modified: 31 Feb 2024

AS

BEGIN
DECLARE @GradePoint int

IF( @NumericGrade >= 90.0 )
SET @GradePoint = 4
ELSE IF( @NumericGrade >= 80.0)
SET @GradePoint = 3
ELSE IF( @NumericGrade >= 70.0)
SET @GradePoint = 2
ELSE IF( @NumericGrade >= 60.0)
SET @GradePoint = 1
ELSE
SET @GradePoint = 0
RETURN (@GradePoint) 

END




CREATE PROCEDURE up_Read_Grades
/**********************************************************
SP: up_Read_Grades
Lists the Grades and course name for each student as well as returning
the students GPA. This takes the Student ID as an input.
Created by Timothy Schwieg, Economics Department, UCF
Last Modified: 31 Feb 2024
**********************************************************/

@StudentID int
AS
DECLARE @TermID int

--We want the report for the current semester, we are assuming that
--that is the maximum of the TermIDs. There isn't really another way
--without passing it as a paramter which is not implied by Dr. West's
--resposnes.

SET @TermID = (SELECT MAX(Term.TermID)
                  FROM Term);

SELECT Course.Name, Enroll.Grade, Course.CreditHours, Term.Term, Term.Year,
   SUM(dbo.GetGradePoint(Enroll.Grade) * Course.CreditHours) / (SUM(CreditHours) * 100.0) AS SemGPA,
   (SUM(dbo.GetGradePoint(Enroll.Grade) * Course.CreditHours) / (SUM(CreditHours) * 100.0) 
       FROM Enroll, Course, Section
       WHERE Enroll.StudentID = @StudentID
          AND Enroll.SectionID = Section.SectionID
          AND Section.CourseID = Course.CourseID) AS FullGPA
FROM Enroll, Course, Section, Term
WHERE Enroll.StudentID = @StudentID
   AND Enroll.SectionID = Section.SectionID
   AND Section.CourseID = Course.CourseID
   AND Section.TermID = @TermID
   AND Term.TermID = @TermID;
