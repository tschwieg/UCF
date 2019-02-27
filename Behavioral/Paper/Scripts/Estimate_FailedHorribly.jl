using JuMP
using Ipopt
using DataFrames
using ForwardDiff

#First we define the CPT functions

function valuation( x::Real, λ::Real, α::Real )
    if( x < 0)
        return -λ*(-x)^α
    else
        return x^α
    end
end

function NegativeValuation( x::Real, λ::Real, α::Real)
     @fastmath return -λ*(-x)^α
end

function PositiveValuation( x::Real, α::Real)
     @fastmath return x^α
end


#Note that this is applied to the cumulative probability, not the prob
function weights( p::Real, δ::Real)
     @fastmath return p^δ / ( p^δ + ( 1. - p^δ)^δ)^(1./δ)
end


function smallLik( quant::Real, price::Real, censor::Real, s::Real, λ::Real, α::Real, δ::Real, lotProb::Vector{Real}, posContents::Vector{Real}, negContents::Vector{Real})
    relVal = (price - Lottery(lotProb, posContents, negContents, λ, α, δ)) / s
    #println( relVal)
    @fastmath a = censor*log( sech( relVal /2.*s)*sech(relVal / 2.*s) / (4.0*s))
    #println(a)
    @fastmath b = (1-censor)*log( 1.0/ ( exp( -1.*relVal) + 1.))
    #println(b)
    return quant*( a + b )
end

function Lottery( lotProb::Vector{Real}, posContents::Vector{Real}, negContents::Vector{Real}, λ::Real, α::Real, δ::Real )
    l = length(lotProb)
    transformedProb = Vector{Real}(l)
    transformedProb[end] = weights( lotProb[end], δ)
    for i in 1:(l-1)
         transformedProb[l-i] = weights( lotProb[l-i], δ)
         transformedProb[l-i+1] -= weights( lotProb[l-i], δ)
    end
    count = 1
    trueVal = 0
     for i in 1:length(negContents)
         trueVal += NegativeValuation( negContents[i], λ, α)*transformedProb[count]
         count += 1
    end
     for i in 1:length(posContents)
         trueVal += PositiveValuation( posContents[i], α)*transformedProb[count]
         count += 1
    end
    return trueVal
end

function searchdir(path,key)
    return filter(x->contains(x,key), readdir(path))
end


function ReadData()

    #files = searchdir( "../Data/", ".csv")
    # files = ["Gamma Case.csv", "Glove Case.csv", "Chroma 3 Case.csv", "Operation Bravo Case.csv", "Operation Breakout Weapon Case.csv",
    #          "Operation Hydra Case.csv", "Operation Phoenix Weapon Case.csv", "Operation Vanguard Weapon Case.csv", "Operation Wildfire Case.csv", "Revolver Case.csv", "Shadow Case.csv", "Spectrum Case.csv", "Falchion Case.csv", "Gamma 2 Case.csv", "Chroma Case.csv", "Chroma 2 Case.csv"]

    
    #files = ["Chroma Case.csv", "Chroma 2 Case.csv", "Shadow Case.csv", "Falchion Case.csv", "Huntsman Case.csv", "Glove Case.csv"]
    #The small training set 
    files = ["../Data/Operation Hydra Case.csv"]
    #The Huntsman and the Chroma 2 will be used in the test set.

    DataPoints = Vector{Real}()
    Probs = Vector{Matrix{Real}}()
    negContentFolder = Vector{Vector{Vector{Real}}}()
    posContentFolder = Vector{Vector{Vector{Real}}}()
    quantityFolder = Vector{Vector{Real}}()
    priceFolder = Vector{Vector{Real}}()
    censorFolder = Vector{Vector{Real}}()
    priceKey = 2.5

    for filename in files
    
        ReadFile( filename, DataPoints, Probs, negContentFolder, posContentFolder, quantityFolder, priceFolder, censorFolder, priceKey)       
    end
    
    

     m = MaximumLiklihoodEstimate( quantityFolder, priceFolder, priceKey, censorFolder, Probs, posContentFolder, negContentFolder, DataPoints, length( files))
    
    # m = MLEUtility( quantityFolder, priceFolder, priceKey, censorFolder, Probs, posContentFolder, negContentFolder, DataPoints, length( files))
end

