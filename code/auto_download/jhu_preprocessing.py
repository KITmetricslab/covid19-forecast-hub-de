import os
import glob
import pandas as pd

# Get latest file
list_of_files = glob.glob('../../data-truth/JHU/raw/*')
latest_file = max(list_of_files, key=os.path.getctime)
df = pd.read_csv(latest_file)

# Transform to standard format
df = df[df['Country/Region'] == 'Germany']
df.drop(columns=['Province/State', 'Country/Region', 'Lat', 'Long'], inplace=True)
df = df.T.reset_index()
df.columns=['date', 'value']
df.date = pd.to_datetime(df.date)
df['location'] = 'GM'
df['location_name'] = 'Germany'
df = df[['date', 'location', 'location_name', 'value']].sort_values('date')

# Cumulative
df.to_csv('../../data-truth/JHU/truth_JHU-Cumulative Deaths_Germany.csv', index=False)

# Incident
df_inc = df.copy()
df_inc.value = df_inc.value.diff()
df_inc = df_inc.iloc[1:]
df_inc.to_csv('../../data-truth/JHU/truth_JHU-Incident Deaths_Germany.csv', index=False)
