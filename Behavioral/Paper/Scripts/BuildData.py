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


files = glob.glob("../ModifiedKnives/*.csv")
#files = ["../ModifiedKnives/Glove Case.csv"]


throwoutDate = dt.strptime("Feb 28 2018 01: +0", "%b %d %Y %H: +0")

for file in files:
    print("Investigating " + file)
    with open(file, "rb") as csvFile:
        simpleName = file.split("/")[-1]
        transactionData = open("../Valuations/" + simpleName, "rb")
        valuationData = open("../Valuations/" +
                             simpleName[0:-4] + "_Demand.csv", "rb")

        transactionReader = csv.reader(transactionData, delimiter=',')
        transRows = [r for r in transactionReader]
        valuationReader = csv.reader(valuationData, delimiter=',')
        valRows = [r for r in valuationReader]
        reader = csv.reader(csvFile, delimiter=',')
        rows = [r for r in reader]

        #sum(1 for line in transactionReader)
        gunData = np.zeros(
            [(len(transRows) + len(valRows)), 2 * len(rows) + 3])

        boxCounter = 0
        price = 0
        quantity = 0

        # Loop through every item contained in the loot box.
        for row in rows:
            #print( row )
            # Contents of the files here are
            # Gun,Skin,Wear,Prob
            gun = row[0]
            skin = row[1]
            wear = row[2]
            prob = row[3]
            # Now we open the file for the gun in question.
            gunFile = open("/root/Classes/Behavioral/Paper/CSV/" +
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
                if( date < throwoutDate):
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
                gunData[transCounter, 2 * boxCounter + 3] = gunPrice
                gunData[transCounter, 1 + 2 * boxCounter + 3] = prob
                gunData[transCounter, 0] = price
                gunData[transCounter, 1] = quantity
                gunData[transCounter, 2] = 1
                transCounter += 1
            #print( "finished transactions")

            gunPrice = gunRows[-1][1]
            gunData[transCounter:(transCounter + len(valRows)),
                    2 * boxCounter + 3] = gunPrice
            gunData[transCounter:(transCounter + len(valRows)),
                    1 + 2 * boxCounter + 3] = prob

            if(len(valRows) > 0 and gunData[transCounter, 0] == 0):
                for transaction in valRows:
                    # Now we don't have a date, just a price and a quantity.
                    # The date is the latest posted by the market
                    price = transaction[0]
                    quantity = transaction[1]
                    gunData[transCounter, 0] = price
                    gunData[transCounter, 1] = quantity
                    gunData[transCounter, 2] = 0
                    transCounter += 1

            #print( price )
            #print( quantity )
            gunFile.close()
            #print( gunData[:,2*boxCounter+2])
            #print( gunData[:,2*boxCounter+3])
            boxCounter += 1
        #print( gunData)
    # Now we just export as a pandas csv
    np.savetxt("../Data/" + simpleName, gunData[0:transCounter,:], delimiter=",")
