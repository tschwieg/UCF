using DataFrames
using CSV
using QuantileRegression
using Plots
pyplot()

function searchdir(path,key)
    return filter(x->contains(x,key), readdir(path))
end

function ReadData( filename, gunNames )

    #Sneak peak to get the number of columns
    sneakPeak = CSV.read( filename, header=[], rows = 1, rows_for_type_detect = 1,allowmissing=:none)
    nCols = size(sneakPeak)[2]
    numGuns = convert( Int64,(nCols-2)/4)

    header = ["Price", "Quantity"]
    for i in 1:numGuns
        push!( header, string(i) *"_Price")
        push!( header, string(i) * "_Prob")
        push!( header, string(i)* "_Rarity" )
        push!( header, string(i)* "_Gun")
    end
    
    frame = CSV.read( filename, header=header, types = vcat( [Float64, Float64], repeat( [Float64, Float64, Int64, Int64], outer=[numGuns])), allowmissing=:none )

    nRows = size(frame)[1]

    nTotalGuns = size(gunNames)[1]

    expectedValues = zeros(nRows,8+nTotalGuns)
    for i in 1:nRows
        for j in 1:numGuns
            xVal = frame[i,3 + 4*(j-1)]*frame[i,4+4*(j-1)]
            expectedValues[i,8] += xVal
            expectedValues[i,2+frame[i,5+4*(j-1)]] += xVal
        end
        
    end

    println("seiughsig")

    for j in 1:nTotalGuns
        expectedValues[:,8+j] .= ((j-1) in Matrix(frame[1,6+4(0:(numGuns-1))]))
    end
    
    # expectedValues[:,1] ./= .0026
    # expectedValues[:,2] ./= .0064
    # expectedValues[:,3] ./= .032
    # expectedValues[:,4] ./= .1598
    # expectedValues[:,5] ./= .7992

    expectedValues[:,1] = frame[:,1]
    expectedValues[:,2] = frame[:,2]

    return expectedValues
end

gunNames = CSV.read( "../gunNames.txt", header=["Names"], allowmissing=:none)

xNames = vcat(["Price", "Quantity", "Gold", "Red", "Pink", "Purple", "Blue", "ExpectedValue"], gunNames[:,1] )


files = searchdir( "../Boxes/", ".csv")
numFiles = length( files)

mat = Vector{Matrix{Float64}}(numFiles)
for i in 1:numFiles
    mat[i] = ReadData( "../Boxes/" * files[i], gunNames )
end

df= DataFrame( vcat( mat...))

names!( df, Symbol.( replace. (xNames, "-", "")) )

hasGold = Vector{Bool}(numFiles)
dfTest = Vector{DataFrame}(numFiles)
for i in 1:numFiles
    dfTest[i] = DataFrame( mat[i])
    names!( dfTest[i], Symbol.( replace. (xNames, "-", "")) )
    if dfTest[i][:Gold] == zeros( size(dfTest[i])[1])
        hasGold[i] = false
    else
        hasGold[i] = true
    end
end

ResultQR = Matrix{StatsModels.DataFrameRegressionModel}(99,20)
coeffs = zeros(6,99)
for i in 1:99
    
    for j in 1:20
        if( hasGold[j])
            ResultQR[i,j] = qreg(@formula(Price ~ Gold + Red + Pink + Purple + Blue + 1 ), dfTest[j], i/100.0)
        else
            ResultQR[i,j] = qreg(@formula(Price ~ Red + Pink + Purple + Blue + 1 ), dfTest[j], i/100.0)
        end
    end
    # for j in 1:6
    #     for z in 1:20
    #         if( hasGold[z])
    #             coeffs[j,i] += coef( ResultQR[i,z])[j]
    #         elseif j == 1 
    #             coeffs[j,i] += coef( ResultQR[i,z])[j]
    #         elseif j > 2
    #             coeffs[j,i] += coef( ResultQR[i,z])[j-1]
    #         end
    #     end
    # end
    # coeffs[1,i] /= 20.0
    # coeffs[3:6,i] /= 20.0
    # coeffs[2,i] /= sum( hasGold )
end


for i in 1:99
    for z in 1:20
        coeffs[1,i] += coef( ResultQR[i,z])[1]
        coeffs[3,i] += coef( ResultQR[i,z])[2 + hasGold[z]]
        coeffs[4,i] += coef( ResultQR[i,z])[3 + hasGold[z]]
        coeffs[5,i] += coef( ResultQR[i,z])[4 + hasGold[z]]
        coeffs[6,i] += coef( ResultQR[i,z])[5 + hasGold[z]]
        if hasGold[z]
            coeffs[2,i] += coef( ResultQR[i,z])[2]
        end
    end
    coeffs[1,i] /= 20
    coeffs[3:6,i] ./= 20
    coeffs[2,i] /= sum( hasGold)
end


plot( 1:99, coeffs[2,:], label="Gold", color=:gold )
plot!( 1:99, coeffs[3,:], label="Red", color=:red )
plot!( 1:99, coeffs[4,:], label="Pink", color=:pink )
plot!( 1:99, coeffs[5,:], label="Purple", color = :purple )
plot!( 1:99, coeffs[6,:], label="Blue", color = :blue )

savefig( "../Plots/SepEstimate.pdf")


ResultQR = Vector{StatsModels.DataFrameRegressionModel}(99)
for i in 1:99
    ResultQR[i] = qreg(@formula(Price ~ Gold + Red + Pink + Purple + Blue + AK47 + AUG + AWP + CZ75Auto + DesertEagle + DualBerettas + FAMAS + FiveSeveN + G3SG1 + GalilAR + Glock18 + M249 + M4A1S + MAC10 + MAG7 + MP7 + MP9 + Negev + Nova ), df, i/100.0)
end

gug= qreg(@formula(Price ~ Gold + Red + Pink + Purple + Blue + AK47 + AUG + AWP + CZ75Auto + DesertEagle + DualBerettas + FAMAS + FiveSeveN + G3SG1 + GalilAR + Glock18 + M249 + M4A1S + MAC10 + MAG7 + MP7 + MP9 + Negev + Nova), df, .95 )

coeffs = Matrix{Float64}(25,99)
for i in 1:99
    coeffs[1:25,i] = coef(ResultQR[i])[1:25]
end

plot( 1:99, coeffs[2,:], label="Gold", color=:gold )
plot!( 1:99, coeffs[3,:], label="Red", color=:red )
plot!( 1:99, coeffs[4,:], label="Pink", color=:pink )
plot!( 1:99, coeffs[5,:], label="Purple", color = :purple )
plot!( 1:99, coeffs[6,:], label="Blue", color = :blue )

savefig( "../Plots/Quality.pdf")


interestingNames = ["AK-47", "AWP", "DesertEagle", "M4A1-S", "G3SG1", "M249", "Negev", "DualBerettas"]

gunNames = vcat( gunNames[1:13,:], gunNames[15:34,:] )

intIndex = Vector{Int64}(8)
for i in 1:8
    intIndex[i] = findfirst( gunNames[:,1], interestingNames[i])
end


plot( 1:99, coeffs[intIndex[1]+6,:], label=interestingNames[1], legend=:bottomleft)
for i in 2:8
    plot!( 1:99, coeffs[intIndex[i]+6,:], label=interestingNames[i] )
end
savefig( "../Plots/CloserLook.pdf" )

plot( 1:99, coeffs[7,:], legend =:none)
for i in 8:25
    plot!( 1:99, coeffs[i,:])
end
savefig( "../Plots/..QuantReg.pdf")
