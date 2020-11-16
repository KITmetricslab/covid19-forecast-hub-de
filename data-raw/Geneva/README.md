### Procedure to process Geneva files:

1. Execute '''python ./code/auto_download/auto-download-geneva.py''' in root directory
Alternatively: download latest files from https://renkulab.io/gitlab/covid-19/covid-19-forecast/-/tree/master/data%2FECDC%2Fraw_prediction  ("ECDC_deaths_predictions_<date>.csv") and ("ECDC_cases_predictions_<date>.csv")
2. Open Geneva-processing-script.R in R, set working direction to data_raw/Geneva (setwd()) and run script
3. Processed files appear in data-processed/Geneva. Add, commit to your fork, create pull request.
