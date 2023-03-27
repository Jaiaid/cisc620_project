import time

# define new header globally and all file paths
header = 'vendor,pickupDateTime,dropoffDateTime,passengerCount,tripDistance,pickupLongitude,pickupLatitude,rateCode,storeAndFwd,dropoffLongitude,dropoffLatitude,paymentType,fareAmount,extra,mtaTax,tipAmount,tollsAmount,surcharge,totalAmount\n'
pathOne = '/Users/darian/Desktop/School/RITCS/BigData/grp4/taxidata/yellow_tripdata_2016-01.csv'
pathTwo = '/Users/darian/Desktop/School/RITCS/BigData/grp4/taxidata/yellow_tripdata_2016-02.csv'
pathThree = '/Users/darian/Desktop/School/RITCS/BigData/grp4/taxidata/yellow_tripdata_2016-03.csv'

def changeHeader(filePath):
   # open first csv
   with open(filePath, 'r+') as f:
    # remove first line from file
    lines = f.readlines()[1:]
    # insert new header
    lines.insert(0, header)
    f.seek(0) # move cursor to beginning of file
    f.writelines(lines) # write to original file
    f.close()

def main():
   start = time.time()
   changeHeader(pathOne)
   changeHeader(pathTwo)
   changeHeader(pathThree)
   end = time.time()
   print(f"Execution time: {(end - start)/60:.2f} minutes")

if __name__=="__main__":
    main()