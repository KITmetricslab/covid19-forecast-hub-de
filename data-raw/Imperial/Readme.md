## How to update Imperial data:
1) Check for new release on https://github.com/mrc-ide/covid19-forecasts-orderly
2) Download *ensemble_model_predictions.rds* from release
3) Rename from *ensemble_model_predictions.rds* to *ensemble_model_predictions_YYYY-MM-DD.rds*
4) Copy file to */data-raw/Imperial/*
5) Run *Imperial-processing-script.R* from source (i.e. from *data-raw/Imperial/*)

### Remarks:
By default, data is generated for Poland and Germany. If you do not want that, set pol=FALSE in *Imperial-processing-script.R* 

### Dependencies:
*Imperial-processing-script.R* has the following dependices:
- in *data-truth/ECDC/*: all cumulative and incident death files (i.e. for Poland and Germany)
- in */data-raw/Imperial/*: *.rds* files and *Imperial-processing_Germany.R*
- in */template/*: *state_codes_germany.csv* and *state_codes_poland.csv*
