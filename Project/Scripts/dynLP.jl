using JuMP
using CPLEX
using Distributions



function SolveLP( f::Matrix{Float64}, sellerN::Int64, buyerN::Int64 )
    primal = Model( solver=CplexSolver())

    @variable( primal, 1 >= a[1:buyerN,1:sellerN] >= 0)

    buyerConst = @constraint( primal, [i=1:buyerN], sum(a[i,j] for j in 1:sellerN) <= 1)
    sellerConst = @constraint( primal, [j=1:sellerN], sum(a[i,j] for i in 1:buyerN) <= 1)

    @objective( primal, Max,  sum( a[i,j]*f[i,j] for i in 1:buyerN, j in 1:sellerN))

    status = solve(primal)

    buyers = Vector{Float64}()
    sellers = Vector{Float64}()
    for i in 1:buyerN
        for j in 1:sellerN
            if getvalue(a[i,j]) > 0
                push!(buyers,i)
                push!(sellers,j)
            end
        end
    end
    return [buyers,sellers,sellerConst]
end

function RunProcess()

    #This is the total number of people in the model
    N = 1000
    dist = Normal(40,14.87)
    srand( 235711 )

    entryDist = Poisson( 150 )

    p = .01
    numLoops = 100

    buyerN = N
    sellerN = 0
    People = max.( rand( dist, N ), 0 )
    HaveNots = People

    Haves = Vector{Int64}()
    HaveNots = Vector{Int64}()
    for i in 1:N
        push!(HaveNots, i )
    end

    Prices = Vector{Float64}(numLoops)
    for z in 1:numLoops

        #println( "Starting Loop" )
        coinflip = rand( Uniform(), N )
        for i in 1:N
            if i in Haves
                continue
            end
            if coinflip[i] < p
                push!( Haves, i )
                deleteat!( HaveNots, findfirst( HaveNots,i ) )
            end
        end

        buyerN = length( HaveNots )
        sellerN = length( Haves)

        #println( "Building f" )

        f = Matrix{Float64}(buyerN,sellerN)
        for i in 1:buyerN
            for j in 1:sellerN
                f[i,j] = People[HaveNots[i]] - People[Haves[j]]
            end
        end

        #println( "Running LP" )

        buyers,sellers,sellerConst = SolveLP( f, sellerN, buyerN )
        buyers = convert.( Int64, buyers )
        sellers = convert.( Int64, sellers )

        Prices[z] =  minimum( [People[Haves[i]] for i in 1:length(Haves ) ] ) + maximum( getdual( sellerConst) )
        #println( "Cleaning up" )

        peopleIndexB = [HaveNots[buyers[i]] for i in 1:length(buyers)]
        peopleIndexS = [Haves[sellers[i]] for i in 1:length(sellers)]
        for i in 1:length(buyers)
            push!( Haves, peopleIndexB[i] )
            #Just using deleteat had problems with the index changing after deletes
            deleteat!( HaveNots, findfirst( HaveNots, peopleIndexB[i] ) )
            #Delete him
        end
        #println( "Seller Cleanup" )
        for i in 1:length(sellers)
            push!( HaveNots, peopleIndexS[i] )
            deleteat!( Haves,  findfirst( Haves, peopleIndexS[i] ) )
        end

        #println("Adding Fresh Meat" )
        #Lets add some fresh meat
        # newEntries = rand( entryDist )
        # NewPeople = max.( rand( dist, newEntries ), 0 )
        # #People += NewPeople
        # append!( People, NewPeople )
        # for i in (N+1):(N+newEntries)
        #     push!(HaveNots, i )
        # end
        # N += newEntries
        # #println( "Added meat" )
    end
    return Prices
end
