import numpy as np
from scipy.optimize import minimize
import math
import matplotlib.pyplot as plt

# Initialize the parameters of the problem.

alpha = .4
beta = .9
gamma = .5
delta = .1

k0 = .6

# It actually takes a little bit if this is made much larger.
I = 5

# The steady state comes from the point where capital and consumption
# are unchanging, so:
# k = k^alpha + (1-delta)k - c
# Solve to reach: c =  k^alpha -  delta k
# Applying the golden rule, AKA max consumption so del c del k = 0
# alpha k^(alpha-1) - delta = 0
# k = (delta/alpha)^(1/(alpha-1))

#kStar = (delta / alpha)**(1 / (alpha - 1))
kStar = (((1 / beta) + delta - 1) / alpha)**(1. / (alpha - 1.))
cStar = kStar**alpha - delta * kStar

Epsilon = .00001

# Now we need to map our points from k0 to kStar + (kStar - k0) to -1,1
a = k0
b = 2 * kStar - k0


def MoveToChebyDomain(x):
    # Go from (a,b) to (-1,1)
    return 2 * (x - a) / (b - a) - 1


def MoveToProblemDomain(x):
    return a + (x + 1) * ((b - a) / 2)

# Following the Notation of Paarsch and Golyeav


def LSFit(y, bT, M):
    a = np.zeros(M)
    for m in range(0, M):
        a[m] = sum(y * bT[m, :]) / sum(bT[m, :] * bT[m, :])

    return a


# This again follows the work in "Effective Computing in Quantitative Research"
def BuildChebyCoeff(Xk, v, k):
    M = k - 1
    # Initialize the matrix, setting the second row
    bT = np.ones((M, k))
    bT[1, :] = Xk
    # Recursively fill the matrix using the Chebyshev polynomials
    for m in range(2, M):
        bT[m, :] = 2. * Xk * bT[m - 1, :] - bT[m - 2, :]
    # Fit the coefficients using Least Squares ala Paarsch/Golyeav
    aHat = LSFit(v, bT, M)
    return aHat

# This builds the chebyshev polynomials recursively


def Chebyshev(index, xVal):
    # Since T_0 = 1 and T_1 = x
    # And T_n = 2xT_n-1 - T_n-2
    if(index == 0):
        return 1

    if(index == 1):
        return xVal

    return(2 * xVal * Chebyshev(index - 1, xVal) - Chebyshev(index - 2, xVal))


# This evaluates Chebyshev polynomials for some coefficients and some x value - Having issues vectoring this.
def EvalChebyCoeff(A, xVal):
    # Evaluate a ChebyChev Polynomial
    # with coefficients a
    # at x and return its value.
    value = 0

    for i in range(len(A)):
        value += A[i] * (Chebyshev(i, xVal))
    return value


k = 2 * I + 1

Xk = np.zeros(k)
for i in range(1, k + 1):
    Xk[i - 1] = -math.cos(math.pi * (2 * i - 1) / (2 * k))

# So I am just going to initialize this with the constant steady state level
# of consumption, and we will see what happens from there
v = np.ones(k) * cStar * (1 / (1 - beta))


A = BuildChebyCoeff(Xk, v, k)


def OptConsume(c, k, a):
    return -1 * (c[0] ** gamma + beta * EvalChebyCoeff(a, MoveToChebyDomain(k**alpha - c[0])))


# Hopefully this does the trick
prevV = np.zeros(k)
cVec = np.ones(k) * cStar
iterCounter = 0
# Whats a reasonable limit on the number of iterations? I was getting ~ 150
while(np.linalg.norm(prevV - v) > Epsilon):
    prevV = np.copy(v)
    for i in range(k):
        curK = MoveToProblemDomain(Xk[i])
        cLow = 0
        cHigh = curK ** alpha + (1 - delta) * curK
        #curK = ((cLow + cHigh) / 2)
        # Choose the C in this range that maximizes c^gamma + beta*V( k^alpha - c )
        # Since we don't know V, all we have is our best guess formed by v.
        cBest = minimize(OptConsume, [(cLow + cHigh) / 2],
                         (curK, A), 'TNC', bounds=[(cLow, cHigh)])
        v[i] = -cBest.fun
        cVec[i] = cBest.x[0]
    # Now we have a new V. So we can estimate a better a.
    A = BuildChebyCoeff(Xk, v, k)
    iterCounter += 1

C = BuildChebyCoeff(Xk, cVec, k)
#C = np.polynomial.chebyshev.chebfit(Xk, cVec, k)

# Supposedly we have a good fit for V now.
# print(v)
# print(A)
print(iterCounter)

# This is plotting nonsense.
t = np.arange(0., MoveToProblemDomain(max(Xk)), .05)

#s = np.polynomial.chebyshev.chebval(t, C)
s = EvalChebyCoeff(C, MoveToChebyDomain(t))
#u = np.polynomial.chebyshev.chebval(t, A)
fig, ax = plt.subplots()
ax.plot(t, s)
#ax.plot(t, u)

ax.grid()

fig.savefig("test.png")
plt.show()
