using Optim
using Plots
# Initialize the parameters of the problem.

alpha = .4
beta = .9
gamma = .5
delta = .1

k0 = .6

# It actually takes a little bit if this is made much larger.
I = 10

# These values have been changed to the steady states given by Paarsch in Email

kStar = (((1/beta)+delta-1) / alpha)^(1./(alpha-1.))

cStar = kStar^alpha-delta*kStar

Epsilon = .00001

# Now we need to map our points from k0 to kStar + (kStar - k0) to -1,1
a = k0
b = 2 * kStar - k0

#Since the Domain of the ChebyShev polynomials is -1,1, we want to move our work into this domain and out
function MoveToChebyDomain( x::Float64 )
    # Go from (a,b) to (-1,1)
    return 2 * (x - a) / (b - a) - 1
end

function MoveToProblemDomain( x::Float64 )
    return a + (x + 1) * ((b - a) / 2)
end

#Following the Notation of Paarsch and Golyeav
function LSFit( y::Vector{Float64}, bT::Matrix{Float64}, M::Integer )
    # a = zeros( M )
    # for m in 1:M
    #     a[m] = sum( y .* bT[m,:])/sum(bT[m,:] .* bT[m,:])
    # end
    return (bT*bT') \ (bT*y)
end

#This again follows the work in "Effective Computing in Quantitative Research"
function BuildChebyCoeff( Xk::Vector{Float64}, v::Vector{Float64}, k::Integer)
    M = k-1
    #Initialize the matrix, setting the second row
    bT = ones( M, k)
    bT[2,:] = Xk
    #Recursively fill the matrix using the Chebyshev polynomials
    #The dots in front of operators are vectorizing the operation
    for m in 3:M
        bT[m,:] = 2.*Xk .* bT[m-1,:]  .- bT[m-2,:]
    end
    #Fit the coefficients using Least Squares ala Paarsch/Golyeav
    aHat = LSFit( v, bT, M)
    return aHat
end

#This builds the chebyshev polynomials recursively
function Chebyshev( index::Integer, xVal::Float64 )
    #Since T_0 = 1 and T_1 = x
    #And T_n = 2xT_n-1 - T_n-2
    if( index == 1 )
        return 1
    end
    if( index == 2)
        return xVal
    end
    return( 2*xVal*Chebyshev(index-1,xVal) - Chebyshev(index-2,xVal))
end

#This evaluates Chebyshev polynomials for some coefficients and some x value - Having issues vectoring this.
function EvalChebyCoeff( A::Vector{Float64}, xVal::Float64 )
    #Evaluate a ChebyChev Polynomial
    #with coefficients a
    #at x and return its value.
    value = 0

    for i in 1:length(A)
        value += A[i]*(Chebyshev(i,xVal))
    end
    return value
end
    
#Find the Chebyshev nodes for k
k = 2 * I + 1
Xk = zeros( k )
for i in 1:k
    Xk[i] = -cos( π*(2*i - 1)/(2*k))
end

#This is the chebyshev nodes located in The Capital Space [a,b]
x = a .+ ((Xk+1).*((b-a)/2))

#Here is our initial guess at valuation - We consume at the steady state of capital
v = ones(k)*cStar*(1/(1-beta))

#Fit the chebyshev polynomial to this valuation
A = BuildChebyCoeff( Xk, v, k)

#Set everything up for the loop
prevV = zeros(k)
cVec = ones(k)*cStar
iterCounter = 0

#While our function is sufficiently different at the points we are "training" it
while( norm(prevV - v) > Epsilon )
    prevV = copy(v)
    for i in 1:k
        #Get the capital level, and the max and min consumption
        curK = x[i]
        cLow = 0
        cHigh = curK^alpha + (1-delta)*curK
        
        #Consumption for some c is given by:
        # c^gamma + beta*v(k^alpha - c)
        #We want to find the c that maximizes this.
        result = optimize(
            (x->-(x^gamma + beta*EvalChebyCoeff(A, MoveToChebyDomain(curK^alpha - x) ))),
            cLow, cHigh)#; alpha, gamma, beta, curK )
        #There is a negative here because we minimized the negative of consumption
        v[i] = -Optim.minimum(result)
        #This is only used on the final loop, should be better way of handing this.
        cVec[i] = Optim.minimizer(result)
    end
    #Now we have a better guess of v, so we can build a better polynomial
    A = BuildChebyCoeff( Xk, v, k)
    iterCounter += 1
end

#Now build our consumption polynomial
C = BuildChebyCoeff( Xk, cVec, k)
#How long did it take us to get there
print( iterCounter )


#This only looks so bad because I haven't managed to vectorize EvalChebyCoeff properly.
# x = linspace( a,b)
# y = zeros( length( x ))
# for xi in x
#     y = EvalChebyCoeff( C, MoveToChebyDomain(xi) )
# end

# #Plot our consumption and label it accordingly
# pyplot()
# plot( x,EvalChebyCoeff( C, MoveToChebyDomain(x) ),title="Consumption", label="",lw=3)
# xlabel!( "Current Capital")
# ylabel!( "Consumption")
# savefig("consumptionPath.pdf") 
