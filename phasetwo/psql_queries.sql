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
