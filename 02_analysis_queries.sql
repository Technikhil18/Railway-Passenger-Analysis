-- Railway Passenger Analysis: SQL business questions
USE railway_analysis;

-- 1. Overall KPIs
SELECT COUNT(*) AS total_bookings,
       ROUND(SUM(Fare), 2) AS total_recorded_fare,
       ROUND(AVG(Fare), 2) AS average_fare,
       SUM(Booking_Status = 'Confirmed') AS confirmed_bookings,
       SUM(Cancellation_Status = 'Yes') AS cancelled_bookings,
       ROUND(100 * SUM(Cancellation_Status = 'Yes') / COUNT(*), 2) AS cancellation_rate_pct
FROM railway_bookings;

-- 2. Train-wise bookings
SELECT Train_Name, COUNT(*) AS bookings
FROM railway_bookings
GROUP BY Train_Name
ORDER BY bookings DESC;

-- 3. Recorded fare by train
SELECT Train_Name, ROUND(SUM(Fare), 2) AS recorded_fare
FROM railway_bookings
GROUP BY Train_Name
ORDER BY recorded_fare DESC;

-- 4. Class-wise demand
SELECT Class, COUNT(*) AS bookings
FROM railway_bookings
GROUP BY Class
ORDER BY bookings DESC;

-- 5. Booking status distribution
SELECT Booking_Status, COUNT(*) AS bookings
FROM railway_bookings
GROUP BY Booking_Status
ORDER BY bookings DESC;

-- 6. Cancellation analysis
SELECT Cancellation_Status, COUNT(*) AS bookings,
       ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM railway_bookings), 2) AS percentage
FROM railway_bookings
GROUP BY Cancellation_Status;

-- 7. Payment mode preference
SELECT Payment_Mode, COUNT(*) AS bookings
FROM railway_bookings
GROUP BY Payment_Mode
ORDER BY bookings DESC;

-- 8. Age-group analysis
SELECT CASE
         WHEN Passenger_Age BETWEEN 18 AND 25 THEN '18-25'
         WHEN Passenger_Age BETWEEN 26 AND 35 THEN '26-35'
         WHEN Passenger_Age BETWEEN 36 AND 45 THEN '36-45'
         WHEN Passenger_Age BETWEEN 46 AND 55 THEN '46-55'
         WHEN Passenger_Age >= 56 THEN '56+'
         ELSE 'Unknown'
       END AS age_group,
       COUNT(*) AS passengers
FROM railway_bookings
GROUP BY age_group
ORDER BY age_group;

-- 9. Monthly journey trend
SELECT DATE_FORMAT(Journey_Date, '%b') AS journey_month,
       COUNT(*) AS bookings
FROM railway_bookings
GROUP BY MONTH(Journey_Date), DATE_FORMAT(Journey_Date, '%b')
ORDER BY MONTH(Journey_Date);

-- 10. Top routes
SELECT Source, Destination, COUNT(*) AS bookings,
       ROUND(AVG(Fare), 2) AS average_fare
FROM railway_bookings
GROUP BY Source, Destination
ORDER BY bookings DESC
LIMIT 10;

-- 11. Booking lead time (days between booking and journey)
SELECT ROUND(AVG(DATEDIFF(Journey_Date, Booking_Date)), 1) AS average_lead_days
FROM railway_bookings
WHERE Journey_Date IS NOT NULL AND Booking_Date IS NOT NULL;


-- 12. Data-quality checks
SELECT COUNT(*) AS missing_required_values
FROM railway_bookings
WHERE Booking_ID IS NULL OR Passenger_ID IS NULL OR Train_Name IS NULL
   OR Source IS NULL OR Destination IS NULL OR Journey_Date IS NULL
   OR Booking_Date IS NULL OR Fare IS NULL;

SELECT Booking_ID, COUNT(*) AS duplicate_count
FROM railway_bookings
GROUP BY Booking_ID
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS journey_before_booking
FROM railway_bookings
WHERE Journey_Date < Booking_Date;

SELECT Booking_ID, Source, Destination
FROM railway_bookings
WHERE LOWER(TRIM(Source)) = LOWER(TRIM(Destination));

SELECT COUNT(*) AS negative_fares
FROM railway_bookings
WHERE Fare < 0;
