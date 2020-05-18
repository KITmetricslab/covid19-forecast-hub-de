# Author: Konstantin G?rgen
# Date: Sat May 09 14:34:39 2020
# --------------
# Modification:
# Author:
# Date:
# --------------


##Script to Process Raw Deaths File from Johns Hopkins University

jhu_raw<-read.csv("time_series_covid19_deaths_global.csv",stringsAsFactors = FALSE)
jhu_germany<-jhu_raw[jhu_raw$Country.Region=="Germany",]
dates<-seq(as.Date("2020-01-22"),as.Date("2020-05-08"),by="days")
jhu_truth_germany_cum<-data.frame(date=dates,location=rep("GM",length(dates)),
                        location_name=rep("Germany",length(dates)),
                        value=as.numeric(t(jhu_germany[1,-c(1:4)])))
inc_deaths<-diff(jhu_truth_germany_cum$value,lag=1)

jhu_truth_germany_inc<-jhu_truth_germany_cum
jhu_truth_germany_inc$value<-c(0,inc_deaths)

write.csv(jhu_truth_germany_cum,file="truth_JHU-Cumulative Deaths_Germany.csv",row.names=FALSE)
write.csv(jhu_truth_germany_inc,file="truth_JHU-Incident Deaths_Germany.csv",row.names=FALSE)
