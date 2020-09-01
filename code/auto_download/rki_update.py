import os
import glob
import pandas as pd

# Load latest file 
list_of_files = glob.glob('../../data-truth/RKI/raw/*')
latest_file = max(list_of_files, key=os.path.getctime)

df = pd.read_csv(latest_file, compression='gzip')

# Add column 'DatenstandISO'
# if 'DatenstandISO' not in df.columns:
#     df['DatenstandISO'] = pd.to_datetime(df.Datenstand.str.replace('Uhr', ''), dayfirst=True).astype(str)
df['DatenstandISO'] = str((pd.to_datetime('today') - pd.Timedelta('1 days')).date())
    
for target in ['Deaths', 'Cases']:
    print('Extracting data for cumulative {}.'.format(target.lower()))
    
    # Aggregation on state level (Bundesländer)
    if target == 'Deaths':
        # compute the sum for each date within each state
        df_agg = df[df.NeuerTodesfall >= 0].groupby(['DatenstandISO', 'Bundesland'])['AnzahlTodesfall'].sum().reset_index()
        df_agg.rename(columns = {'AnzahlTodesfall': 'value'}, inplace=True)
        
    else:
        # compute the sum for each date within each state
        df_agg = df[df.NeuerFall >= 0].groupby(['DatenstandISO', 'Bundesland'])['AnzahlFall'].sum().reset_index()
        df_agg.rename(columns = {'AnzahlFall': 'value'}, inplace=True)

    ### Add FIPS region codes - given by https://en.wikipedia.org/wiki/List_of_FIPS_region_codes_(G–I)#GM:_Germany.

    state_names = ['Baden-Württemberg', 'Bayern', 'Bremen', 'Hamburg', 'Hessen', 'Niedersachsen', 'Nordrhein-Westfalen', 'Rheinland-Pfalz',
    'Saarland', 'Schleswig-Holstein', 'Brandenburg', 'Mecklenburg-Vorpommern', 'Sachsen', 'Sachsen-Anhalt', 'Thüringen', 'Berlin']
    gm = ['GM0' + str(i) for i in range(1, 10)] + ['GM' + str(i) for i in range(10, 17)] 

    fips_codes = pd.DataFrame({'Bundesland':state_names, 'location':gm})

    # add fips codes to dataframe with aggregated data
    df_agg = df_agg.merge(fips_codes, left_on='Bundesland', right_on='Bundesland')

    ### Change location_name to English names

    fips_english = pd.read_csv('../../template/base_germany.csv')
    df_agg = df_agg.merge(fips_english, left_on='location', right_on='V1')

    ### Rename columns and sort by date and location
    df_agg = df_agg.rename(columns={'DatenstandISO': 'date', 'V2':'location_name'})[
        ['date', 'location', 'location_name', 'value']].sort_values(['date', 'location']).reset_index(drop=True)

    df_germany = df_agg.groupby('date')['value'].sum().reset_index()
    df_germany['location'] = 'GM'
    df_germany['location_name'] = 'Germany'

    # add data for Germany to dataframe with states
    df_cum = pd.concat([df_agg, df_germany]).sort_values(['date', 'location']).reset_index(drop=True)

    # save as csv
    #current_date = pd.to_datetime('today').date()
    
    if target == 'Deaths':
        df_cum.to_csv('../../data-truth/RKI/processed/' + df_cum.date[0] + '_RKI_processed.csv', index=False)

    # Load Current Dataframe
    df_all = pd.read_csv('../../data-truth/RKI/truth_RKI-Cumulative {}_Germany.csv'.format(target))

    # Add New Dataframe
    df_cum = pd.concat([df_all, df_cum])
    df_cum.reset_index(drop=True, inplace=True)

    # Drop duplicates - in case we accidentally load the same file twice.
    df_cum.drop_duplicates(subset=['date', 'location'], keep='last', inplace=True)

    # Incidence
    print('Extracting data for incident {}.'.format(target.lower()))

    df_inc = df_cum.copy()

    df_inc.value = df_inc.groupby(['location'])['value'].diff()
    df_inc.dropna(inplace=True)
    df_inc.value = df_inc.value.astype(int)

    ### Export Cum. Deaths
    df_cum.to_csv('../../data-truth/RKI/truth_RKI-Cumulative {}_Germany.csv'.format(target), index=False)

    ### Export Inc. Deaths
    df_inc.to_csv('../../data-truth/RKI/truth_RKI-Incident {}_Germany.csv'.format(target), index=False)
