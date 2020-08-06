Project home page: https://covid19-projections.com
About the model: https://covid19-projections.com/about
Daily projections: https://github.com/youyanggu/covid19_projections

Procedure to process YYG files:

1. Clone (If already done pull latest version with git pull) https://github.com/youyanggu/covid19_projections
2. Copy latest global forecast files ("_global" suffix) from covid19_projections/projections/combined to covid19-forecast-hub-da/data-raw/YYG
3. Execute YYG-processing-script.R in its source file location (In Rstudio click Session -> Set working directory -> To source file location)
4. Processed files appear in data-processed/YYG. Add, commit to your fork, create pull request.
