using JuMP
using CPLEX
using Distributions

function LADestimate( X::Matrix{Float64}, Y::Vector{Float64} )
    ladSolver = Model( solver=CplexSolver())

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


l = 1000
x = rand(Normal(100,10), l )

X = ones( l, 2 )
X[:,2] = x

Y = 14 .+ 6*x .+ rand(Normal(0,2), l )

estimates = LADestimate(X,Y)

beta = (X'X) \ (X'Y)
