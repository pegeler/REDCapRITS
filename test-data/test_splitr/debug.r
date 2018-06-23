# Installing the latest REDCapRITS from GitHub ------------------------------
#devtools::install_github("SpectrumHealthResearch/REDCapRITS/R@s3methods")
devtools::install_github("SpectrumHealthResearch/REDCapRITS/R@longitudinal-data")

# Debugging reading in longitudinal datasets ------------------------------

# Reading in the files
file_paths <- file.path(
  "../test-data/test_splitr/",
  c(
    records = "WARRIORtestForSoftwa_DATA_2018-06-21_1431.csv",
    metadata = "WARRIORtestForSoftwareUpgrades_DataDictionary_2018-06-21.csv"
  )
)

redcap <- lapply(file_paths, read.csv, stringsAsFactors = FALSE)

names(redcap) <- c("records", "metadata")
str(redcap)

# A bunch of blank rows
redcap[["metadata"]] <- redcap[["metadata"]][as.logical(nchar(redcap[["metadata"]][,1])),]
str(redcap, 1)

setdiff(redcap[["metadata"]][,1], names(redcap[["records"]]))

# Viewing the files
View(redcap[["records"]])
View(redcap[["metadata"]])


# Playing with the names --------------------------------------------------

vars_in_data <- names(redcap$records)

universal_fields <- c(
  vars_in_data[1],
  grep("^redcap_(?!(repeat)).*", vars_in_data, value = TRUE, perl = TRUE)
  )


repeat_instrument_fields <- grep("^redcap_repeat.*", vars_in_data, value = TRUE)


# Give it a shot ----------------------------------------------------------

testCheck <- with(redcap, REDCap_split(records, metadata))

lapply(testCheck, names)

commonFields <- Reduce(intersect, lapply(testCheck, names))

commonFields

library(dplyr)

lapply(testCheck, glimpse) %>% invisible

testCheck[[1]] %>%
  left_join(testCheck$informed_consent, by = commonFields) %>%
  glimpse
