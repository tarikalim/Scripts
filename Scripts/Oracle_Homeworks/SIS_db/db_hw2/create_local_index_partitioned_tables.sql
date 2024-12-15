// First, we run a query to check the performance without an index on the enrollment_date column.

SELECT *
FROM Students
WHERE enrollment_date BETWEEN TO_DATE('01-JAN-2023', 'DD-MON-YYYY') AND TO_DATE('31-JAN-2023', 'DD-MON-YYYY');

// Now, we create a local index on the enrollment_date column.
// We use a local index because the Students table is partitioned by the enrollment_date.
// Local indexing ensures that each partition has its own index, which optimizes performance
// for queries that are based on the partition key (enrollment_date). This reduces the amount of data scanned
// and improves query speed, particularly for large tables with many partitions.

CREATE INDEX students_enrollment_date_local_idx
ON Students (enrollment_date)
LOCAL;

// Finally, we run the same query again to observe the performance improvement
// with the local index in place.

SELECT *
FROM Students
WHERE enrollment_date BETWEEN TO_DATE('01-JAN-2023', 'DD-MON-YYYY') AND TO_DATE('31-JAN-2023', 'DD-MON-YYYY');
