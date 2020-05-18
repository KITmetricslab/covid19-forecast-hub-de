https://travis-ci.com/KITmetricslab/covid19-forecast-hub-de.svg?token=tay9rBsDUDXpwELgv9Dn&branch=issue/24

# A German COVID-19 Forecast Hub

### This project is in a development stage and not operational yet. The platform is not officially endorsed by KIT or HITS.

## Purpose

This repository assembles forecasts of cumulative and incident COVID19 deaths in Germany in a standardized format. It is run by members of the [Chair of Econometrics and Statistics at Karlsruhe Institute of Technology](https://statistik.econ.kit.edu/index.php) and the [Computational Statistics Group at Heidelberg Institute of Technology](https://www.h-its.org/research/cst/), see below.

The effort parallels the [US COVID-19 forecast hub](COVID-19 Forecast Hub) run by the UMass-Amherst Influenza Forecasting Center of Excellence based at the [Reich Lab](https://reichlab.io/). We are in close exchange with the Reich Lab team and follow the general structure and [data format](https://github.com/reichlab/covid19-forecast-hub#data-model) defined there.

Unlike in the more advanced US COVID19 forecast hub, forecasts are currently not submitted to us by pull request. Instead, we actively collect available forecasts from various teams and re-format them in a standardized way.

If you are generating forecasts for COVID19 deaths in Germany and would like to contribute to this repository do not hesitate to [get in touch](https://statistik.econ.kit.edu/mitarbeiter_2902.php).

## Forecast targets

Currently we are focussing on forecasts of 1 through 130 day-ahead incident and cumulative deaths, 1 through 20 week-ahead incident and cumulative deaths. Otherwise we follow the principles outlined [here](https://github.com/reichlab/covid19-forecast-hub#what-forecasts-we-are-tracking-and-for-which-locations) for the US COVID19 forecast hub.

## Contents of the repository

The main contents of the repository are currently the following:

- `data-raw`: the forecast files as provided by the various teams on their respective websites
- `data-processed`: forecasts in a standardized format
- `app_forecasts_de`: a simple R shiny app to visualize forecasts (to be run locally and soon available online)

## Data license and reuse

The forecasts assembled in this repository have been created by various independent teams, most of which provided a license with their forecasts. These licenses can be found in the respective subfolders of `data-processed`. Parts of the processing and analysis codes have been adapted from the [US COVID-19 forecast hub](COVID-19 Forecast Hub) where they were provided under an [MIT license](https://github.com/reichlab/covid19-forecast-hub/blob/master/LICENSE). All codes contained in this repository are equally under the [MIT license](LICENSE).


## Teams generating forecasts

Currently we assemble forecasts from the following teams. *Note that not all teams are using the same ground truth data.* (used data source and forecast reuse license in brackets):

- [IHME](https://covid19.healthdata.org/united-states-of-america) (unclear; CC-AT-NC4.0) *Note that we are currently still facing some difficulties in the processing of the IHME files.*
- [LANL](https://covid-19.bsvgateway.org/) (JHU; custom)
- [Imperial](https://github.com/sangeetabhatia03/covid19-short-term-forecasts) (ECDC; Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License)
- [MIT](https://www.covidanalytics.io/) (JHU; Apache 2.0)
- [University of Geneva / Swiss Data Science Center](https://renkulab.shinyapps.io/COVID-19-Epidemic-Forecasting/) (ECDC; none given)
- [YYG](http://covid19-projections.com/) (JHU; MIT)

## Forecast hub team

The following persons have contributed to this repository, either by assembling forecasts or by conceptual work in the background (in alphabetical order):

- [Johannes Bracher](https://statistik.econ.kit.edu/mitarbeiter_2902.php)
- Jannik Deuschel
- [Tilmann Gneiting](https://www.h-its.org/2018/01/08/tilmann-gneiting/)
- [Konstantin Görgen](https://statistik.econ.kit.edu/mitarbeiter_2716.php)
- [Melanie Schienle](https://statistik.econ.kit.edu/mitarbeiter_2068.php)

## Related efforts

- [US COVID-19 Forecast Hub](https://github.com/reichlab/covid19-forecast-hub) run by the [Reich Lab](https://reichlab.io/).
- [Code repository for the SARS-CoV2 modelling initiative](https://github.com/timueh/sars-cov2-modelling-initiative)
