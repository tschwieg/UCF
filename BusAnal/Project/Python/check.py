import pandas as pd
import sys

Tables = {"Reports" : pd.read_csv( "reports.csv",sep=',', header=None ),
	"AssignedTo" : pd.read_csv( "assigned_to.csv",sep=',', header=None ),
	"BugStatus" : pd.read_csv( "bug_status.csv",sep=',', header=None ),
"ComponentType" : pd.read_csv( "component.csv",sep=',', header=None ),
"OperatingSystem" : pd.read_csv( "op_sys.csv",sep=',', header=None ),
"Priority" : pd.read_csv( "priority.csv",sep=',', header=None ),
"Product" : pd.read_csv( "product.csv",sep=',', header=None ),
"Resolution" : pd.read_csv( "resolution.csv",sep=',', header=None ),
"Severity" : pd.read_csv( "severity.csv",sep=',', header=None ),
"Version" : pd.read_csv( "version.csv",sep=',', header=None ),
"Description" : pd.read_csv( "fixed_desc.csv",sep=',', header=None ) }

df = Tables["Reports"]

#for index, row in df.iterrows():
	#id = row[0]
	#resolutions = Tables["Resolution"][ 





