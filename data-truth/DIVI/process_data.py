# -*- coding: utf-8 -*-
"""
Created on Thu Jun 25 16:00:49 2020

@author: Jannik Deuschel
"""


from pathlib import Path
import pandas as pd

data_path = Path.cwd().parent.parent.joinpath("data-truth", "DIVI", "raw")\
    .rglob('*.csv')
files = [x for x in data_path if x.is_file()]

# necessary columns (should sort out the first two datasets (24.04/25.04) due
# to different format)
cols = ['bundesland', 'gemeindeschluessel', 'anzahl_meldebereiche',
        'faelle_covid_aktuell', 'faelle_covid_aktuell_beatmet',
        'anzahl_standorte', 'betten_frei', 'betten_belegt']

# see: https://www.divi.de/register/tagesreport
bundeslaender = {1: "Schleswig-Holstein State",
                2: "Free Hanseatic City of Hamburg",
                3: "Lower Saxony State",
                4: "Free Hanseatic City of Bremen",
                5: "North Rhine-Westphalia State",
                6: "Hesse State",
                7: "Rhineland-Palatinate State",
                8: "Baden-Wuerttemberg State",
                9: "Free State of Bavaria",
                10: "Saarland State",
                11: "Berlin State",
                12: "Brandenburg State",
                13: "Mecklenburg-Western Pomerania State",
                14: "Free State of Saxony",
                15: "Sachsen-Anhalt State",
                16: "Free State of Thueringia"}

state_to_code = {"Schleswig-Holstein State": "GM10",
                 "Free Hanseatic City of Hamburg": "GM04",
                 "Lower Saxony State": "GM06",
                 "Free Hanseatic City of Bremen": "GM03",
                 "North Rhine-Westphalia State": "GM07",
                 "Hesse State": "GM05",
                 "Rhineland-Palatinate State": "GM08",
                 "Baden-Wuerttemberg State": "GM01",
                 "Free State of Bavaria": "GM02",
                 "Saarland State": "GM09",
                 "Berlin State": "GM16",
                 "Brandenburg State": "GM11",
                 "Mecklenburg-Western Pomerania State": "GM12",
                 "Free State of Saxony": "GM13",
                 "Sachsen-Anhalt State": "GM14",
                 "Free State of Thueringia": "GM15"}


outputs = ['anzahl_meldebereiche', 'faelle_covid_aktuell',
           'faelle_covid_aktuell_beatmet', 'anzahl_standorte',
           'betten_frei', 'betten_belegt']

file_names = {"anzahl_meldebereiche": "reporting_areas_Germany",
              "faelle_covid_aktuell": "Current ICU_Germany",
              "faelle_covid_aktuell_beatmet": 
                  "Current Ventilated_Germany",
              "anzahl_standorte": "sites_Germany",
              "betten_frei": "beds_free_Germany",
              "betten_belegt": "beds_occupied_Germany"}

# create a file for each output
for col in outputs:

    df_agg = pd.DataFrame()

    for idx, file in enumerate(files):

        df = pd.read_csv(file)
        correct_idx = all(elem in list(df) for elem in cols)

        # filter out dfs with wrong format
        if correct_idx:

            # agg over bundesländer
            df_day = df[['bundesland', col]]\
                .groupby(by="bundesland").sum()
            df_day = df_day.rename(columns={col: str(file)[-14:-4]})
            df_day = df_day.T

            # append to df
            if df_agg.empty:
                df_agg = df_day
            else:
                df_agg = df_agg.append(df_day)

        else:
            continue

    df_agg = df_agg.sort_index()
    df_agg = df_agg.rename(columns=bundeslaender, errors="raise")
    df_agg = df_agg.unstack().reset_index()
    df_agg = df_agg.rename(columns={"level_1": "date", 0: "value", 
                                    "bundesland": "location_name"})
    df_agg["location"] = [state_to_code[x] for x in df_agg["location_name"].values.tolist()]
    
    df_sum = df_agg.groupby(df_agg['date']).aggregate("sum")
    df_sum = df_sum.reset_index()
    df_sum["location_name"] = "Germany"
    df_sum["location"] = "GM"
    
    df_agg = pd.concat([df_agg, df_sum], ignore_index=True)
    
    df_agg = df_agg[["date","location", "location_name", "value"]]
    df_agg = df_agg.sort_values(by=['date', 'location'])
    df_agg = df_agg.reset_index(drop=True)
    df_agg = df_agg.set_index("date")
    
    df_filename = file_names[col]
    
    if col == "faelle_covid_aktuell" or col == "faelle_covid_aktuell_beatmet":
        df_agg.to_csv("./truth_DIVI-" + df_filename + ".csv")
    
    else:
        df_agg.to_csv("./others/truth_DIVI-" + df_filename + ".csv")
