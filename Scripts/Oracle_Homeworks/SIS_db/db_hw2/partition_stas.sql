// gather statistics to show partition's stats.
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS('sis', 'ENROLLMENTS', 'STUDENTS');
END;
/

// show stats for partitions from ENROLLMENTS table.
SELECT partition_name, high_value, num_rows, blocks, avg_row_len
FROM user_tab_partitions
WHERE table_name = 'ENROLLMENTS';

----------------------------------------------------------------------------

// gather statistics to show partition's stats.
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS('sis', 'STUDENTS');
END;
/

// show stats for partitions from STUDENTS table.
SELECT partition_name, high_value, num_rows, blocks, avg_row_len
FROM user_tab_partitions
WHERE table_name = 'STUDENTS';
