# Contents

The file `truth_cum_deaths.csv` contains daily time series of cumulative COVID19 death counts at the Bundesland and national level (by reporting date). The file `truth_inc_deaths.csv` contains the correponding time series of incident deaths.

# Data Source

The presented counts are updated each day based on [data made available by RKI](https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0) (taking the difference between values from the previous day and the new values). For historic data until 2020-06-24 we aggregated the data collected in https://github.com/ard-data/2020-rki-archive/tree/master/data/2_parsed (see license file). From 2020-06-25 onwards we download the data directly from the RKI/arcgis platform.

# Data Aggregation

For an in-depth explanation of how the data is processed, please have a look at [our Jupyter notebook](https://github.com/KITmetricslab/covid19-forecast-hub-de/blob/master/code/auto_download/ard_data.ipynb). 
