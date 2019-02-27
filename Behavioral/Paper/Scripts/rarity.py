import glob
import csv


def PrintGunToFile(line, newfile, prob):
    splitter = line.split("|")
    gun = splitter[0].replace(" ", "")
    skin = splitter[1].replace(" ", "")
    facNew = False
    minWear = False
    fieldTest = False
    wellWorn = False
    batScar = False
    # conditions = glob.glob(
    #     "/root/Classes/Behavioral/Paper/CSV/" + gun + "/" + skin + "/*")
    # stConditions = glob.glob(
    #     "/root/Classes/Behavioral/Paper/CSV/StatTrak" + gun + "/" + skin + "/*")
    conditions = glob.glob(
        "../CSV/" + gun + "/" + skin + "/*")
    stConditions = glob.glob(
        "../CSV/StatTrak/" + gun + "/" + skin + "/*")
    for condition in conditions:
        #        print(condition)
        if("FactoryNew" in condition):
            facNew = True
        if("MinimalWear" in condition):
            minWear = True
        if("Field-Tested" in condition):
            fieldTest = True
        if("Well-Worn" in condition):
            wellWorn = True
        if("Battle-Scarred" in condition):
            batScar = True
#    for condition in stConditions:
#        print(condition)
        # 0    - 0.07       Factory New
        # 0.07 - 0.15    Minimal Wear
        # 0.15 - 0.38    Field-Tested
        # 0.38 - 0.45    Well-Worn
        # 0.45 - 1       Battle-Scarred
    totalFloat = float(facNew) * .07 + float(minWear) * .08 + \
        float(fieldTest) * .23 + float(wellWorn) * .07 + float(batScar) * .55

 #   print(prob)
 #   print(totalFloat)

    if(facNew):
        if("FactoryNew" in stConditions):
            newfile.write(gun + "," + skin + "," + "FactoryNew," +
                          str(.07 * prob * .9 / totalFloat))
            newfile.write("StatTrak/" + gun + "," + skin + "," +
                          "FactoryNew," + str(.07 * prob * .1 / totalFloat))
        else:
            newfile.write(gun + "," + skin + "," + "FactoryNew," +
                          str(.07 * prob / totalFloat))

    if(minWear):
        if("MinimalWear" in stConditions):
            newfile.write(gun + "," + skin + "," + "MinimalWear," +
                          str(.08 * prob * .9 / totalFloat))
            newfile.write("StatTrak/" + gun + "," + skin + "," +
                          "MinimalWear," + str(.08 * prob * .1 / totalFloat))
        else:
            newfile.write(gun + "," + skin + "," + "MinimalWear," +
                          str(.08 * prob / totalFloat))
    if(fieldTest):
        if("Field-Tested" in stConditions):
            newfile.write(gun + "," + skin + "," + "Field-Tested," +
                          str(.23 * prob * .9 / totalFloat))
            newfile.write("StatTrak/" + gun + "," + skin + "," +
                          "Field-Tested," + str(.23 * prob * .1 / totalFloat))
        else:
            newfile.write(gun + "," + skin + "," + "Field-Tested," +
                          str(.23 * prob / totalFloat))
    if(wellWorn):
        if("Well-Worn" in stConditions):
            newfile.write(gun + "," + skin + "," + "Well-Worn," +
                          str(.07 * prob * .9 / totalFloat))
            newfile.write("StatTrak/" + gun + "," + skin + "," +
                          "Well-Worn," + str(.07 * prob * .1 / totalFloat))
        else:
            newfile.write(gun + "," + skin + "," + "Well-Worn," +
                          str(.07 * prob / totalFloat))
    if(batScar):
        if("Battle-Scarred" in stConditions):
            newfile.write(gun + "," + skin + "," + "Battle-Scarred," +
                          str(.55 * prob * .9 / totalFloat))
            newfile.write("StatTrak/" + gun + "," + skin + "," +
                          "Battle-Scarred," + str(.55 * prob * .1 / totalFloat))
        else:
            newfile.write(gun + "," + skin + "," + "Battle-Scarred," +
                          str(.55 * prob / totalFloat))


