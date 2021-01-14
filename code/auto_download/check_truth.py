import sys
import glob
import pandas as pd
from slack_alerts import *

def check_file(filepath):
    filename = filepath.split('/')[-1]
    data_source = filename.split('-')[0][6:]
    link='https://github.com/KITmetricslab/covid19-forecast-hub-de/tree/master/data-truth/' + data_source + '/' + filename
    
    df = pd.read_csv(filepath)
    df = df[df.date == (pd.Timestamp('today') + pd.DateOffset(days=1)).strftime("%Y-%m-%d")]

    missing_locations = df.loc[df.value.isnull(), ['location', 'location_name']]
    
    if len(missing_locations) != 0:
        # create list of missing locations for the notification
        missing_locations = missing_locations.location + ': ' + missing_locations.location_name
        missing_locations = '\n'.join(['\t- ' + location for location in missing_locations])

        send_notification(title = data_source + ' Data', message='Check Failed: ' + filename, 
                          details='The following locations are missing: \n' + missing_locations, 
                          link=link, color='danger')

    else:
        send_notification(title = data_source + ' Data', message='Check Passed: ' + filename, 
                          details='Data for all locations available.', 
                          link=link, color='good')
        

list_of_files = glob.glob('../../data-truth/MZ/*.csv')

for f in list_of_files:
    check_file(f)
