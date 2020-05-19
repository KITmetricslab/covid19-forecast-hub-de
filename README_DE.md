# A German COVID-19 Forecast Hub - Zusammenstellung von Vorhersagen für COVID-19 Todesfälle in Deutschland

### Dieses Projekt befindet sich in der Entwicklungsphase und ist noch nicht operationell. Dies ist keine offizielle KIT- oder HITS-Plattform.

*Description in English available [here](README.html).*

## Zweck

Dieses Repository dient dazu, Vorhersagen für kumulative und inzidente COVID-19-Todeszahlen in einem standardisierten Format zusammenzutragen. Es wird von Mitgliedern des [Lehrstuhl für Ökonometrie und Statistik am Karslruher Institut für Technologie](https://statistik.econ.kit.edu/index.php) und der [Computational Statistics Gruppe am Heidelberger Institut für Theoretische Studien](https://www.h-its.org/research/cst/) betrieben, siehe Auflistung unten.

Eine interaktive Visualisierung der verschiedenen Vorhersagen ist [hier](https://jobrac.shinyapps.io/app_forecasts_de/) verfügbar.

Dieses Projekt ist vom [US COVID-19 forecast hub](https://github.com/reichlab/covid19-forecast-hub) inspiriert, der vom [Reich Lab](https://reichlab.io/) / UMass-Amherst Influenza Forecasting Center of Excellence betrieben wird. Wir stehen in engem Austausch mit dem Reich Lab und übernehmen weitgehend die dort festgelegten Strukturen und [Datenformate](https://github.com/reichlab/covid19-forecast-hub#data-model).

Anders als im bereits im bereits weiter fortgeschrittenen US COVID19 Forecast Hub haben wir derzeit kein Übermittlungssystem für Vorhersagen eingerichtet. Stattdessen sammeln wir aktiv Vorhersagen aus verschiedenen Quellen und stellen sie hier in einem standardisierten Format zur Verfügung.

Falls Sie an Vorhersagen für COVID-19-Todesfälle in Deutschland arbeiten und gerne zu diesem Repository beitragen treten Sie gerne mit uns in [Kontakt](https://statistik.econ.kit.edu/mitarbeiter_2902.php)

## Vorhersageziele

Derzeit liegt unser Fokus auf 1 bis 130 Tage und 1 bis 20 Wochen Vorhersagen für inzidente und kumulative Todeszahlen. Dabei folgen wir den [hier](https://github.com/reichlab/covid19-forecast-hub#what-forecasts-we-are-tracking-and-for-which-locations) für den S COVID19 Forecast Hub dargelegten Prinzipien.

Beachten Sie, dass wir anders als der US-Hub auch Einträge des Typs `-1 wk ahead <target>`, `0 wk ahead <target>`, `-1 day ahead <target>` und `0 day ahead <target>` zulassen. Falls diese bereits beobachtet wirden (für 0 wk ahead ist dies nicht notwendigerweise der Fall) verwenden wir `type = "observed"`. Wir haben entschieden, diese Einträge aufzunehmen, da verschiedene Teams verschiedene Datengrundlagen verwenden und wir es als hilfreich erachten, die letzten Wahrheitswerteso wie sie von den verschiedenen Modellen verwendet wurden mit abzuspeichern.

## Inhalt des Repositories

Die Hauptinhalte des Repositories sind gegenwärtig die Folgenden:

- `data-raw`: Vorhersagedateien in ihrer ursprünglichen Form, d.h. so, wie sie von den verschiedenen Teams zur Verfügung gestellt wurden.
- `data-processed`: Vorhersagen im Standardformat.
- `app_forecasts_de`: eine einfache R Shiny app zur Visualisierung (online verfügbar [hier](https://jobrac.shinyapps.io/app_forecasts_de/))

## Lizenz und Weiterverwendung der Vorhersagedaten

Die in diesem Repository zusammengetragenen Vorhersagen sind von verschiedenen unabhängigen Teams erstellt worden, in den meisten Fällen zusammen mit einer Lizenz zur Weiterverwendung. Diese Lizenzen sind in den entsprechenden Unterordnern von `data-processed` enthalten. Teile der Processing- und Analyse-Codes sind angepasste Versionen von Codes aus dem [US COVID-19 Forecast Hub](COVID-19 Forecast Hub) (dort unter [MIT Lizenz](https://github.com/reichlab/covid19-forecast-hub/blob/master/LICENSE)). Alle hier bereitgestellten Codes stehen ebenfalls unter der [MIT Lizenz](LICENSE).


## Teams, die Vorhersagen bereitstellen

Derzeit tragen wir Vorhersagen der folgenden Teams zusammen. *Bitte beachten Sie, dass nicht alle Teams ihre Vorhersagen aufgrund der selben Datengrundlage zu Todeszahlen erstellen.* (benutzte Datengrundlage und Lizenz in Klammern).

- [IHME](https://covid19.healthdata.org/united-states-of-america) (unclear; CC-AT-NC4.0) *Note that we are currently still facing some difficulties in the processing of the IHME files.*
- [LANL](https://covid-19.bsvgateway.org/) (JHU; custom)
- [Imperial](https://github.com/sangeetabhatia03/covid19-short-term-forecasts) (ECDC; Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License)
- [MIT](https://www.covidanalytics.io/) (JHU; Apache 2.0)
- [University of Geneva / Swiss Data Science Center](https://renkulab.shinyapps.io/COVID-19-Epidemic-Forecasting/) (ECDC; none given)
- [YYG](http://covid19-projections.com/) (JHU; MIT)

## Datenquellen zu Todeszahlen

Data on observed numbers of deaths come from the following surces:

- [European Centre for Disease Prevention and Control](https://www.ecdc.europa.eu/en/geographical-distribution-2019-ncov-cases)
- [Johns Hopkins University](https://coronavirus.jhu.edu/)

## Forecast hub team

Die folgenden Personen haben zu diesem Projekt beigetragen, entweder durch praktische Arbeit am Repository oder konzeptionelle Arbeit im Hintergrund (in alphabetischer Reihenfolge):

- [Johannes Bracher](https://statistik.econ.kit.edu/mitarbeiter_2902.php)
- Jannik Deuschel
- [Tilmann Gneiting](https://www.h-its.org/2018/01/08/tilmann-gneiting/)
- [Konstantin Görgen](https://statistik.econ.kit.edu/mitarbeiter_2716.php)
- [Melanie Schienle](https://statistik.econ.kit.edu/mitarbeiter_2068.php)

## Verwandte Projekte

- [US COVID-19 Forecast Hub](https://github.com/reichlab/covid19-forecast-hub) run by the [Reich Lab](https://reichlab.io/).
- [Code repository for the SARS-CoV2 modelling initiative](https://github.com/timueh/sars-cov2-modelling-initiative)