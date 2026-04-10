CREATE DATABASE IF NOT EXISTS talaan;
USE talaan;

CREATE TABLE IF NOT EXISTS colleges (
    college_code VARCHAR(50) PRIMARY KEY,
    college_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS programs (
    program_code VARCHAR(50) PRIMARY KEY,
    program_name VARCHAR(255) NOT NULL,
    college_code VARCHAR(50) NULL,
    FOREIGN KEY (college_code) REFERENCES colleges(college_code)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS students (
    id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20) NOT NULL,
    year INT NOT NULL,
    program_code VARCHAR(50) NULL,
    FOREIGN KEY (program_code) REFERENCES programs(program_code)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);