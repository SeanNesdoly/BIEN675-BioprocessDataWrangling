#-------------------------------------------------------------------------------
# Bioprocess Data Wrangling
# Week 12: Process Data Management, Storage, and Security
# BIEN675: Process Analytical Technologies and Data Sciences, Winter 2023
#
# Sean Nesdoly
# Viral Vectors and Vaccines Bioprocessing Group
# https://amine-kamen.lab.mcgill.ca/
# Department of Bioengineering
# McGill University, Montréal QC
# 2023-03-28
#-------------------------------------------------------------------------------

# install.packages("tidyverse") # @TODO: uncomment & run if not yet installed!
library(tidyverse)
library(readxl)

# Set working directory to location of 'BIEN675-BioprocessDataWrangling' git
# repository. @TODO: Change filepath for your machine!
REPO_FILEPATH <- file.path(path.expand("~"),
                           "Downloads",
                           "BIEN675-BioprocessDataWrangling-master",
                           fsep = .Platform$file.sep)
setwd(REPO_FILEPATH)
getwd()

#-------------------------------------------------------------------------------
# readxl: Read Excel spreadsheets (*.xls, *.xlsx)
#-------------------------------------------------------------------------------
# Define filepath to bioprocess dataset
DATA_FILEPATH <- file.path("data",
                           "lucullus_bioreactor_data.xlsx",
                           fsep = .Platform$file.sep)

# List sheets contained in spreadsheet
readxl::excel_sheets(DATA_FILEPATH)

# Peak at bioprocess data from spreadsheet 1
View(readxl::read_xlsx(DATA_FILEPATH,
                       sheet = 1,
                       n_max = 100))

# Extract bioprocess variable metadata
bp_metadata <- read_xlsx(DATA_FILEPATH,
                         sheet = 1,
                         col_names = FALSE,
                         n_max = 6) %>%
                   t() %>%
                   as_tibble() %>%
                   rename(c("ProcessVariable"=V1, "Unit"=V2, "DeviceType"=V3,
                            "Device"=V4, "Reactor"=V5, "ProcessName"=V6))

# Parse bioprocess data from spreadsheet 1
bp_data <- read_xlsx(DATA_FILEPATH,
                     sheet = 1,
                     skip = 6,
                     col_names = bp_metadata$ProcessVariable,
                     guess_max = as.integer(.Machine$integer.max / 100))

# Explore bioprocess data!
print(bp_data, n = 10)
glimpse(bp_data)
View(head(bp_data, n = 50))
View(bp_data)

# Parse capacitance data, a latent variable for biomass, from spreadsheet 2
cap_data <- read_xlsx(DATA_FILEPATH,
                      sheet = 2)

# Explore capacitance data!
print(cap_data, n = 10)
glimpse(cap_data)
View(head(cap_data, n = 50))
View(cap_data)

#-------------------------------------------------------------------------------
# Date and time formats differ between and within sheets:
#     bp_data (sheet1)
#         `Time`        : h.hhhhhhhhhhhhhhh   (fractional hours)
#         `Timestamp`   : dd-mm-yyyy hh:mm:ss
#     cap_data (sheet2)
#         `Time & Date` : yyyy-mm-dd hh:mm:ss
#
# Note on fractional hours: Excel interprets dates as fractional days; Lucullus
# uses fractional hours. To convert to fractional days from fractional hours:
#     time_excel = time_luc * 60 * (1 hour / 60 min) * (1 day / 24 hour)
#-------------------------------------------------------------------------------
# Convert `Timestamp` in bp_data to ISO 8601 format ('yyyy-mm-dd hh:mm:ss').
# This makes it easier to compare datasets.
parse_timestamp <- function(datetime_str) {
    # Parse 'dd-mm-yyyy hh:mm:ss'
    splits <- unlist(str_split(datetime_str, "[- :]"))
    lubridate::make_datetime(year  = as.integer(splits[3]),
                             month = as.integer(splits[2]),
                             day   = as.integer(splits[1]),
                             hour  = as.integer(splits[4]),
                             min   = as.integer(splits[5]),
                             sec   = as.integer(splits[6]),
                             tz    = Sys.timezone()
    )
}

bp_data <- bp_data %>%
               mutate(datetime = purrr::map_vec(Timestamp, parse_timestamp),
                      .before = Timestamp) %>%
               select(-Timestamp) # remove old timestamp column
