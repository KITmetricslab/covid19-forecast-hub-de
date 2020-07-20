from pathlib import Path
import pandas as pd
import numpy as np

def next_monday(date):
    return pd.date_range(start=date, end=date + pd.offsets.Day(6), freq='W-MON')[0]

def get_relevant_dates(dates):
    wds = pd.Series(d.day_name() for d in dates)
    next_mondays = pd.Series(next_monday(d) for d in dates)
    relevant_dates = []
    
    for day in ['Monday', 'Sunday', 'Saturday', 'Friday']:
        relevant_dates.extend(dates[(wds == day) &
                                   ~pd.Series(n in relevant_dates for n in next_mondays) &
                                   ~pd.Series(n in relevant_dates for n in (next_mondays - pd.offsets.Day(1))) &
                                   ~pd.Series(n in relevant_dates for n in (next_mondays - pd.offsets.Day(2)))
                                   ])
    return [str(r.date()) for r in relevant_dates] # return as strings

path = Path('../../data-processed')

models = [f.name for f in path.iterdir() if f.name !='ABC-exampleModel1']

VALID_TARGETS = [f"{_} wk ahead inc death" for _ in range(-1, 5)] + \
                [f"{_} wk ahead cum death" for _ in range(-1, 5)] + \
                [f"{_} wk ahead curr ICU" for _ in range(-1, 5)]+ \
                [f"{_} wk ahead curr ventilated" for _ in range(-1, 5)]

VALID_QUANTILES = [0.025, 0.975]

dfs = []
for m in models:
    p = path/m
    forecasts = [f.name for f in p.iterdir() if '.csv' in f.name]
    available_dates = pd.Series(pd.to_datetime(filename[:10]) for filename in forecasts)
    relevant_dates = get_relevant_dates(available_dates)
    relevant_forecasts = [f for f in forecasts if f[:10] in relevant_dates]
    for f in relevant_forecasts:
        df_temp = pd.read_csv(path/m/f)
        df_temp['model'] = m
        dfs.append(df_temp)

df = pd.concat(dfs)
df.forecast_date = pd.to_datetime(df.forecast_date)
df.target_end_date = pd.to_datetime(df.target_end_date)

df = df[df.target.isin(VALID_TARGETS) & 
        (df['quantile'].isin(VALID_QUANTILES) | (df.type=='point') | (df.type=='observed'))].reset_index(drop=True)

df['timezero'] = df.forecast_date.apply(next_monday)

df = df[['forecast_date', 'target', 'target_end_date', 'location', 'type', 'quantile', 'value', 'timezero', 'model']]

df.to_csv('../data/forecasts_to_plot.csv', index=False)
