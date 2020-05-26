import pandas as pd

df = pd.read_csv('https://opendata.ecdc.europa.eu/covid19/casedistribution/csv')
current_date = pd.to_datetime('today').date()
df.to_csv('../../data-truth/ECDC/raw/' + str(current_date) + '-Deaths-ECDC.csv', index=False)