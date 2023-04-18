-- DATA CLEANING


--CLEANING UP THE TRIP TABLE


-- DELETING ALL THE RECORDS WITH VOID PICKUP AND DROP OFF LOCATION


DELETE FROM trip WHERE pickuplongitude = 0; -- 529,047 rows affected in 30 s 561 ms
DELETE FROM trip WHERE pickuplatitude = 0;
-- nothing happened in this because only the places which had a pickuplongitude = 0 had pickuplatitude = 0
DELETE FROM trip WHERE dropofflatitude = 0; -- 48,941 rows affected in 7 s 721 ms
DELETE FROM trip WHERE dropofflongitude = 0;
-- nothing happened in this because only the places which had a dropofflatitude = 0 had dropofflatitude = 0




-- ROUNDING OFF COORDINATES TO 4 DECIMAL PLACES
UPDATE TRIP
SET pickuplongitude = ROUND(pickuplongitude::numeric, 4),
   pickuplatitude = ROUND(pickuplatitude::numeric, 4),
   dropofflatitude = ROUND(dropofflatitude::numeric, 4),
   dropofflongitude = ROUND(dropofflongitude::numeric, 4);
-- 33,921,871 rows affected in 4 m 16 s 856 ms




-- DELETING ALL TRIPS WITH TRIP DISTANCE = 0, SINCE THOSE ARE VOID
DELETE FROM trip WHERE tripdistance = 0; -- 130,431 rows affected in 51 s 665 ms


--CLEANING UP THE PAYMENT TABLE


-- THIS WAS ALSO VOID TRIPS, SINCE THEY DID NOT HAVE THE TOTAL AMOUNT OF MONEY, AND YOU CANT HAVE A TAXI TRIP FOR FREE
DELETE FROM payment WHERE totalamount = 0; -- 3,145 rows affected in 4 s 659 ms
-- THESE DID NOT HAVE THE CORRECT RATE-CODE ID, AND WE HAD USED THIS VALUE TO HANDLE EDGE CASES WITH UNKNOWN RATE-CODE
-- ID TO POPULATE THE TABLE PROPERLY
DELETE FROM payment where ratecodeid = 99; -- 781 rows affected in 2 s 255 ms


-- CLEANING UP THE VENDOR-TRIPS TABLE


-- DELETING ALL THE TRIPS WITH NO PASSENGERS AS THEY COULD BE THE ONES WHERE DRIVER WAS MOVING AROUND
DELETE FROM vendortrips WHERE passengercount = 0; -- 1,649 rows affected in 17 s 564 ms


-- SEPARATING THE PICKUP DATE FROM TIME, SINCE WE OBSERVED THAT WE HAD TO ALWAYS WORK AROUND IT TO GET PARTIAL INFORMATION




ALTER TABLE vendortrips
ADD COLUMN pickupdate DATE,
ADD COLUMN pickuptime TIME,
ADD COLUMN dropoffdate DATE,
ADD COLUMN dropofftime TIME
;


UPDATE vendortrips
SET pickupdate = DATE_TRUNC('day', pickupdatetime),
   pickuptime = (pickupdatetime - DATE_TRUNC('day', pickupdatetime)); -- 34,498,210 rows affected in 4 m 25 s 837 ms


UPDATE vendortrips
SET dropoffdate = DATE_TRUNC('day', dropoffdatetime),
   dropofftime = (dropoffdatetime - DATE_TRUNC('day', dropoffdatetime)); -- 34,498,210 rows affected in 1 m 25 s 630 ms


ALTER TABLE vendortrips
DROP COLUMN pickupdatetime;


ALTER TABLE vendortrips
DROP COLUMN dropoffdatetime
;