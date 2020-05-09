# Author: Konstantin Görgen
# Date: Sat May 09 13:43:39 2020
# --------------
# Modification:
# Author:
# Date:
# --------------


##Process date from RKI to fit structure of deaths

rki_raw<-read.csv("RKI_COVID19.csv",stringsAsFactors = FALSE)
rki_raw$Meldedatum<-as.Date(rki_raw$Meldedatum)

#transform RKI deaths as in description: 
#https://www.arcgis.com/home/item.html?id=f10774f1c63e40168479a1feb6c7ca74

for (i in 1:dim(rki_raw)[1])
{
  if(rki_raw[i,"NeuerTodesfall"]==0 || rki_raw[i,"NeuerTodesfall"]==1)
  {
    temp_i<-rki_raw[i,"AnzahlTodesfall"]
  }
  
  rki_raw[i,"AnzahlTodesfall"]<-temp_i
}

rki_agg_death<-aggregate(rki_raw[,c(8,13)],list(rki_raw[,9]),sum)

rki_inc_death<-aggre