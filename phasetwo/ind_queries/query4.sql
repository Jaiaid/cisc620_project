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