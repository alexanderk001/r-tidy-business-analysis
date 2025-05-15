# 🔎 US Business Data Analysis

This repository contains an R-based data analysis project exploring real-world datasets about US companies, revenues, market capitalizations, locations, and social statistics. The analysis was developed as part of a programming course at university.

## 📊 Objectives

The main goals of this project were:

- Load and clean multiple datasets using the `tidyverse`.
- Convert unstructured fields (e.g. revenue change percentages, market caps) into numerical formats.
- Calculate company revenue ranks over time and identify movers and losers.
- Explore geographic patterns of company headquarters and match them to state capitals.
- Join employer and revenue data to estimate per-employee revenue and productivity by sector.
- Investigate relationships between state-level population and public incidents.

## 🗃️ Dataset Sources

The project works with several CSV datasets, including:

- `revenues.csv`: company revenue data (2020 and 2021)
- `us_states.csv`: state-level demographic information
- `us_cities.csv`: city-level population estimates
- `employers.csv`: company names and employee counts
- `mass_shootings_2022.csv`: incident-level data for 2022
- `companies_mc.csv`: market capitalizations

## 📦 Libraries and Tools

- R (version 4.x)
- tidyverse (dplyr, tidyr, stringr, readr)
- rstudioapi (for script-path handling)

## 🛫 Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/alexanderk001/r-tidy-business-analysis.git
   cd r-tidy-business-analysis
   ```

2. Open RStudio in this folder.

3. Make sure the CSV files are in the `data/` folder.

3. **Run the analysis**:
   ```R
   source("scripts/analysis.R")
   ```

## 📄 License

This project is licensed under the [MIT License](LICENSE).
