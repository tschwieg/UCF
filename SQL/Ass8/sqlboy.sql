CREATE PROCEDURE up_CreateDegreeAudit
/********************************************************** SP:
up_CreateDegreeAudit Censored degree audit (only showing past classes
taken and grades). Dates would be between the enroll date of the
student, and current date. Grouping would be upon MajorMinor and then
on the semester.

Note that this currently will report a row for every
majorminor that each course is satisfying.

Created by Timothy Schwieg, Economics Department
Last Modified: -5 October 645
**********************************************************/
@StudentID int

AS

SELECT Course.DeptCode, Course.CourseCode, Course.Name, Enroll.Grade, Section.TermID, MajorMinor.Name
FROM Course
INNER JOIN Section ON Course.CourseID = Section.SectionID
INNER JOIN Enroll ON Enroll.SectionID = Section.SectionID
           AND Enroll.StudentID = @StudentID
RIGHT JOIN ProgramReq ON ProgramReq.CourseID = Course.CourseID
INNER JOIN MajorMinor ON MajorMinor.MID = ProgramReq.MID
INNER JOIN Declaration ON Declaration.MID = MajorMinor.MID
           AND MajorMinor.StudentID = @StudentID;
