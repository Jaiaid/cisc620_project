/*
store and fwd
 */

/*
 * is not date time more sensible with Trip table
 */
/* group by day hour */
SELECT EXTRACT(hour FROM dropoffDateTime) as Hour, COUNT(storeAndFwd) as ImmFwdFailure 
FROM Taxi
WHERE storeAndFwd = True
GROUP BY Hour;

/* average latitude longitude, group by store and fwd*/
SELECT storeAndFwd, 
AVG(dropoffLongitude) as AvgFailureLongitude, 
AVG(dropoffLatitude) as AvgFailureLatitude, COUNT(storeAndFwd)  as ImmFwdFailure 
FROM Taxi
INNER JOIN Trip ON Trip.tripID=Taxi.TripID
WHERE storeAndFwd IS NOT NULL
GROUP BY storeAndFwd;


/*--------------------------------------------------*/
/*
traffic density idea
 */

/* pick up average and stddev latitude longitude by  day hour */
SELECT EXTRACT(hour FROM pickupDateTime) as Hour, 
AVG(pickupLongitude) as AvgPickupLongitude, STDDEV(pickupLongitude) as DevPickupLongitude, 
AVG(pickupLatitude) as AvgPickupLatitude, STDDEV(pickupLatitude) as DevPickupLatitude
FROM Taxi
INNER JOIN Trip ON Trip.tripID=Taxi.TripID
WHERE pickupDateTime IS NOT NULL
GROUP BY Hour;

/* dropoff average and stddev latitude longitude by  day hour */
SELECT EXTRACT(hour FROM dropoffDateTime) as Hour, 
AVG(dropoffLongitude) as AvgDropLongitude, STDDEV(dropoffLongitude) as DevDropLongitude, 
AVG(dropoffLatitude) as AvgDropLatitude, STDDEV(dropoffLatitude) as DevDropLatitude
FROM Taxi
INNER JOIN Trip ON Trip.tripID=Taxi.TripID
WHERE dropoffDateTime IS NOT NULL
GROUP BY Hour;

/* which hour are busiest for pickup */
SELECT EXTRACT(hour FROM pickupDateTime) as Hour, Count(*) as tripCount 
FROM Taxi
WHERE pickupDateTime IS NOT NULL
GROUP BY Hour;

/* which hour are busiest for dropoff */
SELECT EXTRACT(hour FROM dropoffDateTime) as Hour, Count(*) as tripCount 
FROM Taxi
WHERE pickupDateTime IS NOT NULL
GROUP BY Hour;

/* obsevation we can hypothesize that residance areas are bit spread but economic zones are dense */

/*--------------------------------------------------*/
/*
vendor service idea
 */


/* 'Creative Mobile Technologies' vendor trip count group by hour */
SELECT EXTRACT(hour FROM pickupDateTime) as Hour, Count(*) as TripCount 
FROM Taxi
INNER JOIN Vendor ON Vendor.vendorID = Taxi.vendorID
WHERE vendorName = 'Creative Mobile Technologies'
GROUP BY Hour;

/* 'VeriFone Inc.' vendor trip count group by hour */
SELECT EXTRACT(hour FROM pickupDateTime) as Hour, Count(*) as TripCount 
FROM Taxi
INNER JOIN Vendor ON Vendor.vendorID = Taxi.vendorID
WHERE vendorName = 'VeriFone Inc.'
GROUP BY Hour;

/* which location a vendor mainly serves */
/* finding is Creative Mobile Technologies serve mainly south east part of newyork */
SELECT vendorName, AVG(dropoffLongitude) as AvgDropLongitude, AVG(dropoffLatitude) as AvgDropLatitude
FROM Taxi
INNER JOIN Trip ON Trip.tripID = Taxi.tripID
INNER JOIN Vendor ON Vendor.vendorID = Taxi.vendorID
GROUP BY vendorName;

/*--------------------------------------------------*/
/*
fare idea
 */

/* how to measure average trip time */
SELECT AVG(dropoffDateTime - pickupDateTime) as avgTripTime 
FROM Taxi;

/* per mile fare group by hour */
SELECT EXTRACT(hour FROM dropOffDateTime) as Hour,  AVG(fareAmount/tripDistance) as FarePerMile 
FROM Taxi
INNER JOIN Trip ON Trip.tripID = Taxi.tripID
INNER JOIN Payment ON Payment.tripID = Trip.tripID
WHERE tripDistance IS NOT NULL AND tripDistance != 0
GROUP BY Hour;
