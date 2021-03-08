# Author: Konstantin Görgen
# Date: Sat May 09 12:14:22 2020
# --------------
# Modification: Added Forecast for Poland
# Author: Konstantin Görgen
# Date: 30.07.2020
# --------------

##File to read in Imperial Forecasts
source("Imperial-processing_Germany.R")

#only process latest?
latest<-TRUE

#make sure your wd is in the same folder as the file that was sourced,
#i.e. in data-raw/Imperial

#Do you want forecasts for Poland?
pol<-TRUE

#read in file paths and delete those without Germany in them
filepaths <- list.files(pattern = "ensemble_model_predictions", recursive =TRUE,full.names = TRUE)

#only take those where Germany was reported
reported_countries<-list()
germany_reported<-rep(NA,length(filepaths))

for(i in 1:length(filepaths))
{
  reported_countries[[i]]<-names(readRDS(filepaths[i])[[1]])
  if(pol)
  {
    germany_reported[i]<-sum(reported_countries[[i]]=="Germany"|reported_countries[[i]]=="Poland")>0
    
  } else {
    
    germany_reported[i]<-as.logical(sum(reported_countries[[i]]=="Germany"))
  }
  

}
filepaths<-filepaths[germany_reported]

#write final files
#test if newest date is good, otherwise change name of file
#test<-readRDS(filepaths[length(filepaths)])
#date_name<-get_date(filepaths[length(filepaths)])
#date_actual<-names(test)

#Only process latest forecast file?
if(latest)
{
filepaths<-tail(filepaths,1)
}

for(i in 1:length(filepaths)){
  formatted_file_1 <- format_imperial(path=filepaths[i],ens_model=1,poland=pol)
  formatted_file_2 <- format_imperial(path=filepaths[i],ens_model=2,poland=pol)

  date<-get_date(filepaths[i])
  
  write_csv(formatted_file_1[[1]],
            path = paste0("../../data-processed/Imperial-ensemble1/",
                          date,
                          "-Germany-Imperial-ensemble1.csv"))
  write_csv(formatted_file_2[[1]],
            path = paste0("../../data-processed/Imperial-ensemble2/",
                          date,
                          "-Germany-Imperial-ensemble2.csv"))
  #same for poland if there
  if(pol)
  {
    if(!is.na(formatted_file_1[[2]]))
    {
      write_csv(formatted_file_1[[2]],
                path = paste0("../../data-processed/Imperial-ensemble1/",
                              date,
                              "-Poland-Imperial-ensemble1.csv"))
    }
    
    if(!is.na(formatted_file_2[[2]]))
    {
      write_csv(formatted_file_2[[2]],
                path = paste0("../../data-processed/Imperial-ensemble2/",
                              date,
                              "-Poland-Imperial-ensemble2.csv"))
    }
    
  }
  
}

# Remarks on warnings/errors:

# Might get warning for is.na CALL, should be fine

# In case of "Error in sample_mat_cum[, which_weeks] : wrong number of dimensions",
# check if truth data is up to date!