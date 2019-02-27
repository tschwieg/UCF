import numpy as np

print( "using JuMP\nusing Cbc\nusing Pajarito\nusing Ipopt")

print( "m = Model( solver = PajaritoSolver(mip_solver=CbcSolver(),cont_solver=IpoptSolver()) )")
#print( "m = Model( solver = CbcSolver() )")

N = 17

C = np.matrix([[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] 
,[0,0,90,90,180,90,90,90,60,90,165,180,120,180,90,60,45]
,[0,60,0,60,150,90,105,75,105,60,90,180,120,45,30,105,80]
,[0,90,45,0,120,60,105,30,90,90,90,180,105,90,60,60,90]
,[0,60,60,60,0,60,90,75,60,45,60,150,30,15,30,75,75]
,[0,140,120,120,210,0,120,75,120,120,180,240,180,180,120,90,120]
,[0,150,90,90,115,30,0,90,30,90,90,180,150,120,90,90,30]
,[0,120,120,90,210,30,105,0,60,30,120,210,210,210,120,75,120]
,[0,120,105,90,180,30,150,105,0,90,105,180,180,180,90,110,120]
,[0,120,90,60,150,30,105,90,60,0,120,180,120,120,90,75,105]
,[0,60,120,120,120,60,90,60,60,60,0,180,120,120,90,60,90]
,[0,30,60,60,15,30,30,30,30,30,30,0,30,30,30,30,30]
,[0,90,90,120,120,30,30,30,30,30,60,180,0,90,60,90,30]
,[0,90,75,60,105,75,90,75,15,60,75,90,120,0,45,90,75]
,[0,90,30,90,120,90,105,45,90,30,90,180,105,120,0,90,90]
,[0,45,60,90,180,45,90,75,45,60,120,180,150,180,105,0,60]
,[0,60,75,90,120,45,120,90,45,90,120,180,60,150,90,75,0]])

for i in range(N):
	for j in range(N):
		if( i == j ):
			continue
		print( "@variable( m, X" + format( i,'02') + format( j, '02' ) + ", Bin )" )
		print( "@variable( m, Y" + format( i,'02') + format( j, '02' ) + ", Bin )" )
for i in range( 1,N ):
	print( "@variable( m, u" + format( i, '02' ) + " >= 0)" )

print( "@variable( m, -100 <= S <= 100 )" )

text = "@constraint( m, "
i= 0
for j in range(N):
	if( i == j ):
		continue
	text += "X" + format( i,'02') + format( j, '02' ) + " + "
text += " 0 == 1)"
print( text )

i= 0
text = "@constraint( m, "
for j in range(N):
	if( i == j ):
		continue
	text += "Y" + format( i,'02') + format( j, '02' ) + " + "
text += " 0 == 1)"
print( text )


j = 0
text = "@constraint( m, "	
for i in range(N):
	if( i == j ):
		continue
	text += "X" + format( i,'02') + format( j, '02' ) + " + "
text += " 0 == 1)"
print( text )

j = 0
text = "@constraint( m, "	
for i in range(N):
	if( i == j ):
		continue
	text += "Y" + format( i,'02') + format( j, '02' ) + " + "
text += " 0 == 1)"
print( text )


for i in range(1,N):
	text = "@constraint( m, "	
	for j in range(N):
		if( i == j ):
			continue
		text += "X" + format( i,'02') + format( j, '02' ) + " + Y" + format( i,'02') + format( j, '02' ) + " + "
	text += " 0 == 1)"
	print( text )
	
for j in range(1,N):
	text = "@constraint( m, "	
	for i in range(N):
		if( i == j ):
			continue
		text += "X" + format( i,'02') + format( j, '02' ) + " + Y" + format( i,'02') + format( j, '02' ) + " + "
	text += " 0 == 1)"
	print( text )
	
