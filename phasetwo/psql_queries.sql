/* How many people are picked up at an NYC airport for New Years Eve */
SELECT 
    AVG(Trip.pickupLatitude) AS averageApproximatePickupLatitude,
    AVG(Trip.pickupLongitude) AS averageApproximatePickupLongitude,
    SUM(PassengerCount) AS count
FROM
    Trip
    INNER JOIN Vendortrips ON Vendortrips.tripid = Trip.tripid
WHERE
    TO_CHAR(pickupdatetime, 'dd-mm') = '01-01'
    AND
    (
        earth_distance(ll_to_earth(pickupLatitude,pickupLongitude),ll_to_earth(40.64131, -73.77892)) < 1000
        OR
        earth_distance(ll_to_earth(pickupLatitude,pickupLongitude),ll_to_earth(40.68953, -74.17456)) < 1000
        OR
        earth_distance(ll_to_earth(pickupLatitude,pickupLongitude),ll_to_earth(40.77692, -73.87353)) < 1000
    )
GROUP BY ROUND(pickupLatitude,2), ROUND(pickupLongitude, 2)
ORDER BY count DESC;
/* Who is the most popular taxi vendor in NYC based off of their maximum profits */

SELECT 
    vendorData.vendorid AS vendorID,
    vendorData.vendorname AS vendorName,
    TotalProfit
FROM
(
    SELECT 
        vendorid,
        SUM(fareamount) AS TotalProfit
    FROM 
        Vendortrips
        INNER JOIN Payment ON Payment.tripid=Vendortrips.tripid
    GROUP BY vendorid
) vendorProfitData
INNER JOIN
    Vendor vendorData ON vendorProfitData.vendorid=vendorData.vendorid
ORDER BY TotalProfit DESC;

/* What is the average number of trips a vendor has per day */

SELECT 
    vendorData.vendorid AS vendorID,
    vendorData.vendorname AS vendorName,
    AverageTripPerDay
FROM
(
    SELECT 
        vendorid,
        ROUND(AVG(TripInDay)) AS AverageTripPerDay
    FROM 
    (
        SELECT 
            vendorid, 
            DATE(dropoffdatetime) AS Date,
            COUNT(*) AS TripInDay
        FROM
            Vendortrips
        GROUP BY vendorid, Date
    ) Temp_table
    GROUP BY vendorid
) vendorTripData
INNER JOIN
    Vendor vendorData ON vendorTripData.vendorid=vendorData.vendorid;
