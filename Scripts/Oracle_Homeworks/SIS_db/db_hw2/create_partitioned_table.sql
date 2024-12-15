CREATE TABLE Faculties (
    faculty_id NUMBER PRIMARY KEY,
    faculty_name VARCHAR2(100) NOT NULL
);

CREATE TABLE Departments (
    department_id NUMBER PRIMARY KEY,
    department_name VARCHAR2(100) NOT NULL,
    faculty_id NUMBER NOT NULL,
    FOREIGN KEY (faculty_id) REFERENCES Faculties(faculty_id)
);

// Creating the Students table with monthly partitioning on the enrollment_date column.
// The partitioning is done using RANGE partitioning with an INTERVAL clause.
// This sql automatically creates a new partition for each month as new records are inserted.
// The initial partition (p_start) handles all records with an enrollment_date before January 1, 2023.
// Subsequent partitions will be created automatically for each month starting from January 2023.CREATE TABLE Students (
    student_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    department_id NUMBER NOT NULL,
    enrollment_date DATE NOT NULL,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
)
PARTITION BY RANGE (enrollment_date) INTERVAL (NUMTOYMINTERVAL(1, 'MONTH'))
(PARTITION p_start VALUES LESS THAN (TO_DATE('01-JAN-2023','DD-MON-YYYY')));

// Creating the Enrollments table with hash partitioning on the student_id column.
// Hash partitioning is used to distribute the data evenly across multiple partitions.
// In this setup, the Enrollments table is divided into 4 partitions.
// The hash function uses the student_id to determine in which of the 4 partitions a particular record will be stored.
CREATE TABLE Enrollments (
    enrollment_id NUMBER PRIMARY KEY,
    student_id NUMBER NOT NULL,
    course_id NUMBER NOT NULL,
    grade VARCHAR2(2),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
)
PARTITION BY HASH (student_id)
PARTITIONS 4;



CREATE TABLE Semesters (
    semester_id NUMBER PRIMARY KEY,
    semester_name VARCHAR2(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

CREATE TABLE Courses (
    course_id NUMBER PRIMARY KEY,
    course_name VARCHAR2(100) NOT NULL,
    credits NUMBER NOT NULL,
    department_id NUMBER NOT NULL,
    semester_id NUMBER,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id),
    FOREIGN KEY (semester_id) REFERENCES Semesters(semester_id)
);

CREATE TABLE Teachers (
    teacher_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL
);