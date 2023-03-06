#-------------------------------------------------------------------------------
# Introduction to Data Wrangling
# Week 11: Process Data Management, Storage, and Security
# BIEN675: Process Analytical Technologies and Data Sciences, Winter 2023
#
# Sean Nesdoly
# Viral Vectors and Vaccines Bioprocessing Group
# https://amine-kamen.lab.mcgill.ca/
# Department of Bioengineering
# McGill University, Montréal QC
# 2023-03-21
#-------------------------------------------------------------------------------
# @TODO: Install R *and* RStudio from https://posit.co/download/rstudio-desktop

# install.packages("tidyverse") # @TODO: uncomment & run if not yet installed!
library(tidyverse)

# @TODO: Set working directory to location of 'BIEN675-BioprocessDataWrangling'
# git repository ('-master' will be a suffix if you choose ZIP format).
setwd("~/Downloads/BIEN675-BioprocessDataWrangling-master") # change filepath for your machine!
getwd()

#-------------------------------------------------------------------------------
# tibble: An alternative to R's base::data.frame, this data structure stores
# collections of variables, much like a spreadsheet (rows & columns).
#     A column contains values for a single variable.
#     A row (observation, case) contains an instance/value of each variable.
#-------------------------------------------------------------------------------
?tibble::tibble

# Column-wise tibble creation: x & y are variables (columns)
tibble(x = 1:5,
       y = 5:1)

# Scalars (vectors of length 1 in R) are copied down a column
tibble(x = 1:5,
       y = 99)

# Heterogeneous data. 'LETTERS' is a built-in R constant
tibble(x = 1:5,
       y = LETTERS[1:5])

# Create a formula 'f' to create a new variable (column) based on existing ones
tibble(x = 1:5,
       y = 99,
       f = x + y)

tibble(x = 1:5,
       y = 2,
       f = x^y)

tibble(x = 1:5,
       y = LETTERS[1:5],
       f = paste(x, y, sep="-"))

# Row-wise tibble creation: the TRansposed tibble ('tribble')
tribble(~item,   ~n,
        "Apple",  1,
        "Banana", 2,
        "Carrot", 3)

# Fixing variable (column) names
tibble(x = 1:5,
       x = 5:1,
       .name_repair = "unique")

# Printing & viewing tibbles
t <- tibble(x = 1:10,
            y = 99)

print(t, n = 3)
View(t)
View(head(t, n = 3))

# Coerce a data.frame (or other base R object) to type tibble
?datasets::iris
as_tibble(iris)
head(as_tibble(iris))
View(as_tibble(iris))

#-------------------------------------------------------------------------------
# dplyr: The Core of Data Wrangling
#-------------------------------------------------------------------------------
# x %>% f(y) becomes f(x,y)
as_tibble(iris) %>% head()

# Summarise variables (columns) by applying functions to them
as_tibble(iris) %>%
    summarise(n = n(),
              mean(Sepal.Length),
              sd(Sepal.Length),
              var(Sepal.Length),
              IQR(Sepal.Length),
    )

# select: Extract columns (variables) as a tibble (table)
as_tibble(iris) %>%
    select(Sepal.Length, Petal.Length)

# Select variables matching a condition
as_tibble(iris) %>%
    select(starts_with("Petal"))

# Remove column X with '-X'
as_tibble(iris) %>%
    select(-Species)

# Apply a function across ALL columns
as_tibble(iris) %>%
    select(-Species) %>%
    summarise(across(everything(), mean))

# filter: Keep rows that match a condition
as_tibble(iris) %>%
    filter(Species == "virginica", Sepal.Length > 7)

# arrange: Sort in descending order
as_tibble(iris) %>%
    filter(Species == "virginica", Sepal.Length > 7) %>%
    arrange(desc(Sepal.Length))

# distinct: Only keep unique rows (remove duplicates)
as_tibble(iris) %>%
    filter(Species == "virginica", Sepal.Length > 7) %>%
    arrange(desc(Sepal.Length)) %>%
    distinct(Sepal.Length, .keep_all = TRUE)

# Slice: select rows by index
as_tibble(iris) %>%
    filter(Species == "virginica", Sepal.Length > 7) %>%
    arrange(desc(Sepal.Length)) %>%
    distinct(Sepal.Length, .keep_all = TRUE) %>%
    slice(1:2, (n()-1):n())

#-------------------------------------------------------------------------------

