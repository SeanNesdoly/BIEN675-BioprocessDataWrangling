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
                           "lucullus_bioreactor_data.v1.xlsx",
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
View(head(bp_data, n = 100))
View(bp_data)

# Parse capacitance data, a latent variable for biomass, from spreadsheet 2
#   NOTE: In sheet1, we also have two variables from the capacitance probe (sheet2):
#       bp_data (sheet1)   | cap_data (sheet2)
#       -------------------------------------
#       `f_capacitance`    = `Biomass`
#       `f_conductivity`   = `Conductivity`
cap_data <- read_xlsx(DATA_FILEPATH,
                      sheet = 2)

# Explore capacitance data!
print(cap_data, n = 10)
glimpse(cap_data)
View(head(cap_data, n = 100))
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
# Convert `Timestamp` in bp_data, formatted as 'dd-mm-yyyy hh:mm:ss', to ISO
# 8601 format ('yyyy-mm-dd hh:mm:ss'). This makes it easier to compare datasets.
bp_data <- bp_data %>%
               mutate(datetime = parse_date_time(Timestamp,
                                                 "d-m-Y H:M:S",
                                                 tz = Sys.timezone()),
                      .before = Timestamp) %>%
               select(-Timestamp) # remove old timestamp column

#-------------------------------------------------------------------------------
# Explore plotting of core bioprocess variables
bp_data %>%
    ggplot(aes(x = datetime)) +
        geom_line(aes(y = m_ph,      colour = "m_ph")) +
        geom_line(aes(y = m_stirrer, colour = "m_stirrer")) +
        geom_line(aes(y = m_temp,    colour = "m_temp")) +
        scale_colour_manual("", values = c("m_ph"     = "green",
                                           "m_stirrer"= "brown",
                                           "m_temp"   = "red")) + ylab("") +
        scale_x_datetime(date_labels = "%dT%H:%M:%S",
                         date_breaks = "4 hour") +
        theme_linedraw() +
        theme(axis.text.x = element_text(angle = 45, hjust=1))

# Fill in missing values for measurement process variables (prefix "m_")
# @TODO: Can you think of another solution to deal with missing values?
bp_data %>%
    fill(starts_with("m_", ignore.case = FALSE), .direction = "downup") %>%
    ggplot(aes(x = datetime)) +
        geom_line(aes(y = m_ph,      colour = "m_ph")) +
        geom_line(aes(y = m_stirrer, colour = "m_stirrer")) +
        geom_line(aes(y = m_temp,    colour = "m_temp")) +
        scale_colour_manual("", values = c("m_ph"     = "green",
                                           "m_stirrer"= "brown",
                                           "m_temp"   = "red")) + ylab("") +
        scale_x_datetime(date_labels = "%dT%H:%M:%S",
                         date_breaks = "4 hour") +
        theme_linedraw() +
        theme(axis.text.x = element_text(angle = 45, hjust=1))

# Fill in missing values for:
#     Measurement variables  (prefix "m_")
#     Biomass variables      (prefix "f_")
#     Dose monitor variables (prefix "dm_")
#
# For all filled-in process variables, we are making the assumption that the
# biology does not change. This is important to keep in mind when making
# conclusions!
bp_data_filled <- bp_data %>%
                      fill(starts_with("m_", ignore.case = FALSE), .direction = "downup") %>%
                      fill(starts_with("dm_"), .direction = "downup")

# Create new time-series plot with 'filled-in' dataset
bp_data_filled %>%
    ggplot(aes(x = datetime)) +
        geom_line(aes(y = m_ph,      colour = "m_ph")) +
        geom_line(aes(y = m_stirrer, colour = "m_stirrer")) +
        geom_line(aes(y = m_temp,    colour = "m_temp")) +
        scale_colour_manual("", values = c("m_ph"     = "green",
                                           "m_stirrer"= "brown",
                                           "m_temp"   = "red")) + ylab("") +
        scale_x_datetime(date_labels = "%dT%H:%M:%S", date_breaks = "4 hour") +
        theme_linedraw() +
        theme(axis.text.x = element_text(angle = 45, hjust=1))

