import time
import pymongo
import pandas as pd

def load():
    try:
        # Establish connection to mongodb
        mongoconnection = pymongo.MongoClient("localhost", 27017)
        mongocursor = mongoconnection.taxi

        # Read in data from csv
        df = pd.read_csv (r'/Users/darian/Desktop/School/RITCS/BigData/grp4/taxidata/yellow_tripdata_2016-01.csv')
        insertOne = df.to_dict('records')
        df = pd.read_csv (r'/Users/darian/Desktop/School/RITCS/BigData/grp4/taxidata/yellow_tripdata_2016-02.csv')
        insertTwo = df.to_dict('records')
        df = pd.read_csv (r'/Users/darian/Desktop/School/RITCS/BigData/grp4/taxidata/yellow_tripdata_2016-03.csv')
        insertThree = df.to_dict('records')

        # Insert data into trip collection
        mongocursor.trip.insert_many(insertOne)
        mongocursor.trip.insert_many(insertTwo)
        mongocursor.trip.insert_many(insertThree)

        # Create index on rateCode to speedup updates
        mongocursor.trip.create_index('rateCode')
        mongocursor.trip.update_many({'rateCode': 1}, {'$set': {'rateCode': 'Standard Rate'}})
        mongocursor.trip.update_many({'rateCode': 2}, {'$set': {'rateCode': 'JFK'}})
        mongocursor.trip.update_many({'rateCode': 3}, {'$set': {'rateCode': 'Newark'}})
        mongocursor.trip.update_many({'rateCode': 4}, {'$set': {'rateCode': 'Nassau or Westchester'}})
        mongocursor.trip.update_many({'rateCode': 5}, {'$set': {'rateCode': 'Negotiated fare'}})
        mongocursor.trip.update_many({'rateCode': 6}, {'$set': {'rateCode': 'Group ride'}})

        # Create index on paymentType
        mongocursor.trip.create_index('paymentType')
        mongocursor.trip.update_many({'paymentType': 1}, {'$set': {'paymentType': 'Credit Card'}})
        mongocursor.trip.update_many({'paymentType': 2}, {'$set': {'paymentType': 'Cash'}})
        mongocursor.trip.update_many({'paymentType': 3}, {'$set': {'paymentType': 'No charge'}})
        mongocursor.trip.update_many({'paymentType': 4}, {'$set': {'paymentType': 'Dispute'}})
        mongocursor.trip.update_many({'paymentType': 5}, {'$set': {'paymentType': 'Unknown'}})
        mongocursor.trip.update_many({'paymentType': 6}, {'$set': {'paymentType': 'Voided Trip'}})

        # Create index on vendors
        mongocursor.trip.create_index('vendor')
        mongocursor.trip.update_many({'vendor': 1}, {'$set': {'vendor': 'Creative Mobile Technologies'}})
        mongocursor.trip.update_many({'vendor': 2}, {'$set': {'vendor': 'VeriFone Inc.'}})

    except (pymongo.errors.ConnectionFailure):
        print("Error while connecting to MongoDB")

def main():
   start = time.time()
   load()
   end = time.time()
   print(f"Execution time: {(end - start)/60:.2f} minutes")


if __name__=="__main__":
    main()