sqlite3 test.db '.read SQL//CreateTables.sql'
rm test.db
python Python//BuildDataSet.py > TableInfo.txt
sqlite3 test.db '.read SQL//CreateIndicatorPY.sql'
rm test.db
Rscript Rscripts//BuildData.r

