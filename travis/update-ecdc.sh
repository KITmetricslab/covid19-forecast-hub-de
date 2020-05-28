#!/usr/bin/env bash

cd ./code/auto_download

# update ECDC truth
python3 ./ecdc_download.py

# process ECDC data
python3 ./ecdc_preprocessing.py

cd ../../
