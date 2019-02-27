import pandas as pd


df = pd.read_csv( "cc.csv", sep=',', header=None)

printString = ""
trueRowID = 0
for index, row in df.iterrows():
	
	
	
	#rowID = row[0]
	bugID = row[1]
	cc = row[2]
	timestamp = row[3]
	reporterID = row[4]
	
	if( cc == ' ' ):
		continue
	
	#data[i] = data[i].replace( ",", " ")
	for indCC in cc.split( ';' ):
		printString = printString + str(trueRowID) + "," + str(bugID) + "," + str(indCC) + "," + str(timestamp) + "," + str(reporterID) + "\n"
		trueRowID += 1

	#if( trueRowID > 10000 ):
		#break

printer = open( "fixed_cc.csv", "w")
printer.write(printString )
printer.close()
	
		
