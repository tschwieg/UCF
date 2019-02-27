#!/usr/bin/python
# -*- coding: utf-8 -*-

import re
import os
import glob
import csv
import pandas as pd
import numpy as np
from datetime import datetime as dt


def ensure_dir(file_path):
    # directory = os.path.dirname(file_path)
    if not os.path.exists(file_path):
        os.makedirs(file_path)


gunNames = open("../gunNames.txt", "r")
gunNameReader = csv.reader(gunNames, delimiter=',')
gunNameRows = [r for r in gunNameReader]
numGuns = len(gunNameRows)


def GetGunID(gunName):
    for i in range(numGuns):
        if gunName == gunNameRows[i][0]:
            return i
    return -1


files = glob.glob("../ModifiedKnives/*.csv")
#files = ["../ModifiedKnives/Glove Case.csv"]


throwoutDate = dt.strptime("Jan 09 1995 01: +0", "%b %d %Y %H: +0")

for file in files:
    print("Investigating " + file)
    with open(file, "rb") as csvFile:
        simpleName = file.split("/")[-1]
        transactionData = open("../Valuations/" + simpleName, "rb")
        transactionReader = csv.reader(transactionData, delimiter=',')
        transRows = [r for r in transactionReader]
        reader = csv.reader(csvFile, delimiter=',')
        rows = [r for r in reader]

        #sum(1 for line in transactionReader)
        gunData = np.zeros(
            [(len(transRows)), 4 * len(rows) + 2])

        boxCounter = 0
        price = 0
        quantity = 0

        # Loop through every item contained in the loot box.
        for row in rows:
            #print( row )
            # Contents of the files here are
            # Gun,Skin,Wear,Prob,rarity
            gun = row[0]
            skin = row[1]
            wear = row[2]
            prob = row[3]
            rarity = row[4]
            # Now we open the file for the gun in question.
            gunFile = open("../CSV/" +
                           gun + "/" + skin + "/" + wear + ".csv", "rb")
            gunReader = csv.reader(gunFile, delimiter=',')
            gunRows = [r for r in gunReader]
            for gunRow in gunRows:
                gunRow[0] = dt.strptime(gunRow[0], "%b %d %Y %H: +0")

            transCounter = 0
            # For every sale of the loot box at any time, find the price of the
            # item at that time
            for transaction in transRows:
                #dt.strptime("10/12/13", "%m/%d/%y")
                date = dt.strptime(transaction[0], "%b %d %Y %H: +0")
                if(date < throwoutDate):
                    continue
                price = transaction[1]
                quantity = transaction[2]
                gunCounter = 0
                #print( "got gun rows")
                for gunRow in gunRows:
                    if(gunRow[0] > date):
                        break
                    gunCounter += 1
                #print( "survived teh break")
                if(gunCounter == len(gunRows)):
                    gunPrice = gunRows[-1][1]
                else:
                    gunPrice = gunRows[gunCounter][1]
                gunData[transCounter, 0 + 4 * boxCounter + 2] = gunPrice
                gunData[transCounter, 1 + 4 * boxCounter + 2] = prob
                gunData[transCounter, 2 + 4 * boxCounter + 2] = rarity
                gunData[transCounter, 3 + 4 * boxCounter + 2] = GetGunID(gun)
                gunData[transCounter, 0] = price
                gunData[transCounter, 1] = quantity
                transCounter += 1
            #print( "finished transactions")

            #print( price )
            #print( quantity )
            gunFile.close()
            #print( gunData[:,2*boxCounter+2])
            #print( gunData[:,2*boxCounter+3])
            boxCounter += 1
        #print( gunData)
    # Now we just export as a pandas csv
    np.savetxt("../Data/" + simpleName,
               gunData[0:transCounter, :], delimiter=",", fmt="%.8f")
