#-------------------------------------------------------------------------------
# Bioprocess Data Wrangling
# BIEN675: Process Analytical Technologies and Data Sciences, Fall 2023
#
# Sean Nesdoly
# Viral Vectors and Vaccines Bioprocessing Group
# https://amine-kamen.lab.mcgill.ca/
# Department of Bioengineering
# McGill University, Montréal QC
# 2023-11-21
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
View(readxl::read_xlsx(DATA_FILEPATH, sheet = 1, n_max = 100))

# Extract bioprocess variable metadata
bp_metadata <- read_xlsx(DATA_FILEPATH,
                         sheet = 1,
                         col_names = FALSE,
                         n_max = 6) %>%
                   t() %>% # transpose data frame (rows become columns & vice versa)
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
#   NOTE: In sheet1, we also have two variables from the capacitance probe:
#       bp_data (sheet1)   | cap_data (sheet2)
#       -------------------------------------
#       `f_capacitance`    = `Biomass`
#       `f_conductivity`   = `Conductivity`
cap_data <- read_xlsx(DATA_FILEPATH, sheet = 2)

# Explore capacitance data!
print(cap_data, n = 10)
glimpse(cap_data)
View(head(cap_data, n = 100))
View(cap_data)

#-------------------------------------------------------------------------------
# Date and time formats differ between and within sheets:
#     bp_data (sheet1)
#         `Time`        --> h.hhhhhhhhhhhhhhh   (fractional hours)
#         `Timestamp`   --> dd-mm-yyyy hh:mm:ss
#     cap_data (sheet2)
#         `Time & Date` --> yyyy-mm-dd hh:mm:ss
#
# NOTE: Excel interprets dates as fractional days; Lucullus uses fractional
# hours. To convert to fractional days from fractional hours:
#     time_excel = time_luc * 60 * (1 hour / 60 min) * (1 day / 24 hour)
#-------------------------------------------------------------------------------
# Convert `Timestamp` in bp_data, formatted as 'dd-mm-yyyy hh:mm:ss', to ISO
# 8601 format ('yyyy-mm-dd hh:mm:ss'). This makes it easier to compare datasets.
bp_data <- bp_data %>%
               mutate(datetime = parse_date_time(Timestamp,
                                                 "d-m-Y H:M:S",
                                                 tz = Sys.timezone()),
                      .before = Timestamp) %>% # control location of new column
               select(-Timestamp) # remove old timestamp column
head(bp_data)

# Make "Time & Date" column the proper type (Date)
cap_data <- cap_data %>%
                mutate(datetime = parse_date_time(`Time & Date`,
                                                  "Y-m-d H:M:S",
                                                  tz = Sys.timezone()),
                       .before = `Time & Date`) %>%
                select(-`Time & Date`) # remove old timestamp column
head(cap_data)

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
        labs(title = "pH, stirring rate, temperature",
             caption = now()) +
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
        labs(title = "pH, stirring rate, temperature with missing values filled in",
             caption = now()) +
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
        labs(title = "pH, stirring rate, temperature with missing values filled in",
             caption = now()) +
        theme_linedraw() +
        theme(axis.text.x = element_text(angle = 45, hjust=1))

# Plot biomass volume over time (derived from capacitance probe measurements)
cap_data %>%
    ggplot(aes(x = datetime)) +
        geom_line(aes(y = Biomass,      colour = "bio (cells/ml)")) +
        geom_line(aes(y = Capacitance,  colour = "cap (pF/cm)")) +
        geom_line(aes(y = Conductivity, colour = "con (mS/cm)")) +
        scale_colour_manual("", values = c("bio (cells/ml)" = "deeppink",
                                           "cap (pF/cm)" = "purple",
                                           "con (mS/cm)" = "orange")) + ylab("") +
        scale_x_datetime(date_labels = "%dT%H:%M:%S", date_breaks = "4 hour") +
        labs(title = "Biomass volume measured by an Aber capacitance probe",
             caption = now()) +
        theme_linedraw() +
        theme(axis.text.x = element_text(angle = 45, hjust=1))

# Cleanup capacitance data
cap_data %>%
    filter(Biomass > 0, Capacitance > 0, Conductivity > 0) %>%
    filter(datetime < make_datetime(2022, 08, 29, 11, 00, tz = Sys.timezone())) %>%
    ggplot(aes(x = datetime)) +
        geom_line(aes(y = Biomass,      colour = "bio (cells/ml)")) +
        geom_line(aes(y = Capacitance,  colour = "cap (pF/cm)")) +
        geom_line(aes(y = Conductivity, colour = "con (mS/cm)")) +
        scale_colour_manual("", values = c("bio (cells/ml)" = "deeppink",
                                           "cap (pF/cm)" = "purple",
                                           "con (mS/cm)" = "orange")) + ylab("") +
        scale_x_datetime(date_labels = "%dT%H:%M:%S", date_breaks = "4 hour") +
        labs(title = "Biomass volume measured by an Aber capacitance probe (filtered)",
             caption = now()) +
        theme_linedraw() +
        theme(axis.text.x = element_text(angle = 45, hjust=1))

#-------------------------------------------------------------------------------
# Take-home Exercise: Oxygen Uptake Rate (OUR) calculation
#
# Oxygen Uptake Rate is the amount of oxygen consumed by cells per unit of time.
#
# We can estimate its value as dO2/dt (ml/s) with the following assumptions:
#   (a) We ignore periods of time where pure oxygen is actively being sparged
#       into the reactor.
#
#   (b) Under normal conditions, air escapes the reactor via an outlet; here, we
#       completely ignore all outlet gas streams, thereby focussing only on
#       oxygen consumption by cells.
#
# This simplifies the OUR calculation.
# Hint: ?lubridate
#-------------------------------------------------------------------------------
bp_data %>%
    ggplot(aes(x = datetime)) +
        geom_line(aes(y = m_do, colour = m_do)) +
        scale_x_datetime(date_labels = "%dT%H:%M:%S",
                         date_breaks = "4 hour") +
        labs(title = "Dissolved Oxygen (DO)",
             caption = now()) +
        theme_linedraw() +
        theme(axis.text.x = element_text(angle = 45, hjust=1))

# Zoom in to smaller window of time
bp_data %>%
    filter(datetime > bp_data$datetime[10000],
           datetime < bp_data$datetime[10000] + hours(2)) %>%
    ggplot(aes(x = datetime)) +
        geom_line(aes(y = m_do, colour = m_do)) +
        scale_x_datetime(date_labels = "%dT%H:%M:%S",
                         date_breaks = "4 hour") +
        labs(title = "Dissolved Oxygen (DO), smaller window",
             caption = now()) +
        theme_linedraw() +
        theme(axis.text.x = element_text(angle = 45, hjust=1))

# Plot distribution of DO values
bp_data %>%
    ggplot(aes(x = m_do)) +
        geom_density() +
        labs(title = "Distribution of Dissolved Oxygen (DO)",
             caption = now())
