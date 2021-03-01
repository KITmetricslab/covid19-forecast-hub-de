## Auto-download forecasts of IHME-Team
## Jakob Ketterer
## January 2021

## check if new forecasts were uploaded on IHME site 

# extract latest forecast date already in repo

# extract update date on IHME website

# check if new forecasts were uploaded

## download new forecasts

## unzip and relocate

# Before executing the script, we need urllib3. Run `pip install urllib3`
# A simple script for automatically download the ihme-covid19.zip file and extract it
import urllib3
import shutil
import zipfile
import os
import sys

def download_covid_zip_files(path):
    # metadata
    url = "https://ihmecovid19storage.blob.core.windows.net/latest/ihme-covid19.zip"
    # url = "https://ihmecovid19storage.blob.core.windows.net/archive/2021-02-20/ihme-covid19.zip"
    http = urllib3.PoolManager()
    name = 'ihme-covid19.zip'
    old_list = os.listdir(path)
    # Download the zip file from URL
    with http.request('GET', url, preload_content=False) as r, open(os.path.join(path, name), 'wb') as out_file:       
        shutil.copyfileobj(r, out_file)
    r.release_conn()

    # Extract the zip file
    with zipfile.ZipFile(os.path.join(path, name), 'r') as zip_ref:
        zip_ref.extractall(path)

    # Remove the zip file
    if os.path.exists(os.path.join(path, name)):
        os.remove(os.path.join(path, name))
    new_list = os.listdir(path)


if __name__ == '__main__':
    path = "./data-raw/IHME"
    download_covid_zip_files(path)

