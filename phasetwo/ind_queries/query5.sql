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