library(googlesheets4)
library(tidyr)
library(tidyverse)
gs4_find()

abbr_vois = c("PL83", "PL78", "PL77", "PL86", "PL74", "PL72", "PL82", "PL80",
              "PL75", "PL79", "PL73", "PL84", "PL81", "PL87", "PL85", "PL76",
              "PL")

# process new cases
new_cases <- read_sheet("1ierEhD6gcq51HAm433knjnVwey4ZE5DCnu1bW7PRG3E", 
           range = "Wzrost w województwach!8:24")

new_cases <- subset(new_cases, select = -c(SUMA))

new_cases <- new_cases %>%
                bind_rows(summarise_all(., funs(if(is.numeric(.)) sum(.) else "Poland"))) %>% 
                add_column(location = abbr_vois)

new_cases_long <- pivot_longer(new_cases, -c(Województwo, location), values_to="value", names_to="date")

new_cases_long <- new_cases_long %>% rename(location_name = Województwo)

new_cases_long_df <- as.data.frame(new_cases_long)
#shift dates to mach ECDC
new_cases_long_df$date <- as.Date(gsub(".", "/", paste(new_cases_long_df$date, "2020", sep="."), fixed = TRUE), format = "%d/%m/%y") + 1

new_cases_long_df$location_name <- gsub("ó", "o", new_cases_long_df$location_name)

write.csv(new_cases_long_df, "../../data-truth/MZ/truth_MZ-Incident Cases_Poland.csv", sep=",", row.names=FALSE)

# process cum cases
cum_cases <- read_sheet("1ierEhD6gcq51HAm433knjnVwey4ZE5DCnu1bW7PRG3E", 
                        range = "Wzrost w województwach!31:47")

cum_cases <- subset(cum_cases, select = -c(SUMA))

cum_cases <- cum_cases %>%
  bind_rows(summarise_all(., funs(if(is.numeric(.)) sum(.) else "Poland"))) %>% 
  add_column(location = abbr_vois)

cum_cases_long <- pivot_longer(cum_cases, -c(Województwo, location), values_to="value", names_to="date")

cum_cases_long <- cum_cases_long %>% rename(location_name = Województwo) 

cum_cases_long_df <- as.data.frame(cum_cases_long)
cum_cases_long_df$date <- as.Date(gsub(".", "/", paste(cum_cases_long_df$date, "2020", sep="."), fixed = TRUE), format = "%d/%m/%y") + 1

cum_cases_long_df$location_name <- gsub("ó", "o", cum_cases_long_df$location_name)

write.csv(cum_cases_long_df, "../../data-truth/MZ/truth_MZ-Cumulative Cases_Poland.csv", sep=",", row.names=FALSE)

# process new deaths
new_deaths <- read_sheet("1ierEhD6gcq51HAm433knjnVwey4ZE5DCnu1bW7PRG3E", 
                                      range = "Wzrost w województwach!51:67")

new_deaths <- subset(new_deaths, select = -c(SUMA))

new_deaths <- new_deaths %>%
  bind_rows(summarise_all(., funs(if(is.numeric(.)) sum(.) else "Poland"))) %>% 
  add_column(location = abbr_vois)

new_deaths_long <- pivot_longer(new_deaths, -c(Województwo, location), values_to="value", names_to="date")

new_deaths_long <- new_deaths_long %>% rename(location_name = Województwo) 

new_deaths_long_df <- as.data.frame(new_deaths_long)
new_deaths_long_df$date <- as.Date(gsub(".", "/", paste(new_deaths_long_df$date, "2020", sep="."), fixed = TRUE), format = "%d/%m/%y") + 1

new_deaths_long_df$location_name <- gsub("ó", "o", new_deaths_long_df$location_name)

write.csv(new_deaths_long_df, "../../data-truth/MZ/truth_MZ-Incident Deaths_Poland.csv", sep=",", row.names=FALSE)

# process cum deaths
cum_deaths <- read_sheet("1ierEhD6gcq51HAm433knjnVwey4ZE5DCnu1bW7PRG3E", 
                                      range = "Wzrost w województwach!71:87")

cum_deaths <- subset(cum_deaths, select = -c(SUMA))

cum_deaths <- cum_deaths %>%
  bind_rows(summarise_all(., funs(if(is.numeric(.)) sum(.) else "Poland"))) %>% 
  add_column(location = abbr_vois)

cum_deaths_long <- pivot_longer(cum_deaths, -c(Województwo, location), values_to="value", names_to="date")

cum_deaths_long <- cum_deaths_long %>% rename(location_name = Województwo) 

cum_deaths_long_df <- as.data.frame(cum_deaths_long)
cum_deaths_long_df$date <- as.Date(gsub(".", "/", paste(cum_deaths_long_df$date, "2020", sep="."), fixed = TRUE), format = "%d/%m/%y") + 1

cum_deaths_long_df$location_name <- gsub("ó", "o", cum_deaths_long_df$location_name)

write.csv(cum_deaths_long_df, "../../data-truth/MZ/truth_MZ-Cumulative Deaths_Poland.csv", sep=",", row.names=FALSE)
