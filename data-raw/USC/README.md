### Procedure to process USC files:

1. Execute '''python ./code/auto_download/auto-download-usc.py''' in root directory
Alternatively: Download latest files from https://github.com/scc-usc/ReCOVER-COVID-19/tree/master/results/historical_forecasts (entire subfolders)
2. Open USC-processing-script.R in R, set working direction to data_raw/USC (setwd()) and run script
3. Processed files appear in data-processed/USC. Add, commit to your fork, create pul request.

Sometimes the files `other_forecasts_deaths.csv` and `other_forecasts_cases.csv` are missing in the folders so that forecasts at the Bundesland level are not available. In this case delete the entire folder.