for k in range(1,N):
	text = "@constraint( m, "	
	for i in range(1,N):
		if( i == k ):
			continue
		text += "X" + format( i,'02') + format( k, '02' ) + " + Y" + format( k,'02') + format( i, '02' ) + " + "
	text += "Y" + format(k,'02') + "00 + X00" + format(k,'02') + " == 1)"
	print( text )
	
for k in range(1,N):
	text = "@constraint( m, "	
	for i in range(1,N):
		if( i == k ):
			continue
		text += "Y" + format( i,'02') + format( k, '02' ) + " + X" + format( k,'02') + format( i, '02' ) + " + "
	text += "X" + format(k,'02') + "00 + Y00" + format(k,'02') + " == 1)"
	print( text )	

for i in range(1,N):		
	for j in range(1,N):
		if( i == j ):
			continue
		print("@constraint( m, u" + format( i,'02') + " - u" + format( j,'02') + " + " + str(N) + "*X" + format( i,'02') + format( j, '02' ) + "  <= " + str(N-1) + " )"  )
		print("@constraint( m, u" + format( i,'02') + " - u" + format( j,'02') + " + " + str(N) + "*Y" + format( i,'02') + format( j, '02' ) + "  <= " + str(N-1) + " )"  )
		
#for i in range(1,N):
#	print( "@constraint( m, u" + format( i,'02') + " <= " + str(N) + " )" )
#	print( "@constraint( m, u" + format( i,'02') + " >= 2 )" )

demand = [[0,0,0,0,0],[153671,143543,137963,242349,187930],[113780,136334,131445,227383,180677],[144958,137176,123900,240497,184143],[112831,128612,120061,183559,144171],[69651,86305,71803,116771,87458],[63053,80685,69876,108356,83499],[60858,78485,71439,114834,90659],[84081,101392,81492,120853,93456],[36295,45315,32515,65120,48518],[34084,43324,29208,52000,50611],[53409,41516,30391,53390,47260],[34308,42293,29016,63564,48618],[34479,43170,28997,63560,49091],[39444,44076,30501,64355,50568],[32892,42824,28481,61799,48215],[30404,33583,29266,54496,48125]]
averageDemand = []
for d in demand:
	sum = 0
	for cell in d:
		sum += cell*.2
	averageDemand.append( sum )


text = "@constraint( m, "
for i in range(1,N):		
	#text += "ceil( ("
	for j in range(N):
		if( i == j ):
			continue
		text += str( np.ceil((averageDemand[i]*1000)/(2100*50)) ) + "*X"+ format( i,'02')+ format( j,'02') + " + "
	#text += "0 ) /2400 ) + "
		
		
text += "0 == "
for i in range(1,N):		
	#text += "ceil( ("
	for j in range(N):
		if( i == j ):
			continue
		text += str( np.ceil((averageDemand[i]*1000)/(2100*50)) ) + "*Y"+ format( i,'02')+ format( j,'02') + " + "
	#text += "0 ) /2400 ) + "
text += " S)"
print( text )


text = "@objective( m, Min, "
for i in range(1,N):		
	for j in range(1,N):
		if( i == j ):
			continue
		text += str( C[i,j] ) + "*( X" + format( i,'02') + format( j, '02' ) + "+ Y" + format( i,'02') + format( j, '02' ) + " + X" + format(i,'02') + "00*X00" + format(j,'02') + " + Y" + format(i,'02') + "00*Y00" + format(j,'02') + " )+ "
text += "0 )"
print( text )



print( "status = solve(m)" )
print( "println( \"Objective Value: \", getobjectivevalue(m))" )
for i in range(N):		
	for j in range(N):
		if( i == j ):
			continue
		print( "println(\"X" + format( i,'02') + format( j, '02' ) + ":\", getvalue(X"  + format( i,'02') + format( j, '02' ) + "))")

for i in range(N):	
	for j in range(N):
		if( i == j ):
			continue
		print( "println(\"Y" + format( i,'02') + format( j, '02' ) + ":\", getvalue(Y"  + format( i,'02') + format( j, '02' ) + "))")


#print( "println( getvalue( x ))")
#print("println( getvalue( s ))")



