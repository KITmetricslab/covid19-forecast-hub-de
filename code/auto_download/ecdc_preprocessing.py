import os
import glob
import pandas as pd

# Get latest file
list_of_files = glob.glob('../../data-truth/ECDC/raw/*')
latest_file = max(list_of_files, key=os.path.getctime)
df = pd.read_csv(latest_file)

# Transform to standard format
df['date'] = pd.to_datetime(df.dateRep, dayfirst=True)
df = df[df.countriesAndTerritories == 'Germany']
df.rename(columns={'countriesAndTerritories' : 'location_name', 'deaths' : 'value', }, inplace=True)
df['location'] = 'GM'
df = df[['date', 'location', 'location_name', 'value']].sort_values('date').reset_index(drop=True)

# Incident
df.to_csv('../../data-truth/ECDC/truth_ECDC-Incident Deaths_Germany.csv', index=False)

# Cumulative
df.value = df.value.cumsum()
df.to_csv('../../data-truth/ECDC/truth_ECDC-Cumulative Deaths_Germany.csv', index=False)