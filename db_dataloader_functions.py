import psycopg
import common

def quote_escape(string_to_escape):
    escaped = string_to_escape.replace("'", "''")
    return escaped

def resolve_vendor_name(id):
    return "CMT" if id==1 else "VTS"

def resolve_store_and_fwd(strstate):
    return strstate!='N'

def resolve_ratecode_name(ratecodeid):
    return str(ratecodeid)+"rate"

def resolve_payment_name(pay_id):
    return str(pay_id)+"payment"

def convert_money_to_millicent(amount):
    return amount * 1e2

# assumption is that there are not too many different vendor name
VENDOR_ID_TO_NAME_DICT = {}
# assumption is that there are not too many different ratecode ID
RATECODE_ID_TO_NAME_DICT = {}
# assumption is that there are not too many different payment type
PAYMENT_ID_TO_NAME_DICT = {}

# filling multiple table through same function to avoid reading large file multiple times 
def taxi_trip_vendor_loader(conn):
    cur = conn.cursor()

    # load the data
    # there is no taxi id so assuming each row is from different taxi
    taxi_id = 0
    print("")
    for filepath in common.DATA_FILEPATH_LIST:
        taxi_data_list = []
        trip_data_list = []
        trip_detail_data_list = []
        vendor_data_list = []
        with open(filepath) as f:
            index = 0
            for line in f.readlines():
                row = line.rsplit("\n")[0].split(",")
                index+=1
                # ignore header line
                if index == 1:
                    continue
                
                print(index, end="\r")
                vendor_id = "null"
                vendor_name = "null"
                pickupDate = "null"
                pickupTime = "null"
                dropoffDate = "null"
                dropoffTime = "null"
                passengercount = "null"
                trip_distance = "null"
                pickuplong = "null"
                pickuplat = "null"
                droplong = "null"
                droplat = "null"
                store_and_fwd_str = "null"
                # now to parse rows and insert

                # get the vendor id first
                vendor_id = int(row[0])
                # name
                vendor_name = resolve_vendor_name(vendor_id)
                pickupDate = row[1].split()[0]
                pickupTime = row[1].split()[1]
                dropoffDate = row[2].split()[0]
                dropoffTime = row[2].split()[1]
                passengercount = int(row[3])
                trip_distance = float(row[4])
                pickuplong = float(row[5])
                pickuplat = float(row[6])
                droplong = float(row[9])
                droplat = float(row[10])
                store_and_fwd_str = row[8] 

                # try creating data insertion tuples
                try:
                    # assuming each row is separate taxi and trip
                    taxi_id += 1
                    trip_id = taxi_id
                    taxi_data_list.append(
                        "(%s, %s, TO_DATE('%s','YYYY-MM-DD'), TO_TIMESTAMP('%s', 'HH24:MI:SS')::TIME, TO_DATE('%s','YYYY-MM-DD'), TO_TIMESTAMP('%s', 'HH24:MI:SS')::TIME, %s, %s)" 
                        % (taxi_id, vendor_id, pickupDate, pickupTime, dropoffDate, dropoffTime, passengercount, resolve_store_and_fwd(store_and_fwd_str))
                    )
                except Exception as e:
                    print("Exception in inserting in Taxi table ", taxi_id, vendor_id, pickupDate, pickupTime, dropoffDate, dropoffTime, passengercount, resolve_store_and_fwd(store_and_fwd_str))
                    print(str(e))
                    cur.close()
                    exit(0)

                try:
                    # assuming each row is separate taxi and trip
                    trip_id = taxi_id
                    trip_data_list.append(
                        "(%s, %s)" % (taxi_id, trip_id)
                    )
                    trip_detail_data_list.append(
                        "(%s, %s, %s, %s, %s, %s)" % (trip_id, trip_distance, pickuplong, pickuplat, droplong, droplat)
                    )
                except Exception as e:
                    print("Exception in inserting in Trip/TaxiTrip table ", taxi_id, trip_id, trip_distance, pickuplong, pickuplat, droplong, droplat)
                    print(str(e))
                    cur.close()
                    exit(0)

                try:
                    if vendor_id not in VENDOR_ID_TO_NAME_DICT:
                        VENDOR_ID_TO_NAME_DICT[vendor_id] = resolve_vendor_name(vendor_id)
                        vendor_data_list.append(
                            "(%s, '%s')" % (vendor_id, quote_escape(resolve_vendor_name(vendor_id)))
                        )
                except Exception as e:
                    print("Exception in inserting in Vendor table ", vendor_id, quote_escape(resolve_vendor_name(vendor_id)))
                    print(str(e))
                    cur.close()
                    exit(0)
                
                # commit at each 2e5 batch to keep memory consumption under control
                if index % 2e5 == 0:
                    try:
                        cur.execute("INSERT INTO Taxi(txID, vendorID, pickupDate, pickupTime, dropoffDate, dropoffTime, passengerCount, storeAndFwd) VALUES" + ",".join(taxi_data_list))
                    except Exception as e:
                        print("exception in taxi table")
                        print(str(e))
                        exit(0)

                    try:
                        if len(vendor_data_list) > 0:
                            cur.execute("INSERT INTO Vendor(vendorID, vendorName) VALUES" + ",".join(vendor_data_list))
                    except Exception as e:
                        print("exception in vendor table")
                        print(str(e))
                        exit(0)

                    try:
                        cur.execute("INSERT INTO Taxi_Trip(txID, tripID) VALUES" + ",".join(trip_data_list))
                    except Exception as e:
                        print("exception in taxi trip table")
                        print(str(e))
                        exit(0)

                    try:
                        cur.execute("INSERT INTO Trip(tripID, tripDistance, pickupLongitude, pickupLatitude, dropoffLongitude, dropoffLatitude) VALUES" + ",".join(trip_detail_data_list))
                    except Exception as e:
                        print("exception in trip table")
                        print(str(e))
                        exit(0)

                    taxi_data_list = []
                    trip_data_list = []
                    vendor_data_list = []
                    trip_detail_data_list = []
        # do all the insertion at a time for efficiency reason
        # insert the remaining data
        try:
            cur.execute("INSERT INTO Taxi(txID, vendorID, pickupDate, pickupTime, dropoffDate, dropoffTime, passengerCount, storeAndFwd) VALUES" + ",".join(taxi_data_list))
        except Exception as e:
            print("exception in taxi table")
            print(str(e))
            exit(0)

        try:
            if len(vendor_data_list) > 0:
                cur.execute("INSERT INTO Vendor(vendorID, vendorName) VALUES" + ",".join(vendor_data_list))
        except Exception as e:
            print("exception in vendor table")
            print(str(e))
            exit(0)

        try:
            cur.execute("INSERT INTO Taxi_Trip(txID, tripID) VALUES" + ",".join(trip_data_list))
        except Exception as e:
            print("exception in taxi trip table")
            print(str(e))
            exit(0)

        try:
            cur.execute("INSERT INTO Trip(tripID, tripDistance, pickupLongitude, pickupLatitude, dropoffLongitude, dropoffLatitude) VALUES" + ",".join(trip_detail_data_list))
        except Exception as e:
            print("exception in trip table")
            print(str(e))
            exit(0)
    # commit it
    conn.commit()
    cur.close()


