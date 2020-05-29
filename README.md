[![Build Status](https://travis-ci.org/KITmetricslab/covid19-forecast-hub-de.svg?branch=master)](https://travis-ci.org/KITmetricslab/covid19-forecast-hub-de)

# A German COVID-19 Forecast Hub

### This project is in a development stage and not operational yet. The platform is not officially endorsed by KIT or HITS.

*Beschreibung in deutscher Sprache siehe [hier](https://github.com/KITmetricslab/covid19-forecast-hub-de/blob/master/README_DE.md).*

## Purpose

This repository assembles forecasts of cumulative and incident COVID-19 deaths in Germany in a standardized format. Other forecast targets will be added in the future. The repository is run by members of the [Chair of Econometrics and Statistics at Karlsruhe Institute of Technology](https://statistik.econ.kit.edu/index.php) and the [Computational Statistics Group at Heidelberg Institute for Theoretical Studies](https://www.h-its.org/research/cst/), see [below](#forecast-hub-team).

An interactive visualization of the different forecasts can be found [here](https://jobrac.shinyapps.io/app_forecasts_de/).

The effort parallels the [US COVID-19 forecast hub](https://github.com/reichlab/covid19-forecast-hub) run by the UMass-Amherst Influenza Forecasting Center of Excellence based at the [Reich Lab](https://reichlab.io/). We are in close exchange with the Reich Lab team and follow the general structure and [data format](https://github.com/reichlab/covid19-forecast-hub#data-model) defined there, see also this [wiki entry](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Data-Format) for more details. We also re-use software provided by the ReichLab (see [below](#data-license-and-reuse)).

If you are generating forecasts for COVID-19 cases, hospitalizations or deaths in Germany and would like to contribute to this repository do not hesitate to [get in touch](https://statistik.econ.kit.edu/mitarbeiter_2902.php).

## Forecast targets

Currently we are focussing on **1 through 30 day and 1 through 4 week ahead forecasts of incident and cumulative deaths** in Germany (national level). We also accept up to 130 day-ahead and up to 20 week-ahead forecasts. This [wiki entry](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Forecast-targets) contains details on the definition of the targets. Further targets, including targets stratified by Bundesland will be added after consultation with interested teams of forecasters. There is no obligation to submit forecasts for all suggested targets and it is up to teams to decide what they feel comfortable forecasting.

Note that our definition of targets parallels the principles outlined [here](https://github.com/reichlab/covid19-forecast-hub#what-forecasts-we-are-tracking-and-for-which-locations) for the US COVID-19 forecast hub.

<!---
Note that unlike the US hub we also allow for `-1 wk ahead <target>`, `0 wk ahead <target>`, `-1 day ahead <target>` and `0 day ahead <target>` which, if they have already been observed (this may or may not be the case for 0 wk ahead) are assigned `type = "observed"`. We decided to include this as there is more heterogeneity concerning the ground truths used by different teams. By also storing the last observed values as provided by teams it becomes easier to spot such differences.
-->

## Contents of the repository

The main contents of the repository are currently the following (see also [this](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Structure-of-the-repository) wiki page):

- `data-raw`: the forecast files as provided by the various teams on their respective websites
- `data-processed`: forecasts in a standardized format
- `data-truth`: truth data from JHU and ECDC in a standardized format


## Guide to submission

Unlike in the more advanced US COVID-19 forecast hub, at the current stage we are actively collect available forecasts from various teams and re-format them in a standardized way. We are, however, moving to a submission system based on pull requests for new teams. Our wiki contains a detailed [guide to submission](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Preparing-your-submission). **Forecasts hould be updated in a weekly rhythm. If at all possible, new forecast should be uploaded on Mondays.** The deadline is 11.59pm and thus corresponds to the deadline of the US Hub (6pm Eastern Time). Note that we also accept additional updates on other days of the week (not more than one per day), but will not include these in visualizations or ensembles.


Especially in the starting phase we will try to provide direct support to teams to help overcome technical difficulties, do not hesitate to [get in touch](https://statistik.econ.kit.edu/mitarbeiter_2902.php).


## Data format

We store point and quantile forecasts in a long format, including information on forecast dates and location, see [this wiki entry](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Data-Format) for details. This format is largely identical to the one outlined for the US Hub [here](https://github.com/reichlab/covid19-forecast-hub#data-model) and [here](https://github.com/reichlab/covid19-forecast-hub/tree/master/data-processed#data-submission-instructions).

## Data license and reuse

The forecasts assembled in this repository have been created by various independent teams, most of which provided a license with their forecasts. These licenses can be found in the respective subfolders of `data-processed`. Parts of the processing, analysis and validation codes have taken or been adapted from the [US COVID-19 forecast hub](https://github.com/reichlab/covid19-forecast-hub) where they were provided under an [MIT license](https://github.com/reichlab/covid19-forecast-hub/blob/master/LICENSE). All codes contained in this repository are equally under the [MIT license](https://github.com/KITmetricslab/covid19-forecast-hub-de/blob/master/LICENSE).

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

## Ensemble building

One of the goals of this forecast hub is to combine the available forecasts into an ensemble prediction as [already done in the US Forecast Hub](https://github.com/reichlab/covid19-forecast-hub#ensemble-model).

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
