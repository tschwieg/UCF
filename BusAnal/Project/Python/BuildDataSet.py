import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import copy
import sys

Clm = {"ID" : 0,
	"Resolution" : 1,
"Statuses" : 2,
"Assignments" : 5,
"ReporterIds" : 4,
"BugStatus" : 6,
"OS" : 7,
"Priorities" : 8,
"Resolutions" : 9,
"Severity" : 10,
"Vesions" : 11,
"TimeOpened" : 12, 
"Desc" : 13,
"Prod" : 14,
"CC" : 15,
"BugChanges" : 16,
"comp" : 17
}


df = pd.read_csv( "csvs//BigCsv.csv", sep=',', header=None)
sLength = len( df[0] )

PossibleResolutions = {}
PossibleStatuses = {}
Assignments = {}
Products = {}
CCs = {}

ReporterIDs = {}
ReporterIDList = []

BugStatus= {}
OperatingSystems = {}
Priorities = {}
Resolutions = {}
Severity = {}
Versions = {}
BugTimes = {}
Resolutions = {}
#OpeningTimes = []

BugStatusSizes = []

NumBins = 25
ComponentTypes = {}
nCols = len(df.columns)
numChecked = 0
for index, row in df.iterrows():
	escape = 0
	for i in range(1,12):
		if i != 9 and i != 1 and pd.isnull( row[i] ):
			print( "Failed on Column: "+ str( i ) )
			escape = 1
			break
	if escape:
		continue
	if pd.isnull(row[Clm["Resolution"]]):
		row[Clm["Resolution"]] = 'UNRESOLVED'
		
		
	for prods in row[Clm["Prod"]].lower().split(';'):
		if prods not in Products:
			Products[prods] = 1
		else:
			Products[prods] += 1
		
		
	if str(row[Clm["Resolution"]]).lower() not in PossibleResolutions:
		PossibleResolutions[str(row[Clm["Resolution"]]).lower()] = 1
	else:
		PossibleResolutions[str(row[Clm["Resolution"]]).lower()] += 1
			
			
	if row[Clm["Statuses"]] not in PossibleStatuses:
		PossibleStatuses[row[Clm["Statuses"]]] = 1
	else:
		PossibleStatuses[row[Clm["Statuses"]]] += 1
		
	for assigns in row[Clm["Assignments"]].lower().split(';' ):
		if assigns not in Assignments:
			Assignments[assigns] = 1
		else:
			Assignments[assigns] += 1
			#Assignments.append( assigns )
	for ccs in row[Clm["CC"]].split(';' ):
		if ccs == "@@@@EMPTY@@@@":
			continue
		if ccs not in CCs:
			CCs[ccs] = 1
		else:
			CCs[ccs] += 1			
			
			
	if row[Clm["ReporterIds"]] not in ReporterIDs:
		#ReporterIDs.append( row[Clm["ReporterIds"]] )
		ReporterIDs[row[Clm["ReporterIds"]]] = 1
	else:
		ReporterIDs[row[Clm["ReporterIds"]]] += 1
		
		
	row[Clm["Resolutions"]] = str(row[Clm["Resolutions"]])
	if( pd.isnull(row[Clm["Resolutions"]]) ):
		row[Clm["Resolutions"]] = "empty"
	for reso in row[Clm["Resolutions"]].lower().split( ';'):
		if not pd.isnull(reso) and reso not in Resolutions:
			Resolutions[reso] = 1
		elif not pd.isnull(reso):
			Resolutions[reso] += 1
		
	for status in row[Clm["BugStatus"]].lower().split( ';' ):
		if status not in BugStatus:
			BugStatus[status] = 1
		else:
			BugStatus[status] += 1
	
	for system in row[Clm["OS"]].lower().split( ';' ):
		if system not in OperatingSystems:
			OperatingSystems[system] = 1
		else:
			OperatingSystems[system] += 1
			
	for prios in row[Clm["Priorities"]].lower().split( ';' ):
		if( prios not in Priorities ):
			Priorities[prios] = 1
		else:
			Priorities[prios] += 1
			
	for sever in row[Clm["Severity"]].lower().split(';'):
		if sever not in Severity:
			Severity[sever] = 1
		else:
			Severity[sever] += 1
			
	for vers in row[Clm["Vesions"]].lower().split(';'):
		if vers not in Versions:
			Versions[vers] = 1
		else:
			Versions[vers] += 1
	for comps in row[Clm["comp"]].lower().split(';'):
		if( comps not in ComponentTypes):
			ComponentTypes[comps] = 1
		else:
			ComponentTypes[comps] += 1
	
	numChecked = numChecked + 1
