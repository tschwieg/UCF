using Plots, ProgressMeter
pyplot(leg=false, ticks=nothing)
using SymPy
using Plots
pyplot(leg=false, ticks=nothing)


@vars N
@vars n

epsilon = 0.00000000000000000000000001

g(n,N) = (N*n*(N-1))/((N+1)*(n*(N-1)+1))
f(n,N) = ((N-1)/(N+1))*(1+epsilon*n)


anim = @animate for i in linspace(0, 2π, 60)
    
    p = surface(linspace(1,10), linspace(1,10), g(n,N),color=:inferno, fillalpha=.6,
            ylabel = "Risk Aversion", xlabel="Number of Bidders",
            xlims = (1,10),xticks = 1:1:10,
            ylims = (1,10),yticks = 1:1:10)
    surface!(p, linspace(1,10), linspace(1,10), f(n,N),color=:blues, fillalpha=.9, label=["test1", "test2"])
    plot!( p, camera=(90*cos(i)+90,20))
end
#gif( "test.gif", fps=15)
    
