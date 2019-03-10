SELECT CO.CourseName, CR.grade FROM courseRegistrations CR, CourseOffers CO WHERE CR.StudentID = %1% and CR.degreeId = %2% and CR.grade >= 5 and CR.CourseOfferId = CO.CourseOfferId ORDER BY CO.year, CO.quartile, CO.CourseOfferId;
SELECT 0;
WITH have_not_taken_yet(studentregistrationid, sumECTS) as (SELECT studentregistrationid, 0 FROM (SELECT studentregistrationid FROM studentRegistrationsToDegrees D EXCEPT SELECT studentregistrationid FROM pointsPerS) as new), activeStudents(studentId, DegreeId) as (SELECT SD.StudentId, D.DegreeId FROM pointsPerS as almost, studentRegistrationsToDegrees SD, degrees D WHERE almost.studentregistrationid = sd.studentregistrationid and D.degreeid = SD.DegreeID and D.totalects > almost.sumECTS UNION SELECT SD.studentid, SD.DegreeID FROM studentRegistrationsToDegrees SD, have_not_taken_yet HY WHERE SD.studentregistrationid = HY.studentregistrationid) SELECT A.DegreeId, count(CASE WHEN S.Gender = 'F' THEN 1 END)/count(S.StudentId)::float as femalePercentage FROM Students S, ActiveStudents A WHERE S.StudentId = A.StudentId GROUP BY A.DegreeId ORDER BY A.DegreeId;
SELECT count(CASE WHEN S.Gender = 'F'  THEN 1 END)/count(SR.StudentId)::float as percentageFemale FROM Degrees D, StudentRegistrationsToDegrees SR, Students S WHERE SR.DegreeId = D.DegreeId and S.StudentId = SR.StudentId and D.Dept = %1%;
SELECT CR.CourseId, count(CASE WHEN CR.Grade >= %1% THEN 1 END)/count(CR.Grade)::float as percentagePassing FROM CourseRegistrations CR WHERE CR.Grade IS NOT NULL GROUP BY CR.CourseId ORDER BY CR.CourseId;
WITH HighestGrade(CourseOfferId, Grade) as (SELECT CR.CourseOfferId, max(CR.Grade) FROM CourseRegistrations CR, CourseOffers CO WHERE CR.CourseOfferId = CO.CourseOfferId and CO.year = 2018 and CO.Quartile = 1 GROUP BY CR.CourseOfferId) SELECT CR.studentId, count(CR.StudentId) FROM CourseRegistrations CR, HighestGrade HG WHERE HG.Grade = CR.Grade and CR.CourseOfferId = HG.CourseOfferId GROUP BY CR.StudentId HAVING count(CR.StudentId) >= %1%;
SELECT 0;
WITH studentCountPerCourseOffer(CourseOfferId, countStudentRegistrationId) as (SELECT CourseOfferId, count(StudentRegistrationID) FROM CourseRegistrations CR Group by CR.CourseOfferID), assistantCountPerCourseOffer(CourseOfferId, countStudentRegistrationId) as (SELECT CourseOfferId, count(StudentRegistrationID) FROM StudentAssistants SA Group by SA.CourseOfferID) SELECT C.CourseName, CO.Year, CO.quartile FROM studentCountPerCourseOffer SPR LEFT JOIN assistantCountPerCourseOffer APR ON (SPR.CourseOfferId = APR.CourseOfferId) INNER JOIN CourseOffers CO ON (SPR.CourseOfferId = Co.CourseOfferId), course C WHERE APR.countStudentRegistrationId < ceil(SPR.countStudentRegistrationId/50) and C.courseId = CO.courseId Order by CO.CourseOfferId;
