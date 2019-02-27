using DataFrames
using CSV
using Query
using Distributions
using ForwardDiff
using Optim
using Plots
using JuMP
using Cbc

pyplot()

function searchdir(path,key)
    return filter(x->contains(x,key), readdir(path))
end

function GetValuations()
    Gun = "Cases"
    Skin = "Cases"
    Condition = "Glove Case"

    MonthBreak = 5.0

    files = searchdir( "../Data/Cases/Cases/", ".csv")
    for file in files
        Condition = file[1:(end-4)]
        println( Condition)
        EstimateDropRate( Gun, Skin, Condition, MonthBreak )
        savefig( "../Plots/Cases/"*Condition*".pdf")
    end
end



function ReadGunCSV( Gun, Skin, Condition, MonthBreak)
    

    Directory = "../Data/"*Gun*"/"*Skin*"/"*Condition*".csv"


    frame = CSV.read(Directory , header= ["Date", "Price",
    "Quantity"], dateformat=DateFormat("d-m-y") )

    dates = unique( frame, :Date )

    function weightAVG( price, quantity)
        return sum( price .* quantity ) / sum( quantity)
    end


    trueData = @from i in dates begin
        @join j in frame on i.Date equals j.Date into k
        @select { T=Dates.year.(i.Date)*12 .+ Dates.month.(i.Date), Q=(sum(k..Quantity)),
                  P=(weightAVG(k..Price, k..Quantity))}
        @collect DataFrame
    end

   
    

    dat = Matrix( trueData)
    cutoff = findfirst( dat[:,3] .< .04 )
    if( cutoff == 0)
        cutoff = size(dat)[1]
    end
    
    dat = dat[1:cutoff,:]
    #Honestly its better to do 30 running days than to use the actual month
    #Force them to start at index one.
    #dat[:,1] .-= (minimum( dat[:,1])-1)

    for i in 1:size(dat)[1]
        dat[i,1] = ceil( i / MonthBreak)
    end
    

    return dat
end



function logTrans(x)
    return 1.0 / ( exp(-x) + 2)
end

function InvLog(x)
    return log( x / (1-x))
end


