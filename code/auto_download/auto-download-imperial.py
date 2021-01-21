## Auto-download forecasts of Imperial-Team
## Jakob Ketterer
## January 2021

import os
import urllib.request
from datetime import datetime, timedelta

import rpy2.robjects as robjects
from rpy2.robjects import pandas2ri
pandas2ri.activate()
readRDS = robjects.r['readRDS']
names = robjects.r['names']

if __name__ == "__main__":


    ############ logic to determine which files shall be downloaded

    data_raw_dir = "./data-raw/Imperial/"
    files = os.listdir(data_raw_dir)
    DATE_FORMAT = "%Y-%m-%d"
    prefix = "ensemble_model_predictions_"
    
    file_list = sorted([f for f in files if f.startswith(prefix)], reverse=True)
    
    if file_list:
        date_str_list = [file_list[i].replace(prefix, "").strip(".rds") for i in range(len(file_list))]
        date_list = [datetime.strptime(date_str_list[i], DATE_FORMAT) for i in range(len(date_str_list))]    
    else:
        raise Exception(f"No forecasts of given format in {data_raw_dir} yet, set latest_fc_date manually!")
    
    # define start combination of version numbers and forecast dates
    start_version = 31
    start_fc_date = datetime.strptime("2020-12-27", DATE_FORMAT)

    # get latest combination of version numbers and forecast dates already present in our repo
    latest_fc_date = date_list[0]
    latest_fc_version = start_version + sum(1 for date in date_list if date > start_fc_date)

    ############################################
    # VERSION A: only consider next release and fail if not available
    ############################################

    # next version info
    next_version = latest_fc_version + 1
    print(f"Trying to download forecasts for the following release: v{next_version}")

    # url
    root = "https://github.com/mrc-ide/covid19-forecasts-orderly/releases/download/"
    url = root + "v" + str(next_version) + "/ensemble_model_predictions.rds"

    placeholder_name = data_raw_dir + "ensemble_model_predictions.rds"

    # download and save file
    urllib.request.urlretrieve(url, placeholder_name)
    # open forecast file
    df = readRDS(placeholder_name)
    # extract date
    extracted_date = names(df)[0]
    # replace placeholder name with final name containing forecast date
    final_name = data_raw_dir + "ensemble_model_predictions_" + extracted_date + ".rds"
    os.rename(placeholder_name, final_name)
    print(f"Downloaded forecast from Release: v{next_version}, Date: {extracted_date} and saved it to", final_name)
    
    ############################################
    # VERSION B: consider all releases between latest_fc and now and fail if none is available
    ############################################
    
    ## calculate next expected release versions based on time between latest fc date and today
    
    # # define date up to forecasts shall be downloaded
    # download_up_to_date = datetime.today()
    # print(download_up_to_date, latest_fc_date)
    # assert download_up_to_date > latest_fc_date, "Required forecasts already exists in the repo!"
    
    # # generate list of dates to download
    # next_dates_list = [latest_fc_date + timedelta(days=x) for x in range(1, (download_up_to_date-latest_fc_date).days+1)]
    
    # # restrict dates (Imperial forecasts are usually submitted once a week, mostly on Sundays)
    # next_dates_list = [date for date in next_dates_list if date.weekday() == 6]
    # next_versions = [latest_fc_version+i+1 for i in range(len(next_dates_list))]
    # print("Trying to download forecasts for the following date-release pairs: ", [f"{str(next_dates_list[i].date())} (v{next_versions[i]})" for i in range(len(next_dates_list))])

    # ## url generation and download of files
    # root = "https://github.com/mrc-ide/covid19-forecasts-orderly/releases/download/"

    # urls = [root + "v" + str(version) + "/ensemble_model_predictions.rds" for version in next_versions]
    # file_names = ["ensemble_model_predictions_" + date.strftime(DATE_FORMAT) + ".rds" for date in next_dates_list]
    # dir_names = [os.path.join(data_raw_dir, name) for name in file_names]

    # placeholder_name = data_raw_dir + "ensemble_model_predictions.rds"
    # success_counter = 0
    # for url, date, v in zip(urls, next_dates_list, next_versions):
    #     try:
    #         # download and save file
    #         urllib.request.urlretrieve(url, placeholder_name)
    #         # open forecast file
    #         df = readRDS(placeholder_name)
    #         # extract date
    #         extracted_date = names(df)[0]
    #         # replace placeholder name with final name containing forecast date
    #         final_name = data_raw_dir + "ensemble_model_predictions_" + extracted_date + ".rds"
    #         os.rename(placeholder_name, final_name)
    #         print(f"Downloaded forecast from Release: v{v}, Date: {extracted_date} and saved it to", final_name)
    #         success_counter += 1
            
    #     # except for the case that not all expected releases / 
    #     except urllib.error.URLError as e:
    #         print(f"URL-ERROR: Download failed for Release v{v}, expected Date {date.date()}. The release probably doesn't exist in the repo.")

    # # raise Exception if no forecasts are available
    # if success_counter == 0:
    #     raise Exception(f"Download failed for all releases (versions {next_versions}). The expected releases probably don't exist in the repo yet.")