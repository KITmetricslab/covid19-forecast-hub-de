import pandas as pd

# Download data from https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0/data
df = pd.read_csv('https://opendata.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0.csv')

# Save as compressed csv-file
yesterdays_date = (pd.to_datetime('today') - pd.Timedelta('1 days')).date()
df.to_csv('../../data-truth/RKI/raw/' + str(yesterdays_date) + '_RKI_raw.csv.gz', index=False, compression='gzip')