import numpy as np
import matplotlib.pyplot as plotter

def SimpleRegression( Y ):
	xBar = 0
	yBar = 0
	length = len( Y )
	
	for i in range( length ):
		xBar += Y[i,0]/length
		yBar += Y[i,1]/length
		
	Sxy = 0
	Sxx = 0
	for i in range( length ):
		Sxy += (Y[i,0] - xBar)*(Y[i,1] - yBar )
		Sxx += (Y[i,0] - xBar)**2
		
	betaHat = Sxy / Sxx
	alphaHat = yBar - xBar*betaHat
	
	return alphaHat,betaHat

N = 250
mu = 69
muVec = [mu,mu]
sigmasq = 9
sigma_12 = 4.5

sigma = np.array( [[sigmasq, sigma_12],[sigma_12,	sigmasq]] )

F = np.linalg.cholesky( sigma )
np.random.seed( 235711 )

Z = np.random.normal( 0,1,[N,2])
Y = np.dot( Z,F ) + muVec

#print( Y )
alphahat,betahat = SimpleRegression( Y )




nCorruptions = 999
newAlphas = np.zeros( nCorruptions )
newBetas = np.zeros( nCorruptions )
tau = np.random.uniform( 0,1,nCorruptions) 

for j in range( nCorruptions ):
	A = Y
	
	Indicator = np.random.uniform( 0,1,N)
	for i in range(N):
		if( Indicator[i] < tau[j] ):#Aldultery
			A[i,0] = Z[int(Indicator[i]*N),0]
	
	newAlphas[j],newBetas[j] = SimpleRegression( A )
	
plotter.scatter( tau, newBetas )
plotter.xlabel("tau")
plotter.ylabel( "Beta" )
plotter.grid(True)
plotter.savefig('BetavTau.pdf')
plotter.show()

print( "Old alpha hat was: " + str( alphahat ) + " and old betahat was: " + str( betahat ) )
print( "New alpha hat was: " + str( np.mean( newAlphas ) ) + " and new betahat was: " + str( np.mean(newBetas) ) )

