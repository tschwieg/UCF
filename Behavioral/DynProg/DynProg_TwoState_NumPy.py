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

k0 = .6

s = np.array([2, 1])

TPM = np.matrix([[3 / 4, 1 / 4], [1 / 2, 1 / 2]])


# It actually takes a little bit if this is made much larger.
I = 25

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

# Don't really need these that much since I am using the methods in numpy


def MoveToChevyDomain(x):
    # Go from (a,b) to (-1,1)
    return 2 * (x - a) / (b - a) - 1

# Keep this fella around since I'm using this for the cheby roots


def MoveToProblemDomain(x):
    return a + (x + 1) * ((b - a) / 2)


k = 2 * I + 1

Xk = np.zeros(k)
for i in range(1, k + 1):
    Xk[i - 1] = MoveToProblemDomain(-math.cos(math.pi *
                                              (2 * i - 1) / (2 * k)))

# So I am just going to initialize this with the constant steady state level
# of consumption, and we will see what happens from there
#v1 = np.ones(k) * cStar * (1 / (1 - beta))
# for i in range(k):
#    v[i] = (math.sin(i)**2) * v[i]
v1 = (np.arange(0, k) * cStar * (1 / (k * (1 - beta))))
v2 = (np.arange(0, k) * cStar * (1 / (k * (1 - beta))))

#ChebyBoy = np.polynomial.chebyshev.Chebyshev.fromroots( Xk, domain=[a,b] )

A1 = np.polynomial.chebyshev.chebfit(Xk, v1, k)
A2 = np.polynomial.chebyshev.chebfit(Xk, v2, k)
#A = ChebyBoy.fit( Xk, v, k)

# This is used in the loop since scipy.minimize needs a seperate function call


def OptConsume(c, state, k, a):
    return -1 * (c[0] ** gamma + beta *
                 (TPM[state, 0] * cheb.chebval(s[0] *
                                               k**alpha - c[0], a) +
                  TPM[state, 1] * cheb.chebval(s[1] *
                                               k**alpha - c[0], a)))


# Hopefully this does the trick
prevV1 = np.zeros(k)
prevV2 = np.zeros(k)
cVec1 = np.ones(k) * cStar
cVec2 = np.ones(k) * cStar
iterCounter = 0
# Whats a reasonable limit on the number of iterations? I was getting ~ 150
while(np.linalg.norm(prevV1 - v1) > Epsilon
      or np.linalg.norm(prevV2 - v2) > Epsilon):
    prevV1 = np.copy(v1)
    prevV2 = np.copy(v2)
    for i in range(1, k + 1):
        cLow = 0
        cHigh1 = s[0] * Xk[i - 1] ** alpha + (1 - delta) * Xk[i - 1]
        cHigh2 = s[1] * Xk[i - 1] ** alpha + (1 - delta) * Xk[i - 1]
        # Choose the C in this range that maximizes c^gamma + beta*V( k^alpha - c )
        # Since we don't know V, all we have is our best guess formed by v.
        cBest1 = minimize(OptConsume, [(cLow + cHigh1) / 2],
                          (0, Xk[i - 1], A1), 'TNC', bounds=[(cLow, cHigh1)])
        cBest2 = minimize(OptConsume, [(cLow + cHigh2) / 2],
                          (1, Xk[i - 1], A2), 'TNC', bounds=[(cLow, cHigh2)])
        v1[i - 1] = -cBest1.fun
        v2[i - 1] = -cBest2.fun
        cVec1[i - 1] = cBest1.x[0]
        cVec2[i - 1] = cBest2.x[0]
    # Now we have a new V. So we can estimate a better a.
    A1 = cheb.chebfit(Xk, v1, k)
    A2 = cheb.chebfit(Xk, v2, k)
    iterCounter += 1

C1 = cheb.chebfit(Xk, cVec1, k)
C2 = cheb.chebfit(Xk, cVec2, k)

# Supposedly we have a good fit for V now.
# print(v)
# print(A)
print(iterCounter)

# This is plotting nonsense.
t = np.arange(0.0, max(Xk), 0.05)
s = np.polynomial.chebyshev.chebval(t, C1)
u = np.polynomial.chebyshev.chebval(t, C2)
fig, ax = plt.subplots()
ax.plot(t, s)
ax.plot(t, u)

ax.grid()

fig.savefig("test.png")
plt.show()
