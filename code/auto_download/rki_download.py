import pandas as pd

# Download data from https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0/data
df = pd.read_csv('https://opendata.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0.csv')

# Save as rki_raw.csv
current_date = pd.to_datetime('today').date()
df.to_csv('../../data-truth/RKI/raw/' + str(current_date) + '-rki_raw.csv', index=False)