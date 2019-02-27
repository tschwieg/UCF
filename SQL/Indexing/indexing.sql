-- Most frequent Business Event is to assign grades to students.
-- This can take two forms, passing grades to a single student, as identified by
-- their student ID, the grade consisting of Points Earned and a comment
-- Alternatively, the grade and comment could be given to a group, in which case
-- All students need to recieve the same grade

-- Assign Grades: This function takes an assignment and a student and creates an AssnGrade Object
-- Input: I_AssignID, I_StudentID, I_PointsEarned, I_Comment

-- This Provides a grade for a specified student ID
INSERT INTO AssnGrade( EnrollID, AssnID, PointsEarned, Comment)
    SELECT Enroll.EnrollID, I_AssnID, I_PointsEarned, I_Comment
    FROM Enroll,  Assignment
    WHERE Enroll.StudentID = I_StudentID
       AND Enroll.SectionID = Assignment.SecID
       AND Assignment.AssnID = I_AssnID;

-- This Updates the students grade element in Enroll According to the new AssnGrade Created
-- We use a cast here to avoid sql's tendency to want to do integer division. We need our grade to be returned as a decimal
-- Hopefully with solid precision, so we will use the float object
UPDATE Enroll
SET Enroll.Grade = CAST( SUM( AssnGrade.PointsEarned ) AS float ) / SUM( Assignment.PointsPossible)
    FROM Assignment, AssnGrade, Enroll
    WHERE Enroll.StudentID = I_StudentID
       AND AssnGrade.EnrollID = Enroll.EnrollID
       AND Assignment.SecID = Enroll.SectionID
       AND AssnID = Assignment.AssnID;
       
-- This Provides a grade for a specified Group given by its ID
-- Input: I_AssnID, I_GroupID, I_PointsEarned, I_Comment
-- Since Group is unique to a section, once we have the group ID we do not need to check sections
INSERT INTO AssnGrade( EnrollID, AssnID, PointsEarned, Comment)
    SELECT GroupEnroll.EnrollID, I_AssnID, I_PointsEarned, I _Comment
    FROM GroupEnroll
    WHERE GroupEnroll.GroupID = I_GroupID;

UPDATE Enroll
SET Enroll.Grade = CAST( SUM( AssnGrade.PointsEarned ) AS float ) / SUM( Assignment.PointsPossible)
    FROM Assignment, AssnGrade, GroupEnroll, Group
    WHERE Enroll.EnrollID = GroupEnroll.EnrollID
       AND Assignment.SecID = Group.SecID
       AND Group.GroupID = GroupEnroll.GroupID
       AND AssnGrade.EnrollID = GroupEnroll.EnrollID
       AND AssnGrade.AssnID = Assignment.AssnID;


Enroll
EnrollID        ASC    Clustered
StudentID       ASC    NonClustered
SectionID       ASC    NonClustered

Assignment
AssnID          ASC    NonClustered
SecID           ASC    Clustered

GroupEnroll
GroupID         ASC    NonClustered
EnrollID        ASC    Clustered

Group
GroupID         ASC    Clustered
SecID           ASC    NonClustered

