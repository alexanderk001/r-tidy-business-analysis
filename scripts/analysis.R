# Load libraries
library(tidyverse)
library(rstudioapi)

# Set path to data folder
current_dir <- getwd()
data_dir <- file.path(dirname(current_dir), "data")

# Helper function to read and trim whitespace from character columns
read_and_trim <- function(file) {
  read_csv(file) |> mutate(across(where(is.character), str_trim))
}

# Load data
states <- read_and_trim(file.path(data_dir, "us_states.csv"))
revenues <- read_and_trim(file.path(data_dir, "revenues.csv"))
cities <- read_and_trim(file.path(data_dir, "us_cities.csv"))
employers <- read_and_trim(file.path(data_dir, "employers.csv"))
shootings <- read_and_trim(file.path(data_dir, "mass_shootings_2022.csv"))
marketCap <- read_and_trim(file.path(data_dir, "companies_mc.csv"))


# 1. Convert market_cap to numeric billions
to_billion <- function(x) {
  x <- ifelse(str_detect(x, "T"), as.numeric(str_remove_all(x, "[^0-9\\.]")) * 1000, x)
  x <- ifelse(str_detect(x, "B"), as.numeric(str_remove_all(x, "[^0-9\\.]")), x)
  
  return(as.numeric(x))
}

marketCap <- marketCap |> mutate(market_cap = to_billion(market_cap))


# 2. Convert rev_change to numeric factor
to_factor <- function(x) {
    x <- ifelse(str_detect(x, "Increase"), 1 + as.numeric(str_remove_all(x,"Increase\\s*|[%]")) / 100, x)
    x <- ifelse(str_detect(x, "Decrease"), 1 - as.numeric(str_remove_all(x, "Decrease\\s*|[%]")) / 100, x)
    
    return(as.numeric(x))
}

revenues <- revenues |> mutate(rev_change = to_factor(rev_change))


# 3. Calculate revenue_2020 and ranks
revenues <- revenues |>
  mutate(revenue_2020 = revenue_2021 / rev_change, .before = "revenue_2021") |>
  mutate(rank_2020 = as.integer(rank(-revenue_2020)),  # notice '-' or desc()
         rank_2021 = as.integer(rank(-revenue_2021)),
         rank_change = as.integer(rank_2020 - rank_2021),
         .before = "headquarter")

cc_g <- revenues$company[which.max(revenues$rank_change)]
pp_g <- max(revenues$rank_change)
cc_l <- revenues$company[which.min(revenues$rank_change)]
pp_l <- min(revenues$rank_change)

message(str_glue("In the ranking, {cc_g} has climbed the furthest with {pp_g} places.\n",
                 "{cc_l} has fallen the furthest with {pp_l} places."))


# 4. Split headquarter into city and state
revenues <- revenues |>
  separate_wider_delim(headquarter, names = c("hq_city", "hq_state"), delim = ", ")


# 5. Join revenues and states to count firms in state capitals
num_firms_in_capitals <- inner_join(revenues, states, by = join_by(hq_state == name)) |>
  select(hq_state, hq_city, capital) |>
  filter(hq_city == capital) |>
  nrow()

message("Number of top revenue firms located in state capitals: ", num_firms_in_capitals)


# 6. Revenue per employee and sector productivity
rev_per_employee <- employers |>
  left_join(revenues, by = join_by(employer == company)) |>
  select(employer, employees, sector, revenue_2021) |>
  mutate(per_cap_rev = (revenue_2021 / employees) * 1e6)

# Replace NA per_cap_rev by half of min per_cap_rev (excluding NAs)
min_rev <- min(rev_per_employee$per_cap_rev, na.rm = TRUE)
rev_per_employee <- rev_per_employee |>
  mutate(per_cap_rev = replace_na(per_cap_rev, min_rev / 2))

# Calculate mean productivity per sector excluding artificial NAs
sector_productivity <- rev_per_employee |>
  filter(!is.na(revenue_2021)) |>
  group_by(sector) |>
  summarize(meanProductivity = mean(per_cap_rev, na.rm = TRUE)) |>
  arrange(desc(meanProductivity))

print(sector_productivity)


# 7. Join states and cities, find capitals among top 300 cities by population
largeCapitals <- inner_join(states, cities, by = join_by(name == state, capital == city)) |>
  select(name, capital, Estim_2021) |>
  arrange(Estim_2021)

message("Number of capitals among top 300 cities: ", nrow(largeCapitals))


# 8. Mass shootings deaths per capita by state
shooting_stats <- inner_join(shootings, states[c("name", "population")], by = join_by(State == name)) |>
  group_by(State) |>
  summarize(deaths_total = sum(`# Killed`),
            per_cap_deaths = sum(`# Killed`) / mean(population)) |>
  arrange(desc(per_cap_deaths))

print(shooting_stats, n = 50)