#	if row[3] not in OpeningTimes:
#			OpeningTimes.append( row[3] )



		
print( "Num Resolutions: " + str(len( PossibleResolutions )))
print( "Num Statuses: " + str(len(PossibleStatuses )))
print( "Num ReporterIDs: " +str(len(ReporterIDs )))
print( "Num BugStatuses: " + str(len(BugStatus )))
print( "Num OperatingSystems: " + str(len(OperatingSystems )))
print( "Num Priorities: " + str(len(Priorities )))
print( "Num Severities: " + str(len(Severity )))
print( "Num Versions: " + str(len(Versions )))
print( "Num Assignments: "+ str( len( Assignments )))
print( "Num CCs: " + str( len( CCs ) ) )

print( "Max of Bug Times: " + str( max( df.loc[:,Clm["TimeOpened"]] ) ) + " Min of times: " + str( min( df.loc[:,Clm["TimeOpened"]] ) ) )
#print( Resolutions )
dictCounte = 0
print( "\n\nStatuses:" )
#print( PossibleStatuses )



for key in PossibleStatuses:
	dictCounte += PossibleStatuses[key]
	print( str(key) + " : " + str(PossibleStatuses[key] ))
print( dictCounte )
dictCounte = 0



print( "\n\nResolutions:" )
#print( PossibleResolutions )
for key in PossibleResolutions:
	dictCounte += PossibleResolutions[key]
	print( str(key) + " : " + str(PossibleResolutions[key] ))
print( dictCounte )
dictCounte = 0

print( "\n\nOperating System:" )
#print( OperatingSystems )
for key in sorted(OperatingSystems, key=OperatingSystems.get):
	if( OperatingSystems[key] >= 100 ):
		print( str( key ) + " : " + str(OperatingSystems[key]) )

dictCounte = 0

print( "\n\nPriority" )
#print( Priorities )
for key in Priorities:
	dictCounte += Priorities[key]
	print( str( key ) + " : " + str(Priorities[key]) )
print( dictCounte )
dictCounte = 0

print( "\n\nBug Status" )
#print( Priorities )
for key in BugStatus:
	dictCounte += BugStatus[key]
	print( str( key ) + " : " + str(BugStatus[key]) )
print( dictCounte )
dictCounte = 0

print( "\n\nSeverity" )
#print( Severity )
for key in Severity:
	dictCounte += Severity[key]
	print( str( key ) + " : " + str(Severity[key]) )
print( dictCounte )
dictCounte = 0

print( "\n\nVersions" )
#print( Versions )
for key in sorted(Versions, key=Versions.get):
	if( Versions[key] >= 100 ):
		print( str( key ) + " : " + str(Versions[key]) )
	

print( "\n\nProducts:" )
for key in sorted( Products, key=Products.get):
	if( Products[key] >= 100 ):
		print( str(key)  + " : " + str( Products[key] ) )
print( len( Products ) )

print( "\n\nComponents:" )


for key in sorted( ComponentTypes, key=ComponentTypes.get):
	if( ComponentTypes[key] >= 100 ):
		print( str(key)  + " : " + str( ComponentTypes[key] ) )

print( "\nResolutions:" )
for key in sorted( Resolutions, key=Resolutions.get):
	if( Resolutions[key] >= 100 ):
		print( str(key)  + " : " + str( Resolutions[key] ) )


print( "\n\nNumber of Rows: " + str( numChecked ) )

sortedBugTimes = df.loc[:,Clm["TimeOpened"]].tolist()
sortedBugTimes.sort()

print( "\n\nBug Times:" )
BugTimeBins = []
for i in range(NumBins-1):
	#BugTimeBins.append( sortedBugTimes[int((len( sortedBugTimes ) / NumBins)*(i)):int((len( sortedBugTimes ) / NumBins)*(i+1))] )
	BugTimeBins.append( (sortedBugTimes[int((len( sortedBugTimes ) / NumBins)*(i))], sortedBugTimes[int((len( sortedBugTimes ) / NumBins)*(i+1))] ) )
	print( "Bin " + str( i ) + " starts at time: " + str( sortedBugTimes[int((len( sortedBugTimes ) / NumBins)*(i))] ) + " and ends at time: " + str( sortedBugTimes[int((len( sortedBugTimes ) / NumBins)*(i+1))] ) + " and has size: " + str( len(BugTimeBins[-1]))  )
