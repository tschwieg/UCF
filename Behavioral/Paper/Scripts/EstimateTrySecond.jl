using DataFrames
using ForwardDiff
using Optim

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

    @fastmath a = censor*log( sech( relVal /2.*s)*sech(relVal / 2.*s) / (4.0*s))
    @fastmath b = (1-censor)*log( 1.0/ ( exp( -1.*relVal) + 1.))
    
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


function MaximumLiklihoodEstimate( quantityLot, priceLot, priceKey, censorLot, lotProbs, posContents, negContents, nDataPoints, boxSize)

    function allTogether( x)
        return -1.0*sum(sum(smallLik( quantityLot[j][i], priceLot[j][i],  censorLot[j][i], 1.0, exp(x[1]), exp(x[2]), exp(x[3]), lotProbs[j][i,:], posContents[j][i], negContents[j][i]) for i=1:nDataPoints[j]) for j in 1:boxSize)
    end

    function gradTogether( storage, x )
        grad = ForwardDiff.gradient(allTogether,x)
        
        storage[1] = grad[1]
        storage[2] = grad[2]
        storage[3] = grad[3]
    end

    function ChromaSeperate( x)
        ChromaLik = -1.0*sum(sum(smallLik( quantityLot[j][i], priceLot[j][i],  censorLot[j][i], 1.0, exp(x[1]), exp(x[2]), exp(x[3]), lotProbs[j][i,:], posContents[j][i], negContents[j][i]) for i=1:nDataPoints[j]) for j in 1:2)
        RestLik = -1.0*sum(sum(smallLik( quantityLot[j][i], priceLot[j][i],  censorLot[j][i], 1.0, exp(x[4]), exp(x[5]), exp(x[6]), lotProbs[j][i,:], posContents[j][i], negContents[j][i]) for i=1:nDataPoints[j]) for j in 3:boxSize)
        return ChromaLik + RestLik
    end

    function gradSeperate( storage, x)
        grad = ForwardDiff.gradient(ChromaSeperate,x)

        for i in 1:6
            storage[i] = grad[i]
        end
        
    end        

    O = optimize(allTogether, gradTogether, zeros(3), ConjugateGradient())
    println( "Values for the Combined Estimate: ")
    println( O.minimum )
    println( O.minimizer)

    sepOptim = optimize(ChromaSeperate, gradSeperate, zeros(6), ConjugateGradient())
    println("Values for the seperate Estimates: ")
    println( sepOptim.minimum )
    println( exp.(sepOptim.minimizer))

end


function searchdir(path,key)
    return filter(x->contains(x,key), readdir(path))
end

function ReadData()
    
    files = ["Chroma Case.csv", "Chroma 2 Case.csv", "Shadow Case.csv", "Falchion Case.csv", "Huntsman Weapon Case.csv", "Glove Case.csv",]
    

    DataPoints = Vector{Real}()
    Probs = Vector{Matrix{Real}}()
    negContentFolder = Vector{Vector{Vector{Real}}}()
    posContentFolder = Vector{Vector{Vector{Real}}}()
    quantityFolder = Vector{Vector{Real}}()
    priceFolder = Vector{Vector{Real}}()
    censorFolder = Vector{Vector{Real}}()
    priceKey = 2.5

    for filename in files
        filename = "../Data/" * filename
        ReadFile( filename, DataPoints, Probs, negContentFolder, posContentFolder, quantityFolder, priceFolder, censorFolder, priceKey)       
    end
    
    

     m = MaximumLiklihoodEstimate( quantityFolder, priceFolder, priceKey, censorFolder, Probs, posContentFolder, negContentFolder, DataPoints, length( files))
    
    
end

function ReadFile( filename, DataPoints, Probs, negContentFolder, posContentFolder, quantityFolder, priceFolder, censorFolder, priceKey )
     
    frame = readtable( filename)
    

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

        expectedValue = dot( lotProbs[i,:], convert( Matrix{Real}, frame[i,2*order+2])[1,:] )
        
        for j in 2:numContents
            lotProbs[i,j] += lotProbs[i,j-1]
        end
        
        values = convert( Matrix{Real}, frame[i,2*order+2])[1,:] .- priceLot[i] .- priceKey .- expectedValue

        negContents[i] = Vector{Real}()
        posContents[i] = Vector{Real}()
        for j in 1:numContents
            if( values[j] < 0)
                push!( negContents[i], values[j])
            #This guy was breaking automatic differentiation
            elseif( values[j] == 0 )
                push!( posContents[i], 0.01)
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
