using Plots
using GaussQuadrature
using ForwardDiff
# Initialize the parameters of the problem.

#Since the Domain of the ChebyShev polynomials is -1,1, we want to move our work into this domain and out
function MoveToChebyDomain( x::Real,a::Float64,b::Float64 )
    # Go from (a,b) to (-1,1)
    @fastmath return 2 * (x - a) / (b - a) - 1
end


function MoveToProblemDomain( x::Float64,a::Float64,b::Float64 )
    @fastmath return a + (x + 1) * ((b - a) / 2)
end

#Following the Notation of Paarsch and Golyeav
function LSFit( y::Vector{Float64}, bT::Matrix{Float64}, M::Integer )
     F = cholfact(bT*bT')
     return F[:U] \ (F[:L]\ (bT*y))
end

#This again follows the work in "Effective Computing in Quantitative Research"
function BuildChebyCoeff( Xk::Vector{Float64}, v::Vector{Float64}, k::Integer)
    M = k-1
    #Initialize the matrix, setting the second row
    bT = ones( M, k)
    @inbounds bT[2,:] = Xk
    #Recursively fill the matrix using the Chebyshev polynomials
    #The dots in front of operators are vectorizing the operation
    @simd for m in 3:M
        @inbounds bT[m,:] = 2.*Xk .* bT[m-1,:]  .- bT[m-2,:]
    end
    #Fit the coefficients using Least Squares ala Paarsch/Golyeav
    aHat = LSFit( v, bT, M)
    return aHat
end

#This evaluates Chebyshev polynomials for some coefficients and some x value - Having issues vectoring this.
function EvalChebyCoeff( xValue::Real, C::Vector{Float64}, vSize::Int64 )
    #Evaluate a ChebyChev Polynomial
    #with coefficients C
    #at xValue and return its value.

    #Note that we don't use ones() because ForwardDiff has a hissy fit converting its type to Float64
    dotVec = Vector(vSize)#ones(vSize)
    @inbounds dotVec[1] = 1.
    @inbounds dotVec[2] = xValue

    @simd for i in 3:vSize
      @inbounds dotVec[i] = 2*xValue*dotVec[i-1] - dotVec[i-2]
    end

    return vecdot(dotVec,C)
end


function NewtonConsumeFunc( x::Real, cLow::Float64, cHigh::Float64, curK::Float64, gamma::Float64, beta::Float64, alpha::Float64, A::Vector{Float64}, l::Vector{Float64}, w::Vector{Float64}, k::Int64, a::Float64, b::Float64, mu::Float64, sigma::Float64, degree::Int64 )
    #Since we need to keep c within a certain interval, I am going to parameterize c by:
    #c = cLow + ((cHigh-cLow)*exp( .1*x ))/(1 + exp(.1*x))
     integral = 0
     degree = 10
     @fastmath c = cLow + ((cHigh-cLow)*exp( .1*x ))/(1 + exp(.1*x))

    #Calculate the Guass-Hermite Integral for the expected v under the log normal shock
    integral = 0
    @simd for i in 1:degree
        @inbounds sNew = exp(mu + sqrt(2) * sigma * l[i])
        @fastmath xVal = sNew*curK^alpha - c
        chebValue = EvalChebyCoeff( MoveToChebyDomain(xVal,a,b), A, k-1)
        @inbounds integral += w[i] * chebValue
    end
    return (c^gamma + beta*(1/sqrt(pi))*integral)
    #return c^gamma + beta*EvalChebyCoeff( MoveToChebyDomain(curK^alpha - c,a,b), A, k-1)
end

function OptimizeConsumption( cLow::Float64, cHigh::Float64, cGuess::Float64, curK::Float64, gamma::Float64, beta::Float64, alpha::Float64, A::Vector{Float64}, l::Vector{Float64}, w::Vector{Float64}, k::Int64, a::Float64, b::Float64, mu::Float64, sigma::Float64, degree::Int64 )
    #Since we are not allowed to pass any parameters to f, we use the closure to get around this nicely.
    f(x) = NewtonConsumeFunc(x, cLow, cHigh, curK, gamma, beta, alpha, A, l, w, k,a,b, mu, sigma, degree)
    #Doesn't seem to bemuch benefit from having this much lower, issues with hermitian integration not being accurate at that point
    Epsilon = 1e-10
    #Since c is a logistic function of x, we invert it to get x from the guess
    x = 10*log( (cGuess-cLow)/(cHigh-cGuess) )
    #Take the derivatives
    g = x -> ForwardDiff.derivative( f,x )
    h = x -> ForwardDiff.derivative(g,x)
    iterations = 0
    #Newton step the function until we're where we want to be.
    while( vecnorm( g(x) ) > Epsilon && iterations < 25)
        x = x - h(x) \ g(x)
        iterations += 1
    end
    #Return value is the value function f, and the c that maximized it.
    return( [f(x),cLow + ((cHigh-cLow)*exp( .1*x ))/(1 + exp(.1*x))]  )
end


function RunDynProg()
    #Keep things out of the global namespace to speed everything up.
    alpha = .4
    beta = .9
    gamma = .5
    delta = .1
    mu = -.005
    sigma = .1

    k0 = .6

    # It actually takes a little bit if this is made much larger.
    I = 20

    # These values have been changed to the steady states given by Paarsch in Email
    kStar = (((1/beta)+delta-1) / alpha)^(1./(alpha-1.))

    cStar = kStar^alpha-delta*kStar

    Epsilon = .001

    # Now we need to map our points from k0 to kStar + (kStar - k0) to -1,1
    a = k0
    b = 2 * kStar - k0

    #Find the Chebyshev nodes for k
    k = 2 * I + 1
    Xk = zeros( k )
    @simd for i in 1:k
       @inbounds Xk[i] = -cos( pi*(2*i - 1)/(2*k))
    end

    #This is the chebyshev nodes located in The Capital Space [a,b]
    cap = MoveToProblemDomain.(Xk,a,b)

    #Here is our initial guess at valuation
    #We consume at the steady state of capital for each Xk
    #cStar = kStar^alpha-delta*kStar
     v = cap.^alpha .- cap.*delta

    #Fit the chebyshev polynomial to this valuation
    A = BuildChebyCoeff( Xk, v, k)

    #Set everything up for the loop
    prevV = zeros(k)
    cVec = ones(k)*cStar
    iterCounter = 0

    #Since this is a relatively expensive part of quadrature, and we don't change our degree, calculate it outside
    #the loop then pass it to the function that does the quadrature.
    degree = 10
    l,w = GaussQuadrature.hermite(degree)


    #While our function is sufficiently different at the points we are "training" it
    while( norm(prevV - v) > Epsilon )
        prevV = copy(v)
        for i in 1:k
            #Get the capital level, and the max and min possible consumption
            @inbounds curK = cap[i]
            cLow = 0.
            @fastmath cHigh = curK^alpha + (1-delta)*curK

            #This runs Newton's method from the Third Arguement as the initialization to find the optimal level of consumption
            #It handles the max and min and by parameterizing it by cLow + (cHigh-Clow)exp(x)/(1+exp(x))
            #Since it is a monotonic increasing function, the optimals should occur in the same location
            OptBoy = OptimizeConsumption( cLow, cHigh, curK^alpha-delta*curK, curK, gamma, beta, alpha, A, l, w, k, a, b, mu, sigma, degree )
            @inbounds v[i] = OptBoy[1]
            @inbounds cVec[i] = OptBoy[2]
        end

        #Now we have a better guess of v, so we can build a better polynomial
        A = BuildChebyCoeff( Xk, v, k)
        iterCounter += 1
    end

    #Now build our consumption polynomial
    C = BuildChebyCoeff( Xk, cVec, k)
    #How long did it take us to get there
    print( iterCounter )

    # x = Vector{Float64}(1000)
    # y = Vector{Float64}(1000)
    # @simd for i in 1:1000
    #     x[i] =  ((kStar+1)*i)/1000.
    #     y[i] = EvalChebyCoeff(MoveToChebyDomain(x[i],a,b),C, k-1)
    # end

    # print( cVec )
    # plotly()
    # plot( x, y)
end

@time  RunDynProg()

