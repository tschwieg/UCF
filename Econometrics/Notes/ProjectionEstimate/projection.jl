using SymPy
using Distributions
import Distributions.mgf

@vars x

@vars e_1,e_2,e_3

N = 1000
λ = 1

Dist = Erlang( N, 1/λ )

#Find the bounds by figuring out a confidence interval on the sum then apply the transformation
gamRange = [mean(Dist)-std(Dist)*3.0/sqrt(N), mean(Dist)+std(Dist)*3.0/sqrt(N)]

myNorm(F) = integrate( F*F, x, 1/gamRange[2], 1/gamRange[1])
innerprod( F,G ) = integrate( F*G, x, 1/gamRange[2], 1/gamRange[1])

gamMean = mean( Erlang(N,1/λ))
gamMomentTwo = var( Erlang(N,1/λ)) + gamMean^2

approxMoment = innerprod( 1/x, 1) + innerprod( 1/x,x)*gamMean + innerprod( 1/x, x^2)*gamMomentTwo
