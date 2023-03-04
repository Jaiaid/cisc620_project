INSERT INTO type(paymentname)
VALUES('Credit Card'),
    ('Cash'),
    ('No Charge'),
    ('Dispute'),
    ('Unknown'),
    ('Voided Trip'); -- 6 rows affected in 2 ms


INSERT INTO Rate (rateName)
VALUES ('Standard Rate'),
    ('JFK'),
    ('Newark'),
    ('Nassau or Westchester'),
    ('Negotiated Fare'),
    ('Group Ride'); -- 6 rows affected in 2 ms


INSERT INTO Rate (rateCodeID, rateName)
VALUES (99, 'UNKNOWN_RATE_NAME'); --1 row affected in 3 ms


INSERT INTO Vendor (vendorName)
VALUES ('Creative Mobile Technologies'),
    ('VeriFone Inc.'); -- 2 rows affected in 3 ms


INSERT INTO Taxi (tripid, vendorID, pickupDateTime, dropOffDateTime, passengerCount, storeAndFwd)
SELECT
  id,
 vendorID,
 tpep_pickup_datetime,
 tpep_dropoff_datetime,
 passenger_count,
 store_and_fwd_flag
FROM main_table; -- 34,499,859 rows affected in 1 m 0 s 310 ms


-- Add relevant data to trip table
INSERT INTO Trip (tripid, tripDistance, pickupLongitude, pickupLatitude, dropoffLongitude, dropoffLatitude)
SELECT
  id,
 trip_distance,
 pickup_longitude,
 pickup_latitude,
 dropoff_longitude,
 dropoff_latitude
FROM main_table; -- 34,499,859 rows affected in 30 s 867 ms


INSERT INTO taxi_trip(txid, tripid)
  SELECT taxi.txid, trip.tripid
FROM taxi JOIN trip ON taxi.txid = trip.tripid;-- 34,499,859 rows affected in 1 m 19 s 52 ms


INSERT INTO payment(tripID, paymentType, rateCodeID, fareAmount, extra, mtaTax, tipAmount, tollsAmount, surcharge, totalAmount)
SELECT id,
     payment_type,
     ratecodeid,
     fare_amount,
     extra,
     mta_tax,
     tip_amount,
     tolls_amount,
     improvement_surcharge,
     total_amount
FROM main_table; -- 34,499,859 rows affected in 2 m 1 s 486 ms


--  ALTERING TABLE TAXI TO CORRECT DATA TYPES AND ADDING FOREIGN KEYS
ALTER TABLE Taxi
ALTER COLUMN vendorID TYPE INTEGER USING (vendorID::INTEGER),
ALTER COLUMN pickupDateTime TYPE TIMESTAMP USING (pickupDateTime::TIMESTAMP),
ALTER COLUMN dropoffDateTime TYPE TIMESTAMP USING (dropoffDateTime::TIMESTAMP),
ALTER COLUMN passengerCount TYPE INTEGER USING (passengerCount::INTEGER),
ALTER COLUMN storeAndFwd TYPE BOOLEAN USING (storeAndFwd::BOOLEAN),
ADD CONSTRAINT fk_vendor
FOREIGN KEY (vendorID)
 REFERENCES Vendor (vendorID)
 ON DELETE CASCADE; -- completed in 1 m 0 s 842 ms


--  ADDING FOREIGN KEYS TO TAXI_TRIP
ALTER TABLE Taxi_Trip
ADD CONSTRAINT fk_taxi
FOREIGN KEY (txID)
 REFERENCES Taxi (txID)
 ON DELETE CASCADE,
ADD CONSTRAINT fk_trip
FOREIGN KEY (tripID)
 REFERENCES Trip (tripID)
 ON DELETE CASCADE;-- completed in 46 s 528 ms


-- ALLOWS FOREIGN KEY REFERENCE
ALTER TABLE Payment ADD UNIQUE(tripID); -- completed in 16 s 858 ms


--  ALTERING TABLE TRIP TO CORRECT DATA TYPES AND ADDING FOREIGN KEYS
ALTER TABLE Trip
ALTER COLUMN tripDistance TYPE NUMERIC USING (tripDistance::NUMERIC),
ALTER COLUMN pickupLongitude TYPE NUMERIC USING (pickupLongitude::NUMERIC),
ALTER COLUMN pickupLatitude TYPE NUMERIC USING (pickupLatitude::NUMERIC),
ALTER COLUMN dropoffLongitude TYPE NUMERIC USING (dropoffLongitude::NUMERIC),
ALTER COLUMN dropoffLatitude TYPE NUMERIC USING (dropoffLatitude::NUMERIC),
ADD CONSTRAINT fk_trip2pay
FOREIGN KEY (tripID)
 REFERENCES Payment (tripID)
 ON DELETE CASCADE; -- completed in 1 m 59 s 988 ms


-- --  ALTERING TABLE PAYMENT TO CORRECT DATA TYPES AND ADDING FOREIGN KEYS
ALTER TABLE Payment
ALTER COLUMN paymentType TYPE INTEGER USING (paymentType::INTEGER),
ALTER COLUMN rateCodeID TYPE INTEGER USING (rateCodeID::INTEGER),
ALTER COLUMN fareAmount TYPE NUMERIC USING (fareAmount::NUMERIC),
ALTER COLUMN extra TYPE NUMERIC USING (extra::NUMERIC),
ALTER COLUMN mtaTax TYPE NUMERIC USING (mtaTax::NUMERIC),
ALTER COLUMN surcharge TYPE NUMERIC USING (surcharge::NUMERIC),
ALTER COLUMN tipAmount TYPE NUMERIC USING (tipAmount::NUMERIC),
ALTER COLUMN tollsAmount TYPE NUMERIC USING (tollsAmount::NUMERIC),
ALTER COLUMN totalAmount TYPE NUMERIC USING (totalAmount::NUMERIC),
ADD CONSTRAINT ck_type
CHECK (paymentType >= 1 AND paymentType <= 6),
ADD CONSTRAINT ck_rid
CHECK (rateCodeID >= 1 AND rateCodeID <= 6 OR rateCodeID = 99),
ADD CONSTRAINT fk_payType
FOREIGN KEY (paymentType)
 REFERENCES Type (typeID)
 ON DELETE CASCADE,
ADD CONSTRAINT fk_rateCode
FOREIGN KEY (rateCodeID)
 REFERENCES Rate (rateCodeID)
 ON DELETE CASCADE; -- completed in 1 m 53 s 23 ms


DROP TABLE Main_Table; -- completed in 318 ms