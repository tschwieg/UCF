import requests
import json
import re
from bs4 import BeautifulSoup
import time
import os


def ensure_dir(file_path):
    # directory = os.path.dirname(file_path)
    if not os.path.exists(file_path):
        os.makedirs(file_path)

# params = {'country': 'US', 'currency': 1, 'appid': 730,
#           'market_hash_name': 'AK-47%20%7C%20Redline%20%28Field-Tested%29'}


# Note this is going to not be valid if you attempt to pull data again.
# To get a valid cookie you need to log in via a webbrowser to steam online,
# View cookies, and copy and paste the value for the steamLogin.
cookie = {
    'steamLogin': '76561198004383713%7C%7C0F3B5EB2F8A2701C074947965BA5D4FC990876F2'}

# data = requests.get(
#     'http://steamcommunity.com/market/pricehistory/?country=US&currency=1&appid=730&market_hash_name=AK-47%20%7C%20Redline%20%28Field-Tested%29', cookies=cookie)


def GetSupplyandDemand(things, dTime):
    try:
        reg = re.compile(r"Market_LoadOrderSpread\( [0-9]+ \)")
        for item in things:
            # if(("Case" not in item['href'][46:] and "Capsule" not in item['href'][46:]) or "Hardened" in item['href'][46:]):
            #     continue
            data = requests.get(
                'http://steamcommunity.com/market/listings/730/' + item['href'][46:], cookies=cookie)
            numBer = reg.search(data.text).group(0).split(" ")[1]
            buySellOrders = requests.get(
                'http://steamcommunity.com/market/itemordershistogram?country=EN&language=english&currency=1&two_factor=0&item_nameid=' + numBer, cookies=cookie)
            parsed_json = json.loads(buySellOrders.text)
            demandcsvfile = ""
            for demandData in parsed_json['buy_order_graph']:
                demandcsvfile += str(demandData[0]) + \
                    ',' + str(demandData[1]) + '\n'

            supplycsvfile = ""
            for supplyData in parsed_json['sell_order_graph']:
                supplycsvfile += str(supplyData[0]) + \
                    ',' + str(supplyData[1]) + '\n'

            filename = "../CSV/" + dTime + '/' + \
                item.find("span", class_="market_listing_item_name").get_text(
                ).replace("/", "")

            print(filename)

            fileOpen = open(filename + "_Demand.csv", "w")
            fileOpen.write(demandcsvfile)
            fileOpen.close()
            fileOpen = open(filename + "_Supply.csv", "w")
            fileOpen.write(supplycsvfile)
            fileOpen.close()
            time.sleep(1)

    except:
        print("Sleeping for 60 seconds and trying again")
        time.sleep(60)
        GetSupplyandDemand(things, dTime)
        pass
    # else:
    #     print("No exceptions")


def GetPriceHistory(things, dTime):
    try:
        for item in things:
            # [m.start() for m in re.finditer('/', item['href'] )]
            data = requests.get(
                'http://steamcommunity.com/market/pricehistory/?country=US&currency=1&appid=730&market_hash_name=' + item['href'][46:], cookies=cookie)
            parsed_json = json.loads(data.text)

            csvfile = ""
            for pricePoint in parsed_json['prices']:
                csvfile += str(pricePoint[0]) + ',' + \
                    str(pricePoint[1]) + ',' + str(pricePoint[2]) + '\n'

            filename = "../CSV/" + dTime + '/' + \
                       item.find(
                           "span", class_="market_listing_item_name").get_text().replace("/", "") + ".csv"

            fileOpen = open(filename, "w")
            print(filename)
            fileOpen.write(csvfile)
            fileOpen.close()
        time.sleep(5)
    except:
        time.sleep(60)
        GetPriceHistory(things, dTime)
        pass


allstuff = requests.get(
    'http://steamcommunity.com/market/search/render/?query=appid:730&start=0&count=10250&currency=1&l=english&cc=pt', cookies=cookie)

parsedStuff = json.loads(allstuff.text)
totalCount = parsedStuff['total_count']
pageSize = parsedStuff['pagesize']
numLoops = (totalCount / pageSize) + 1

dTime = time.strftime("%Y-%m-%d_%H", time.gmtime())
ensure_dir("../CSV/" + dTime + '/')

for i in range(numLoops):

    url = 'http://steamcommunity.com/market/search/render/?query=appid:730&start=' + \
        str(i * pageSize) + '&count=10250&currency=1&l=english&cc=pt'

    print(url)

    page = requests.get(
        url, cookies=cookie)
    parsedStuff = json.loads(page.text)

    soup = BeautifulSoup(parsedStuff["results_html"], 'html.parser')
    things = soup.find_all(
        "a", class_="market_listing_row_link", recursive=False)

    t = re.compile("[a-zA-Z0-9.,_-]")

    GetSupplyandDemand(things, dTime)

    #GetPriceHistory(things, dTime)
