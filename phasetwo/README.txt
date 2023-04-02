README FILE FOR BIG DATA PROJECT PHASE TWO
Group 4: Darian Hodzic, Jaiaid Mobin, Muskan Mall, Anirudh Narayanan

This assignment utilizes 3 out of the 4 data files from the following link:
https://www.kaggle.com/datasets/elemento/nyc-yellow-taxi-trip-data?resource=download&select=yellow_tripdata_2016-01.csv

`yellow_tripdata_2016-01.csv`
`yellow_tripdata_2016-02.csv`
`yellow_tripdata_2016-03.csv`

The file `yellow_tripdata_2015-01.csv` was discarded and is not utilized in this project since
we are only loading our database with taxi trip data from 2016.

These are the files to be aware of:

	`preprocess.py` -- Renames the headers of each .csv so that they correctly correspond to the MongoDB schema established in the writeup.
	`mongo.py` -- Loads our MongoDB database with the appropriate data and creates the Trips collection.
	`psql_queries.py` -- Contains all five queries written for this phase
	`run_sql.py` -- Script that connects to our Postgres database and runs each query (reports timings via terminal)

STEP 1: Make sure file paths in `preprocess.py` and `mongo.py` are accurate for each data file.
	
	`yellow_tripdata_2016-01.csv`
	`yellow_tripdata_2016-02.csv`
	`yellow_tripdata_2016-03.csv`
	
STEP 2: To load the MongoDB database, run the loader script in terminal with:

    `python mongo.py`
    

NOTE BEFORE STEP 3 MAKE SURE TO:

	Install earthdistance module for PostgreSQL since it is utilized in our second query.
	This can be done by executing the following SQL on your existing PostgreSQL db:
		
		`CREATE EXTENSION cube`
		`CREATE EXTENSION earthdistance`
		
	These must be executed in this order with `cube` being created first.
	
STEP 3: To execute all five sql queries, `run_sql.py` with:

	`python run_sql.py`
	
Libraries used:
`time`
`pymongo`
`pandas`