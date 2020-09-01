# A German COVID-19 Forecast Hub - Zusammenstellung von Vorhersagen für COVID-19 Todesfälle in Deutschland

*Description in English available [here](https://github.com/KITmetricslab/covid19-forecast-hub-de/).*

## Zweck

Dieses Repository dient dazu, Vorhersagen für kumulative und inzidente COVID-19-Todeszahlen in einem standardisierten Format zusammenzutragen. Es wird von Mitgliedern des [Lehrstuhl für Ökonometrie und Statistik am Karslruher Institut für Technologie](https://statistik.econ.kit.edu/index.php) und der [Computational Statistics Gruppe am Heidelberger Institut für Theoretische Studien](https://www.h-its.org/research/cst/) betrieben, siehe Auflistung unten.

Eine **interaktive Visualisierung** der verschiedenen Vorhersagen ist [hier](https://jobrac.shinyapps.io/app_forecasts_de/) verfügbar.

Dieses Projekt ist vom [US COVID-19 Forecast Hub](https://github.com/reichlab/covid19-forecast-hub) inspiriert, der vom [Reich Lab](https://reichlab.io/) / UMass-Amherst Influenza Forecasting Center of Excellence betrieben wird. Wir stehen in engem Austausch mit dem Reich Lab und übernehmen weitgehend die dort festgelegten Strukturen und [Datenformate](https://github.com/reichlab/covid19-forecast-hub#data-model), siehe auch diesen [Wiki-Eintrag](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Data-Format) (auf englisch). Ausserdem verwenden wir vom ReichLab zur Verfügung gestellte Software (siehe [unten](#lizenz-und-weiterverwendung-der-vorhersagedaten)).

Falls Sie an Vorhersagen für COVID-19-Todesfälle in Deutschland arbeiten und gerne zu diesem Repository beitragen möchten treten Sie bitte mit uns in [Kontakt](https://statistik.econ.kit.edu/mitarbeiter_2902.php)

## Vorhersageziele

### Todeszahlen

Unser Hauptfokus liegt auf **1 bis 30 Tages und 1 bis 4 Wochen-Vorhersagen für inzidente und kumulative Todeszahlen**. Wir akzeptieren auch Vorhersagen bis zu 130 Tage oder 20 Wochen voraus. Dieser [Wiki-Eintrag](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Forecast-targets) (auf englisch) beinhaltet eine genauere Beschreibung der Vorhersageziele. Es gibt keine Verpflichtung, Vorhersagen für alle genannten Ziele abzugeben und es bleibt den einzelnen Gruppen überlassen, einzuschätzen, für welche Ziele ihr Modell sinnvolle Vorhersagen generieren kann.

Die Definition unserer Vorhersageziele folgt den [hier](https://github.com/reichlab/covid19-forecast-hub#what-forecasts-we-are-tracking-and-for-which-locations) für den US COVID-19 forecast hub beschriebenen Prinzipien.

Derzeit betrachten wir die [ECDC Daten](https://www.ecdc.europa.eu/en/publications-data/download-todays-data-geographic-distribution-covid-19-cases-worldwide) als die zugrundeliegende und vorherzusagende ``Wahrheit'' (*ground truth*). Unser R-Skript zur Berechnung der kumuativen Todeszahlen ist [hier](https://github.com/KITmetricslab/covid19-forecast-hub-de/blob/master/data-truth/ECDC/ECDC.R) verfügbar. Für Todeszahlen auf der Bundeslanebene beziehen wir täglich Daten aus dem [RKI/arcgis Dashboard](https://www.arcgis.com/home/item.html?id=f10774f1c63e40168479a1feb6c7ca74). Für historische Todeszahlen ziehen wir ausserdem Daten aus dem [ard-data](https://github.com/ard-data/2020-rki-archive) Archiv heran. Die resultierenden Datensätze zu täglichen Todeszahlen sind [hier](https://github.com/KITmetricslab/covid19-forecast-hub-de/tree/master/data-truth/RKI) verfügbar.

### Fälle

Wir akzeptieren ausserdem **1 bis 30 Tages und 1 bis 4 Wochen-Vorhersagen für inzidente und kumulative Fallzahlen**, siehe auch Beschreibung [hier](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Forecast-targets). Die entsprechenden Wahrheitsdaten basierend auf RKI-Daten sind [hier](https://github.com/KITmetricslab/covid19-forecast-hub-de/tree/master/data-truth/RKI) verfügbar.

### Intensivmedizinische Versorgung

Wir beabsichtigen, demnächst auch Vorhersagen für den Bedarf an intensivmedizinischer Versorgung aufgrund von COVID19-Erkrankungen abzudecken. Daten aus dem [DIVI Register](https://www.divi.de/) werden als Gundlage für die Definition von Vorhersagezielen dienen.


Die Definition unserer Vorhersageziele folgt den [hier](https://github.com/reichlab/covid19-forecast-hub#what-forecasts-we-are-tracking-and-for-which-locations) für den US COVID-19 forecast hub beschriebenen Prinzipien.

## Inhalt des Repositories

Die Hauptinhalte des Repositories sind gegenwärtig die Folgenden:

- `data-raw`: Vorhersagedateien in ihrer ursprünglichen Form, d.h. so, wie sie von den verschiedenen Teams zur Verfügung gestellt wurden.
- `data-processed`: Vorhersagen im Standardformat.
- `data-truth`: ECDC- und JHU-Daten zu COVID19 Todesfällen in einem standardisierten Format


## Anleitung zur Einreichung von Vorhersagen

Im Gegensatz zum weiter fortgeschrittenen US COVID-19 forecast hub sammeln wir auch aktiv verfügbare Vorhersagen und bringen sie in ein Standardformat. Wir gehen allerdings schrittweise zu einem auf Pull Requests basierenden Einreichungssystem über. In unserem Wiki stellen wir eine ausführliche [Anleitung zur Einreichung](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Preparing-your-submission) zur Verfügung. **Vorhersagen sollten in wöchentlichen Abständen aktualisiert werden, wenn möglich jeden Montag.** Als Frist haben wir Montag 23.59 gewählt, was mit der Frist des US Forecast Hub zusammenfällt (6pm ET). Neue Vorhersagen können auch an anderen Wochentagen abgegeben werden (nicht mehr als eine pro Tag), diese werden jedoch nicht in Visualisierungen oder Ensembles verwendet (Ausnahme: Falls an einem Montag keine Vorhersage abgegeben wurde verwenden wir Vorhersagen, die am vorangegangenen Sonntag, Samstag oder Freitag abgegeben wurden).

Vor allem in der Anfangsphase sind wir bemüht, teilnehmenden Gruppen technische Unterstützung bei der Einreichung anzubieten. Treten Sie hierzu gerne mit uns in [Kontakt](https://statistik.econ.kit.edu/mitarbeiter_2902.php).

## Speicherformat für Vorhersagen

Wir speichern Punktvorhersagen und Vorhersagequantile in einem Langformat mit Informationen zu Datum und Ort, siehe [hier](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Data-Format). Dieses Format ist weithgehend identisch zu dem im US Hub verendeten Format (siehe [hier](https://github.com/reichlab/covid19-forecast-hub#data-model) and [hier](https://github.com/reichlab/covid19-forecast-hub/tree/master/data-processed#data-submission-instructions)).


## Lizenz und Weiterverwendung der Vorhersagedaten

Die in diesem Repository zusammengetragenen Vorhersagen sind von verschiedenen unabhängigen Teams erstellt worden, in den meisten Fällen zusammen mit einer Lizenz zur Weiterverwendung. Diese Lizenzen sind in den entsprechenden Unterordnern von `data-processed` enthalten. Teile der Processing- und Analyse-Codes sind angepasste Versionen von Codes aus dem [US COVID-19 Forecast Hub](COVID-19 Forecast Hub) (dort unter [MIT Lizenz](https://github.com/reichlab/covid19-forecast-hub/blob/master/LICENSE)). Alle hier bereitgestellten Codes stehen ebenfalls unter der [MIT license](https://github.com/KITmetricslab/covid19-forecast-hub-de/blob/master/LICENSE).

## Wahrheitsdaten

Daten zu den beobachteten Todeszahlen beziehen wir aus den folgenden Quellen:

- [European Centre for Disease Prevention and Control](https://www.ecdc.europa.eu/en/geographical-distribution-2019-ncov-cases) **(Dies ist unsere bevorzugte Quelle und wird bei der Evaluierung zugrundegelegt.)**
- [Johns Hopkins University](https://coronavirus.jhu.edu/)


- [European Centre for Disease Prevention and Control](https://www.ecdc.europa.eu/en/geographical-distribution-2019-ncov-cases) **(Dies ist unsere bevorzugte Quelle und wird bei der Evaluierung zugrundegelegt.)**
- [Robert Koch Institut](https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0). Die Generierung dieser Datensätze erfordert einige Pre-Processing-Schritte, sieher [hier](data-truth/RKI). **(Dies ist unsere bevorzugte Quelle für Daten auf der Bundesland-Ebene. Die Daten sind kompatibel mit den ECDC-DAten auf der Bundesebene.)**
- [Johns Hopkins University](https://coronavirus.jhu.edu/). Diese Daten werden von einer Reihe von Teams zur Generierung von Vorhersagen genutzt. Derzeit (August 2020) ist die Übereinstimmung mit den ECDC-DAten gut, in der Vergangenheit gab es allerdings stärkere Diskrepanzen.
- [DIVI Intensivregister](https://www.divi.de/register/tagesreport) Diese Daten werden derzeit nicht genutzt, wir planen jedoch, künftig auch Vorhersagen basierend auf diesen Daten zusammenzutragen.


## Teams, die Vorhersagen bereitstellen

Derzeit tragen wir Vorhersagen der folgenden Teams zusammen. *Bitte beachten Sie, dass nicht alle Teams ihre Vorhersagen aufgrund der selben Datengrundlage zu Todeszahlen erstellen.* (benutzte Datengrundlage und Lizenz in Klammern).

- [Frankfurt Institute for Advanced Studies & Forschungszentrum Jülich](https://www.medrxiv.org/content/10.1101/2020.04.18.20069955v1) (ECDC; no license specified)
- [IHME](https://covid19.healthdata.org/united-states-of-america) (JHU; CC-AT-NC4.0)
- [KIT](https://github.com/KITmetricslab/KIT-baseline) (ECDC; MIT) *This is a simple baseline model run by the Forecast Hub Team. Part of these forecasts were created retrospectively, but using only data available at the respective forecast date.*
- [LANL](https://covid-19.bsvgateway.org/) (JHU; custom)
- [Imperial](https://github.com/mrc-ide/covid19-forecasts-orderly) (ECDC; Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License)
- [Johannes Gutenberg University Mainz / University of Hamburg](https://github.com/QEDHamburg/covid19) (ECDC; MIT)
- [MIT](https://www.covidanalytics.io/) (JHU; Apache 2.0)
- [University of Geneva / Swiss Data Science Center](https://renkulab.shinyapps.io/COVID-19-Epidemic-Forecasting/) (ECDC; none given)
- [University of Leipzig IMISE/GenStat](https://github.com/holgerman/covid19-forecast-hub-de) (ECDC; none given)
- [University of Southern California Data Science Lab](https://scc-usc.github.io/ReCOVER-COVID-19)(JHU; MIT) (MIT)
- [YYG](http://covid19-projections.com/) (JHU; MIT)

## Vorhersageevaluation und Ensembles

Eines der Ziele des Forecast Hubs ist es, verschiedene Vorhersagen in einer Ensemble-Vorhersage zusammenzuführen, siehe [hier](https://github.com/KITmetricslab/covid19-forecast-hub-de/wiki/Creation-of-equally-weighted-ensemble) für eine kurze Beschreibung des derzeit verwendeten Ansatzes ohne Gewichtung. Aufwändigere datengetriebene Verfahren setzen voraus, dass verschiedene Vorhersagen, sowohl Ensemble-Vorhersagen als auch Vorhersagen einzelner Teams evaluiert und verglichen werden. **Wir möchten jedoch betonen, dass es sich hierbei nicht um einen Wettbewerb, sondern um ein kollaboratives Projekt handelt.** Die Methoden zur Vorhersageevaluation die Anwendung finden werden sind [hier](https://arxiv.org/abs/2005.12881) beschrieben.


## Forecast hub team

Die folgenden Personen haben zu diesem Projekt beigetragen, entweder durch praktische Arbeit am Repository oder konzeptionelle Arbeit im Hintergrund (in alphabetischer Reihenfolge):

- [Johannes Bracher](https://statistik.econ.kit.edu/mitarbeiter_2902.php)
- Jannik Deuschel
- [Tilmann Gneiting](https://www.h-its.org/2018/01/08/tilmann-gneiting/)
- [Konstantin Görgen](https://statistik.econ.kit.edu/mitarbeiter_2716.php)
- Jakob Ketterer
- [Melanie Schienle](https://statistik.econ.kit.edu/mitarbeiter_2068.php)
- Daniel Wolffram

## Verwandte Projekte

- [US COVID-19 Forecast Hub](https://github.com/reichlab/covid19-forecast-hub), betrieben vom [Reich Lab](https://reichlab.io/) (Preprint [hier](https://www.medrxiv.org/content/10.1101/2020.08.19.20177493v1) verfügbar).
- [Code repository der SARS-CoV2 modelling initiative](https://github.com/timueh/sars-cov2-modelling-initiative)

## Acknowledgements

Das Forecast Hub-Projekt ist Teil des von der Helmholtz-Gemeinschaft geförderten [SIMCARD Information& Data Science Pilot Project](https://www.helmholtz.de/forschung/information-data-science/information-data-science-pilot-projekte/pilotprojekte-2/). Ausserdem gilt unser Dank der [Alexander von Humboldt Stiftung](http://www.humboldt-foundation.de/web/start.html) deren Unterstützung für Nicholas G. Reich maßgeblich dazu beigetragen hat, die Zusammenarbeit mit dem [ Reich Lab](https://reichlab.io/) und dem und dem [US COVID-19 Forecast Hub](https://github.com/reichlab/covid19-forecast-hub) in die Wege zu leiten.

**Für die Inhalte dieser Seite sind einzig die Autoren verantwortlich. Diese Seite spiegelt nicht notwendigerweise die Standpunkte des KIT, HITS, der Humboldt Stiftung oder der Helmholtz-Gemeinschaft wider.**