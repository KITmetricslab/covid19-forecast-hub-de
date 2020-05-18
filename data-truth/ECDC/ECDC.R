# Author: Konstantin G?rgen
# Date: Sat May 09 14:34:39 2020
# --------------
# Modification:
# Author:
# Date:
# --------------


##Script to Process Raw Deaths File from ecdc

#read the Dataset sheet into “R”. The dataset will be called "data".
ecdc <- read.csv("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv",
                 na.strings = "", fileEncoding = "UTF-8-BOM", stringsAsFactors = FALSE)

ecdc_germany <- subset(ecdc, countriesAndTerritories == "Germany")
ecdc_germany <- ecdc_germany[, c("dateRep", "deaths")]
colnames(ecdc_germany) <- c("date", "value")
ecdc_germany$date <- as.Date(ecdc_germany$date, format = "%d/%m/%y")
ecdc_germany <- subset(ecdc_germany, date < "2020-12-31")

ecdc_germany$location <- "GM"
ecdc_germany$location_name <- "Germany"
ecdc_germany <- ecdc_germany[, c("date", "location", "location_name", "value")]
head(ecdc_germany)
ecdc_germany <- ecdc_germany[order(ecdc_germany$date), ]

write.csv(ecdc_germany, file= "truth_ECDC-Incident Deaths_Germany.csv", row.names=FALSE)

# cumulative:
ecdc_germany_cum <- data.frame(
  date = ecdc_germany$date,
  location = "GM",
  location_name = "Germany",
  value = cumsum(ecdc_germany$value)
)
write.csv(ecdc_germany_cum, file="truth_ECDC-Cumulative Deaths_Germany.csv", row.names=FALSE)