# Group rows (cases) by value
as_tibble(iris) %>%
    group_by(Species)

# Count number of rows (flowers) in each group (Species)
as_tibble(iris) %>%
    group_by(Species) %>%
    count()

# Summarise using within-group statistics
as_tibble(iris) %>%
    group_by(Species) %>%
    summarise(across(everything(), mean))

# mutate: Make new variables (columns) with functions
as_tibble(iris) %>%
    mutate(Sepal.Area = Sepal.Length * Sepal.Width) %>%
    mutate(Petal.Area = Petal.Length * Petal.Width) %>%
    group_by(Species) %>%
    filter(Sepal.Area > 18) %>%
    summarise(across(everything(), mean))

#-------------------------------------------------------------------------------
# ggplot2: Visualize data using the 'Grammar of Graphics'
#-------------------------------------------------------------------------------
ggplot(iris, aes(x = Sepal.Length, y = Petal.Length)) +
    geom_point()

# Colour points based on flower species
ggplot(iris, aes(x = Sepal.Length, y = Petal.Length)) +
    geom_point(aes(color = Species))

# Fit linear model to data
ggplot(iris, aes(x = Sepal.Length, y = Petal.Length)) +
    geom_point(aes(color = Species)) +
    geom_smooth(method = lm)

# Plot distributions of petal width stratified by species
p <- ggplot(iris, aes(x = Species, y = Petal.Width, fill = Species)) +
         geom_violin(); p;

# Iteratively build on existing plot: add labels
p <- p + labs(title = "Flower petal width distributions stratified by species.",
              caption = "Source: R datasets::iris",
              x = "Flower species",
              y = "Petal width (cm)"); p;

# Add boxplots showing median, Interquartile Range (IQR), and outliers
# (defined as below Q1-1.5*IQR and above Q3+1.5*IQR)
p <- p + geom_boxplot(fill = "white", alpha = 0.9, width = 0.1); p;

# Add theme to change appearance
p <- p + theme_classic(); p;

# Facets: create subplots based on discrete values in a column (variable)
p <- ggplot(iris, aes(x = Petal.Width, fill = Species)) +
         geom_density(alpha = 0.5) +
         labs(title = "Flower petal width distributions stratified by species.",
              caption = "Source: R datasets::iris",
              x = "Petal width (cm)"); p;

p <- p + facet_grid(rows = vars(Species)); p;

# Wrangle dataset, then plot
as_tibble(iris) %>%
    mutate(Sepal.Area = Sepal.Length * Sepal.Width) %>%
    mutate(Petal.Area = Petal.Length * Petal.Width) %>%
    filter(Sepal.Length >= 5) %>%
    ggplot(aes(x = Sepal.Area, y = Petal.Area, color = Species)) +
        geom_point()

#-------------------------------------------------------------------------------
# readr: Read & Write Data
#-------------------------------------------------------------------------------
?readr

# Read files with Comma Separated Values (*.csv)
readr::read_csv("./data/in.csv",
                col_names = FALSE)

# Read files with Tab Separated Values (*.tsv)
readr::read_tsv("./data/in.tsv",
                col_names = FALSE)

# Read in a file, replacing 'world' with 'NA' (Not Available; a missing value)
readr::read_csv("./data/in.csv",
                col_names = FALSE,
                na = c("world")) # change 'world' to 'NA'

# Read files with any delimiter
file_in_tsv <- readr::read_delim("./data/in.tsv",
                                  delim = "\t",
                                  col_names = FALSE)
file_in_tsv

# Write file as Comma Separated Values (*.csv), with header (by default)
dir.create("out")
readr::write_csv(file_in_tsv,
                 file = "./out/out.csv")

# Write file as Tab Separated Values (*.tsv), withOUT header
readr::write_tsv(file_in_tsv,
                 file = "./out/out.tsv",
                 col_names = FALSE)

# Write files with any delimiter
readr::write_delim(file_in_tsv,
                   "./out/out.txt",
                   delim = "\n")

# To keep track of things, append timestamps to your output filenames. This
# function creates a safe timestamp that operating systems can handle correctly.
time_fmt <- function() {
    gsub('\\s+', 'T', gsub('[-:]', '', Sys.time()))
}

time_fmt() # Format: yyyymmddThhmmss (delimiter T stands for time)

readr::write_csv(file_in_tsv,
                 file = paste("./out/", "out.", time_fmt(), ".csv", sep = ""))
