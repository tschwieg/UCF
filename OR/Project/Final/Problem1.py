import numpy as np

print( "using JuMP\nusing Cbc")
print( "m = Model( solver = CbcSolver() )")

N = 16

C = np.matrix( [[0,90,90,180,90,90,90,60,90,165,180,120,180,90,60,45]
,[60,0,60,150,90,105,75,105,60,90,180,120,45,30,105,80]
,[90,45,0,120,60,105,30,90,90,90,180,105,90,60,60,90]
,[60,60,60,0,60,90,75,60,45,60,150,30,15,30,75,75]
,[140,120,120,210,0,120,75,120,120,180,240,180,180,120,90,120]
,[150,90,90,115,30,0,90,30,90,90,180,150,120,90,90,30]
,[120,120,90,210,30,105,0,60,30,120,210,210,210,120,75,120]
,[120,105,90,180,30,150,105,0,90,105,180,180,180,90,110,120]
,[120,90,60,150,30,105,90,60,0,120,180,120,120,90,75,105]
,[60,120,120,120,60,90,60,60,60,0,180,120,120,90,60,90]
,[30,60,60,15,30,30,30,30,30,30,0,30,30,30,30,30]
,[90,90,120,120,30,30,30,30,30,60,180,0,90,60,90,30]
,[90,75,60,105,75,90,75,15,60,75,90,120,0,45,90,75]
,[90,30,90,120,90,105,45,90,30,90,180,105,120,0,90,90]
,[45,60,90,180,45,90,75,45,60,120,180,150,180,105,0,60]
,[60,75,90,120,45,120,90,45,90,120,180,60,150,90,75,0]])

for i in range(N):
	for j in range(N):
		if( i == j ):
			continue
		print( "@variable( m, X" + format( i,'02') + format( j, '02' ) + ", Bin )" )
for i in range( 1,N ):
	print( "@variable( m, u" + format( i, '02' ) + " >= 0)" )


for i in range(N):
	text = "@constraint( m, "	
	for j in range(N):
		if( i == j ):
			continue
		text += "X" + format( i,'02') + format( j, '02' ) + " + "
	text += " 0 == 1)"
	print( text )
	
for j in range(N):
	text = "@constraint( m, "	
	for i in range(N):
		if( i == j ):
			continue
		text += "X" + format( i,'02') + format( j, '02' ) + " + "
	text += " 0 == 1)"
	print( text )

for i in range(1,N):		
	for j in range(1,N):
		if( i == j ):
			continue
		print("@constraint( m, u" + format( i,'02') + " - u" + format( j,'02') + " + " + str(N) + "*X" + format( i,'02') + format( j, '02' ) +  "<= " + str(N-1) + " )"  )
		
#for i in range(1,N):
#	print( "@constraint( m, u" + format( i,'02') + " <= " + str(N) + " )" )
#	print( "@constraint( m, u" + format( i,'02') + " >= 2 )" )
		
text = "@objective( m, Min, "
for i in range(N):		
	for j in range(N):
		if( i == j ):
			continue
		text += str( C[i,j] ) + "*X" + format( i,'02') + format( j, '02' ) + "+ "
text += "0 )"
print( text )



print( "status = solve(m)" )
print( "println( \"Objective Value: \", getobjectivevalue(m))" )
for i in range(N):		
	for j in range(N):
		if( i == j ):
			continue
		print( "println(\"X" + format( i,'02') + format( j, '02' ) + ":\", getvalue(X"  + format( i,'02') + format( j, '02' ) + "))")


#print( "println( getvalue( x ))")
#print("println( getvalue( s ))")
