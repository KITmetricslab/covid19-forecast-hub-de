#!/usr/bin/env bash
pip3 install pandas

cd ./code/auto_download

# update and process ECDC truth
python3 ./ecdc_download.py
sleep 5
python3 ./ecdc_preprocessing.py
echo "ECDC done"

# update and process jhu truth
python3 ./jhu_download.py
sleep 5
python3 ./jhu_preprocessing.py
echo "JHU done"

# update RKI data
python3 ./rki_update.py
echo "RKI done"

# update Shiny data
cd ../../app_forecasts_de/code
python3 ./data_preparation.py
echo "Shiny done"

# update Readme image
cd ../../code/visualization
Rscript ./plot_current_forecasts.R
echo "Image done"

cd ../../
