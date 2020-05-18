# Author: Konstantin G?rgen
# Date: Sat May 09 14:34:39 2020
# --------------
# Modification:
# Author:
# Date:
# --------------


##Script to Process Raw Deaths File from Johns Hopkins University

jhu_raw<-read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv",stringsAsFactors = FALSE)
jhu_germany<-jhu_raw[jhu_raw$Country.Region=="Germany",]

cols_dates <- colnames(jhu_germany)[grepl("X", colnames(jhu_germany))]
dates <- as.Date(gsub("X", "", cols_dates), format = "%m.%d.%y")

jhu_truth_germany_cum <- data.frame(date = dates,
                                    location = "GM",
                                    location_name = "Germany",
                                    value = as.numeric(jhu_germany[, cols_dates]))


jhu_truth_germany_inc <- data.frame(date = dates[-1],
                                    location = "GM",
                                    location_name = "Germany",
                                    value = diff(as.numeric(jhu_germany[, cols_dates])))


write.csv(jhu_truth_germany_cum,file="truth_JHU-Cumulative Deaths_Germany.csv", row.names = FALSE)
write.csv(jhu_truth_germany_inc,file="truth_JHU-Incident Deaths_Germany.csv", row.names = FALSE)
