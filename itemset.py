"""
Subject: INTRODUCTION TO BIG DATA
PROJECT
DATASET: NYC TAXI CAB
AUTHORS: Anirudh Narayanan, Muskan Mall, Darian Hodzic, Jaiaid Mobin
"""

import psycopg2
from itertools import combinations
import time
import pandas as pd
from prettytable import PrettyTable

# Create table to perform itemset mining on. Select 1.2 million rows as anymore than that results in the code
# not finishing execution .
def create_coordinates():
    try:
        # Establish connection to database
        conn = psycopg2.connect(
            database="Taxi",
            host="localhost")
        print("Connection Successful")

        # Create Cursor
        cur = conn.cursor()
        # Query to create coorodiantes table to perform itemset mining on. 
        query = "CREATE TABLE coordinates as SELECT tripid, pickuplatitude as picklat, pickuplongitude as picklon, " \
                "dropofflatitude as droplat, dropofflongitude as droplon from trip ORDER BY RANDOM() LIMIT 1000000;"
        cur.execute(query)
        conn.commit()
        print("Created Coordinated. Now creating lattices.")
    except Exception as e:
        print(e)


# Function to create all the lattices required for item-set mining of drop-off coordinates and pick up coordinates.
def create_lattices():
    try:
        # Establish connection to database
        conn = psycopg2.connect(
            database="Taxi",
            host="localhost")
        print("Connection Successful")

        # Create Cursor
        cur = conn.cursor()

        # Create and run queries and break out of loop if 0 item-sets are found.
        groups_found = i = 1
        while groups_found > 0:
            # Create Query by appending to a string.
            # Inital create table statement.
            query = "Create table L" + str(i) + " as ( Select"

            # Add columns to pick, increasing for every lattice level.
            for k in range(1, i + 1):
                query += " c" + str(k) + \
                         ".picklat as picklat" + str(k) + ","
                query += " c" + str(k) + ".picklon as picklon" + str(k) + ","
            query += " count((c" + str(i) + ".droplat, c" + str(i) + ".droplon)) as count from coordinates c1"

            #  Perform these actions for all queries except for Table L1.
            if i != 1:
                arr = []
                # Join table popular_movie_actor a number of times depending on the value of 'i'
                for k in range(2, i + 1):
                    query += " join coordinates c" + str(k) + " on c1.droplat = c" + str(k) + ".droplat"
                    query += " and c1.droplon = c" + str(k) + ".droplon"

                # Create a list of combinations in order to make sure duplicate itemsets are not formed.
                k = 1
                while k < i + 1:
                    arr.append(k)
                    k = k + 1
                # add every combination in the list
                result = list(combinations(arr, 2))
                combi = 0
                # for every combination add check to make sure there is not duplicate rows formed.
                while combi < len(result):
                    query += " AND (c" + str(result[combi][0]) + ".picklat < c" + str(result[combi][1]) + ".picklat"
                    query += " OR (c" + str(result[combi][0]) + ".picklat = c" + str(result[combi][1]) + ".picklat"
                    query += " AND c" + str(result[combi][0]) + ".picklon < c" + str(result[combi][1]) + ".picklon))"
                    combi += 1

                # Check if the coordinate values exist in the previous table.
                query += " WHERE ("
                x = combinations(range(1, i + 1), i - 1)
                x = [l for l in x]
                cntr = 0
                for j in x:
                    if cntr != 0:
                        query += " AND ("
                    for k in range(len(j)):
                        if k != len(j) - 1:
                            query += f"c{str(j[k])}.picklon ,"
                        else:
                            query += f"c{str(j[k])}.picklon)"

                            query += " IN (SELECT "
                            for l in range(1, i):
                                if l != i - 1:
                                    query += f"l{str(i - 1)}.picklon{str(l)}, "
                                else:
                                    query += f"l{str(l)}.picklon{str(l)} FROM l{str(i - 1)} )"
                    query += " AND ("
                    for k in range(len(j)):
                        if k != len(j) - 1:
                            query += f" c{str(j[k])}.picklat ,"
                        else:
                            query += f" c{str(j[k])}.picklat)"

                            query += " IN (SELECT "
                            for l in range(1, i):
                                if l != i - 1:
                                    query += f"l{str(i - 1)}.picklat{str(l)}, "
                                else:
                                    query += f"l{str(l)}.picklat{str(l)} FROM l{str(i - 1)} )"

                    cntr += 1
                # Group by clause of the query
                query += "  group by ( "
                check_len = 1

                while check_len < i + 1:
                    query += "c" + str(check_len) + ".picklat, "
                    query += "c" + str(check_len) + ".picklon"
                    if check_len + 1 < i + 1:
                        query += ", "
                    check_len += 1
                query += ")"
            # Only Append for L1
            else:
                query += " group by c1.picklat, c1.picklon "

            # Set minimum support
            query += " HAVING count((c" + str(i) + ".droplat, c" + str(i) + ".droplon)) >= 4);"

            # Store start time of query
            start = time.time()

            # Execute the query created and commit to the database.
            cur.execute(query)
            conn.commit()

            # Get number of itemsets in the lattice created and print it.
            query2 = "Select count(*) from L" + str(i) + ";"
            cur.execute(query2)
            result = cur.fetchone()
            groups_found = result[0]

            # Print statements
            print("Created L" + str(i))
            print("Found " + str(groups_found) + " itemsets of pickup coordinates for Level " + str(i) + ".")
            end = time.time()
            print(str(end - start) + " seconds taken for this lattice level.")
            print()

            # Break out of loop of 0 itemsets formed. (ie last lattice level has been created.)
            if groups_found == 0:
                print(f"Completed check for all Lattice Levels. Level {str(i)} returns an empty table.")
                query_f = f" SELECT * from L{str(i-1)}"
                cur.execute(query_f)
                result = cur.fetchall()
                col_names = [desc[0] for desc in cur.description]
                table = PrettyTable(col_names)
                for row in result:
                    table.add_row(row)
                print(table)


            i = i + 1
        # Close the cursor and database connections
        cur.close()
        conn.close()

    # Print exception
    except Exception as e:
        print("Error connection: ", e)


# Run functions to perform itemset mining
create_coordinates()
create_lattices()