#BugTimeBins.append( sortedBugTimes[int((len( sortedBugTimes ) / NumBins)*(NumBins-1)):len( sortedBugTimes )] )
BugTimeBins.append( ( sortedBugTimes[int((len( sortedBugTimes ) / NumBins)*(NumBins-1))],sortedBugTimes[len( sortedBugTimes )-1] ) )

AssignmentList = []
AssignmentBins = []
for key in sorted(Assignments, key=Assignments.get):
    AssignmentList.append( key )
    
for i in range( NumBins-1 ):
	AssignmentBins.append( AssignmentList[ int((len( AssignmentList) / NumBins)*(i)):int((len(AssignmentList)/ NumBins)*(i+1))] )                          
AssignmentBins.append( AssignmentList[int((len( AssignmentList ) / NumBins)*(NumBins-1)):len( AssignmentList )] )

print( "\n\nAssignment Bins: " )
counter = 1
for bin in AssignmentBins:
	print( "Assignment Bin #" + str( counter ) )
	counter += 1
	print( bin )


ReporterList = []
for key in sorted( ReporterIDs, key=ReporterIDs.get):
	ReporterList.append( key )

bins = []
for i in range( NumBins-1 ):
	bins.append( ReporterList[ int((len( ReporterList) / NumBins)*(i)):int((len(ReporterList)/ NumBins)*(i+1))] )                          
bins.append( ReporterList[int((len( ReporterList ) / NumBins)*(NumBins-1)):len( ReporterList )] )	
print( "\n\nReporter Bins: " )
counter = 1
for bin in bins:
	print( "Reporter Bin #" + str( counter ) )
	counter += 1
	print( bin )

CCList = []
CCBins = []
for key in sorted(CCs, key=CCs.get):
    CCList.append( key )

CCBins.append( ["@@@@EMPTY@@@@"])
for i in range( NumBins-2 ):
	CCBins.append( CCList[ int((len( CCList) / (NumBins-1))*(i)):int((len(CCList)/ (NumBins-1))*(i+1))] )                          
CCBins.append( CCList[int((len( CCList ) / (NumBins-1))*(NumBins-2)):len( CCList )] )

counter = 1
print( "\n\nCC Bins: " )
for bin in CCBins:
	print( "CC Bin #" + str( counter ) )
	counter += 1
	print( bin )
	
	
Products = { key:value for key, value in Products.items() if value >= 75 }
ComponentTypes = { key:value for key, value in ComponentTypes.items() if value >= 75 }
Versions = { key:value for key, value in Versions.items() if value >= 75 }
OperatingSystems = { key:value for key, value in OperatingSystems.items() if value >= 75 }

del BugStatus["new"]
#del Priorities["P5"]
#del Severity["blocker"]

#del PossibleResolutions["fixed"]
#del PossibleResolutions["unresolved"]
#BugStatus?
#ComponentType?
#Resolution?
#Priority?

#Severity?

PossibleResolutions = { "fixed" : 1 }
#PossibleResolutions = { "fixed" : 1, "worksforme" : 1, "duplicate" : 1, "invalid" : 1, "wontfix" : 1, "not_eclipse" : 1 }