function EstimateDropRate( Gun, Skin, Condition, MonthBreak )
    Data = ReadGunCSV( Gun, Skin, Condition, MonthBreak )

    numMonths = convert( Int64,Data[end,1] )
    
    l = size(Data)[1]

    plot( 1:l, log.(Data[1:l,3]))
    
    #μ = 35
    #σ = (15)
    N = (100000.0)
    ξ = ones(numMonths)*(.1)
    m = convert( Vector{Int64}, Data[:,1] )

    x = Vector{Float64}(numMonths+1)
    x[1] = N
    x[2:end] = 0

    # #For now: N = 700000
    q = Data[:,2]
    N = 11145196*1
    #N = sum(q)
    λ = ones(l)
    λ[1] = .5 - sqrt( .25 - q[1] / N)
    for i in 2:l
        #println(i)
        #M = N*prod( 1 .- λ[1:(i-1)])
        λ[i] = .5 - sqrt( max( .25 - q[i] / N, 0 ))
    end
    

    
    # function f(x)
    #     #This is just: $q_s = N ξ_T \prod_{t=0}^T ( 1 - ξ_t)$
    #     #We have forced ξ to be the same within each grouping of size MonthBreak
        
    #     loss = 0
    #     for i in 1:l
    #         estimate = x[1] * logTrans( x[ 1 + m[i]])
    #         if( m[i] == 1)
    #             estimate *= ( 1.0 - logTrans( x[2]))^(i)
    #         else                
    #             for j in 1:(m[i]-1)
    #                 estimate *= ( 1.0 - logTrans( x[ 1 + j]))^(MonthBreak)
    #             end
    #             estimate *= ( 1.0 - logTrans( x[ 1 + m[i]]))^(i-(m[i]-1)*MonthBreak)
    #         end
            
    #         #estimate = x[1]*logTrans(x[1 +  m[i]])*prod(1.0 .- logTrans.( x[1 .+(1:m[i])]))
    #         loss += (estimate-Data[i,2])*(estimate-Data[i,2])
    #     end
    #     #println(loss)
    #     return loss
    # end

    # function g( storage, x)
    #     grad = ForwardDiff.gradient(f,x)

    #     for i in 1:(numMonths+1)
    #         storage[i] = grad[i]
    #     end
        
    # end

    
    # O = optimize(f, g, x, BFGS())

    # N = O.minimizer[1]
    # ξ = logTrans.( O.minimizer[2:end])

    # #println( ξ )

    # #if this gets too small, we start getting numerical problems.
    # ξ = clamp.( ξ, 1e-10, 1.0 - 1e-10)


    # norm = Normal()

    # quantiles = Vector{Float64}(l)
    quantiles = quantile.( Normal(), [prod( 1 .- λ[1:i]) for i in 1:l] )
    # for i in 1:l
    #     if( m[i] == 1)
    #         quantiles[i] = clamp( quantile( norm, (1-ξ[1])^i), -3.5, 3.5 )
    #     else
    #         estimate = (1-ξ[m[i]])^(i - (m[i]-1)*MonthBreak)
    #         for j in 1:(m[i]-1)
    #             estimate *= (1.0 - ξ[j])^MonthBreak
    #         end
    #         #println( i )
    #         #println( estimate )
    #         quantiles[i] = clamp( quantile( norm, estimate), -3.5, 3.5)
    #     end
    # end
    
    #Bound this by -3 and 3, since its a normal distribution
    #quantiles = min. (max.( quantile.(norm, [prod( 1.0 .- ξ[1:i]) for i in 1:numMonths]), -3 ), 3 )

    X = ones(l,2)
    X[:,2] = quantiles

    F = cholfact(X'*X)
    β = F[:U] \ (F[:L]\ (X'*log.(Data[:,3])))

    
    dottyBoy = ones(l)
    for i in 1:l
        dottyBoy[i] = max(dot( β, X[i,:]), log(.03))
    end
    plot!( 1:l, dottyBoy[1:l])

    ladEst = LADestimate( X, log.(Data[:,3]))
    for i in 1:l
        dottyBoy[i] = max(dot( ladEst, X[i,:]), log(.03))
    end
    plot!( 1:l, dottyBoy[1:l])

    

    #This one is estimating with the quantiles as the Y as they are measured with error.
    # X[:,2] = log.(Data[:,3])

    # F = cholfact(X'*X)
    # β = F[:U] \ (F[:L]\ (X'*quantiles))

    # σ = 1.0 / β[2]
    # μ = β[1] * σ

    # for i in 1:l
    #     dottyBoy[i] = μ + σ*quantiles[i]#(dot( β, X[i,:]))
    # end
    # plot!( 1:l, dottyBoy[1:l])

end

function LADestimate( X::Matrix{Float64}, Y::Vector{Float64} )
    ladSolver = Model( solver=CbcSolver())

    l = size(X)[1]
    k = size(X)[2]

    @variable( ladSolver, u[1:l] )
    @variable( ladSolver, a[1:k] )

    @constraint( ladSolver, [i=1:l], u[i] >= Y[i] - vecdot( a, X[i,:] ) )
    @constraint( ladSolver, [i=1:l], u[i] >= -(Y[i] - vecdot( a, X[i,:] )) )
    @objective( ladSolver, Min, sum( u[i] for i in 1:l ) )

    status = solve(ladSolver)

    return getvalue( a )
end



function diffmin( x,y, ρ)
    return (-1.0/ρ)*log( exp( -ρ*x) + exp( -ρ*y))
end

function diffmax( x,y, ρ)
    return (1.0/ρ)*log( exp( ρ*x) + exp( ρ*y))
end

function BuyerVal( T, t, p, λ, bVals, dist, months )
    if t == 1
        return cdf( dist, p[T])
    else
        return (bVals[t-1]/ (bVals[t-1] + λ[months[t]]))*diffmin( 1, BuyerVal( T, t-1, p, λ, bVals, dist, months) / bVals[t-1], 10)
                + (λ[months[t]] / (bVals[t-1] + λ[months[t]]))*BuyerVal( T, 1, p, λ, bVals, dist, months)
    end
end

function SellerMass( T, t, N, p, bVals, λ, rVals )
    return  N*( 1 - bVals[t] + sum( rVals[1:(t-1)]))
end

function SellMassR( i, λ, bVals, rVals, months)
    if i == 1
        return λ[months[i]]
    else
        return λ[months[i]]*(bVals[i-1] + rVals[i-1])
    end
end

function SellerVal( T, t, p, λ, bVals, dist, sellerMass, months)
    if t == 1
        return cdf( dist, p[T])
    else 
        return (sellerMass[t-1]/sellerMass[t])*diffmax( 0, (BuyerVal(T,t-1,p,λ,bVals,dist,months) - bVals[t-1])/(1-bVals[t-1]), 10)
        + ((sellerMass[t]-sellerMass[t-1])/sellerMass[t])*BuyerVal(T,t,p,λ,bVals,dist,months)
    end
end


function ObjectiveFun( x, l, p, q, numMonths)

    dist = Normal( x[numMonths+1], exp(x[numMonths+2]) + 1 )


    buyerMass = Vector{Real}(l)
    sellerMass = Vector{Real}(l)
    bVals = Vector{Real}(l)
    sVals = Vector{Real}(l)
    rVals = Vector{Real}(l)

    for i in 1:l
        bVals[i] = BuyerVal( i,i,p,x[1:numMonths].*x[1:numMonths],bVals,dist, m)
        rVals[i] = SellMassR( i, x[1:numMonths].*x[1:numMonths], bVals, rVals, m)
        sellerMass[i] = SellerMass( i,i,exp(x[numMonths+3]),p,bVals,x[1:numMonths].*x[1:numMonths],rVals)
        sVals[i] = SellerVal(i,i,p,x[1:numMonths].*x[1:numMonths], bVals,dist, sellerMass, m)
        buyerMass[i] = exp(x[numMonths+3])*bVals[i]
    end

    return sum( (buyerMass[i] *(1-bVals[i]) - q[i])^2 + (sellerMass[i]*sVals[i] - q[i])^2 for i in 1:l )
end



function GrowthTest(Gun, Skin, Condition)


    Data = ReadGunCSV( Gun, Skin, Condition, 30)

    numMonths = convert( Int64,Data[end,1] )
    
    l = size(Data)[1]

    
    μ = 35
    σ = (15)
    N = sum(Data[:,2])
    λ = ones(numMonths)*(.1)
    m = convert( Vector{Int64}, Data[:,1] )
    p = log.(Data[:,3])
    q = Data[:,2]

    x = Vector{Float64}(numMonths+3)
    x[1:numMonths] = sqrt.(λ )
    x[numMonths+1] = μ
    x[numMonths+2] = log(σ)
    x[numMonths+3] = log(N)

    
    f(x) = ObjectiveFun( x, l, p, q, numMonths)

    function g( storage, x)
        grad = ForwardDiff.gradient(f,x)

        for i in 1:(numMonths+3)
            storage[i] = grad[i]
        end
        
    end

    
    O = optimize(f, g, x, BFGS())
    
    growth = O.minimizer[1:numMonths].^2

    ourMean = O.minimizer[numMonths+1]
    stdDev = exp(O.minimizer[numMonths+2])
    nPeeps = exp(O.minimizer[numMonths+3])
end

function NoGrowthModel()
    Data = ReadGunCSV( Gun, Skin, Condition)

    numMonths = convert( Int64,Data[end,1] )
    
    l = size(Data)[1]

    
    μ = 35
    σ = (15)
    N = (100000)
    ξ = ones(numMonths)*(.01)
    m = convert( Vector{Int64}, Data[:,1] )
    p = Data[:,3]
    q = Data[:,2]

    
    #Mass of suppliers is: $N \prod_{t=0}^{T-1} ( 1- \xi_t) \xi_T
    #Supplier distribution is: $\frac{ F_v (p) }{ \prod_{t=0}^{T-1} ( 1- \xi_t) }

    #Mass of buyers is: $N \prod_{t=0}^{T} ( 1- \xi_t)
    #Buyer distribution is: $1 - \frac{ F_v (p)}{ \prod_{t=0}^{T-1} ( 1- \xi_t) }

    #Moment restriction simplifies to:
    #N \xi_T F_v (p) = q_T
    #N ( 1- \xi_T) \left [ \prod_{t=0}^{T-1} ( 1- \xi_t) - F_v(p) \right ] = q_T
    

    x = Vector{Real}(numMonths+3)
    x[1] = log(μ)
    x[2] = log(σ)
    x[3] = log(N)
    x[4:end] = InvLog.(ξ)

    function objectiveNoEntry(x, p, q, m)
        vecZ = logTrans.(x[4:end])
        dist = Normal( exp(x[1]), exp(x[2]))


        s = exp(x[3])*exp(vecZ[m[1]])*cdf(dist,p[1]) - q[1]
        t = exp(x[3])*(1.0 - vecZ[m[1]])*( 1.0 - cdf( dist, p[1])) - q[1]
        sumsq = s*s + t*t
        
        for i in 2:l
            s = exp(x[3])*exp(vecZ[m[i]])*cdf(dist,p[i]) - q[i]

            # prodVec = 1.0
            # for j in 1:m[i]
            #     prodVec *= (1.0 - vecZ[j])
            # end
            prodVec = cdf(dist, p[i-1])
            
            t = exp(x[3])*(1.0 - vecZ[m[i]])*diffmax( prodVec - cdf( dist, p[i]), 0, 10) - q[i]
            
            sumsq += s*s + t*t
            # sumsq += s*s
        end
        return sumsq
    end

    f(x) = objectiveNoEntry( x, p, q, m )


    function g( storage, x)
        grad = ForwardDiff.gradient(f,x)

        for i in 1:(numMonths+3)
            storage[i] = grad[i]
        end
        
    end

    

    O = optimize(f, g, zeros(numMonths+3), ConjugateGradient())
    
    growth = logTrans.(O.minimizer[4:end])

    mean = exp(O.minimizer[1])
    stdDev = exp(O.minimizer[2])
    nPeeps = exp(O.minimizer[3])



    
end

             
    
