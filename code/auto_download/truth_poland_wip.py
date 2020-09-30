# -*- coding: utf-8 -*-
"""
Created on Tue Sep  8 08:56:11 2020

@author: Jannik
"""


import pandas as pd
import json
import csv
from google.oauth2 import service_account
import pygsheets

with open('creds.json') as source:
    info = json.load(source)
credentials = service_account.Credentials.from_service_account_info(info)

client = pygsheets.authorize(service_account_file='creds.json')

sheet_data = client.sheet.get('1EUo9_NvzEPY7BXWgENihiLEEZR5rhwmPIs4I8-r5E10')

#sheet = client.open('Tabellenblatt1')
sheet = client.open_by_url('https://docs.google.com/spreadsheets/d/1EUo9_NvzEPY7BXWgENihiLEEZR5rhwmPIs4I8-r5E10/edit#gid=1309014089')

print(sheet)
wks = sheet.worksheet_by_title('Tabellenblatt1')

wks.get_all_values()[0:2]
