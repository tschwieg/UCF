using JuMP
using Cbc
using Distributions
using Plots

dual = Model( solver=CbcSolver())

p = .5

N = 100
BuyerN = convert(Int64, floor(N*(1-p)/p) )

dist = Normal(35,10)
f = Matrix{Float64}(BuyerN,N)
for i in 1:BuyerN
    for j in 1:N
        f[i,j] = max(quantile(dist,((i-1)/BuyerN)),0) - max(quantile( dist, (j-1)/N), 0 )
    end
end


@variable( dual, x[1:BuyerN] >= 0)

@variable( dual, y[1:N] >= 0)

@constraint( dual, [i=1:BuyerN,j=1:N], x[i] + y[j] >= f[i,j] )

@objective( dual, Min, sum(x[i] for i in 1:BuyerN) + sum(y[j] for j in 1:N))

status = solve(dual)

println( getobjectivevalue(dual))

println( getvalue( x))
println( getvalue( y))

prices = getvalue(y)[getvalue(y) .> 0]
numPrices = length(prices)




primal = Model( solver=CbcSolver())

@variable( primal, 1 >= a[1:BuyerN,1:N] >= 0)
@constraint( primal, [i=1:BuyerN], sum(a[i,j] for j in 1:N) <= 1)
@constraint( primal, [j=1:N], sum(a[i,j] for i in 1:N) <= 1)

buyers = Vector{Float64}()
sellers = Vector{Float64}()

@objective( primal, Max,  sum( a[i,j]*f[i,j] for i in 1:BuyerN, j in 1:N))
status = solve(primal)
for i in 1:BuyerN
    for j in 1:N
        if( getvalue(a[i,j]) > 0 )
            println( "There is a trade made between type: ", i, " and ", j )
            push!(buyers,i)
            push!(sellers,j)
        end
    end
end

println( sort!(buyers))
println( sort!(sellers))

price = [max(quantile(dist, (i-1)/N),0) + getvalue(y[i]) for i in 1:N]
#push!(price,price[end])

Supply = max.( quantile.( dist, (0:(N-1))/N ), 0 )
#Supply = price .- getvalue(y)
Demand = max.( quantile.( dist, (0:(BuyerN-1))/BuyerN), 0)
#Demand = [price[i] .+ getvalue(x[BuyerN+1-i]) for i in 1:N]

plot( (1:N)/N, Supply, label="Supply")

plot!( (1:N )/N, price, label = "Seller type + Producer Surplus", color=:green )
plot!( (1:N)/N, reverse!(Demand[(BuyerN-N+1):(BuyerN)]), label="Demand", color=:red )

savefig( "evenStevens.pdf")
