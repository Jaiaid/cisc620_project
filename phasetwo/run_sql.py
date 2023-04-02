import psycopg2
import time

# MAKE SURE TO CHANGE PATHS HERE TO CORRECT PATHS ON YOUR LOCAL SYSTEM
# Global Paths 
pathOne = '/Users/darian/Desktop/School/RITCS/BigData/grp4/phase2_local/query1.sql'
pathTwo = '/Users/darian/Desktop/School/RITCS/BigData/grp4/phase2_local/query2.sql'
pathThree = '/Users/darian/Desktop/School/RITCS/BigData/grp4/phase2_local/query3.sql'
pathFour = '/Users/darian/Desktop/School/RITCS/BigData/grp4/phase2_local/query4.sql'
pathFive = '/Users/darian/Desktop/School/RITCS/BigData/grp4/phase2_local/query5.sql'
indexes = '/Users/darian/Desktop/School/RITCS/BigData/grp4/phase2_local/index.sql'

# Execute sql query
def execute_sql_file(sql_file_path):
    try:
        # Establish connection to postgres db
        connection = psycopg2.connect(
            host="localhost",
            database="taxi"
        )
        connection.autocommit = True
        cursor = connection.cursor()
        with open(sql_file_path, 'r') as f:
            cursor.execute(f.read())    # Execute sql queries
        print("SQL script executed successfully")
    except (Exception, psycopg2.Error) as error:
        print("Error while connecting to PostgreSQL", error)
    finally:
        if (connection):
            cursor.close()
            connection.close()

def main():
   # Create Indexes 
   start = time.time()
   print("RUNNING: index.sql")
   execute_sql_file(indexes)
   end = time.time()
   print(f"Execution time: {(end - start):.2f} seconds")

   # QUERY 1
   start = time.time()
   print("RUNNING: query1.sql")
   execute_sql_file(pathOne)
   end = time.time()
   print(f"Execution time: {(end - start):.2f} seconds")

   # QUERY 2
   start = time.time()
   print("RUNNING: query2.sql")
   execute_sql_file(pathTwo)
   end = time.time()
   print(f"Execution time: {(end - start):.2f} seconds")

   # QUERY 3   
   start = time.time()
   print("RUNNING: query3.sql")
   execute_sql_file(pathThree)
   end = time.time()
   print(f"Execution time: {(end - start):.2f} seconds")

   # QUERY 4
   start = time.time()
   print("RUNNING: query4.sql")
   execute_sql_file(pathFour)
   end = time.time()
   print(f"Execution time: {(end - start):.2f} seconds")

   # QUERY 5
   start = time.time()
   print("RUNNING: query5.sql")
   execute_sql_file(pathFive)
   end = time.time()
   print(f"Execution time: {(end - start):.2f} seconds")

if __name__=="__main__":
    main()