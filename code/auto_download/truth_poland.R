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
                bind_rows(summarise_all(., funs(if(is.numeric(.)) sum(.) else "Polsce"))) %>% 
                add_column(location = abbr_vois)

new_cases_long <- pivot_longer(new_cases, -c(Województwo, location), values_to="value", names_to="date")

write.table(new_cases_long, "../../data-truth/POLAND/truth-Incident Cases_Germany.csv")

# process cum cases
cum_cases <- read_sheet("1ierEhD6gcq51HAm433knjnVwey4ZE5DCnu1bW7PRG3E", 
                        range = "Wzrost w województwach!31:47")

cum_cases <- cum_cases %>%
  bind_rows(summarise_all(., funs(if(is.numeric(.)) sum(.) else "Polsce"))) %>% 
  add_column(location = abbr_vois)

cum_cases_long <- pivot_longer(cum_cases, -c(Województwo, location), values_to="value", names_to="date")

write.table(cum_cases_long, "../../data-truth/POLAND/truth-Cumulative Cases_Germany.csv")

# process new deaths
new_deaths <- read_sheet("1ierEhD6gcq51HAm433knjnVwey4ZE5DCnu1bW7PRG3E", 
                                      range = "Wzrost w województwach!51:67")

new_deaths <- new_deaths %>%
  bind_rows(summarise_all(., funs(if(is.numeric(.)) sum(.) else "Polsce"))) %>% 
  add_column(location = abbr_vois)

new_deaths_long <- pivot_longer(new_deaths, -c(Województwo, location), values_to="value", names_to="date")

write.table(new_deaths_long, "../../data-truth/POLAND/truth-Incident Deaths_Germany.csv")

# process cum deaths
cum_deaths <- read_sheet("1ierEhD6gcq51HAm433knjnVwey4ZE5DCnu1bW7PRG3E", 
                                      range = "Wzrost w województwach!51:67")

cum_deaths <- cum_deaths %>%
  bind_rows(summarise_all(., funs(if(is.numeric(.)) sum(.) else "Polsce"))) %>% 
  add_column(location = abbr_vois)

cum_deaths_long <- pivot_longer(cum_deaths, -c(Województwo, location), values_to="value", names_to="date")

write.table(new_deaths_long, "../../data-truth/POLAND/truth-Cumulative Deaths_Germany.csv")
