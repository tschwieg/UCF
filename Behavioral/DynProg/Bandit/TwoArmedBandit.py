# This is a python implementation of TwoArmedBandit.m
# Note that since this relies heavily on vectorization in numpy,
# It will not run properly in python 2.7. Run with Python3

import numpy as np
import matplotlib.pyplot as plt
import copy

# These are the paramters of the problem
alpha1 = .25
yh1 = 50
yl1 = -50
alpha2 = .5
beta2 = 0.05
yh2 = 200
yl2 = -50
delta = .95

# How close does our norm need to be
Epsilon = .00000001

# n is the number of steps where we approximate the function
n = 9999
# This gives us n numbers between 0 and 1, begining the index at one.
# In R or Julia this would be: (1:n)*(1/(n+1))
phi = (np.arange(n) + 1) * (1 / (n + 1))

# vone is the function we are approximating, lets start with a really bad fit
vone = np.ones(n) * -999999
# This will be the distance between the functions, lets start it off quite large
dnorm = 999999
# Lets see how long it takes us to approximate this function
iter = 1

while(dnorm >= Epsilon):
    dnorm = 0
    vnot = np.copy(vone)
    # V1 is the safe bet
    V1 = (1 - delta) * (alpha1 * yh1 + (1 - alpha1) * yl1) + delta * vnot

    # j is the indices of the updates for sucess for each phi
    # This is why it is clamped to 0,n-1 and is forced to be an integer
    phips = phi * alpha2 / (phi * alpha2 + (1 - phi) * beta2)
    j = np.clip(np.round(n * phips), 0, n - 1).astype(int)

    # k is the indices of the updates for failures for each phi
    phipf = phi * (1 - alpha2) / (phi * (1 - alpha2) + (1 - phi) * (1 - beta2))
    k = np.clip(np.round(n * phipf), 0, n - 1).astype(int)
    # This is the expected Value of Option Two
    EV2 = (phi * alpha2 + (1 - phi) * beta2) * vnot[j] + \
        (phi * (1 - alpha2) + (1 - phi) * (1 - beta2)) * vnot[k]
    # This is the more dangerous boy
    V2 = (1 - delta) * (phi * (alpha2 * yh2 + (1 - alpha2) * yl2) +
                        (1 - phi) * (beta2 * yh2 + (1 - beta2) * yl2)) + delta * EV2
    # We always choose which we find to be better
    vone = np.maximum(V1, V2)
    # Figure out how close we are to having the function approximated
    # Since we are doing functional approximation, it seems the sup norm may
    # Be a better option
    dnorm = np.linalg.norm((vone - vnot))
    iter += 1
# This tells us if we're doing it in a reasonable amount of time,
# And doubles as fixing the indentation b/c python has no end
print(iter)

# Now that we have approximated the function vone well, we can find the paths
# From choosing either arm of the "bandit"
# V1 star is the valuation of the safe bet
v1star = (1 - delta) * (alpha1 + yh1 + (1 - alpha1) * yl1) + delta * vone

# Again we need the indices of successes and failures, and j and k are that.
phips = phi * alpha2 / (phi * alpha2 + (1 - phi) * beta2)
j = np.clip(np.round(n * phips), 0, n - 1).astype(int)
phipf = phi * (1 - alpha2) / (phi * (1 - alpha2) + (1 - phi) * (1 - beta2))
k = np.clip(np.round(n * phipf), 0, n - 1).astype(int)

# Using these values, calculate the expected value
EV2 = (phi * alpha2 + (1 - phi) * beta2) * \
    vone[j] + (phi * (1 - alpha2) + (1 - phi) * (1 - beta2)) * vnot[k]

# This is our valuation function for the risky boy
v2star = (1 - delta) * (phi * (alpha2 * yh2 + (1 - alpha2) * yl2) +
                        (1 - phi) * (beta2 * yh2 + (1 - beta2) * yl2)) + delta * EV2
# The reason I Don't do v2star < v1star is to make sure the type is not bool
policy = (1 - (v1star >= v2star))


# I found that the plot of vone on the same graph crowded the plot and didn't
# make anything actually better.
fig, ax = plt.subplots()
ax.plot(phi, 10 * policy)
#ax.plot(phi, vone)
ax.plot(phi, v1star)
ax.plot(phi, v2star)

ax.grid()

fig.savefig("test.png")
plt.show()
