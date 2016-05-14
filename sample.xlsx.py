
import xlrd
#import MySQLdb
import mysql.connector

#email, password, device_id, role, phone_number, name, Datecreated, datemodify, region, subregion) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"""
# Open the workbook and define the worksheet
book = xlrd.open_workbook("FSS.xlsx")
sheet = book.sheet_by_name("Sheet1")

# Establish a MySQL connection
database = mysql.connector.connect (host="127.0.0.1", user = "root", passwd = "kamal", db = "mydata")

# Get the cursor, which is used to traverse the database, line by line
cursor = database.cursor()

# Create the INSERT INTO sql query
query = """INSERT INTO data (email, password, device_id, role, phone_number, name, Datecreated, datemodify, region, subregion) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""

# Create a For loop to iterate through each row in the XLS file, starting at row 2 to skip the headers
for r in range(0, sheet.nrows):
      email= sheet.cell(r,0).value
      password= sheet.cell(r,1).value
      device_id = sheet.cell(r,2).value
      role= sheet.cell(r,3).value
      phone_number= sheet.cell(r,4).value
      name = sheet.cell(r,5).value
      Datecreated = sheet.cell(r,6).value
      datemodify = sheet.cell(r,7).value
      region= sheet.cell(r,8).value
      subregion= sheet.cell(r,9).value
     

      # Assign values from each row
      values =(email, password, device_id, role, phone_number, name, Datecreated, datemodify, region, subregion)

      # Execute sql Query
      cursor.execute(query, values)

# Close the cursor
cursor.close()

# Commit the transaction
database.commit()

# Close the database connection
database.close()

# Print results
print ""
print "Data  Successfully Inserted."
print ""
columns = str(sheet.ncols)
rows = str(sheet.nrows)
#print "I just imported " %2B columns %2B " columns and " %2B rows %2B " rows to MySQL!"
