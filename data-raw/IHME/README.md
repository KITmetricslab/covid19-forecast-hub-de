## How to update IHME data:
1) Check for new release on http://www.healthdata.org/covid/data-downloads
2) Copy unzipped folder into */data-raw/IHME*
3) Run *IHME-germany-processing-script.R* from source (i.e. from *data-raw/IHME/*)

### Remarks:
By default, data is generated for Poland and Germany.

### Dependencies:
*IHME-germany-processing-script.R* has the following dependices:
- in */data-raw/IHME/*: *Reference_hospitalization_all_locs.csv* files and *process_IHME-germany_functions.R *
- in */template/*: *state_codes_germany.csv* and *state_codes_poland.csv*
