-- Drop and recreate the database
DROP DATABASE IF EXISTS mydb;
CREATE DATABASE mydb;
USE mydb;

-- Create table 1
CREATE TABLE table1 (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        name VARCHAR(50),
                        value INT
);

-- Create table 2
CREATE TABLE table2 (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        description TEXT,
                        date_created DATE
);

-- Create table 3
CREATE TABLE table3 (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        email VARCHAR(100),
                        status ENUM('active', 'inactive', 'pending')
);

-- Insert 100 rows into table1
INSERT INTO table1 (name, value)
SELECT
    CONCAT('Name', LPAD(seq, 3, '0')),
    FLOOR(RAND() * 1000)
FROM
    (SELECT @row := @row + 1 AS seq
     FROM (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) t1,
         (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) t2,
         (SELECT @row:=0) r
         LIMIT 100) seq_1_to_100;

-- Insert 100 rows into table2
INSERT INTO table2 (description, date_created)
SELECT
    CONCAT('Description for row ', seq),
    DATE_ADD(CURDATE(), INTERVAL -FLOOR(RAND() * 365) DAY)
FROM
    (SELECT @row := @row + 1 AS seq
     FROM (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) t1,
         (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) t2,
         (SELECT @row:=0) r
         LIMIT 100) seq_1_to_100;

-- Insert 100 rows into table3
INSERT INTO table3 (email, status)
SELECT
    CONCAT('user', LPAD(seq, 3, '0'), '@example.com'),
    ELT(FLOOR(RAND() * 3) + 1, 'active', 'inactive', 'pending')
FROM
    (SELECT @row := @row + 1 AS seq
     FROM (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) t1,
         (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) t2,
         (SELECT @row:=0) r
         LIMIT 100) seq_1_to_100;