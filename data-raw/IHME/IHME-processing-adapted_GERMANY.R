##File adapted from original project to fit Germany

## reformat IHME forecasts
# Run from data-raw/IHME
source("process_IHME_functions.R")

## list all files and read
filepaths <- list.files("./",pattern = "Hospitalization_all_locs.csv", recursive =TRUE,full.names = TRUE)
# file_processed_dates <- substr(basename(list.files("../../data-processed/IHME-CurveFit",
#                                                    pattern = ".csv", 
#                                                    recursive = TRUE,
#                                                    full.names = TRUE)),
#                                start = 1,
#                                stop  = 10)
# file_processed_dates <- file_processed_dates[-length(file_processed_dates)]

#date_offset = 3
# raw_file_dates <- substr(dirname(filepaths),
#                          start = date_offset +  1,
#                          stop  = date_offset + 10)
# 
# newfile_date <- setdiff(gsub("_", "-",raw_file_dates),file_processed_dates)

#if (length(newfile_date)) {
#  new_filepath <- filepaths[grepl(gsub("-", "_",newfile_date),filepaths)]
  for(i in 1:length(filepaths)){
    formatted_file <- make_qntl_dat(filepaths[i])
    
    # date <- gsub("_", "-",substr(dirname(new_filepath[i]),
    #                              start = date_offset +  1,
    #                              stop  = date_offset + 10))
    date<-get_date(filepaths[i])
    
    write_csv(formatted_file,
              path = paste0("../../data-processed/IHME-CurveFit/",
                            date,
                            "-Germany-IHME-CurveFit.csv"))
  }
#}
