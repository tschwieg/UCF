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
mu = -.5
sigma = 1

k0 = .6

# It actually takes a little bit if this is made much larger.
I = 10

# The steady state comes from the point where capital and consumption
# are unchanging, so:
# k = k^alpha + (1-delta)k - c
# Solve to reach: c =  k^alpha -  delta k
# Applying the golden rule, AKA max consumption so del c del k = 0
# alpha k^(alpha-1) - delta = 0
# k = (delta/alpha)^(1/(alpha-1))

kStar = (((1 / beta) + delta - 1) / alpha)**(1. / (alpha - 1.))
cStar = kStar**alpha - delta * kStar

Epsilon = .001

# Now we need to map our points from k0 to kStar + (kStar - k0) to -1,1
a = k0
b = 2 * kStar - k0
sLow = 0
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

#v = np.ones(k) * cStar * (1 / (1 - beta))
v = (np.arange(0, k) * cStar * (1 / (k * (1 - beta))))

A = cheb.chebfit(Xk, v, k)

x, y = np.polynomial.hermite.hermgauss(7)


def GaussHermiteIntegrate(degree, A, c, k):
    """This returns the integral of the expected Value function when
 s is a log-normal distribution."""
    # Note that f(x) = V( (s**rho)*exp(sigma*x*sqrt(2))*k**alpha - c, (s**rho) *
    # exp( sigma*x*sqrt(2))) * 1/sqrt(pi)
    integral = 0
    for i in range(degree):
        # Traditonally we used: V( k^alpha - c)
        # Now it has taken the form of: V( s*k^alpha - c, s)
        sNew = np.exp(mu + np.sqrt(2) * sigma * x[i])
        #xPos = np.clip(sNew * k**alpha - c, a, b)
        xPos = sNew * k**alpha - c
        if( xPos < a):
            print( xPos )
        if( xPos > b ):
            print( xPos )
        chebValue = cheb.chebval(xPos, A)
        integral += y[i] * chebValue
    return integral * (1. / np.sqrt(math.pi))

# Since we know that


def OptConsume(c, k, a):
    """This is the function that is optimized to find optimal consumption
 for the current capital and shock given v"""
    return -1 * (c[0] ** gamma + beta * GaussHermiteIntegrate(7, a, c[0], k))


#Initialize the values:
prevV = np.zeros(k)
cVec = np.ones(k) * cStar
iterCounter = 0

# Whats a reasonable limit on the number of iterations? I was getting ~ 150
while(np.linalg.norm(prevV - v) > Epsilon):
    prevV = np.copy(v)
    for i in range(k):
        cLow = 0
        cHigh = Xk[i] ** alpha + (1 - delta) * Xk[i]
        # Choose the C in this range that maximizes c^gamma + beta*E[V( s*k^alpha - c )]
        # Since we don't know V, all we have is our best guess formed by v.
        cBest = minimize(OptConsume, [(cLow + cHigh) / 2],
                         (Xk[i], A), 'TNC', bounds=[(cLow, cHigh)])
        v[i] = -cBest.fun
        cVec[i] = cBest.x[0]

    # Now we have a new V. So we can estimate a better a.
    A = cheb.chebfit(Xk, v, k)
    iterCounter += 1
    print(iterCounter)
    print(v)
    print("\n\n")

C = cheb.chebfit(Xk, cVec, k)

# Supposedly we have a good fit for V now.
# print(v)
# print(A)
print(iterCounter)

# This is plotting nonsense.
t = np.arange(0.0, max(Xk), 0.05)
s = cheb.chebval(t, C)
u = cheb.chebval(t, A)
fig, ax = plt.subplots()
ax.plot(t, s)
#ax.plot(t, u)

ax.grid()

fig.savefig("LogNormalConsumption.png")
plt.show()
