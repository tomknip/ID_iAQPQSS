SELECT CO.CourseName, CR.grade FROM studentRegistrationsToDegrees SD, courseRegistrations CR, CourseOffers CO WHERE SD.studentRegistrationId = CR.studentRegistrationId and SD.StudentID = %1% and SD.degreeId = %2% and CR.grade >= 5 and CR.grade is not NULL and CR.CourseOfferId = CO.CourseOfferId ORDER BY CO.year, CO.quartile, CO.CourseOfferId;
WITH pointsPerS(studentId, studentregistrationid, GPA) as (SELECT  CR.studentid, CR.studentregistrationid, sum(CR.Grade * C.ECTS)/sum(C.ECTS) FROM courseRegistrations CR, CourseOffers CO, Courses C WHERE CR.CourseOfferId = CO.CourseOfferId And CO.CourseId = C.CourseId and CR.Grade >= 5 GROUP BY CR.studentid, CR.studentregistrationid), studentNoFails(studentRegistrationId) as (SELECT CR.StudentRegistrationID FROM courseRegistrations CR EXCEPT SELECT CR2.StudentRegistrationId FROM CourseRegistrations CR2 WHERE CR2.grade < 5) SELECT distinct P.StudentId FROM pointsPerS P, studentNoFails SNF WHERE P.StudentRegistrationId = SNF.studentRegistrationId and P.GPA > %1% ORDER BY P.studentid;
WITH pointsPerS(studentregistrationid, sumECTS) as (SELECT CR.studentregistrationid, sum(ECTS) FROM courseRegistrations CR, CourseOffers CO, Courses C WHERE CR.CourseOfferId = CO.CourseOfferId And CO.CourseId = C.CourseId and CR.Grade >= 5 GROUP BY CR.studentid, CR.studentregistrationid), have_not_taken_yet(studentregistrationid, sumECTS) as (SELECT studentregistrationid, 0 FROM (SELECT studentregistrationid FROM studentRegistrationsToDegrees D EXCEPT SELECT studentregistrationid FROM pointsPerS) as new), activeStudents(studentId, DegreeId) as (SELECT SD.StudentId, D.DegreeId FROM pointsPerS as almost, studentRegistrationsToDegrees SD, degrees D WHERE almost.studentregistrationid = sd.studentregistrationid and D.degreeid = SD.DegreeID and D.totalects > almost.sumECTS UNION SELECT SD.studentid, SD.DegreeID FROM studentRegistrationsToDegrees SD, have_not_taken_yet HY WHERE SD.studentregistrationid = HY.studentregistrationid) SELECT A.DegreeId, count(CASE WHEN S.Gender = 'F' THEN 1 END)/count(S.StudentId)::float as femalePercentage FROM Students S, ActiveStudents A WHERE S.StudentId = A.StudentId GROUP BY A.DegreeId ORDER BY A.DegreeId; 
SELECT count(CASE WHEN S.Gender = 'F'  THEN 1 END)/count(SR.StudentId)::float as percentageFemale FROM Degrees D, StudentRegistrationsToDegrees SR, Students S WHERE SR.DegreeId = D.DegreeId and S.StudentId = SR.StudentId and D.Dept = %1%;
SELECT CR.CourseId, count(CASE WHEN CR.Grade >= %1% THEN 1 END)/count(CR.Grade)::float as percentagePassing FROM CourseRegistrations CR WHERE CR.Grade IS NOT NULL GROUP BY CR.CourseId ORDER BY CR.CourseId;
WITH HighestGrade(CourseOfferId, Grade) as (SELECT CR.CourseOfferId, max(CR.Grade) FROM CourseRegistrations CR, CourseOffers CO WHERE CR.CourseOfferId = CO.CourseOfferId and CO.year = 2018 and CO.Quartile = 1 GROUP BY CR.CourseOfferId) SELECT CR.studentId, count(CR.StudentId) FROM CourseRegistrations CR, HighestGrade HG WHERE HG.Grade = CR.Grade and CR.CourseOfferId = HG.CourseOfferId GROUP BY CR.StudentId HAVING count(CR.StudentId) >= %1%;
WITH pointsPerS(studentregistrationid, sumECTS, GPA) as (SELECT  CR.studentregistrationid, sum(ECTS), sum(CR.Grade * C.ECTS)/sum(C.ECTS) FROM courseRegistrations CR, CourseOffers CO, Courses C WHERE CR.CourseOfferId = CO.CourseOfferId And CO.CourseId = C.CourseId and CR.Grade >= 5 GROUP BY CR.studentid, CR.studentregistrationid), have_not_taken_yet(studentregistrationid, sumECTS) as (SELECT studentregistrationid, 0 FROM (SELECT studentregistrationid FROM studentRegistrationsToDegrees D EXCEPT SELECT studentregistrationid FROM pointsPerS) as new), activeStudents(studentId, DegreeId) as (SELECT SD.StudentId, D.DegreeId FROM  pointsPerS as almost, studentRegistrationsToDegrees SD, degrees D WHERE almost.studentregistrationid = sd.studentregistrationid and D.degreeid = SD.DegreeID and D.totalects > almost.sumECTS UNION SELECT SD.studentid, SD.DegreeID FROM studentRegistrationsToDegrees SD, have_not_taken_yet HY WHERE SD.studentregistrationid = HY.studentregistrationid) SELECT SR.degreeId, S.birthYearStudent, S.gender, avg(P.GPA) FROM Students S, pointspers P, StudentRegistrationsToDegrees SR, ActiveStudents A WHERE A.StudentId = S.studentId and S.studentId = SR.studentId and P.StudentRegistrationId = SR.studentRegistrationId GROUP BY CUBE (SR.degreeId, S.birthYearStudent, S.gender) ORDER BY SR.degreeId, S.birthYearStudent, S.gender asc;
WITH studenCountPerCourseOffer(CourseOfferId, countStudentRegistartionId) as (SELECT CourseOfferId, count(StudentRegistrationID) FROM CourseRegistrations CR Group by CR.CourseOfferID), assistantCountPerCourseOffer(CourseOfferId, countStudentRegistrationId) as (SELECT CourseOfferId, count(StudentRegistrationID) FROM StudentAssistants SA Group by SA.CourseOfferID) SELECT CO.CourseName, CO.Year, CO.quartile FROM studenCountPerCourseOffer SPR , assistantCountPerCourseOffer APR, CourseOffers CO WHERE SPR.CourseOfferId = APR.CourseOfferId and SPR.CourseOfferId = Co.CourseOfferId and APR.countStudentRegistartionId < (SPR.countStudentRegistartionId/50) Order by CO.CourseId; 
