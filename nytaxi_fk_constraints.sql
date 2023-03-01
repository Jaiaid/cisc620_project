ALTER TABLE Taxi
ADD CONSTRAINT constraint_vendor_to_taxi
FOREIGN KEY (vendorID)
REFERENCES Vendor(vendorID)
ON DELETE CASCADE;

ALTER TABLE Taxi_Trip
ADD CONSTRAINT constraint_taxi_to_taxi_trip
FOREIGN KEY (txID)
REFERENCES Taxi(txID)
ON DELETE CASCADE;

ALTER TABLE Taxi_Trip
ADD CONSTRAINT constraint_trip_to_taxi_trip
FOREIGN KEY (tripID)
REFERENCES Trip(tripID)
ON DELETE CASCADE;

ALTER TABLE Payment
ADD CONSTRAINT constraint_trip_to_payment
FOREIGN KEY (tripID)
REFERENCES Trip(tripID) 
ON DELETE CASCADE;

ALTER TABLE Payment
ADD CONSTRAINT constraint_type_to_payment
FOREIGN KEY (paymentType)
REFERENCES Type(typeID) 
ON DELETE CASCADE;

ALTER TABLE Payment
ADD CONSTRAINT constraint_rate_to_payment
FOREIGN KEY (rateCodeID)
REFERENCES Rate(rateCodeID) 
ON DELETE CASCADE;