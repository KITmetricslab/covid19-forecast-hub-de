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
bundesländer = {1: "Schleswig-Holstein",
                2: "Freie und Hansestadt Hamburg",
                3: "Niedersachsen",
                4: "Freie Hansestadt Bremen",
                5: "Nordrhein-Westfalen",
                6: "Hessen",
                7: "Rheinland-Pfalz",
                8: "Baden-Wuerttemberg",
                9: "Freistaat Bayern",
                10: "Saarland",
                11: "Berlin",
                12: "Brandenburg",
                13: "Mecklenburg-Vorpommern",
                14: "Freistaat Sachsen",
                15: "Sachsen-Anhalt",
                16: "Freistaat Thueringen"}

outputs = ['anzahl_meldebereiche', 'faelle_covid_aktuell',
           'faelle_covid_aktuell_beatmet', 'anzahl_standorte',
           'betten_frei', 'betten_belegt']

# create a file for each output
for col in outputs:

    df_agg = pd.DataFrame()

    for idx, file in enumerate(files):

        df = pd.read_csv(file)
        correct_idx = all(elem in list(df) for elem in cols)

        # filter ou dfs with wrong format
        if correct_idx:

            # agg over bundesländer
            df_day = df[['bundesland', col]]\
                .groupby(by="bundesland").sum()
            df_day = df_day.rename(columns={col: str(file)[-20:-10]})
            df_day = df_day.T

            # append to df
            if df_agg.empty:
                df_agg = df_day
            else:
                df_agg = df_agg.append(df_day)

        else:
            continue

    df_agg = df_agg.sort_index()
    df_agg = df_agg.rename(columns=bundesländer, errors="raise")
    df_agg.to_csv("./bundeslaender/DIVI-" + col + ".csv")
