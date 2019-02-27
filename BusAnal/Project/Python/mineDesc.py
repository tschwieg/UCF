import pandas as pd
import numpy as np
import copy
import sys

df = pd.read_csv( "fixed_desc.csv", sep=',', header=None)
sLength = len( df[0] )

Brackets = {}
Parenthesis = {}
Colons = {}
DoubleQuotes = {}
Functions = {}


functionCounter = 0
for index, row in df.iterrows():
	Desc = row[2]
	
	
	
	if( type(Desc) is str ):
		Desc = Desc.lower()
		
		bracketDesc = copy.copy(Desc)
		parDesc = copy.copy(Desc)
		colonDesc = copy.copy(Desc)
		FunctionDesc = copy.copy(Desc)
		
		#Look for shit inside of []
		if '[' in bracketDesc and ']' in bracketDesc:
			Inside = (bracketDesc.split( '[' )[1]).split(']')[0]
			if( Inside not in Brackets ):
				Brackets[Inside] = []
			Brackets[Inside].append( index )
				
		
		#This was an absolute failure
		'''
		if '(' in parDesc and ')' in parDesc:
			Inside = (parDesc.split( '(' )[1]).split(')')[0]
			if( Inside in Parenthesis ):
				Parenthesis[Inside] += 1
			else:
				Parenthesis[Inside] = 1
		'''		
		
		
		while ':' in colonDesc:
			WordBefore = colonDesc.split( ':' )[0]
			colonDesc = colonDesc.replace( WordBefore + ':', "" )
			if ' ' in WordBefore:
				WordBefore = WordBefore.split( ' ' )[-1]
			if WordBefore not in Colons:
				Colons[WordBefore] = []
			Colons[WordBefore].append( index )
				
		'''
		#I don't even want to talk about this one
		if '\"' in quoteDesc and quoteDesc.count('\"') >= 2:
			#print( quoteDesc )
			Inside = quoteDesc.split('\"')[1]
			if Inside in DoubleQuotes:
				DoubleQuotes[Inside] += 1
			else:
				DoubleQuotes[Inside] = 1
		'''
		
		#This is begging for a GREP
		while(  "()" in FunctionDesc ):
			WordBefore = FunctionDesc.split( '()' )[0]
			FunctionDesc = FunctionDesc.replace( WordBefore + "()", "" )
			if ' ' in WordBefore:
				WordBefore = WordBefore.split( ' ' )[-1]
			if '.' in WordBefore:
				WordBefore = WordBefore.split( '.' )[-1]
			if '#' in WordBefore:
				WordBefore = WordBefore.split( '#' )[-1]
			if '::' in WordBefore:
				WordBefore = WordBefore.split( '::' )[-1]
			if( WordBefore not in Functions ):
				Functions[WordBefore] = []
			Functions[WordBefore].append( index )
			functionCounter += 1

		
	else:
		print( row[0] )


LargeBrackets = { key:value for key, value in Brackets.items() if len(value) >= 50 }
LargeColons = { key:value for key, value in Colons.items() if len(value) >= 50 }
LargeFunctions = { key:value for key, value in Functions.items() if len(value) >= 50 }

for key in sorted( LargeBrackets, key=LargeBrackets.get):
	del Brackets[key]
	
for key in sorted( LargeColons, key=LargeColons.get):
	del Colons[key]

for key in sorted( LargeFunctions, key=LargeFunctions.get):
	del Functions[key]



'''print( "\n\nBrackets:" )
bracketCount = 0

for key in sorted( Brackets, key=Brackets.get):
	print( str(key)  + " : " + str( Brackets[key] ) )
	bracketCount += 1
print( bracketCount )
	
	
print( "\n\nParthensis:" )
for key in sorted( Parenthesis, key=Parenthesis.get):
	if( Parenthesis[key] > 50 ):
		print( str(key)  + " : " + str( Parenthesis[key] ) )
		
print( "\n\nColons:" )

for key in sorted( Colons, key=Colons.get):
	print( str(key)  + " : " + str( Colons[key] ) )
		
print( "\n\nQuotes:" )
for key in sorted( DoubleQuotes, key=DoubleQuotes.get):
	if( DoubleQuotes[key] > 25 ):
		print( str(key)  + " : " + str( DoubleQuotes[key] ) )'''
		
'''DescBins = []
		
sqlString = "CREATE TABLE DESC_Indicator(RowID integer,BugID INTEGER"
for key in sorted( LargeBrackets, key=LargeBrackets.get):
	sqlString += ",DESC_Brackets_" + key + " INTEGER"
	DescBins.append( "DESC_Brackets_" + key )
sqlString += ",DESC_Brackets_undisclosed" + key + " INTEGER"
DescBins.append( "DESC_Brackets_undisclosed" )

for key in sorted( LargeColons, key=LargeColons.get):
	sqlString += ",DESC_Colon_" + key + " INTEGER"
	DescBins.append( "DESC_Colon_" + key )
sqlString += ",DESC_Colon_undisclosed INTEGER"
DescBins.append( "DESC_Colon_undisclosed" )

for key in sorted( LargeFunctions, key=LargeFunctions.get):
	sqlString += ",DESC_Function_" + key + " INTEGER"
	DescBins.append( "DESC_Function_" + key )
sqlString += ",DESC_Function_undisclosed INTEGER"
DescBins.append( "DESC_Function_undisclosed" )
sqlString += ");"

sqlString +="\n\nCREATE TABLE DESC_Clean(BugID int "
counter = 1
for bin in DescBins:
	sqlString += "," + bin + " int"
	counter += 1
sqlString += " );"
sqlString += "\n\nINSERT INTO DESC_Clean( BugID"
counter = 1
for bin in DescBins:
	sqlString += "," + bin
	counter += 1
sqlString += " )\nSELECT a.BugID, max( a.TimeStamp)"
counter = 1
for bin in DescBins:	
	sqlString += ",max(a." + bin + ")"
	counter += 1
sqlString += "\nFROM DESC_Indicator as a\nLEFT OUTER JOIN DESC_Indicator as ca on ca.BugID = a.BugID\nGROUP BY a.BugID;"

print( sqlString )'''



rowCounter = 0
text = ""
for index, row in df.iterrows():
	Desc = row[2]
	if( type(Desc) is str ):
		Desc = Desc.lower()
		text += str( rowCounter )
		rowCounter += 1
		text += ',' + str( int(row[1]) )
		for key in sorted( LargeBrackets, key=LargeBrackets.get):
			if( index in LargeBrackets[key] ):
				text += ",1"
			else:
				text += ",0"
		found = 0
		for key in sorted( Brackets, key=Brackets.get):
			if( index in Brackets[key] ):
				found = 1
		if found:
			text += ",1"
		else:
			text += ",0"
		
		for key in sorted( LargeColons, key=LargeColons.get):
			if( index in LargeColons[key] ):
				text += ",1"
			else:
				text += ",0"
				
		found = 0
		for key in sorted( Colons, key=Colons.get):
			if( index in Colons[key] ):
				found = 1
		if found:
			text += ",1"
		else:
			text += ",0"
			
		#Add function check here

		for key in sorted( LargeFunctions, key=LargeFunctions.get):
			if( index in LargeFunctions[key] ):
				text += ",1"
			else:
				text += ",0"
		found = 0
		for key in sorted( Functions, key=Functions.get):
			if( index in Functions[key] ):
				found = 1
		if found:
			text += ",1"
		else:
			text += ",0"
		
		text += "\n"
		
		
indicatorDesc = open( "csvs//Indicator_Desc.csv", "w" )
indicatorDesc.write( text )
indicatorDesc.close()