text = """--This Code is AutoGenerated by BuildDataSet.py

create table Reports(
BugID integer,
CurResolution text not null,
CurStatus text,
OpeningTime integer not null,
ReporterID integer not null,
primary key (BugID));
CREATE TABLE AssignedTo(
RowID integer,
BugID INTEGER ,
Assignment VARCHAR(128) NOT NULL,
Timestamp INTEGER NOT NULL,
ReporterID INTEGER NOT NULL,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID) );
CREATE TABLE BugStatus(
RowID integer,
BugID INTEGER,
BugStatus TEXT NOT NULL,
Timestamp INTEGER NOT NULL,
ReporterID INTEGER NOT NULL,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );
CREATE TABLE Comp(
RowID		integer,
BugID		INTEGER,
Component	TEXT NOT NULL,
Timestamp	INTEGER NOT NULL,
Reporterid	INTEGER NOT NULL,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );
CREATE TABLE OperatingSystem(
RowID			integer,
BugID			INTEGER,
OperatingSystem	text not null,
Timestamp		integer not null,
Reporterid		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );
CREATE TABLE Priority(
RowID			integer,
BugID			INTEGER,
Priority		text not null,
Timestamp		integer not null,
Reporterid		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );
CREATE TABLE Product(
RowID			integer,
BugID			INTEGER,
ProductType		text not null,
Timestamp		integer not null,
Reporterid		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );


CREATE TABLE temp_Resolution(
RowID			integer,
BugID			INTEGER,
Resolution		text,
Timestamp		integer not null,
Reporterid		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );


CREATE TABLE Severity(
RowID			integer,
BugID			INTEGER,
Severity		text not null,
Timestamp		integer not null,
Reporterid		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );
CREATE TABLE Version(
RowID			integer,
BugID			INTEGER,
Version			text not null,
Timestamp		integer not null,
Reporterid		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );
CREATE TABLE Description(
RowID 			integer,
BugID			INTEGER,
Descript		Varchar( 256),
Timestamp		integer not null,
ReporterID		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY( RowID ) );
CREATE TABLE CC(
RowID 			integer,
BugID			INTEGER,
Copied		Varchar( 256),
Timestamp		integer not null,
ReporterID		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY( RowID ) );
.separator ,
.import csvs/reports.csv Reports
.import csvs/assigned_to.csv AssignedTo
.import csvs/bug_status.csv BugStatus
.import csvs/component.csv Comp
.import csvs/op_sys.csv OperatingSystem
.import csvs/priority.csv Priority
.import csvs/product.csv Product
.import csvs/resolution.csv temp_Resolution
.import csvs/severity.csv Severity
.import csvs/version.csv Version
.import csvs/fixed_desc.csv Description
.import csvs/fixed_cc.csv CC


CREATE TABLE Resolution(
RowID			integer,
BugID			INTEGER,
Resolution		text,
Timestamp		integer not null,
Reporterid		integer not null );


CREATE TABLE MAX_Resolution(
RowID			integer,
BugID			INTEGER,
Resolution		text,
Timestamp		integer not null,
Reporterid		integer not null );

--Using a combination of witchcraft and far more sinister sql, this removes the Row of Resolution with the maximum timestamp value.
--It seems logical that this would be the value equal to what we find in product, while preserving other resolution claims.
INSERT INTO Resolution( RowID, BugID, Resolution, Timestamp, Reporterid )
SELECT DISTINCT a.RowID, a.BugID, a.Resolution, a.Timestamp, a.Reporterid 
FROM temp_Resolution a
LEFT OUTER JOIN temp_Resolution b
    ON a.BugID = b.BugID AND a.Timestamp < b.Timestamp
WHERE b.BugID IS NULL;"""

"""INSERT INTO Resolution( RowID, BugID, Resolution, Timestamp, Reporterid )
SELECT RowID, BugID, Resolution, Timestamp, Reporterid
FROM temp_Resolution
EXCEPT 
SELECT RowID, BugID, Resolution, Timestamp, Reporterid
FROM MAX_Resolution;
"""

def CleanKey( key ):
	#return str(key).replace(".","").replace("-","").replace(" ","_").replace( "(","").replace( ")","").replace( ">", "" ).replace( "<", "" )
	return str(key).replace(" ","_").translate( None, ".-()<>" )

def AddDictToTable( Dict, Prefix ):
	text = ""
	for key in Dict:
		text += ", " + Prefix + "_" + CleanKey(key) + " int"
	return text

def CreateIndicatorForTable( Dict, Prefix,abbrev, field, fn  ):
	text ="\n\nCREATE TABLE " + Prefix + "_Indicator(BugID int, TimeStamp int"
	text += AddDictToTable( Dict, Prefix )
	text += " );"
	text += "\n\nINSERT INTO " + Prefix + "_Indicator( BugID, TimeStamp"
	for key in Dict:
		text += ", " + Prefix + "_" + CleanKey(key) 
	text += ")\nSELECT r.BugID," + abbrev + ".Timestamp"
	for key in Dict:
		text += ",LOWER(" + abbrev + "." + field + ") LIKE \"" + str(key) +"\" "
	text += "\nFROM Reports as r, " + Prefix + " as " + abbrev + "\nWHERE r.BugID = " + abbrev + ".BugID"
	#text += " and " + abbrev + ".TimeStamp < r.ClosingTime"
	text += ";"
	
	
	text +="\n\nCREATE TABLE " + Prefix + "_Clean(BugID int, TimeStamp int"
	text += AddDictToTable( Dict, Prefix )
	text += " );"
	text += "\n\nINSERT INTO " + Prefix + "_Clean( BugID, TimeStamp"
	for key in Dict:
		text += ", " + Prefix + "_" + CleanKey(key) 
	text += ")\nSELECT a.BugID, max( ca.TimeStamp)"
	for key in Dict:
		text += "," + fn + "(a."+Prefix + "_" + CleanKey(key) + ")"
	text += "\nFROM " + Prefix + "_Indicator as a\nLEFT OUTER JOIN " + Prefix + "_Indicator as ca on ca.BugID = a.BugID\nGROUP BY a.BugID;\n\ndrop table " + Prefix + "_Indicator;"
	return text

