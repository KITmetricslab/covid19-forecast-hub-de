# -*- coding: utf-8 -*-
"""
Created on Wed Oct 14 10:31:53 2020

@author: Jannik
"""


import pygsheets
import pandas as pd
from unidecode import unidecode
import datetime
import numpy as np
import time

#gc = pygsheets.authorize(service_account_env_var ='SHEETS_CREDS')
gc = pygsheets.authorize(service_file='creds.json')
a = gc.open_by_key('1ierEhD6gcq51HAm433knjnVwey4ZE5DCnu1bW7PRG3E')

worksheet = a.worksheet('title','Wzrost w województwach')

abbr_vois = {"Śląskie": "PL83", "Mazowieckie": "PL78", "Małopolskie": "PL77", 
             "Wielkopolskie": "PL86", "Łódzkie": "PL74", "Dolnośląskie": "PL72", 
             "Pomorskie": "PL82", "Podkarpackie": "PL80",
             "Kujawsko-Pomorskie": "PL73", "Lubelskie": "PL75", 
             "Opolskie": "PL79", "Świętokrzyskie": "PL84", "Podlaskie": "PL81",
             "Zachodniopomorskie": "PL87", "Warmińsko-Mazurskie": "PL85", 
             "Lubuskie": "PL76", "Poland": "PL"}

inc_case_rows = range(8, 25)
cum_case_rows = range(31, 48)
inc_death_rows = range(51, 68)
cum_death_rows = range(71, 88)


result = []

for relevant_rows in [inc_case_rows, cum_case_rows, inc_death_rows, cum_death_rows]:
    
    
    rows = []
    
    for row in relevant_rows:
        rows.append(worksheet.get_row(row))
        time.sleep(1)
        print("hi")
        
    df = pd.DataFrame(rows[1:], columns=rows[0])
    
    # drop cols without values
    df = df.loc[:,~df.columns.duplicated()]
    df = df.drop(df.columns[-1],axis=1)
    
    # delete suma col if exists
    if "SUMA" in list(df):
        df = df.drop(columns=["SUMA"])
        
    if "Dane" in list(df)[-1]:
        df = df.drop(df.columns[-1],axis=1)
        
    df = df.rename(columns={"Województwo": "location_name"})
    df = df.set_index("location_name")
    df = df.replace(r'^\s*$', np.nan, regex=True)
    df = df.astype(float)
    df.loc['Poland']= df.sum(axis=0)
    
    #df["location"] = abbr_vois
    
    df = df.unstack().reset_index()
    
    df = df.rename(columns={"level_0": "date", 0: "value"})
    
    # handle date
    df["date"] = df['date'].apply(lambda x: (x + ".2020").replace(".", "/"))
    df["date"] = pd.to_datetime(df["date"], format="%d/%m/%Y")
    
    # add location names
    df["location"] = df["location_name"].apply(lambda x: abbr_vois[x])
    
    # handle polish characters
    df["location_name"] = df["location_name"].apply(lambda x: unidecode(x))
    
    #shift to ecdc
    df["date"] = df["date"]. apply(lambda x: x + datetime.timedelta(days=1))
    df = df.set_index("date")
    
    df = df[["location_name", "location", "value"]]
    
    result.append(df)
    
result[0].to_csv("../../data-truth/MZ/truth_MZ-Incident Cases_Poland.csv")
result[1].to_csv("../../data-truth/MZ/truth_MZ-Cumulative Cases_Poland.csv")
result[2].to_csv("../../data-truth/MZ/truth_MZ-Incident Deaths_Poland.csv")
result[3].to_csv("../../data-truth/MZ/truth_MZ-Cumulative Deaths_Poland.csv")