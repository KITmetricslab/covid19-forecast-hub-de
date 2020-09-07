[![Build Status](https://travis-ci.org/KITmetricslab/covid19-forecast-hub-de.svg?branch=master)](https://travis-ci.org/KITmetricslab/covid19-forecast-hub-de)

# German and Polish COVID-19 Forecast Hub

*Beschreibung in deutscher Sprache siehe [hier](https://github.com/KITmetricslab/covid19-forecast-hub-de/blob/master/README_DE.md).*

## Purpose

This repository assembles forecasts of cumulative and incident COVID-19 deaths and cases in Germany and Poland in a standardized format. Forecasts for ICU need will be added in the near future, other forecast targets may follow. The repository is run by members of the [Chair of Econometrics and Statistics at Karlsruhe Institute of Technology](https://statistik.econ.kit.edu/index.php) and the [Computational Statistics Group at Heidelberg Institute for Theoretical Studies](https://www.h-its.org/research/cst/), see [below](#forecast-hub-team).

An **interactive visualization** of the different forecasts can be found [here](https://jobrac.shinyapps.io/app_forecasts_de/).

![static visualization of current forecasts](code/visualization/current_forecasts.png?raw=true)

The effort parallels the [US COVID-19 forecast hub](https://github.com/reichlab/covid19-forecast-hub) run by the UMass-Amherst Influenza Forecasting Center of Excellence based at the [Reich Lab](https://reichlab.io/). We are in close exchange with the Reich Lab team and follow the general structure and [data format](https://github.com/reichlab/covid19-forecast-hub/blob/master/data-processed/README.md) defined there, see this [wiki entry](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Forecast-Data-Format) for more details. We also re-use software provided by the ReichLab (see [below](#data-license-and-reuse)).

If you are generating forecasts for COVID-19 cases, hospitalizations or deaths in Germany and would like to contribute to this repository do not hesitate to [get in touch](https://statistik.econ.kit.edu/mitarbeiter_2902.php).

## Forecast targets

### Deaths

Our main focus is on **1 through 30 day and 1 through 4 week ahead forecasts of incident and cumulative deaths by reporting date in Germany and Poland (national level) and the German states (Bundesländer)**. We also accept up to 130 day-ahead and up to 20 week-ahead forecasts. This [wiki entry](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Forecast-targets) contains details on the definition of the targets. There is no obligation to submit forecasts for all suggested targets and it is up to teams to decide what they feel comfortable forecasting.

Note that our definition of targets parallels the principles outlined [here](https://github.com/reichlab/covid19-forecast-hub#what-forecasts-we-are-tracking-and-for-which-locations) for the US COVID-19 forecast hub.

Note that we currently treat the **ECDC data** available [here](https://www.ecdc.europa.eu/en/publications-data/download-todays-data-geographic-distribution-covid-19-cases-worldwide) as our ground truth for the national level death forecasts. Our R script to compute cumulative deaths can be found [here](https://github.com/KITmetricslab/covid19-forecast-hub-de/blob/master/data-truth/ECDC/ECDC.R). For deaths at the Bundeland level we extract data from the [RKI/arcgis Dashboard](https://www.arcgis.com/home/item.html?id=f10774f1c63e40168479a1feb6c7ca74) on a daily basis. For historical data we use the archive provided by [ard-data](https://github.com/ard-data/2020-rki-archive). The resulting data set on daily reported deaths can be found [here](https://github.com/KITmetricslab/covid19-forecast-hub-de/tree/master/data-truth/RKI). We are working on adding data for Polish voivodeships to our repository.

### Cases

We are also accepting **1 through 30 day and 1 through 4 week ahead forecasts of incident and cumulative confirmed cases by reporting date in Germany and Poland (national level) and the German states (Bundesländer)**, see the [wiki entry](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Forecast-targets). The respective truth data from RKI can be found [here](https://github.com/KITmetricslab/covid19-forecast-hub-de/tree/master/data-truth/RKI). We are working on adding data for Polish voivodeships to our repository.

### Intensive care use

We intend to start covering forecasts for intensive care use due to COVID19 (at the German national and Bundesland levels). Details will be provided here soon. Data from the [DIVI Registry](https://www.divi.de/) have been compiled [here](https://github.com/KITmetricslab/covid19-forecast-hub-de/tree/master/data-truth/DIVI) and will be used to define prediction targets.



<!---
Note that unlike the US hub we also allow for `-1 wk ahead <target>`, `0 wk ahead <target>`, `-1 day ahead <target>` and `0 day ahead <target>` which, if they have already been observed (this may or may not be the case for 0 wk ahead) are assigned `type = "observed"`. We decided to include this as there is more heterogeneity concerning the ground truths used by different teams. By also storing the last observed values as provided by teams it becomes easier to spot such differences.
-->

## Contents of the repository

The main contents of the repository are currently the following (see also [this](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Structure-of-the-repository) wiki page):

- `data-raw`: the forecast files as provided by the various teams on their respective websites
- `data-processed`: forecasts in a standardized format
- `data-truth`: truth data from JHU and ECDC in a standardized format


## Guide to submission

Unlike in the more advanced US COVID-19 forecast hub, at the current stage we actively collect available forecasts from various teams and re-format them in a standardized way. We are, however, moving to a submission system based on pull requests for new teams. Our wiki contains a detailed [guide to submission](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Preparing-your-submission). **Forecasts should be updated in a weekly rhythm. If at all possible, new forecast should be uploaded on Mondays.** The deadline is 11.59pm and thus corresponds to the deadline of the US Hub (6pm Eastern Time). Note that we also accept additional updates on other days of the week (not more than one per day), but will not include these in visualizations or ensembles (if no new forecast was provided on a Monday we will, however, use forecasts from the preceding Sunday, Saturday or Friday).

Especially in the starting phase we will try to provide direct support to teams to help overcome technical difficulties, do not hesitate to [get in touch](https://statistik.econ.kit.edu/mitarbeiter_2902.php).


## Data format

We store point and quantile forecasts in a long format, including information on forecast dates and location, see [this wiki entry](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Forecast-Data-Format) for details. This format is largely identical to the one outlined for the US Hub [here](https://github.com/reichlab/covid19-forecast-hub/tree/master/data-processed#data-submission-instructions).

## Data license and reuse

The forecasts assembled in this repository have been created by various independent teams, most of which provided a license with their forecasts. These licenses can be found in the respective subfolders of `data-processed`. Parts of the processing, analysis and validation codes have been taken or adapted from the [US COVID-19 forecast hub](https://github.com/reichlab/covid19-forecast-hub) where they were provided under an [MIT license](https://github.com/reichlab/covid19-forecast-hub/blob/master/LICENSE). All codes contained in this repository are equally under the [MIT license](https://github.com/KITmetricslab/covid19-forecast-hub-de/blob/master/LICENSE).

## Truth data

Data on observed numbers of deaths and several other quantities are compiled [here](https://github.com/KITmetricslab/covid19-forecast-hub-de/tree/master/data-truth) and come from the following sources:

- [European Centre for Disease Prevention and Control](https://www.ecdc.europa.eu/en/geographical-distribution-2019-ncov-cases) **(This is our preferred source for national level counts.)**
- [Robert Koch Institut](https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0). Note that these data are subject to some processing steps, see [here](data-truth/RKI). **(This is our preferred source for Bundesland level counts. The data are coherent with the national level data from ECDC.)**
- [Johns Hopkins University](https://coronavirus.jhu.edu/). These data are used by a number of teams generating forecasts. Currently (August 2020) the agreement with ECDC is good, but in the past there have been larger discrepancies.
- [DIVI Intensivregister](https://www.divi.de/register/tagesreport) These data are currently not yet used for forecasts, but we intend to extend our activities in this direction.

Details can be found in the respective README files in the subfolders of `data-truth`.

## Teams generating forecasts

Currently we assemble forecasts from the following teams. *Note that not all teams are using the same ground truth data.* (used truth data source and forecast reuse license in brackets):

- [Frankfurt Institute for Advanced Studies & Forschungszentrum Jülich](https://www.medrxiv.org/content/10.1101/2020.04.18.20069955v1) (ECDC; no license specified)
- [IHME](https://covid19.healthdata.org/united-states-of-america) (JHU; CC-AT-NC4.0)
- [KIT](https://github.com/KITmetricslab/KIT-baseline) (ECDC; MIT) *This is a simple baseline model run by the Forecast Hub Team. Part of these forecasts were created retrospectively, but using only data available at the respective forecast date. The commit dates of all forecasts can be found [here](https://github.com/KITmetricslab/covid19-forecast-hub-de/blob/master/code/validation/commit_dates.csv).*
- [LANL](https://covid-19.bsvgateway.org/) (JHU; custom)
- [Imperial](https://github.com/mrc-ide/covid19-forecasts-orderly) (ECDC; Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License)
- [Johannes Gutenberg University Mainz / University of Hamburg](https://github.com/QEDHamburg/covid19) (ECDC; MIT)
- [MIT](https://www.covidanalytics.io/) (JHU; Apache 2.0)
- [University of Geneva / Swiss Data Science Center](https://renkulab.shinyapps.io/COVID-19-Epidemic-Forecasting/) (ECDC; none given)
- [University of Leipzig IMISE/GenStat](https://github.com/holgerman/covid19-forecast-hub-de) (ECDC; none given)
- [University of Southern California Data Science Lab](https://scc-usc.github.io/ReCOVER-COVID-19)(JHU; MIT) (MIT)
- [YYG](http://covid19-projections.com/) (JHU; MIT)

## Forecast evaluation and ensemble building

One of the goals of this forecast hub is to combine the available forecasts into an ensemble prediction, see [here](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Creation-of-equally-weighted-ensemble) for a description of the current unweighted ensemble approach. *Note that we only started generating ensemble forecasts each week on 17 August 2020. Ensemble forecasts from earlier weeks have been generated retrospectively to assess performance. As the ensemble is only a simple average of other models this should not affect the behaviour of the ensemble forecasts. The commit dates of all forecasts can be found [here](https://github.com/KITmetricslab/covid19-forecast-hub-de/blob/master/code/validation/commit_dates.csv)*


At a later stage we intend to generate more data-driven ensembles, which requires evaluating different forecasts, both those submitted by teams and those generated using different ensembling techniques. **We want to emphasize, however, that this is not a competition, but a collaborative effort.** The forecast evaluation method which will be applied is described in [this preprint](https://arxiv.org/abs/2005.12881).

## Forecast hub team

The following persons have contributed to this repository, either by assembling forecasts or by conceptual work in the background (in alphabetical order):

- [Johannes Bracher](https://statistik.econ.kit.edu/mitarbeiter_2902.php)
- Jannik Deuschel
- [Tilmann Gneiting](https://www.h-its.org/2018/01/08/tilmann-gneiting/)
- [Konstantin Görgen](https://statistik.econ.kit.edu/mitarbeiter_2716.php)
- Jakob Ketterer
- [Melanie Schienle](https://statistik.econ.kit.edu/mitarbeiter_2068.php)
- Daniel Wolffram

## Related efforts

- [US COVID-19 Forecast Hub](https://github.com/reichlab/covid19-forecast-hub) run by the [Reich Lab](https://reichlab.io/), see also [this proprint](https://www.medrxiv.org/content/10.1101/2020.08.19.20177493v1).
- [Code repository for the SARS-CoV2 modelling initiative](https://github.com/timueh/sars-cov2-modelling-initiative)

## Acknowledgements

The Forecast Hub project is part of the [SIMCARD Information& Data Science Pilot Project](https://www.helmholtz.de/forschung/information-data-science/information-data-science-pilot-projekte/pilotprojekte-2/) funded by the Helmholtz Association. We moreover wish to acknowledge the [Alexander von Humboldt Foundation](http://www.humboldt-foundation.de/web/start.html) whose support facilitated early interactions and collaboration with the [Reich Lab](https://reichlab.io/) and the [US COVID-19 Forecast Hub](https://github.com/reichlab/covid19-forecast-hub).

**The content of this site is solely the responsibility of the authors and does not necessarily represent the official views of KIT, HITS, the Humboldt Foundation or the Helmholtz Association.**
