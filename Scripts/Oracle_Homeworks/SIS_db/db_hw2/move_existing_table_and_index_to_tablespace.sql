// create tablespace as a sys user
CREATE TABLESPACE students_ts
DATAFILE '/u02/oradata/CDB1/pdb1/sis/students_ts01.dbf' SIZE 1000M
AUTOEXTEND ON NEXT 100M MAXSIZE 2000M;


// pl/sql commands to relocate partitioned table to tablespace in the offline mode.
BEGIN
    FOR part IN (SELECT partition_name FROM user_tab_partitions WHERE table_name = 'STUDENTS') LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE Students MOVE PARTITION ' || part.partition_name || ' TABLESPACE students_ts';
    END LOOP;
END;
/
// check  if any unusable indexes after relocating operation.
SELECT index_name, status
FROM user_indexes
WHERE status = 'UNUSABLE';

// commands to move and rebuild indexes of table
ALTER INDEX SYS_C007446 REBUILD TABLESPACE students_ts;
ALTER INDEX SYS_C007447 REBUILD TABLESPACE students_ts;

// since we used local indexing for enrollment date, we need to move and rebuild every index for each partition with following pl/sql:
BEGIN
    FOR part IN (SELECT partition_name FROM user_ind_partitions WHERE index_name = 'STUDENTS_ENROLLMENT_DATE_LOCAL_IDX') LOOP
        EXECUTE IMMEDIATE 'ALTER INDEX students_enrollment_date_local_idx REBUILD PARTITION ' || part.partition_name || ' TABLESPACE students_ts';
    END LOOP;
END;
/

// default tablespace for partitiones to be created.
ALTER TABLE Students MODIFY DEFAULT ATTRIBUTES TABLESPACE students_ts;

// this will show the tablespace of our table, since our table is partitioned table
// query result should show tablespace as null.
SELECT table_name, tablespace_name
FROM user_tables
WHERE table_name = 'STUDENTS';

// this query will show tablespaces of all partitiones. Result should be "STUDENT_TS".
SELECT partition_name, tablespace_name
FROM user_tab_partitions
WHERE table_name = 'STUDENTS';

// this query show the tablespacesof indexes, except for index which is using partitioned column,
// all indexes table space should be "STUDENT_TS".
SELECT index_name, tablespace_name
FROM user_indexes
WHERE table_name = 'STUDENTS';





