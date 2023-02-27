-- Insert payment types
INSERT INTO Type (paymentName)
VALUES ('Credit Card'), 
	   ('Cash'), 
	   ('No Charge'),
	   ('Dispute'),
	   ('Unknown'),
	   ('Voided Trip');
	   
-- Insert rate code names
INSERT INTO Rate (rateName)
VALUES ('Standard Rate'), 
	   ('JFK'), 
	   ('Newark'),
	   ('Nassau or Westchester'),
	   ('Negotiated Fare'),
	   ('Group Ride');
	   
-- Default the rateCodeIDs out of range
INSERT INTO Rate (rateCodeID, rateName)
VALUES (99, 'UNKNOWN_RATE_NAME');

-- Insert vendor names
INSERT INTO Vendor (vendorName)
VALUES ('Creative Mobile Technologies'),
	   ('VeriFone Inc.');

-- Add relevant data to taxi table		
INSERT INTO Taxi (vendorID, pickupDateTime, dropOffDateTime, passengerCount, storeAndFwd)
SELECT 	
	vendorID, 
	tpep_pickup_datetime, 
	tpep_dropoff_datetime, 
	passenger_count, 
	store_and_fwd_flag
FROM TemporaryTable;

-- Add relevant data to trip table
INSERT INTO Trip (tripDistance, pickupLongitude, pickupLatitude, dropoffLongitude, dropoffLatitude)
SELECT
	trip_distance,
	pickup_longitude,
	pickup_latitude,
	dropoff_longitude,
	dropoff_latitude
FROM
	TemporaryTable;
	
-- Add relevant data to Taxi_Trip
INSERT INTO Taxi_Trip (txID, tripID)
SELECT Taxi.txID, Trip.tripID
FROM Taxi
JOIN Trip ON Taxi.txID = Trip.tripID;

-- Add relevant data to payment table
ALTER TABLE TemporaryTable
ADD COLUMN id SERIAL;

INSERT INTO Payment (tripID, paymentType, rateCodeID, fareAmount, extra, mtaTax, surcharge, tipAmount, tollsAmount, totalAmount)
SELECT
	Trip.tripID,
	TemporaryTable.payment_type,
	TemporaryTable.ratecodeid,
	TemporaryTable.fare_amount,
	TemporaryTable.extra,
	TemporaryTable.mta_tax,
	TemporaryTable.improvement_surcharge,
	TemporaryTable.tip_amount,
	TemporaryTable.tolls_amount,
	TemporaryTable.total_amount
FROM
	Trip
	JOIN TemporaryTable ON Trip.tripID = TemporaryTable.id;
	
DROP TABLE TemporaryTable;

-- Alter datatypes and add fk constraint to Taxi Table
ALTER TABLE Taxi
ALTER COLUMN vendorID TYPE INTEGER USING (vendorID::INTEGER),
ALTER COLUMN pickupDateTime TYPE TIMESTAMP USING (pickupDateTime::TIMESTAMP),
ALTER COLUMN dropoffDateTime TYPE TIMESTAMP USING (dropoffDateTime::TIMESTAMP),
ALTER COLUMN passengerCount TYPE INTEGER USING (passengerCount::INTEGER),
ALTER COLUMN storeAndFwd TYPE BOOLEAN USING (storeAndFwd::BOOLEAN),
ADD CONSTRAINT fk_vendor
FOREIGN KEY (vendorID)
	REFERENCES Vendor (vendorID)
	ON DELETE CASCADE;

-- Add fk references to Taxi and Trip
ALTER TABLE Taxi_Trip
ADD CONSTRAINT fk_taxi
FOREIGN KEY (txID)
	REFERENCES Taxi (txID)
	ON DELETE CASCADE,
ADD CONSTRAINT fk_trip
FOREIGN KEY (tripID)
	REFERENCES Trip (tripID)
	ON DELETE CASCADE;
	
-- Alter datatypes and add fk constraint to Trip
ALTER TABLE Payment ADD UNIQUE(tripID); -- allows for fk reference from Trip to Payment

ALTER TABLE Trip
ALTER COLUMN tripDistance TYPE NUMERIC USING (tripDistance::NUMERIC),
ALTER COLUMN pickupLongitude TYPE NUMERIC USING (pickupLongitude::NUMERIC),
ALTER COLUMN pickupLatitude TYPE NUMERIC USING (pickupLatitude::NUMERIC),
ALTER COLUMN dropoffLongitude TYPE NUMERIC USING (dropoffLongitude::NUMERIC),
ALTER COLUMN dropoffLatitude TYPE NUMERIC USING (dropoffLatitude::NUMERIC),
ADD CONSTRAINT fk_trip2pay
FOREIGN KEY (tripID)
	REFERENCES Payment (tripID)
	ON DELETE CASCADE;


-- Alter datatypes and add fk constraints to Payment
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
	ON DELETE CASCADE;