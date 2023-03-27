README FILE FOR BIG DATA PROJECT PHASE ONE
Group 4: Darian Hodzic, Jaiaid Mobin, Muskan Mall, Anirudh Narayanan

This assignment utilizes 3 out of the 4 data files from the following link:
https://www.kaggle.com/datasets/elemento/nyc-yellow-taxi-trip-data?resource=download&select=yellow_tripdata_2016-01.csv

`yellow_tripdata_2016-01.csv`
`yellow_tripdata_2016-02.csv`
`yellow_tripdata_2016-03.csv`

The file `yellow_tripdata_2015-01.csv` was discarded and is not utilized in this project since
we are only loading our database with taxi trip data from 2016.


STEP 1: Make sure file paths in `cctables.sql` are accurate for each data file.
	
	`yellow_tripdata_2016-01.csv`
	`yellow_tripdata_2016-02.csv`
	`yellow_tripdata_2016-03.csv`
	
STEP 2: To load the database and execute queries, run the loader script in terminal with:

    `python loader.py`

** Specify the file paths on your local system to the following sql files in `loader.py`: **
	`cctables.sql`
	`updtables.sql`