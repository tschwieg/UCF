#!/usr/bin/python
# -*- coding: utf-8 -*-

import re
import os
import glob


def ensure_dir(file_path):
    # directory = os.path.dirname(file_path)
    if not os.path.exists(file_path):
        os.makedirs(file_path)


files = glob.glob("*.csv")

for csvFile in files:
    print(csvFile)
    basePath = "../CSV/"
    # continue
    NewcsvFile = csvFile
    dragonKing = False
    if("(Dragon King)" in csvFile):
        NewcsvFile = csvFile.replace("(Dragon King)", "Dragon King")
        dragonKing = True
        # continue
    if("★ " in csvFile):
        NewcsvFile = csvFile.replace("★ ", "")
    if("Music Kit" in csvFile):
        ensure_dir(basePath + "MusicKits/")
        os.rename(csvFile, basePath + "MusicKits/" + csvFile)
        continue
    if("Sticker" in csvFile):
        ensure_dir(basePath + "Stickers/")
        os.rename(csvFile, basePath + "Stickers/" + csvFile)
        continue
    if("Graffiti" in csvFile):
        ensure_dir(basePath + "Graffiti/")
        os.rename(csvFile, basePath + "Graffiti/" + csvFile)
        continue
    if("Capsule" in csvFile):
        ensure_dir(basePath + "Capsule/")
        os.rename(csvFile, basePath + "Capsule/" + csvFile)
        continue
    statTrak = False
    if("StatTrak" in csvFile):
        NewcsvFile = NewcsvFile.replace("StatTrak™ ", "")
        statTrak = True

    print(NewcsvFile)

    vanKnife = False
    # We need special treatment of vanilla knives

    regX = re.compile(
        r'(?P<gun>[a-zA-Z0-9 \-]+)\|(?P<skin>[a-zA-Z0-9 \-\'\!弐]+)(?P<quality>\([a-zA-Z0-9 \-]+\)).csv', re.UNICODE)
    # regX = re.compile("*.csv")
    skinInfo = regX.match(NewcsvFile)

    if(skinInfo is None and not dragonKing):
        if("Knife" in NewcsvFile or "Shadow Daggers" in NewcsvFile or "Karambit" in NewcsvFile or "Bayonet" in NewcsvFile):
            # Vanilla knife
            vanKnife = True
        else:
            continue

    #print(skinInfo.group('gun').replace(" ", ""))

    if(statTrak):
        basePath += "StatTrak/"

    if(dragonKing):
        print(NewcsvFile)
        gun = "M4A4"
        skin = "龍王(DragonKing)"
        condition = NewcsvFile[NewcsvFile.find("(") + 1:NewcsvFile.find(")")]
    elif(vanKnife):
        gun = NewcsvFile.replace(".csv", "").replace(" ", "")
        skin = "vanilla"
        condition = "vanilla"
    else:
        gun = skinInfo.group(1).replace(" ", "")
        skin = skinInfo.group(2).replace(" ", "")

        condition = skinInfo.group(3).replace(
            " ", "").replace("(", "").replace(")", "")

    ensure_dir(basePath + gun)
    ensure_dir(basePath + gun + "/" + skin)

    os.rename(csvFile, basePath + gun + "/" +
              skin + "/" + condition + ".csv")
