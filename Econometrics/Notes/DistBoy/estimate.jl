using Distributions
simulations = 1000000
ChiSize = 500
ChiBuckets = exp(-1)*[1,1,1/2,1/6,exp(1)-(8/3)]
GeoBuckets = .5*[1,.5,.25,.125,(2-1.75-.125)]

PBigGBOne =0
PBigGBTwo = 0

i = 0
j = 0

for i in 1:simulations
    Poissons = rand(Poisson(1),ChiSize)
    PChiBins = zeros(5)
    GChiBins = zeros(5)
    Geometrics = rand(Geometric( .5 ),ChiSize)
    
    for j in 1:ChiSize
        #print( min(Poissons[j],4)+1)
        PChiBins[min(Poissons[j],4)+1] += 1
        GChiBins[min(Geometrics[j],4)+1] += 1
    end
    CPBONE = 0
    CGBONE = 0
    CPBTWO = 0
    CGBTWO = 0
    for j in 1:5
        CPBONE += ((PChiBins[j]- ChiBuckets[j])/ChiBuckets[j])^2
        CGBONE += ((GChiBins[j]- ChiBuckets[j])/ChiBuckets[j])^2
        CPBTWO += ((PChiBins[j]- GeoBuckets[j])/GeoBuckets[j])^2
        CGBTWO += ((GChiBins[j]- GeoBuckets[j])/GeoBuckets[j])^2
    end
    if CPBONE > CGBONE
        PBigGBOne += 1
    end
    if CPBTWO > CGBTWO 
        PBigGBTwo += 1
    end
end

PBigGBOne / simulations
1 - (PBigGBTwo / simulations)
