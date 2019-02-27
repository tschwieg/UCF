#using Optim
using Plots
using GaussQuadrature
using ForwardDiff
using Distributions
# Initialize the parameters of the problem.

#Since the Domain of the ChebyShev polynomials is -1,1
#, we want to move our work into this domain and output in a,b
function MoveToChebyDomain( x::Real,a::Float64,b::Float64 )
    # Go from (a,b) to (-1,1)
    return 2 * (x - a) / (b - a) - 1
end


function MoveToProblemDomain( x::Float64,a::Float64,b::Float64 )
    return a + (x + 1) * ((b - a) / 2)
end

#Use the Choleksy decomp to speed this up a lot
function LSFit( y::Vector{Float64}, bT::Matrix{Float64}, M::Integer )
     F = cholfact(bT*bT')
     return F[:U] \ (F[:L]\ (bT*y))
end

#This follows the work in "Effective Computing in Quantitative Research"
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

function Build2dChebyCoeff( Xk::Vector{Float64}, Yk::Vector{Float64},V::Matrix{Float64}, k::Int64)

    #First build the Regular T_x and T_y matrices so we can quickly call them
    M = k-1
    bTx = ones( M,k )
    bTy = ones( M,k )
    bTx[2,:] = Xk; bTy[2,:] = Yk
    for m in 3:M
        bTx[m,:] = 2.*Xk .*bTx[m-1,:] .- bTx[m-2,:]
        bTy[m,:] = 2.*Yk .*bTy[m-1,:] .- bTy[m-2,:]
    end

    bT = ones( (M*(M+1))/2, k*k)
    index = 1
    for i in 1:M
        for j in i:M
            for l in 1:k
                #Fill the X matrix with all the different combinations of the tensor product
                #The rows are filled with the different combinations of Xk and Yk
                bT[index,(l-1)*k+1:(l)*k] = bTx[i,:].*bTy[j,l]
            end
            index += 1
        end
    end
    #Flatten V so that it is a single vector as LS needs
    return LSFit( reshape( V, k*k), bT, M)
end

function Eval2dChebyCoeff( xValue::Real, yValue::Float64, C::Vector{Float64}, vSize::Int64)
    dotVecX = Vector(vSize)
    dotVecY = Vector(vSize)
    dotVecX[1] = 1.
    dotVecY[1] = 1.
    dotVecX[2] = xValue
    dotVecY[2] = yValue
    for i in 3:vSize
        dotVecX[i] = 2*xValue*dotVecX[i-1] - dotVecX[i-2]
        dotVecY[i] = 2*yValue*dotVecY[i-1] - dotVecY[i-2]
    end
    #dotVec = Vector( convert(Int64,(vSize*(vSize+1))/2))
    index = 1
    val = 0
    for i in 1:vSize
        for j in i:vSize
            val += C[index]*dotVecX[j]*dotVecY[i]
            index += 1
        end
    end
    return val
end

    

#This evaluates Chebyshev polynomials for some coefficients and some x value - Having issues vectoring this.
function EvalChebyCoeff( xValue::Real, C::Vector{Float64}, vSize::Int64 )
    #Evaluate a ChebyChev Polynomial
    #with coefficients C
    #at xValue and return its value.

    #Note that we don't use ones() because ForwardDiff has a hissy fit converting its type to Float64
    dotVec = Vector(vSize)#ones(vSize)
    dotVec[1] = 1.
    dotVec[2] = xValue
    
    for i in 3:vSize
        dotVec[i] = 2*xValue*dotVec[i-1] - dotVec[i-2]
    end

    return vecdot(dotVec,C)
end


function NewtonConsumeFunc( x::Real, cLow::Float64, cHigh::Float64, curK::Float64, gamma::Float64,
                            beta::Float64, alpha::Float64, A::Vector{Float64}, l::Vector{Float64},
                            w::Vector{Float64}, k::Int64, a::Float64, b::Float64, μ::Float64, σ::Float64,
                            degree::Int64, sLow::Float64, sHigh::Float64, curShock::Float64 )
    #Since we need to keep c within a certain interval, I am going to parameterize c by:
    #c = cLow + ((cHigh-cLow)*exp( .1*x ))/(1 + exp(.1*x))
    integral = 0
    degree = 10
    c = cLow + ((cHigh-cLow)*exp( .1*x ))/(1 + exp(.1*x))
    
    #Calculate the Guass-Hermite Integral for the expected v under the log normal shock
    integral = 0
    for i in 1:degree
        sNew = exp(μ + sqrt(2) * σ * l[i])
        xVal = sNew*curK^alpha - c
        #chebValue = EvalChebyCoeff( MoveToChebyDomain(xVal,a,b), A, k-1)
        #clamp(sNew,sLow,sHigh)
        chebValue = Eval2dChebyCoeff( MoveToChebyDomain(clamp(xVal,a,b),a,b), MoveToChebyDomain(clamp(sNew,sLow,sHigh),  sLow, sHigh), A, k-1)
        integral += w[i] * chebValue
    end
    return (c^gamma + beta*(1/sqrt(π))*integral)
    #return c^gamma + beta*EvalChebyCoeff( MoveToChebyDomain(curK^alpha - c,a,b), A, k-1)
end

function OptimizeConsumption( cLow::Float64, cHigh::Float64, cGuess::Float64, curK::Float64,
                              gamma::Float64, beta::Float64, alpha::Float64, A::Vector{Float64},
                              l::Vector{Float64}, w::Vector{Float64}, k::Int64, a::Float64,
                              b::Float64, μ::Float64, σ::Float64, degree::Int64, sLow::Float64,
                              sHigh::Float64, curShock::Float64 )
    #Since we are not allowed to pass any parameters to f, we use the closure to get around this nicely.
    f(x) = NewtonConsumeFunc(x, cLow, cHigh, curK, gamma, beta, alpha, A, l, w, k,a,b, μ, σ, degree, sLow, sHigh, curShock)
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
    #Should there be a special case when we used up all 25 iterations?
    
    #Return value is the value function f, and the c that maximized it.
    return( [f(x),cLow + ((cHigh-cLow)*exp( .1*x ))/(1 + exp(.1*x))]  )
end


function RunDynProg()
    #Keep things out of the global namespace to speed everything up.
    alpha = .4
    beta = .9
    gamma = .5
    delta = .1

    #Keep the entire process mean one, but allow for variation
    σ = .25
    μ = -σ*σ/2.0

    #This is for the AR process
    ρ = .8

    k0 = .6

    # It actually takes a little bit if this is made much larger.
    I = 5

    # These values have been changed to the steady states given by Paarsch in Email
    kStar = (((1.0/beta)+delta-1.0) / alpha)^(1.0/(alpha-1.0))

    cStar = kStar^alpha-delta*kStar

    Epsilon = .001

    # Now we need to map our points from k0 to kStar + (kStar - k0) to -1,1
    a = k0
    b = 2 * kStar - k0

    sLow = 0.1
    sHigh = 3.0

    #Find the Chebyshev nodes for k
    k = 2 * I + 1
    Xk = zeros( k )
    for i in 1:k
        Xk[i] = -cos( π*(2*i - 1)/(2*k))
    end

    #This is the chebyshev nodes located in The Capital Space [a,b]
    cap = MoveToProblemDomain.(Xk,a,b)
    shock = MoveToProblemDomain.( Xk, sLow, sHigh)
    

    #Since this is a relatively expensive part of quadrature, and we don't change our degree, calculate it outside
    #the loop then pass it to the function that does the quadrature.
    degree = 10
    l,w = GaussQuadrature.hermite(degree)

    #This will be used to plot:
    x = Vector{Float64}(1000)
    for i in 1:1000
        x[i] =  ((kStar+1)*i)/1000.
    end
    

    #Here is our initial guess at valuation
    #We consume at the steady state of capital for each Xk
    #cStar = kStar^alpha-delta*kStar
    v = zeros(k,k)#ones(k)*cStar*(1/(1-beta))
    for i in 1:k
        for j in 1:k
           v[j,i] = shock[j]*cap[i]^alpha -delta*cap[i]
        end
        #v[:,i] = cap[i]^alpha - delta*cap[i]
    end
    #return v
    
    #Fit the chebyshev polynomial to this valuation
    #A = BuildChebyCoeff( Xk, v, k)
    A = Build2dChebyCoeff( Xk, Xk, v, k)

    h = zeros(k,k)
    for i in 1:k
        for j in 1:k
            h[j,i] = Eval2dChebyCoeff( Xk[i], Xk[j], A, k-1)
        end
    end
    

    #Set everything up for the loop
    prevV = zeros(k,k)
    cVec = ones(k,k)*cStar
    iterCounter = 0

    #While our function is sufficiently different at the points we are "training" it
    while( norm(prevV - v) > Epsilon )
        prevV = copy(v)
        for i in 1:k
            for j in 1:k
                curShock = shock[j]
                #Get the capital level, and the max and min possible consumption
                curK = cap[i]
                cLow = 0.
                cHigh = curShock*curK^alpha + (1-delta)*curK
                
                #This runs Newton's method from the Third Arguement as the initialization to find the optimal level of consumption
                #It handles the max and min and by parameterizing it by cLow + (cHigh-Clow)exp(x)/(1+exp(x))
                #Since it is a monotonic increasing function, the optimals should occur in the same location

                #curK^alpha-delta*curK
                OptBoy = OptimizeConsumption( cLow, cHigh, (cLow+cHigh)/2.0, curK, gamma, beta,
                                              alpha, A, l, w, k, a, b, ρ*log(curShock), σ, degree, sLow, sHigh, curShock )
                if( OptBoy[2] > cHigh )
                    println( "Consuming above what is possible")
                    return OptBoy
                end
                
                v[j,i] = OptBoy[1]
                cVec[j,i] = OptBoy[2]
            end
        end
        if( any(isnan, v) )
            println("NaN Problems")
            println(iterCounter)
            println( cVec)
            return v
        end
        
        #Now we have a better guess of v, so we can build a better polynomial
        #A = BuildChebyCoeff( Xk, v, k)
        A = Build2dChebyCoeff( Xk, Xk, v, k)
        iterCounter += 1
        
        # #If things are spinning out of control, lets get some idea of whats happening to the value function
        if( iterCounter % 1000 == 0)
            println( iterCounter)
            println(cVec)
            println( maximum(abs.(v)) )
            println("\n\n")
        end
        
    end

    #Now build our consumption polynomial
    C = Build2dChebyCoeff( Xk,Xk,  cVec, k)
    #How long did it take us to get there

    println( iterCounter )
    println( v )
    println( C )
    

    x = Vector{Float64}(100)
    y = Vector{Float64}(100)
    z = Matrix{Float64}(100,100)
    for i in 1:100
        x[i] =  a + (b*i)/100.
        y[i] = sLow + sHigh*i/100.
    end

    for i in 1:100
        for j in 1:100
            z[j,i] = Eval2dChebyCoeff( MoveToChebyDomain(x[i],a,b), MoveToChebyDomain(y[j],sLow,sHigh), C, k-1)
        end
    end
    
     pyplot()
    plot( cap, shock,cVec', st=:surface)
    plot!( x, y,z, st=:surface)
    gui()
     #savefig( "test.png")

    
    return x,y,z
end


x,y,z = RunDynProg()