text += CreateIndicatorForTable( PossibleStatuses, "BugStatus", "bs", "BugStatus", "SUM" )
#text += CreateIndicatorForTable( PossibleResolutions, "Resolution", "res", "Resolution", "MAX" )
text += CreateIndicatorForTable( OperatingSystems, "OperatingSystem", "os", "OperatingSystem", "MAX" )
text += CreateIndicatorForTable( Priorities, "Priority", "prio", "Priority", "MAX" )
text += CreateIndicatorForTable( Severity, "Severity", "sev", "Severity", "MAX" )
text += CreateIndicatorForTable( Versions, "Version", "ver", "Version", "MAX" )
text += CreateIndicatorForTable( Products, "Product", "prod", "ProductType", "MAX" )
text += CreateIndicatorForTable( ComponentTypes, "Comp", "cmp", "Component", "MAX" )


def CreateIndicatorFromBins( Bins, Prefix,abbrev, field, fn ):
	text ="\n\nCREATE TABLE " + Prefix + "_Indicator(BugID int, TimeStamp int"
	counter = 1
	for bin in Bins:
		text += "," + Prefix + "_bin" + str( counter ) + " int"
		counter += 1
	text += " );"
	text += "\n\nINSERT INTO " + Prefix + "_Indicator( BugID, TimeStamp"
	counter = 1
	for bin in Bins:
		text += "," + Prefix + "_bin" + str( counter )
		counter += 1
			
	text += ")\nSELECT r.BugID," + abbrev + ".Timestamp"
	
	for bin in Bins:
		ztext = ""
		for zbin in bin:
			ztext += str(zbin) + ";"
		text += ",\"" + ztext +"\" LIKE" "\"%\"||" + abbrev + "." + field + "||\"%\"" 
	text += "\nFROM Reports as r, " + Prefix + " as " + abbrev + "\nWHERE r.BugID = " + abbrev + ".BugID;"
	
	text +="\n\nCREATE TABLE " + Prefix + "_Clean(BugID int, TimeStamp int"
	counter = 1
	for bin in Bins:
		text += "," + Prefix + "_bin" + str( counter ) + " int"
		counter += 1
	text += " );"
	text += "\n\nINSERT INTO " + Prefix + "_Clean( BugID, TimeStamp"
	counter = 1
	for bin in Bins:
		text += "," + Prefix + "_bin" + str( counter )
		counter += 1
	text += " )\nSELECT a.BugID, max( a.TimeStamp)"
	counter = 1
	for bin in Bins:	
		text += "," + fn + "(a."+Prefix + "_bin" + str(counter) + ")"
		counter += 1
	text += "\nFROM " + Prefix + "_Indicator as a\nLEFT OUTER JOIN " + Prefix + "_Indicator as ca on ca.BugID = a.BugID\nGROUP BY a.BugID;\n\ndrop table " + Prefix + "_Indicator;"
	return text

text += CreateIndicatorFromBins( AssignmentBins, "AssignedTo", "asto", "Assignment", "MAX" )
text += CreateIndicatorFromBins( CCBins, "CC", "copy", "Copied", "MAX" )

bugStatusFillerDict = {}
bugStatusDict = {}
bugStatusDict["VERIFIED"] = [0,3,4,5,6,7]
bugStatusDict["RESOLVED"] = [0,2,3,4,5,8,10,12]
bugStatusDict["REOPENED"] = [0,4,5,6,7]
bugStatusDict["NEW"] = [0,1,2,3,4,5,6,8,10,12]
bugStatusDict["CLOSED"] = [0,2,3,4]
bugStatusDict["ASSIGNED"] = [0,2,3,4,5,6,10,12,14]

text += "\n\nCREATE TABLE BugStatus_MULTIPLE_Clean(BugID int, TimeStamp int"
for key in bugStatusDict:
	for element in bugStatusDict[key]:
		text += ", BugStatus_MULTIPLE_" + key + str(element) + " int"
		bugStatusFillerDict[ key + str(element) ] = 1
