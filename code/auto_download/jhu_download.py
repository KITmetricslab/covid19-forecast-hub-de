import pandas as pd

df = pd.read_csv('https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/' \
                 'csse_covid_19_time_series/time_series_covid19_deaths_global.csv')

current_date = pd.to_datetime('today').date()

df.to_csv('../../data-truth/JHU/raw/' + str(current_date) + '-Deaths-JHU.csv', index=False)
