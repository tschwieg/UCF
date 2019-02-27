using DataFrames
using CSV
using Query
using Distributions
using ForwardDiff


function searchdir(path,key)
    return filter(x->contains(x,key), readdir(path))
end

Gun = "AK-47"
Skin = "Jaguar"

Directory = "../Data/AK-47/Jaguar/FactoryNew.csv"


frame = CSV.read(Directory , header= ["Date", "Price", "Quantity"], dateformat=DateFormat("d-m-y") )

data = Matrix(frame)[:,2]

months = convert( Int64, ceil(length(data)/30))


N = 11145196

function diffmin( x,y, ρ)
    return (-1.0/ρ)*log( exp( -ρ*x) + exp( -ρ*y))
end

function diffmax( x,y, ρ)
    return (1.0/ρ)*log( exp( ρ*x) + exp( ρ*y))
end


function logLik( p, μ, σ )
    dist = LogNormal( μ, σ)
    l = length(data)

    cLast = 1
    Lik = 0

    c = cdf( dist, p[1])
    var = c*(1.0 - c)
    Lik = logpdf( Normal( 0, sqrt( var ) ), 0 )
    
    
    for i in 1:l
        c = cdf(dist,p[i])
        #prodXI *= ξ[i-1]
        mean = 0#N*(prodXI*ξ[i] - c)
        variance = c*diffmax(1.0 - c/cLast,0,10)
        #println( c,"    ", cLast )
        Lik += logpdf( Normal( mean, sqrt(variance) ),0)
        cLast = c
    end
    return Lik
end



x = ones(2)
x[1] = log(5)
x[2] = log(3)
#x[3] = log( 10 )

w = 100


function rep( x, n)
    return repeat( [x], outer=[n])
end


function f(x)
    # ξ = Vector{Real}(length(data))
    # for i in 1:(months-1)
    #     ξ[(30*(i-1)+1):(30*i)] = exp.( ones(30)*x[2+i]) ./ ( 1 .+ exp.( ones(30)*x[2+i]) )
    # end
    # ξ[(30*(months-1)+1):end] = exp.( ones(length(data)-(30*(months-1)))*x[end]) ./ ( 1 .+ exp.( ones(length(data)-(30*(months-1)))*x[end]) )
    return logLik( data, exp(x[1]), exp(x[2]) )
end


g = x -> ForwardDiff.gradient(f,x);
h = x -> ForwardDiff.hessian( f,x );

grad = g(x)
iterations = 0
while( vecnorm(grad) > 1e-10 && iterations < 50)
    x = x - h(x) \ grad
    
    println( vecnorm(grad))
    #println(exp(x[1]))
    #println(exp(x[2]))

    grad = g(x)
    iterations += 1
end