#files = glob.glob("/root/Classes/Behavioral/Paper/knives/*.txt")
files = glob.glob("*.txt")

#csvfile = open("/root/Classes/Behavioral/Paper/knives/knives.csv")
csvfile = open("knives.csv")
knifeInfo = csv.reader(csvfile, delimiter=',')

knifeSkins = {}
# knifeSkinFileNames = glob.glob(
#     "/root/Classes/Behavioral/Paper/knives/knifetypes/*.txt")
knifeSkinFileNames = glob.glob(
    "knifetypes/*.txt")
for filename in knifeSkinFileNames:
    with open(filename) as f:
        words = f.read().replace("\r", "").replace("\t", "")
        lines = words.split("\n")
        knifeSkins[lines[0]] = lines[1:-1]
        print(lines[1:-1])

print("\n\n")

files = ["glovecase.txt"]

for filename in files:
    with open(filename) as f:
        lines = f.readlines()
        print(lines[0])

        numItems = len(lines)

        # Prob of things occurring
        red = int(input("How many red?"))
        pink = int(input("How many pink?"))
        purple = int(input("How many purple?"))
        blue = numItems - red - pink - purple - 1
        #Blue - .7992
        #Purple - .1598
        #Pink - .032
        # Red .0064
        # Yellow .0026
        itemName = lines[0].replace("\n", "").replace(
            "\t", "").replace("\r", "")

        # newfile = open(
        #     "/root/Classes/Behavioral/Paper/ModifiedKnives/" + itemName + ".csv", "w")
        newfile = open(
            "../ModifiedKnives/" + itemName + ".csv", "w")

        # Now we need to find the knives this case drop All Cases
        # can recieve vanilla: Bayonet, Gut, Flip, m9, karambit,
        # bowie knife
        knives = []
        #csvfile = open("/root/Classes/Behavioral/Paper/knives/knives.csv")
        csvfile = open("knives.csv")
        knifeInfo = csv.reader(csvfile, delimiter=',')
        for row in knifeInfo:
            # print( row[1] )
            if(row[1] == itemName or row[1] == "All"):
                knives.append(row[0] + "|vanilla")
            drops = row[2].split(";")
            for drop in drops:
                #print( drop )
                if(drop == itemName):
                    for skin in knifeSkins[row[0]]:
                        knives.append(row[0] + "|" + skin)

        # Floats are uniform - here are the cutoffs
        # 0 - 0.07       Factory New
        # 0.07 - 0.15    Minimal Wear
        # 0.15 - 0.38    Field-Tested
        # 0.38 - 0.45    Well-Worn
        # 0.45 - 1       Battle-Scarred
        # Every item has a 10% chance of being StatTrak

        # Certain items have limited float values:

        gold = len(knives)
        for knive in knives:
            #print( knive )
            prob = .0026 / float(gold)
            PrintGunToFile(knive, newfile, prob)
            newfile.write(",1\n")

        for i in range(1, numItems):
            lines[-i] = lines[-i].replace("\n",
                                          "").replace("\r", "").replace("\t", "")
            if(i <= red):
                prob = .0064 / float(red)
                PrintGunToFile(lines[-i], newfile, prob)
                newfile.write(",2\n")
            elif(i <= red + pink):
                prob = .032 / float(pink)
                PrintGunToFile(lines[-i], newfile, prob)
                newfile.write(",3\n")
            elif(i <= red + pink + purple):
                prob = .1598 / float(purple)
                PrintGunToFile(lines[-i], newfile, prob)
                newfile.write(",4\n")
            else:
                prob = .7992 / float(blue)
                PrintGunToFile(lines[-i], newfile, prob)
                newfile.write(",5\n")

            print("sending " + lines[-i] + " to the printer")
            # newfile.close()

    print("\n\n")
