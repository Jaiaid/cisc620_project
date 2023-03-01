CREATE TABLE Taxi (
    txID INT,
    vendorID INT,
    pickupDate DATE,
    pickupTime TIME,
    dropoffDate DATE,
    dropoffTime TIME,
    passengerCount INT,
    storeAndFwd BOOLEAN,
    PRIMARY KEY (txID)
);

CREATE TABLE Vendor (
    vendorID INT,
    vendorName CHAR(32),
    PRIMARY KEY (vendorID)
);

CREATE TABLE Taxi_Trip (
    txID INT,
    tripID INT,
    PRIMARY KEY (txID, tripID)
);

CREATE TABLE Trip (
    tripID INT,
    tripDistance REAL,
    pickupLongitude REAL,
    pickupLatitude REAL,
    dropoffLongitude REAL,
    dropoffLatitude REAL,
    PRIMARY KEY (tripID)
);

CREATE TABLE Payment (
    paymentID SERIAL PRIMARY KEY,
    tripID INT,
    paymentType INT,
    rateCodeID INT,
    fareAmount INT,
    extra INT,
    mtaTax INT,
    surcharge INT,
    tipAmount INT,
    tollsAmount INT,
    totalAmount INT
);

CREATE TABLE Type (
    typeID INT,
    paymentName INT,
    PRIMARY KEY (typeID)
);

CREATE TABLE Rate (
    rateCodeID INT,
    rateName CHAR(16),
    PRIMARY KEY (rateCodeID)
);
