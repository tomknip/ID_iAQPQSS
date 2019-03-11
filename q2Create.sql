CREATE INDEX idx_gender ON students(gender);
CREATE INDEX idx_studentIdAndDegreeIdAndGrade ON courseRegistrations(studentId,degreeId,grade);
CREATE MATERIALIZED VIEW pointsPerS(studentId, studentregistrationid, sumECTS, GPA) as SELECT CR.studentid, CR.studentregistrationid, sum(CO.ECTS), sum(CR.Grade * CO.ECTS)/sum(CO.ECTS)::float FROM courseRegistrations CR, CourseOffers CO WHERE CR.CourseOfferId = CO.CourseOfferId and CR.Grade >= 5 GROUP BY CR.studentid, CR.studentregistrationid;
CREATE MATERIALIZED VIEW have_not_taken_yet(studentregistrationid, sumECTS) as (SELECT studentregistrationid, 0 FROM (SELECT studentregistrationid FROM studentRegistrationsToDegrees D EXCEPT SELECT studentregistrationid FROM pointsPerS) as new);
with finishedStud(studentId, studentregistrationid, sumECTS, GPA) as (SELECT P.studentId, P.studentregistrationid, P.sumECTS, P.GPA FROM pointsPerS P, studentRegistrationsToDegrees SD, degrees D WHERE P.studentregistrationid = sd.studentregistrationid and D.degreeid = SD.DegreeID and P.sumECTS >= D.totalects) CREATE MATERIALIZED VIEW nofails(id, regid, gpa) as (select fi.studentid, fi.studentregistrationid, fi.gpa from finishedstud as fi, courseregistrations as cr where fi.studentregistrationid = cr.studentregistrationid group by fi.studentregistrationid, fi.studentid, fi.GPA having min(cr.grade) >= 5);
