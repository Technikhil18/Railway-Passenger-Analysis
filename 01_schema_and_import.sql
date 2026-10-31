-- Railway Passenger Analysis: MySQL schema
CREATE DATABASE IF NOT EXISTS railway_analysis;
USE railway_analysis;

CREATE TABLE IF NOT EXISTS railway_bookings (
    Booking_ID VARCHAR(20) PRIMARY KEY,
    Passenger_ID VARCHAR(20) NOT NULL,
    Train_Name VARCHAR(100) NOT NULL,
    Source VARCHAR(80) NOT NULL,
    Destination VARCHAR(80) NOT NULL,
    Journey_Date DATE,
    Booking_Date DATE,
    Class VARCHAR(10),
    Passenger_Age INT,
    Gender VARCHAR(20),
    Fare DECIMAL(10,2),
    Payment_Mode VARCHAR(30),
    Booking_Status VARCHAR(30),
    Cancellation_Status VARCHAR(5)
);

-- This script does not delete existing table data.
-- Import the CSV after replacing the path with your local absolute path.
-- MySQL Workbench: Table Data Import Wizard is an easy option.
-- If importing again, avoid duplicate primary keys; clear the table only if you
-- intentionally want to reload the complete sample dataset.
-- Command line example:
-- LOAD DATA LOCAL INFILE 'C:/path/railway_passenger_data.csv'
-- INTO TABLE railway_bookings
-- FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (Booking_ID, Passenger_ID, Train_Name, Source, Destination,
--  @Journey_Date, @Booking_Date, Class, Passenger_Age, Gender,
--  Fare, Payment_Mode, Booking_Status, Cancellation_Status)
-- SET Journey_Date = STR_TO_DATE(@Journey_Date, '%Y-%m-%d'),
--     Booking_Date = STR_TO_DATE(@Booking_Date, '%Y-%m-%d');
