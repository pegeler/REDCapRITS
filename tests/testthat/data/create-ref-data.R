# Setup -------------------------------------------------------------------

devtools::load_all()

library(digest)
library(magrittr)
library(jsonlite)


ref_data_location <- function(x) file.path("tests","testthat","data", x)

# RCurl -------------------------------------------------------------------

REDCap_split(
  ref_data_location("ExampleProject_records.json") %>% fromJSON,
  ref_data_location("ExampleProject_metadata.json") %>% fromJSON
  ) %>% digest


# Basic CSV ---------------------------------------------------------------

REDCap_split(
  ref_data_location("ExampleProject_DATA_2018-06-07_1129.csv") %>% read.csv,
  ref_data_location("ExampleProject_DataDictionary_2018-06-07.csv") %>% read.csv
  ) %>% digest

# REDCap R Export ---------------------------------------------------------

source("tests/testthat/helper-ExampleProject_R_2018-06-07_1129.r")

REDCap_split(
  ref_data_location("ExampleProject_DATA_2018-06-07_1129.csv") %>%
    read.csv %>%
    REDCap_process_csv,
  ref_data_location("ExampleProject_DataDictionary_2018-06-07.csv") %>% read.csv
  ) %>% digest

# Longitudinal data from @pbchase; Issue #7 -------------------------------

file_paths <- vapply(
  c(
    records = "WARRIORtestForSoftwa_DATA_2018-06-21_1431.csv",
    metadata = "WARRIORtestForSoftwareUpgrades_DataDictionary_2018-06-21.csv"
  ), FUN.VALUE = "character", ref_data_location
)

redcap <- lapply(file_paths, read.csv, stringsAsFactors = FALSE)
redcap[["metadata"]] <- with(redcap, metadata[metadata[,1] > "",])
with(redcap, REDCap_split(records, metadata)) %>% digest
