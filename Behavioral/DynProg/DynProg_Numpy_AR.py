import numpy as np
import numpy.polynomial.chebyshev as cheb
from scipy.optimize import minimize
import math
import matplotlib.pyplot as plt

# Initialize the parameters of the problem.

alpha = .4
beta = .9
gamma = .5
delta = .1
rho = .8
sigma = 1

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

kStar = (((1 / beta) + delta - 1) / alpha)**(1. / (alpha - 1.))
cStar = kStar**alpha - delta * kStar

Epsilon = .00001

# Now we need to map our points from k0 to kStar + (kStar - k0) to -1,1
a = k0
b = 2 * kStar - k0
sLow = 0.5
sHigh = 10

# Don't really need these that much since I am using the methods in numpy


def MoveToChevyDomain(x, a, b):
    # Go from (a,b) to (-1,1)
    return 2 * (x - a) / (b - a) - 1

# Keep this fella around since I'm using this for the cheby roots


def MoveToProblemDomain(x, a, b):
    return a + (x + 1) * ((b - a) / 2)


k = 2 * I + 1

Xk = np.zeros(k)
for i in range(1, k + 1):
    Xk[i - 1] = MoveToProblemDomain(-math.cos(math.pi *
                                              (2 * i - 1) / (2 * k)), a, b)
Xj = np.zeros(k)
for i in range(1, k + 1):
    Xj[i - 1] = MoveToProblemDomain(-math.cos(math.pi *
                                              (2 * i - 1) / (2 * k)), sLow, sHigh)
# The order is A[s,k]
# Shock is the first element, and capital is second
v = np.ones(k * k) * cStar * (1 / (1 - beta))
#A = []
# for j in range(k):
#     v[j, :] = (np.arange(0, k) * cStar * (1 / (k * (1 - beta))))
# A.append(cheb.chebfit(Xk, v[j, :], k))


def FitChebyshev2d(k, v, Xk, Yk):
    """Use a least squares fit to fit a polynomial to both x and y
This is mostly going to be ripped from numpy.polynomial.chebyshev"""
    Xk = MoveToChevyDomain(np.asarray(Xk) + 0.0, a, b)
    Yk = MoveToChevyDomain(np.asarray(Yk) + 0.0, sLow, sHigh)

    M = k - 1
    # Initialize the matrix, setting the second row
    bT = np.ones((2 * M - 1, k * k))
    for i in range(k):
        bT[1, (k * i):((i + 1) * k)] = Xk
        # Recursively fill the matrix using the Chebyshev polynomials
        for m in range(2, M):
            bT[m, k * i:(i + 1) * k] = 2. * Xk * bT[m - 1, k *
                                                    i:(i + 1) * k] - bT[m - 2, k * i:(i + 1) * k]

        # Need to do Two here since we don't have a seperate y intercept.
        bT[M, k * i:(i + 1) * k] = Yk
        bT[M + 1, k * i:(i + 1) * k] = 2. * Yk + Yk - bT[0, k * i:(i + 1) * k]
        # Pretty much the same fit as the X but now for Ys
        for m in range(M + 2, 2 * M - 1):
            bT[m, k * i:(i + 1) * k] = 2. * Yk * bT[m - 1, k *
                                                    i:(i + 1) * k] - bT[m - 2, k * i:(i + 1) * k]

    coeff, r, rank, s = np.linalg.lstsq(bT.T, v)
    return coeff


def Chebyshev(index, xVal):
    # Since T_0 = 1 and T_1 = x
    # And T_n = 2xT_n-1 - T_n-2
    if(index == 0):
        return 1

    if(index == 1):
        return xVal

    return(2 * xVal * Chebyshev(index - 1, xVal) - Chebyshev(index - 2, xVal))


def EvalChebyShev2D(A, x, y, k):
    value = A[0]
    for i in range(k - 2):
        value += A[i + 1] * Chebyshev(i + 1, MoveToChevyDomain(x, a, b)) + \
            A[k + i - 1] * Chebyshev(i + 1, MoveToChevyDomain(y, sLow, sHigh))
    return value


A = FitChebyshev2d(k, v, Xk, Xj)

x, y = np.polynomial.hermite.hermgauss(5)


def GaussHermiteIntegrate(degree, A, s, c, Cap):
    """This returns the integral of the expected Value function when
 s is a log-normal distribution."""
    # Note that f(x) = V( (s**rho)*exp(sigma*x*sqrt(2))*k**alpha - c, (s**rho) *
    # exp( sigma*x*sqrt(2))) * 1/sqrt(pi)

    integral = 0
    for i in range(degree):
        # Traditonally we used: V( k^alpha - c)
        # Now it has taken the form of: V( s*k^alpha - c, s)
        sNew = np.clip(s**rho * np.exp(np.sqrt(2) * sigma * x[i]), sLow, sHigh)
        xPos = np.clip(sNew * Cap**alpha - c, a, b)
        yPos = sNew
        chebValue = EvalChebyShev2D(A, xPos, yPos, k)
        integral += y[i] * chebValue
        # print(xPos)
        # print(yPos)
        # print(chebValue)
        # print(y[i] * chebValue)
        # print("\n\n")
    return integral * (1 / np.sqrt(math.pi))


def OptConsume(c, k, a, s):
    """This is the function that is optimized to find optimal consumption
 for the current capital and shock given v"""
    return -1 * (c[0] ** gamma + beta * GaussHermiteIntegrate(5, a, s, c[0], k))


# Hopefully this does the trick
prevV = np.zeros(k * k)
cVec = np.ones(k) * cStar
iterCounter = 0
# Whats a reasonable limit on the number of iterations? I was getting ~ 150
while(np.linalg.norm(prevV - v) > Epsilon):
    prevV = np.copy(v)
    for i in range(k):
        for j in range(k):
            cLow = 0
            cHigh = Xj[j] * Xk[i] ** alpha + (1 - delta) * Xk[i]
            # Choose the C in this range that maximizes c^gamma + beta*V( k^alpha - c )
            # Since we don't know V, all we have is our best guess formed by v.
            cBest = minimize(OptConsume, [(cLow + cHigh) / 2],
                             (Xk[i], A, Xj[j]), 'TNC', bounds=[(cLow, cHigh)])
            v[i * k + j] = -cBest.fun

        #cVec[i - 1] = cBest.x[0]
    # Now we have a new V. So we can estimate a better a.
    A = FitChebyshev2d(k, v, Xk, Xj)
    iterCounter += 1
    print(iterCounter)
    print(v)

#C = cheb.chebfit(Xk, cVec, k)

# Supposedly we have a good fit for V now.
# print(v)
# print(A)
print(iterCounter)

# This is plotting nonsense.
# t = np.arange(0.0, max(Xk), 0.05)
# s = cheb.chebval(t, C)
# u = cheb.chebval(t, A)
# fig, ax = plt.subplots()
# ax.plot(t, s)
# #ax.plot(t, u)

# ax.grid()

# fig.savefig("test.png")
# plt.show()
