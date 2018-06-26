context("CSV Exports")

# Set up the path and data -------------------------------------------------

data_dir <- system.file("tests", "testthat", "data", package = "REDCapRITS")

metadata <- read.csv(
  file.path(
    data_dir,
    "ExampleProject_DataDictionary_2018-06-07.csv"
  )
)

records <- read.csv(
  file.path(
    data_dir,
    "ExampleProject_DATA_2018-06-07_1129.csv"
  )
)

# Test that basic CSV export matches reference ------------------------------
test_that("CSV export matches reference", {
  redcap_output_csv1 <- REDCap_split(records, metadata)

  expect_known_hash(redcap_output_csv1, "f74558d1939c17d9ff0e08a19b956e26")
})

# Test that R code enhanced CSV export matches reference --------------------
test_that("R code enhanced export matches reference", {
  source(file.path(data_dir, "ExampleProject_R_2018-06-07_1129.r"))

  redcap_output_csv2 <- REDCap_split(REDCap_process_csv(records), metadata)

  expect_known_hash(redcap_output_csv2, "34f82cab35bf8aae47d08cd96f743e6b")
})
