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