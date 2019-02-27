import pandas as pd
import numpy as np
import sys

for i in range( len(sys.argv)-1):
	print( "Preparing to read: " + sys.argv[i+1] )
	df = pd.read_csv( sys.argv[i+1],sep=',', header=None )
	
	df.drop(df.index[0],inplace=True)
	#sLength = len(df[1])
	#df[4] = pd.Series( df[0], index=df.index )
	#df[0] = pd.Series(range(sLength), index=df.index)
	
	
	print(df)
	#print( sLength )
	
	df.to_csv( sys.argv[i+1], sep=',', header=None )