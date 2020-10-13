# Contents

The file `truth_RKI-Cumulative Deaths_Germany.csv` contains daily time series of cumulative COVID19 death counts at the Bundesland and national level (by reporting date). The file `truth_RKI-Incidence Deaths_Germany.csv` contains the correponding time series of incident deaths. In both, the `date`variable corresponds to the date of reporting, as is the case for the ECDC data provided in `data-truth/ECDC` (indeed, when summed over all Bundesländer, the data provided here agree almost perfectly with the ECDC data).

# Data Source

The presented counts are updated each day based on [data made available by RKI](https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0) (taking the difference between values from the previous day and the new values). The `date` variable consequently refers to the reporting date. For historic data from 2020-04-01 until 2020-06-24 we aggregated the data collected in https://github.com/ard-data/2020-rki-archive/tree/master/data/2_parsed (see license file). From 2020-06-25 onwards we download the data directly from the RKI/arcgis platform. For the time before 2020-04-01 we additionally extracted the data provided on http://www.healthdata.org/covid/data-downloads by IHME. These have been manually extracted from the *Lageberichte* issued by RKI on a daily basis. Re-use of these data is covered by the [Creative Commons Attribution-NonCommercial 4.0 International License specified by IHME](http://www.healthdata.org/about/terms-and-conditions).

# Data Aggregation

For an in-depth explanation of how the data is processed, please consider [our Jupyter notebook](https://github.com/KITmetricslab/covid19-forecast-hub-de/blob/master/code/auto_download/ard_data.ipynb). 
For details on how the data by IHME is processed, refer to [this Jupyter notebook](https://github.com/KITmetricslab/covid19-forecast-hub-de/blob/master/code/auto_download/add_IHME_truth.ipynb).
