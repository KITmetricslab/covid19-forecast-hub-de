# -*- coding: utf-8 -*-
"""
Created on Wed Jun 24 18:29:53 2020

@author: Jannik
"""

import os
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
from webdriver_manager.chrome import ChromeDriverManager
from pathlib import Path

path = str(Path.cwd().parent.parent.joinpath("data-truth", "DIVI", "raw"))


url = "https://www.divi.de/divi-intensivregister-tagesreport-archiv-2/divi-intensivregister-tagesreports-csv"
options = webdriver.ChromeOptions()
prefs = {'download.default_directory': path}
options.add_argument('--no-sandbox')
options.add_argument('--headless')
options.add_argument('--disable-dev-shm-usage')
options.add_argument('--disable-gpu')
options.add_experimental_option('prefs', prefs)
driver = webdriver.Chrome(ChromeDriverManager().install(),
                              chrome_options=options)
driver.get(url)

pagination = driver.find_element_by_css_selector("ul.pagination")
pages = pagination.find_elements(By.TAG_NAME, "li")

page_links = ["https://www.divi.de/divi-intensivregister-tagesreport-archiv-2/divi-intensivregister-tagesreports-csv"]

for page in pages[1:]:
    ele = page.find_elements(By.TAG_NAME, "a")[0]
    name = ele.text
    if name.isdigit():
        link = ele.get_attribute('href')
        if link:
            page_links.append(link)

csv_links = []

for link in page_links:

    driver.get(link)

    csv_table = driver.find_element_by_css_selector("div#edocman-documents.span12")
    csvs = csv_table.find_elements(By.CLASS_NAME, "edocman-document-title-link")

    for csv_link in csvs:
        csv_links.append(csv_link.get_attribute('href'))

for link in csv_links:
    base_name = link.split('/')[-1][:-6]
    base_name = base_name.replace("divi", "DIVI")

    # first naming convention (since 06.05)
    first_name = list(base_name)
    first_name[5] = "I"
    first_name[-11] = "_"
    first_name = "".join(first_name)

    # second naming convention
    second_name = list(base_name)
    second_name[4] = "_"
    second_name[5] = "I"
    second_name[-11] = "_"
    second_name = "".join(second_name)

    # list of files
    csv_files = [f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f))]

    flag_1 = any(first_name in x for x in csv_files)
    flag_2 = any(second_name in x for x in csv_files)

    if flag_1 or flag_2:
        print("done")
        continue
    else:
        download_link = link.split('/')
        del download_link[-2]
        final_link = ""
        for s in download_link:
            final_link = final_link + s + "/"
        final_link = final_link[:-1]
        print(final_link)
        print(name)
        #driver.get(final_link + "/download")
        #time.sleep(3)
