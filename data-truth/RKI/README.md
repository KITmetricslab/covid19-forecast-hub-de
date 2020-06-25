# Data Source
For historic data until 2020-06-24 we aggregated the data collected in https://github.com/ard-data/2020-rki-archive/tree/master/data/2_parsed.

From 2020-06-25 on, we download the data directly from https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0.

# Data Aggregation
For each date and German state we compute the number of cumulative deaths following the [recommendations by RKI](https://www.arcgis.com/home/item.html?id=dd4580c810204019a7b8eb3e0b329dd6) and the incident deaths by taking the difference to the previous day. For an in-depth explanation of how the data is processed, please have a look at [our Jupyter notebook](https://github.com/KITmetricslab/covid19-forecast-hub-de/blob/master/code/auto_download/ard_data.ipynb). 
