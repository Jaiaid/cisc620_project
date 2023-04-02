SELECT
	dropoffLatitude,
	dropoffLongitude,
	COUNT(*) AS count
FROM
	Trip
WHERE
	dropoffLatitude != 0 AND dropoffLongitude != 0
GROUP BY dropoffLatitude, dropoffLongitude
ORDER BY count DESC;