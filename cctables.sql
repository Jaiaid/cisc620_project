-- Method of copying all the data into created tables where the correct data
-- types and keys/references and schema will be defined after the COPY commands

CREATE TABLE IF NOT EXISTS TemporaryTable (
	vendorID VARCHAR,
	tpep_pickup_datetime VARCHAR,
	tpep_dropOff_datetime VARCHAR,
	passenger_count VARCHAR,
	trip_distance VARCHAR,
	pickup_longitude VARCHAR,
	pickup_latitude VARCHAR,
	rateCodeID VARCHAR,
	store_and_fwd_flag VARCHAR,
	dropoff_longitude VARCHAR,
	dropoff_latitude VARCHAR,
	payment_type VARCHAR,
	fare_amount VARCHAR,
	extra VARCHAR,
	mta_tax VARCHAR,
	tip_amount VARCHAR,
	tolls_amount VARCHAR,
	improvement_surcharge VARCHAR,
	total_amount VARCHAR
);


CREATE TABLE IF NOT EXISTS Taxi (
	txID SERIAL PRIMARY KEY,
	vendorID VARCHAR,
	pickupDateTime VARCHAR,
	dropoffDateTime VARCHAR,
	passengerCount VARCHAR,
	storeAndFwd VARCHAR
);

CREATE TABLE IF NOT EXISTS Trip (
	tripID SERIAL PRIMARY KEY,
	tripDistance VARCHAR,
	pickupLongitude VARCHAR,
	pickupLatitude VARCHAR,
	dropoffLongitude VARCHAR,
	dropoffLatitude VARCHAR
);

CREATE TABLE IF NOT EXISTS Payment (
	paymentID SERIAL,
	tripID INTEGER,
	paymentType VARCHAR,
	rateCodeID VARCHAR,
	fareAmount VARCHAR,
	extra VARCHAR,
	mtaTax VARCHAR,
	surcharge VARCHAR,
	tipAmount VARCHAR,
	tollsAmount VARCHAR,
	totalAmount VARCHAR,
	PRIMARY KEY(paymentID, tripID)
);

CREATE TABLE IF NOT EXISTS Vendor (
	vendorID SERIAL PRIMARY KEY,
	vendorName VARCHAR
);

CREATE TABLE IF NOT EXISTS Taxi_Trip(
	txID INTEGER,
	tripID INTEGER,
	PRIMARY KEY (txID, tripID)
);


CREATE TABLE IF NOT EXISTS Type (
	typeID SERIAL PRIMARY KEY,
	paymentName VARCHAR
);

CREATE TABLE IF NOT EXISTS Rate (
	rateCodeID SERIAL PRIMARY KEY,
	rateName VARCHAR
);


COPY TemporaryTable FROM '/Users/darian/Desktop/School/RITCS/BigData/grp4/phase1/taxidata/yellow_tripdata_2016-01.csv' 
DELIMITER ',' 
CSV HEADER;

COPY TemporaryTable FROM '/Users/darian/Desktop/School/RITCS/BigData/grp4/phase1/taxidata/yellow_tripdata_2016-02.csv' 
DELIMITER ',' 
CSV HEADER;

COPY TemporaryTable FROM '/Users/darian/Desktop/School/RITCS/BigData/grp4/phase1/taxidata/yellow_tripdata_2016-03.csv' 
DELIMITER ',' 
CSV HEADER;