function GradientAllDifferent( g, s1, s2, s3, s4, λ1, λ2, λ3, λ4, α1, α2, α3, α4, δ1, δ2, δ3, δ4, quantityLot, priceLot, priceKey, censorLot, lotProbs, posContents, negContents, nDataPoints, boxSize  )
    temp = Vector{Float64}(4)
    temp = sum( MyGradient(quantityLot[1][i], priceLot[1][i], priceKey, censorLot[1][i], s1, λ1, α1,δ1, lotProbs[1][i,:], posContents[1][i], negContents[1][i]) for i=1:nDataPoints[1] )
    g[1] = temp[1]
    g[5] = temp[2]
    g[9] = temp[3]
    g[13] = temp[4]
    temp = sum( MyGradient(quantityLot[2][i], priceLot[2][i], priceKey,censorLot[2][i], s2, λ2, α2,δ2, lotProbs[2][i,:], posContents[2][i], negContents[2][i]) for i=1:nDataPoints[2] )
    g[2] = temp[1]
    g[6] = temp[2]
    g[10] = temp[3]
    g[14] = temp[4]

    temp = sum( MyGradient(quantityLot[3][i], priceLot[3][i], priceKey,censorLot[3][i], s3, λ3, α3,δ3, lotProbs[3][i,:], posContents[3][i], negContents[3][i]) for i=1:nDataPoints[3] )
    g[3] = temp[1]
    g[7] = temp[2]
    g[11] = temp[3]
    g[15] = temp[4]

    temp = sum( MyGradient(quantityLot[4][i], priceLot[4][i], priceKey,censorLot[4][i], s4, λ4, α4,δ4, lotProbs[4][i,:], posContents[4][i], negContents[4][i]) for i=1:nDataPoints[4] )
    g[4] = temp[1]
    g[8] = temp[2]
    g[12] = temp[3]
    g[16] = temp[4]
end


function MaximumLiklihoodEstimate( quantityLot, priceLot, priceKey, censorLot, lotProbs, posContents, negContents, nDataPoints, boxSize)
    
    #Now lets look as if there was no differences between any.

    println( "Modeling with the same λ, α, δ")
    
    m = Model(solver=IpoptSolver())
    @variable( m, 10. >= s >= 1e-10)
    @variable( m, 10. >= λ >= 1e-10)
    @variable( m, 10. >= α >= 1e-10)
    @variable( m, 10. >= δ >= 1e-10 )

    #@constraint( m, s == 1.)
    #@constraint( m, s >= 1.)

    newTest( s, λ, α, δ ) = sum(sum(smallLik( quantityLot[j][i], priceLot[j][i],  censorLot[j][i], s, λ, α, δ, lotProbs[j][i,:], posContents[j][i], negContents[j][i]) for i=1:nDataPoints[j]) for j in 1:boxSize)

    #This code is an abomination, it defines gradFunc as a function which sets g equal to the sum of the gradient for each datapoint
    gradFunc( g, s, λ,α, δ) = (g,s,λ,α,δ) -> g = sum(sum( MyGradient(quantityLot[j][i], priceLot[j][i], censorLot[j][i], s, λ, α,δ, lotProbs[j][i,:], posContents[j][i], negContents[j][i]) for i=1:nDataPoints[j] ) for j in 1:boxSize)


    #JuMP.register( m, :objFN, 4, newTest, autodiff=true)
    JuMP.register( m, :objFN, 4, newTest, gradFunc)

    @NLobjective( m, Max, objFN( s, λ, α, δ ))

    solve(m)

    println( getvalue(s))
    println( getvalue(λ))
    println( getvalue(α))
    println( getvalue(δ))
    return allDifferent
end


function wPrime( p, δ)
    @fastmath a = p^δ
    @fastmath b = (1-p)^δ

    @fastmath partOne = a*(a+b)^((2-δ)/δ)
    @fastmath partTwo = log(p)*δ*δ*(a+b)^((δ+1)/δ)
    @fastmath partThree = ((a + b)^(1./δ))*(-δ*(log(p)*a + log(1-p)*b) + (a+b)*log( a + b))
    #println( [partOne, partTwo, partThree])
    return partOne*( partTwo + partThree)
end

function MyGradient(  quantityLot::Real, priceLot::Real, priceKey::Real, censored::Real, s::Real, λ::Real, α::Real, δ::Real, lotProb::Vector{Real}, posContents::Vector{Real}, negContents::Vector{Real})

    x = priceLot
    d = censored

    
    v = Lottery( lotProb, posContents, negContents, λ, α, δ )
    a = (v-x)/s
    b = exp(a)
    @fastmath delS =  -d*(1.0/s^2)*(2*s - .5*(v-x)*tanh(.5*a)) + (1-d)*(v-x)*b/ (s^2 * (b + 1))
    #@fastmath delV = -( 2*d*(b + 1)*tanh(a) - (1-d)*b) / ( s*(b+1))
    @fastmath delV = -( d*tanh(.5*a)/(2.0*s) + (1-d)*b/(s*(b+1)))

    l = length(lotProb)
    transformedProb = Vector{Real}(l)
    transformedProbPrime = Vector{Real}(l)
    transformedProb[end] = weights( lotProb[end], δ)
    transformedProbPrime[end] = wPrime( lotProb[end], δ)
    for i in 1:(l-1)
        #println([l,l-1,i])
        @inbounds transformedProb[l-i] = weights( lotProb[l-i], δ)
        @inbounds transformedProb[l-i+1] -= weights( lotProb[l-i], δ)
        @inbounds transformedProbPrime[l-i] = wPrime( lotProb[l-i], δ)
        @inbounds transformedProbPrime[l-i+1] -= wPrime( lotProb[l-i], δ)
    end

    count = 1
    delAlpha = 0
    delLambda = 0
    delDelta = 0
    @simd for i in 1:length(negContents)
        @fastmath delLambda += -(transformedProb[count]*(-negContents[i])^α)
        @fastmath delAlpha += -λ*(transformedProb[count]*(-negContents[i])^α * log(-negContents[i]))
        @fastmath delDelta += -λ*(-negContents[i])^α * transformedProbPrime[count]
        count += 1
    end
    @simd for i in 1:length( posContents)
        @fastmath delAlpha += transformedProb[count]*posContents[i]^α * log(posContents[i])
        @fastmath delDelta += posContents[i]^α * transformedProbPrime[count]
        count += 1
    end
    return [delS, delV*delLambda, delV*delAlpha, delV*delDelta ]
