# A German COVID-19 Forecast Hub

### This project is in a development stage and not operational yet. The platform is not officially endorsed by KIT or HITS.

*Beschreibung in deutscher Sprache siehe [hier](https://github.com/KITmetricslab/covid19-forecast-hub-de/blob/master/README_DE.md).*

## Purpose

This repository assembles forecasts of cumulative and incident COVID19 deaths in Germany in a standardized format. It is run by members of the [Chair of Econometrics and Statistics at Karlsruhe Institute of Technology](https://statistik.econ.kit.edu/index.php) and the [Computational Statistics Group at Heidelberg Institute for Theoretical Studies](https://www.h-its.org/research/cst/), see below.

An interactive visualization of the different forecasts can be found [here](https://jobrac.shinyapps.io/app_forecasts_de/).

The effort parallels the [US COVID-19 forecast hub](https://github.com/reichlab/covid19-forecast-hub) run by the UMass-Amherst Influenza Forecasting Center of Excellence based at the [Reich Lab](https://reichlab.io/). We are in close exchange with the Reich Lab team and follow the general structure and [data format](https://github.com/reichlab/covid19-forecast-hub#data-model) defined there, see also this [Wiki entry](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Data-Format) for more details.

Unlike in the more advanced US COVID19 forecast hub, forecasts are currently not submitted to us by pull request. Instead, we actively collect available forecasts from various teams and re-format them in a standardized way. We are, however trying to move to a submission system based on pull requests, see this [wiki entry](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Preparing-your-submission).

If you are generating forecasts for COVID19 deaths in Germany and would like to contribute to this repository do not hesitate to [get in touch](https://statistik.econ.kit.edu/mitarbeiter_2902.php).

## Forecast targets

Currently we are focussing on forecasts of 1 through 130 day-ahead incident and cumulative deaths, 1 through 20 week-ahead incident and cumulative deaths in Germany (national level). This [wiki entry](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Data-Format) contains details on the definition of the targets. Further targets, including targets stratified by Bundesland will be added after consultation with interested teams of forecasters.

Note that our definition of targets parallels the principles outlined [here](https://github.com/reichlab/covid19-forecast-hub#what-forecasts-we-are-tracking-and-for-which-locations) for the US COVID19 forecast hub.

<!---
Note that unlike the US hub we also allow for `-1 wk ahead <target>`, `0 wk ahead <target>`, `-1 day ahead <target>` and `0 day ahead <target>` which, if they have already been observed (this may or may not be the case for 0 wk ahead) are assigned `type = "observed"`. We decided to include this as there is more heterogeneity concerning the ground truths used by different teams. By also storing the last observed values as provided by teams it becomes easier to spot such differences.
-->

## Contents of the repository

The main contents of the repository are currently the following:

- `data-raw`: the forecast files as provided by the various teams on their respective websites
- `data-processed`: forecasts in a standardized format
- `data-truth`: truth data from JHU and ECDC in a standardized format
- `app_forecasts_de`: a simple R shiny app to visualize forecasts (also available online [here](https://jobrac.shinyapps.io/app_forecasts_de/))

## Guide to submission

Our Wiki contains a detailed [guide to submission](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Preparing-your-submission). Especially in the starting phase we will also try to provide direct support to teams to help overcome technical difficulties, do not hesitate to [get in touch](https://statistik.econ.kit.edu/mitarbeiter_2902.php).

## Data format

We store point and quantile forecasts in a long format, including information on forecast dates and location, see [this Wiki entry](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Data-Format) for details. This format is largely identical to the one outlined for the US Hub [here](https://github.com/reichlab/covid19-forecast-hub#data-model) and [here](https://github.com/reichlab/covid19-forecast-hub/tree/master/data-processed#data-submission-instructions).

## Data license and reuse

The forecasts assembled in this repository have been created by various independent teams, most of which provided a license with their forecasts. These licenses can be found in the respective subfolders of `data-processed`. Parts of the processing and analysis codes have been adapted from the [US COVID-19 forecast hub](COVID-19 Forecast Hub) where they were provided under an [MIT license](https://github.com/reichlab/covid19-forecast-hub/blob/master/LICENSE). All codes contained in this repository are equally under the [MIT license](LICENSE).

## Truth data

Data on observed numbers of deaths come from the following surces:

- [European Centre for Disease Prevention and Control](https://www.ecdc.europa.eu/en/geographical-distribution-2019-ncov-cases)
- [Johns Hopkins University](https://coronavirus.jhu.edu/)

## Teams generating forecasts

Currently we assemble forecasts from the following teams. *Note that not all teams are using the same ground truth data.* (used truth data source and forecast reuse license in brackets):

- [IHME](https://covid19.healthdata.org/united-states-of-america) (unclear; CC-AT-NC4.0) *Note that we are currently still facing some difficulties in the processing of the IHME files.*
- [LANL](https://covid-19.bsvgateway.org/) (JHU; custom)
- [Imperial](https://github.com/sangeetabhatia03/covid19-short-term-forecasts) (ECDC; Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License)
- [MIT](https://www.covidanalytics.io/) (JHU; Apache 2.0)
- [University of Geneva / Swiss Data Science Center](https://renkulab.shinyapps.io/COVID-19-Epidemic-Forecasting/) (ECDC; none given)
- [YYG](http://covid19-projections.com/) (JHU; MIT)


## Submission system via pull requests

We use a submission system based on pull requests as in the US version of the hub. The system closely resembles the one outlined [here](https://github.com/reichlab/covid19-forecast-hub/tree/master/data-processed#data-submission-instructions), with automated formatting checks as described [here](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Validation-Checks). *Note that we add the word `-Germany-` in all forecast file names after the date (see existing examples).* Do not hesitate to get in touch with us (via [email](https://statistik.econ.kit.edu/mitarbeiter_2902.php) or github issue) to get some assistance in getting started. 
Additional information about the [submission format](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Submission-Format) or the [submission via pull requests](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Upload-Submission) can be found in our [Wiki](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Upload-Submission).

## Forecast hub team

The following persons have contributed to this repository, either by assembling forecasts or by conceptual work in the background (in alphabetical order):

- [Johannes Bracher](https://statistik.econ.kit.edu/mitarbeiter_2902.php)
- Jannik Deuschel
- [Tilmann Gneiting](https://www.h-its.org/2018/01/08/tilmann-gneiting/)
- [Konstantin Görgen](https://statistik.econ.kit.edu/mitarbeiter_2716.php)
- [Melanie Schienle](https://statistik.econ.kit.edu/mitarbeiter_2068.php)
- Daniel Wolffram

## Related efforts

- [US COVID-19 Forecast Hub](https://github.com/reichlab/covid19-forecast-hub) run by the [Reich Lab](https://reichlab.io/).
- [Code repository for the SARS-CoV2 modelling initiative](https://github.com/timueh/sars-cov2-modelling-initiative)
