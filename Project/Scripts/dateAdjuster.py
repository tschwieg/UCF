import sys
import csv
import glob
from datetime import datetime as dt


filecontents = ""

for args in glob.iglob("../Data/Cases/**/*.csv", recursive=True):
    args = str( args )
    print( args )
    with open(args, 'r') as csvfile:
        fileReader = csv.reader(csvfile, delimiter=',')
        for row in fileReader:
            dateString = dt.strptime(row[0], "%b %d %Y %H: +0")
            row[0] = dt.strftime(dateString, "%d-%m-%y")
            filecontents += ','.join(row) + "\n"
    with open( args, "w") as csvfile:
        csvfile.write( filecontents )
    filecontents = ""

