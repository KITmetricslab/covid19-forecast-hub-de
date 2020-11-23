### Procedure to process UCLA files:

1. Execute '''python ./code/auto_download/auto-download-ucla.py''' in root directory
Alternatively: download latest files from https://github.com/uclaml/ucla-covid19-forecasts/tree/master/projection_result ("pred_world_<date>.csv")
2. Open UCLA-processing-script.R in R, set working direction to data_raw/UCLA-SuEIR (setwd()) and run script
3. Processed files appear in data-processed/UCLA-SuEIR. Add, commit to your fork, create pull request.
