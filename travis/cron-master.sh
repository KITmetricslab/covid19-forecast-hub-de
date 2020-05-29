#!/usr/bin/env bash

cd ./code/auto_download

# update and process ECDC truth
python3 ./ecdc_download.py
sleep 5
python3 ./ecdc_preprocessing.py

# update and process jhu truth
python3 ./jhu_download.py
sleep 5
python3 ./jhu_preprocessing.py

# update RKI data
python3 ./rki_download.py

cd ../../