end




function ReadFile( filename, DataPoints, Probs, negContentFolder, posContentFolder, quantityFolder, priceFolder, censorFolder, priceKey )
     #filename = "Huntsman Weapon Case.csv"
    frame = readtable( filename)
    
    #size(frame)

    numContents = convert(Int64, (size(frame)[2] - 3) / 2)
    nDataPoints = size(frame)[1]

    lotProbs = Matrix{Real}(nDataPoints,numContents)
    negContents = Vector{Vector{Real}}(nDataPoints)
    posContents = Vector{Vector{Real}}(nDataPoints)
    quantityLot = Vector{Real}(nDataPoints)
    priceLot = Vector{Real}(nDataPoints)
    censorLot = Vector{Real}(nDataPoints)
    

    for i in 1:nDataPoints
        priceLot[i] = frame[i,1]
        quantityLot[i] = frame[i,2]
        censorLot[i] = frame[i,3]
        #The order we want:
        j = 1:numContents
        order = sortperm( convert( Matrix{Real}, frame[i,2*j+2])[1,:])

        lotProbs[i,:] = convert( Matrix{Real}, frame[i,2*order+3])[1,:]
        for j in 2:numContents
            lotProbs[i,j] += lotProbs[i,j-1]
        end
        
        values = convert( Matrix{Real}, frame[i,2*order+2])[1,:] .- priceLot[i] .- priceKey

        negContents[i] = Vector{Real}()
        posContents[i] = Vector{Real}()
        for j in 1:numContents
            if( values[j] < 0)
                push!( negContents[i], values[j])
            else
                push!( posContents[i], values[j])
            end
        end        
    end

    push!( DataPoints, nDataPoints )
    push!( Probs, lotProbs)
    push!( negContentFolder, negContents )
    push!( posContentFolder, posContents )
    push!( quantityFolder, quantityLot)
    push!( priceFolder, priceLot )
    push!( censorFolder, censorLot)        
end

function UtilityLik( quant::Real, price::Real, priceKey::Real, censor::Real, s::Real, λ::Real, α::Real, lotProb::Vector{Real}, Contents::Vector{Real})
    relVal = (price + priceKey - sum( λ*Contents[i]^α * lotProb[i] for i in 1:length(Contents) )) / s^2
    #println( relVal)
    a = censor*log( sech( relVal /2.0 *s^2 )^2 / (4.0*s^2 ))
    #println(a)
    b = (1-censor)*log( 1.0/ ( exp( -1.*relVal) + 1.))
    #println(b)
    return quant*( a + b )
end


function MLEUtility( quantityLot, priceLot, priceKey, censorLot, lotProbs, posContents, negContents, nDataPoints, boxSize)
    #Utility is defined as sum λ x^α p(x)

    Contents = Vector{Vector{Vector{Real}}}(boxSize)
    for j in 1:boxSize
        Contents[j] = Vector{Vector{Real}}(nDataPoints[j])
        for i in 1:nDataPoints[j]
            Contents[j][i] = vcat( negContents[j][i], posContents[j][i])
        end
        
    end
    
    
    m = Model( solver=IpoptSolver())
    @variable( m, 2. >= s >= 1e-10)
    @variable( m, 1. >= λ >= 1e-10)
    @variable( m, 1. >= α >= 1e-10)

    objMax( s, λ, α) = sum( sum(UtilityLik( quantityLot[j][i], priceLot[j][i], priceKey, censorLot[j][i], s, λ, α, lotProbs[j][i,:], Contents[j][i] ) for i in 1:100) for j in 1:1 )

    JuMP.register( m, :objFN, 3, objMax, autodiff=true)

    @NLobjective( m, Max, objFN( s, λ, α ))

    solve(m)

    println( getvalue(s))
    println( getvalue(λ))
    println( getvalue(α))
    
        
end

    

function ComputeTestError( λ, α, δ )
    #The Huntsman and the Chroma 2 will be used in the test set.
    testSet = ["Huntsman Case.csv","Chroma 2 Case.csv"]

    expectedVal = Vector{Float64}()
    priceKey = 2.5

    for filename in testSet
        frame = readtable( filename)

        numContents = convert(Int64, (size(frame)[2] - 3) / 2)
        nDataPoints = size(frame)[1]

        
    end

    #We can only evaluate this in terms of buy or not buy?
    #How do we compare 
    
end


