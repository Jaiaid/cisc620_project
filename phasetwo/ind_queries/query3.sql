SELECT
	pickupLongitude,
	pickupLatitude,
	MAX(tipAmount) AS tips
FROM
	Trip
	JOIN Payment ON (Payment.tripID = Trip.tripID)
	JOIN VendorTrips ON (VendorTrips.tripID = Trip.tripID)
WHERE
	Payment.paymentType = 2 AND passengerCount > 1
GROUP BY pickupLongitude, pickupLatitude
ORDER BY tips DESC;