text += ");\n\n INSERT INTO BugStatus_MULTIPLE_Clean(BugID, TimeStamp"
for key in bugStatusDict:
	for element in bugStatusDict[key]:
		text += ", BugStatus_MULTIPLE_" + key + str(element)
text += ")\nSELECT a.bugID, a.TimeStamp"
for key in bugStatusDict:
	for element in bugStatusDict[key]:
		text += ", a.BugStatus_" + key + " = " + str(element )
text += "\nFROM BugStatus_Clean as a;"


#This hack lets our bins be loaded the same way that the dicts are being loaded
fakedict = {}
for i in range( 2,(NumBins+1) ):
	fakedict["bin" + str(i)] = 1


text += "\n\ncreate table IndicatorTable( BugID int, Fixed int"
#text += AddDictToTable( PossibleStatuses, "BugStatus" )
text += AddDictToTable( bugStatusFillerDict, "BugStatus_MULTIPLE" )
#text += AddDictToTable( PossibleResolutions, "Resolution" )
text += AddDictToTable( OperatingSystems, "OperatingSystem" )
text += AddDictToTable( Priorities, "Priority" )
text += AddDictToTable( Severity, "Severity" )
text += AddDictToTable( Versions, "Version" )
text += AddDictToTable( Products, "Product" )
text += AddDictToTable( ComponentTypes, "Comp" )
text += AddDictToTable( fakedict, "AssignedTo" )
text += AddDictToTable( fakedict, "CC" )

counter = 0
for bin in BugTimeBins:
	text += ",TimeStamp" + str( counter )
	counter += 1
	text += " int"
text += ");"

	
def BuildInsertStatement( dictlist ):
	text = "\n\nINSERT INTO IndicatorTable( BugID, Fixed"
	for dicts in dictlist:
		for key in dicts["dict"]:
			text += ", " + dicts["prefix"] + "_" + CleanKey(key)
	counter = 0
	for bin in BugTimeBins:
		text += ",TimeStamp" + str( counter )
		counter += 1
	text += ")\nSELECT r.BugID, r.CurResolution LIKE \"FIXED\" "
	for dicts in dictlist:
		for key in dicts["dict"]:
			text += "," + dicts["abbrev"] + "." + dicts["prefix"]+"_" + CleanKey(key)
			
	maxStatement = "(max("
	for dicts in dictlist:
		maxStatement += dicts["abbrev"] + ".TimeStamp,"
	maxStatement += "0)- r.OpeningTime)"
	for bin in BugTimeBins:
		text += ",( " + maxStatement + " > " + str(bin[0]) + " and " + maxStatement + " <= " + str(bin[1]) + " ) "
	
		
		
		
	text += "\nFROM Reports as r"
	for dicts in dictlist:
		text += ", " + dicts["prefix"] + "_Clean as " + dicts["abbrev"]
	text += "\nWHERE "
	skip = 0
	for dicts in dictlist:
		if( skip ):
			text += " and "
		skip = 1
		text += "r.BugID = " + dicts["abbrev"] + ".bugID"
	text += ";"
	return text



dictlist = [ #{"dict" : PossibleStatuses, "prefix" : "BugStatus", "abbrev" : "bs" },
	{"dict" : bugStatusFillerDict, "prefix" : "BugStatus_MULTIPLE", "abbrev" : "bs" },
	#{"dict" : PossibleResolutions, "prefix" : "Resolution", "abbrev" : "res" },
	{"dict" : OperatingSystems, "prefix" : "OperatingSystem", "abbrev" : "os" },
	{"dict" : Priorities, "prefix" : "Priority", "abbrev" : "prio" },
	{"dict" : Severity, "prefix" : "Severity", "abbrev" : "sev" },
	{"dict" : Versions, "prefix" : "Version", "abbrev" : "ver" },
{"dict" : Products, "prefix" : "Product", "abbrev" : "prod" },
{"dict" : ComponentTypes, "prefix" : "Comp", "abbrev" : "cmp" },
{"dict" : fakedict, "prefix" : "AssignedTo", "abbrev" : "asto" },
{"dict" : fakedict, "prefix" : "CC", "abbrev" : "copy" }
]

text += BuildInsertStatement( dictlist )

text += "\n\n.mode csv\n.headers on\n.output csvs/IndicatorTest.csv\nSELECT * FROM IndicatorTable;"

sqlfile = open( "SQL//CreateIndicatorPY.sql", "w" )
sqlfile.write( text )
sqlfile.close()