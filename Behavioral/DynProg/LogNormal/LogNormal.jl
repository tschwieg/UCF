using Distributions
using GaussQuadrature

μ = -.005
σ = .1

degree = 10

integral = 0

x,y = GaussQuadrature.hermite(degree)
for i in 1:degree
    sNew = exp(μ + sqrt(2) * σ * x[i])
    chebValue = sNew
    integral += y[i] * chebValue
    #integral *= (1. / sqrt(π))
end
integral *= (1/sqrt(π))

print( integral )

mean( LogNormal(μ,σ))
