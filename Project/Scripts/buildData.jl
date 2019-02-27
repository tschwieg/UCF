using DataFrames
using CSV
using Query
using Distributions
using Plots

pyplot()

function searchdir(path,key)
    return filter(x->contains(x,key), readdir(path))
end

function BuildSkinCSV( Gun, Skin )
    Directory = "../Data/" * Gun * "/" * Skin * "/"

    files = searchdir( Directory, ".csv")
    frames = Vector{DataFrame}(length(files))
    for i in 1:length(files)
        frames[i] = CSV.read(Directory * files[i], header= ["Date", "Price", "Quantity"], dateformat=DateFormat("d-m-y") )

        #Add the indicators for qualities that aren't factory new
        for j in 2:5
            if( length(files) >= j )
                frames[i] = hcat( frames[i], repeat( [i==j], outer=[nrow( frames[i])]), makeunique=true)
            else
                break
            end
        end
    end

    #Combine all the frames into one giant frame
    bigData = vcat( frames[1], frames[2])
    if( length( files ) > 2 )
        for i in 3:length(files )
            bigData = vcat( bigData, frames[i])
        end
    end

    #print( head( bigData))


    #Now we need to add up the quantities sold at each date
    uniqueDates = sort!( unique( bigData, :Date), :Date )

    quantities =  @from i in uniqueDates begin
                         @join j in bigData on i.Date equals j.Date into k
                         @select {i.Date, Q=(sum(k..Quantity))}
                         @collect DataFrame
    end

    quantities = Matrix( sort!( quantities, :Date))[:,2]


    #What this should be is up for some debate
    #playerCount = 11145196*.1
    playerCount = sum(quantities)


    #we know that: ξ(1-ξ)N = q
    @simd for i in 1:length( quantities)
        #quantities[i] = 1 - quantities[i] / playerCount
        quantities[i] = (playerCount + sqrt(playerCount*playerCount - 4*playerCount*quantities[i]) )/(2*playerCount)
    end

    Regressands = Vector{Float64}(length(quantities))
    dist  = Normal(0,1)
    for i in 1:length(quantities)
        Regressands[i] = quantile( dist, prod( quantities[1:i]))
    end

    #print( Regressands)

    #Append the inverse normal of our quantiles
    uniqueDates = hcat( uniqueDates, Regressands, makeunique=true )

    #We need to grab the indicators if they exist
    if length( frames ) == 1
        bigData = @from i in uniqueDates begin
            @join j in bigData on i.Date equals j.Date
            @orderby i.Date
            @select {i.x1, j.Price }
            @collect DataFrame
        end
        names!(bigData, [:ZScore, :Price ])
    elseif length(frames ) == 2
        bigData = @from i in uniqueDates begin
            @join j in bigData on i.Date equals j.Date
            @orderby i.Date
            @select {i.x1_1, j.Price, j.x1 }
            @collect DataFrame
        end
        names!(bigData, [:ZScore, :Price, :IndOne ])
    elseif length( frames) == 3
        bigData = @from i in uniqueDates begin
            @join j in bigData on i.Date equals j.Date
            @orderby i.Date
            @select {i.x1_2, j.Price, j.x1, j.x1_1 }
            @collect DataFrame
        end
        names!(bigData, [:ZScore, :Price, :IndOne, :IndTwo ])
    elseif length( frames) == 4
        bigData = @from i in uniqueDates begin
            @join j in bigData on i.Date equals j.Date
            @orderby i.Date
            @select {i.x1_3, j.Price, j.x1, j.x1_1, j.x1_2 }
            @collect DataFrame
        end
        names!(bigData, [:ZScore, :Price, :IndOne, :IndTwo, :IndThree ])
    elseif length(frames ) == 5
        bigData = @from i in uniqueDates begin
            @join j in bigData on i.Date equals j.Date
            @orderby i.Date
            @select {i.x1_4, j.Price, j.x1, j.x1_1, j.x1_2, j.x1_3 }
            @collect DataFrame
        end
        names!(bigData, [:ZScore, :Price, :IndOne, :IndTwo, :IndThree, :IndFour ])
    end


    CSV.write(  "../Data/" * Gun * "/" * Skin * ".csv", bigData)
    return bigData
end


function EstimateLeastSquares( df, logNormal )
    y = copy(df[:,1])
    #We need to add the row of all ones
    x = copy(df)
    x[:,1] = repeat( [1], outer=[size(df)[1]])
    if logNormal
        x[:,2] = log.( x[:,2])
    end
    

    #X'X is positive definite, so invert it wtih the choleksy decomp
    F = cholfact(x'*x)
    β = F[:U] \ (F[:L]\ (x'*y))

    #Now our consutrction of μ and σ from the estimates.
    σ = 1 / β[2]
    μ = -β[1]*σ
    return [μ,σ]
end


skins = searchdir( "../Data/AK-47/", "")
for skin in skins
    df = BuildSkinCSV( "AK-47", skin)
    logEstimates = EstimateLeastSquares( Matrix( df ), true)
    Estimates = EstimateLeastSquares( Matrix( df), false)

    println( Estimates )

    #println(Estimates)

    # facnew = @from i in df begin
    #     @where i.IndOne == false
    #     @where i.IndTwo == false
    #     @where i.IndThree == false
    #     @where i.IndFour == false
    #     @select { i.ZScore, i.Price }
    #     @collect DataFrame
    # end

    # p = Matrix( facnew )[:,2]
    # lnY = exp.( logEstimates[1] + logEstimates[2]*(Matrix(facnew)[:,1]))
    # regY = Estimates[1] + Estimates[2]*(Matrix(facnew)[:,1])

    # l = length(p)
    # plot( 1:l, p )
    # plot!( 1:l, lnY)
    # plot!( 1:l, regY )
    # println( Estimates)
    # savefig( "../Plots/AK-47/" * skin)
end

