// create students
DECLARE
    v_student_id NUMBER := 1;
    v_first_name VARCHAR2(50);
    v_last_name VARCHAR2(50);
    v_email VARCHAR2(100);
    v_department_id NUMBER;
    v_enrollment_date DATE;
BEGIN
    FOR month_offset IN 0..11 LOOP
        FOR student_in_month IN 1..1000 LOOP
            v_first_name := 'Student_' || TO_CHAR(v_student_id);
            v_last_name := 'LastName_' || TO_CHAR(v_student_id);
            v_email := 'student_' || TO_CHAR(v_student_id) || '@university.edu';
            v_department_id := TRUNC(DBMS_RANDOM.VALUE(1, 7)); 
            v_enrollment_date := ADD_MONTHS(TO_DATE('01-JAN-2023', 'DD-MON-YYYY'), month_offset);
            
            INSERT INTO Students (student_id, first_name, last_name, email, department_id, enrollment_date)
            VALUES (v_student_id, v_first_name, v_last_name, v_email, v_department_id, v_enrollment_date);
            
            v_student_id := v_student_id + 1;
        END LOOP;
    END LOOP;
    
    COMMIT;
END;
/

// create courses 

DECLARE
    v_course_id NUMBER := 1;
    v_course_name VARCHAR2(100);
    v_credits NUMBER;
    v_department_id NUMBER;
    v_semester_id NUMBER;
BEGIN
    FOR dept_id IN 1..7 LOOP
        FOR course_num IN 1..40 LOOP
            v_course_name := 'Course_' || TO_CHAR(dept_id) || '_' || TO_CHAR(course_num);
            v_credits := TRUNC(DBMS_RANDOM.VALUE(2, 5)); 
            v_department_id := dept_id;
            v_semester_id := TRUNC(DBMS_RANDOM.VALUE(1, 7)); 
            
            INSERT INTO Courses (course_id, course_name, credits, department_id, semester_id)
            VALUES (v_course_id, v_course_name, v_credits, v_department_id, v_semester_id);
            
            v_course_id := v_course_id + 1;
        END LOOP;
    END LOOP;
    
    COMMIT;
END;
/

// create enrollments

DECLARE
    v_enrollment_id NUMBER := 1;
    v_student_id NUMBER;
    v_course_id NUMBER;
    v_grade VARCHAR2(2);
BEGIN
    FOR student_id IN 1..12000 LOOP
        FOR course_num IN 1..5 LOOP
            v_student_id := student_id;
            v_course_id := TRUNC(DBMS_RANDOM.VALUE(1, 281));
            v_grade := CHR(TRUNC(DBMS_RANDOM.VALUE(65, 70)));
            
            INSERT INTO Enrollments (enrollment_id, student_id, course_id, grade)
            VALUES (v_enrollment_id, v_student_id, v_course_id, v_grade);
            
            v_enrollment_id := v_enrollment_id + 1;
        END LOOP;
    END LOOP;
    
    COMMIT;
END;
/
