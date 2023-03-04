import psycopg2
import time

def execute_sql_file(sql_file):
    try:
        start_time = time.time()
        # Establish connection to postgres db
        # connection is made as postgres user which should be there by default
        # provide the password for postgres user
        # or else change both user and password field
        connection = psycopg2.connect(
            host="localhost",
            database="taxi",
            user="postgres",
            password="password"
        )
        connection.autocommit = True
        cursor = connection.cursor()
        with open(sql_file, 'r') as f:
            cursor.execute(f.read())    # Execute sql queries
        print("SQL script executed successfully")
        end_time = time.time()
        print(f"Execution time: {(end_time - start_time):.2f} seconds")
        print()
    except (Exception, psycopg2.Error) as error:
        print("Error while connecting to PostgreSQL", error)
    finally:
        if (connection):
            cursor.close()
            connection.close()
            return ((end_time - start_time) / 60)

# Edit for the correct path to cctables.sql on your system
print("RUNNING: cctables.sql")
time1 = execute_sql_file(
    './cctables.sql')

print("RUNNING: updtables.sql")
# Edit for the correct path to updtables.sql on your system
time2 = execute_sql_file(
    './updtables.sql')
print("Total Time to Load Database: {:.2f}".format(time1 + time2) + " minutes")
print()
