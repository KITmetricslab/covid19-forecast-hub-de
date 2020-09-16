# setwd("/home/johannes/Documents/COVID/covid19-forecast-hub-de/data-processed/ICM-agentModel")

Sys.setlocale("LC_ALL", "en_US.utf8") # Linux
# Sys.setlocale("LC_ALL","English") # Windows

file <- "2020-09-07-Poland-ICM-agentModel.csv"
ICM <- read.csv(file, stringsAsFactors = FALSE,
                colClasses = list("target_end_date" = "Date"))

subs_saturday_ICM <- subset(ICM, weekdays(target_end_date) == "Saturday" & grepl("cum", target))

subs_saturday_ICM$target <- gsub("5 day ahead", "1 wk ahead", subs_saturday_ICM$target)
subs_saturday_ICM$target <- gsub("12 day ahead", "2 wk ahead", subs_saturday_ICM$target)

ICM <- rbind(ICM, subs_saturday_ICM)
tail(ICM)

write.csv(ICM, "2020-09-07-Poland-ICM-agentModel.csv")
