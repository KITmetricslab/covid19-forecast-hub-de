#!/usr/bin/env bash

cd ./code/auto_download

# update ECDC truth
python3 ./ecdc_download.py

sleep 10

# process ECDC data
python3 ./ecdc_preprocessing.py

cd ../../
