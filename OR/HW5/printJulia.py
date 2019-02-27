print( "using JuMP\nusing Cbc")

print( "m = Model( solver = CbcSolver() )")
print( "@variable( m, x[0:9] >= 0)" )
print( "@variable( m, s[0:9] >= 0)" )
for i in range(10):
  for j in range(10):
    if( i == j ):
      continue
    print( "@variable( m, y" + str(i) + str(j) + ", Bin)" )
print( "@variable( m, Z, Bin)" )
print( "@objective( m, Min, 1*s[0] + 2*s[1] + 5*s[2] + 1*s[3] + 3*s[4] + 5*s[5] + 2*s[6] + 4*s[7] + 3*s[8] + 7*s[9])" )
P = [10,3,13,15,9,22,17,30,12,16]
D = [20,98,100,34,50,44,32,60,80,150]
for i in range(10):
  print( "@constraint( m, x[" + str(i) + "] - s[" + str(i) + "] <= " + str(D[i]) + " - " + str(P[i]) + ")" )
M = "10000"
Epsilon = "0.0001"


for i in range(10):
  for j in range(10):
    if( i <= j):
      continue
    print( "@constraint( m, " + M + "*y" + str(i) + str(j) + " + x[" + str(i) + "] - x[" + str(j) + "] >= " + str( P[j] ) + ")" )
    print( "@constraint( m, " + M + "*y" + str(j) + str(i) + " + x[" + str(j) + "] - x[" + str(i) + "] >= " + str( P[i] ) + ")" )
    print( "@constraint( m, y" + str(i) + str(j) + "+ y" + str(j) + str(i) + " == 1)")
print( "@constraint( m, x[2] - x[3] - " + str(P[4-1]) + " <= " + M + "*(1-Z)- " + Epsilon + ")")
print( "@constraint( m, x[8] + " + str(P[9-1]) +" - x[2] <= "+M+"*Z)" )
print( "status = solve(m)" )
print( "println( \"Objective Value: \", getobjectivevalue(m))" )
print( "println( getvalue( x ))")
print("println( getvalue( s ))")