# filling multiple table through same function to avoid reading large file multiple times
def payment_type_rate_loader(conn):
    global PAYMENT_ID_TO_NAME_DICT, RATECODE_ID_TO_NAME_DICT
    cur = conn.cursor()
    # load the data

    # there is no trip id so assuming each row is from different trip
    trip_id = 0
    for filepath in common.DATA_FILEPATH_LIST:
        pay_data_list = []
        pay_detail_data_list = []
        rate_data_list = []
        print("")
        with open(filepath) as f:
            index = 0
    
            for line in f.readlines():
                row = line.rsplit("\n")[0].split(",")
                index+=1
                # ignore header line
                if index == 1:
                    continue
                
                print(index, end="\r")
                paytype_id = "null"
                pay_type = "null"
                rateid = "null"
                ratename = "null"
                payment_name = "null"
                fare_amount = "null"
                extra = "null"
                mtatax = "null"
                surcharge = "null"
                tip = "null"
                toll = "null"
                total = "null"

                # now to parse rows and insert
                paytype_id = int(row[11])
                payment_name = resolve_payment_name(paytype_id)
                ratecodeid = int(row[7])
                ratename = resolve_ratecode_name(ratecodeid)
                fare_amount = convert_money_to_millicent(float(row[12])) if row[12]!='' else "null"
                extra = convert_money_to_millicent(float(row[13])) if row[13]!='' else "null"
                mtatax = convert_money_to_millicent(float(row[14])) if row[14]!='' else "null"
                tip = convert_money_to_millicent(float(row[15])) if row[15]!='' else "null"
                toll = convert_money_to_millicent(float(row[16])) if row[16]!='' else "null"
                surcharge = convert_money_to_millicent(float(row[17])) if row[17]!='' else "null"
                total = convert_money_to_millicent(float(row[18])) if row[18]!='' else "null"
                
                # try creating data insertion tuples
                try:
                    # assuming each row is separate trip and payment
                    trip_id += 1
                    payment_id = trip_id
                    pay_detail_data_list.append(
                        "(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)" 
                        % (trip_id, paytype_id, ratecodeid, fare_amount, extra, mtatax, surcharge, tip, toll, total)
                    )
                except Exception as e:
                    print("Exception in inserting in Payment table ", trip_id, trip_id, pay_id, ratecodeid, fare_amount, extra, mtatax, surcharge, tip, toll, total)
                    print(str(e))
                    cur.close()
                    exit(0)

                try:
                    if paytype_id not in PAYMENT_ID_TO_NAME_DICT:
                        pay_data_list.append(
                            "(%s, '%s')" % (paytype_id, quote_escape(resolve_payment_name(paytype_id)))
                        )
                        PAYMENT_ID_TO_NAME_DICT[paytype_id] = quote_escape(resolve_payment_name(paytype_id))
                except Exception as e:
                    print("Exception in inserting in Type table ", paytype_id, quote_escape(resolve_payment_name(paytype_id)))
                    print(str(e))
                    cur.close()
                    exit(0)

                try:
                    if ratecodeid not in RATECODE_ID_TO_NAME_DICT:
                        RATECODE_ID_TO_NAME_DICT[ratecodeid] = quote_escape(resolve_ratecode_name(ratecodeid))
                        rate_data_list.append(
                            "(%s, '%s')" % (ratecodeid, RATECODE_ID_TO_NAME_DICT[ratecodeid])
                        )
                except Exception as e:
                    print("Exception in inserting in Vendor table ", vendor_id, quote_escape(resolve_vendor_name(vendor_id)))
                    print(str(e))
                    cur.close()
                    exit(0)
                
                # commit at each 2e5 batch to keep memory consumption under control
                if index % 2e5 == 0:
                    try:
                        cur.execute("INSERT INTO Payment(tripID, paymentType, rateCodeID, fareAmount, extra, mtaTax, surcharge, tipAmount, tollsAmount, totalAmount) VALUES"
                        + ",".join(pay_detail_data_list))
                        if len(pay_data_list) > 0:
                            cur.execute("INSERT INTO Type(typeID, paymentName) VALUES" + ",".join(pay_data_list))
                        if len(rate_data_list) > 0:
                            cur.execute("INSERT INTO Rate(rateCodeID, rateName) VALUES" + ",".join(rate_data_list))
                    except Exception as e:
                        print(str(e))
                        exit(0)
                    pay_detail_data_list = []
                    pay_data_list = []
                    rate_data_list = []
        # do all the insertion at a time for efficiency reason
        # insert the remaining data
        try:
            cur.execute("INSERT INTO Payment(tripID, paymentType, rateCodeID, fareAmount, extra, mtaTax, surcharge, tipAmount, tollsAmount, totalAmount) VALUES"
            + ",".join(pay_detail_data_list))
            if len(pay_data_list) > 0:
                cur.execute("INSERT INTO Type(typeID, paymentName) VALUES" + ",".join(pay_data_list))
            if len(rate_data_list) > 0:
                cur.execute("INSERT INTO Rate(rateCodeID, rateName) VALUES" + ",".join(rate_data_list))
        except Exception as e:
            print(str(e))
            exit(0)
    # commit
    conn.commit()
    cur.close()

def db_constraint_loader(conn):
    cur = conn.cursor()
    cur.execute(open(common.DATABASE_CONSTRAINT_SCRIPT).read())
    conn.commit()
    cur.close()
