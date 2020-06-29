# Author: Konstantin Görgen
# Date: Sat May 09 13:43:39 2020
# --------------
# Modification:
# Author:
# Date:
# --------------

#Run from source location

##Process date from RKI to fit structure of deaths

rki_raw<-read.csv("RKI_COVID19.csv",stringsAsFactors = FALSE)
rki_raw$Meldedatum<-as.Date(rki_raw$Meldedatum)

#transform RKI deaths as in description: 
#https://www.arcgis.com/home/item.html?id=f10774f1c63e40168479a1feb6c7ca74

#data is on individual level and deaths are coded with respect to 
#previous days and dates:

#AnzahlTodesfall: Anzahl der Todesfälle in der entsprechenden Gruppe

#NeuerTodesfall:
#0: Fall ist in der Publikation für den aktuellen Tag und in der für den Vortag
#jeweils ein Todesfall

#1: Fall ist in der aktuellen Publikation ein Todesfall, nicht jedoch in der
#Publikation des Vortages

#-1: Fall ist in der aktuellen Publikation kein Todesfall, jedoch war er in der
#Publikation des Vortags ein Todesfall

#-9: Fall ist weder in der aktuellen Publikation noch in der des Vortages ein 
#Todesfall

#damit ergibt sich: Anzahl Todesfälle der aktuellen Publikation als 
#Summe(AnzahlTodesfall) wenn NeuerTodesfall in (0,1); Delta zum Vortag als 
#Summe(AnzahlTodesfall) wenn NeuerTodesfall in (-1,1)


rki_deaths<-rki_raw[,c("Meldedatum","AnzahlTodesfall","NeuerTodesfall")]

#Look whether new deaths is positive
#add up deahts in these columns
#clean up data

rki_inc_deaths<-rki_deaths %>% 
  #only take true deaths and not false reports
  mutate(death_true=ifelse(NeuerTodesfall<0,0,AnzahlTodesfall)) %>%
  #group by date for all of Germany
  group_by(Meldedatum) %>%
  #sum up for each date
  summarise(deaths=sum(death_true)) %>%
  #complete date column for days where no case occured
  complete(Meldedatum=seq.Date(min(Meldedatum),max(Meldedatum),by="day")) %>%
  #put in death count of 0 if no new death (i.e. NA) and create needed columns
  mutate(value=ifelse(is.na(deaths),0,deaths),location="GM",location_name="Germany") %>%
  #rename date
  rename(date=Meldedatum) %>%
  #select and order only needed columns
  select(date,location,location_name,value)

rki_cum_deaths<-rki_inc_deaths %>% mutate(value=cumsum(value))
 
write.csv(rki_cum_deaths,"truth_RKI-Cumulative Deaths_Germany.csv",row.names = FALSE)
write.csv(rki_inc_deaths,"truth_RKI-Incident Deaths_Germany.csv",row.names = FALSE)

