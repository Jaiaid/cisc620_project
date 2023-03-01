import psycopg

from util import conn_config_loader
from common import DATABASE_NAME, DATABASE_CONN_INF_FILEPATH, DATABASE_SCHEMA_SCRIPT, DATABASE_CONSTRAINT_SCRIPT
from db_dataloader_functions import taxi_trip_vendor_loader, payment_type_rate_loader, db_constraint_loader

DATABASE_CREATION_CMD = "CREATE DATABASE " + DATABASE_NAME + ";"


if __name__=="__main__":
    db_connection = None
    # connect to database with out particular database
    try:
        conn_params = conn_config_loader(DATABASE_CONN_INF_FILEPATH)
        db_connection = psycopg.connect(**conn_params) 
    except Exception as e:
        print(str(e) + "...exiting")
        exit(0)
    # ensure database is created
    try:
        try:
            db_connection.autocommit = True
            cursor = db_connection.cursor()
            cursor.execute(DATABASE_CREATION_CMD)
            cursor.close()
            db_connection.autocommit = False
        except Exception as e:
            print(str(e))
            db_connection.autocommit = False
    except Exception as e:
        print(str(e))

    # reopen the connection with created database to connect with it
    db_connection.close()
    try:
        conn_params = conn_config_loader(DATABASE_CONN_INF_FILEPATH)
        conn_params["dbname"] = DATABASE_NAME
        db_connection = psycopg.connect(**conn_params) 
    except Exception as e:
        print(str(e) + "...exiting")
        exit(0)
    # create the relations by executing script
    try:
        db_connection.autocommit = True
        cursor = db_connection.cursor()
        cursor.execute(open(DATABASE_SCHEMA_SCRIPT, "r").read())
        cursor.close()
        db_connection.autocommit = False
    except Exception as e:
        print(str(e))

    db_connection.close()

    # connect with database
    # database should exist already
    try:
        conn_params = conn_config_loader(DATABASE_CONN_INF_FILEPATH)
        conn_params["dbname"] = DATABASE_NAME
        db_connection = psycopg.connect(**conn_params) 
    except Exception as e:
    	print(str(e) + "...exiting")
    	exit(0)

    # load taxi, vendor, trip
    print("loading taxi, trip data...")
    taxi_trip_vendor_loader(db_connection)
    
    # insert payment related data
    print("loading payment data...")
    payment_type_rate_loader(db_connection)

    # add the foreign key constraints
    # we have used on delete cascade so if these later added constraint cause error that row will be deleted
    # this will happen specially to title_actor, title_producer, title_director, title_producer 
    # due to less title in title and possibly less member member table
    print("adding foreign key constraints...")
    db_constraint_loader(db_connection)

    # close connection
    db_connection.close()
    
