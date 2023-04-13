


# Global variables --------------------------------------------------------

# Cars
metadata <-
  jsonlite::fromJSON(get_data_location("ExampleProject_metadata.json"))

records <-
  jsonlite::fromJSON(get_data_location("ExampleProject_records.json"))

redcap_output_json <- REDCap_split(records, metadata, forms = "all")

# Longitudinal
file_paths <- vapply(
  c(records = "WARRIORtestForSoftwa_DATA_2018-06-21_1431.csv",
    metadata = "WARRIORtestForSoftwareUpgrades_DataDictionary_2018-06-21.csv"),
  FUN.VALUE = "character",
  get_data_location
)

redcap <- lapply(file_paths, read.csv, stringsAsFactors = FALSE)
redcap[["metadata"]] <- with(redcap, metadata[metadata[, 1] > "", ])
redcap_output_long <-
  with(redcap, REDCap_split(records, metadata, forms = "all"))
redcap_long_names <- names(redcap[[1]])

# Tests -------------------------------------------------------------------

test_that("Each form is an element in the list", {
  expect_length(redcap_output_json, 3L)
  expect_identical(names(redcap_output_json),
                   c("motor_trend_cars", "grouping", "sale"))

})

test_that("All variables land somewhere", {
  expect_true(setequal(names(records), Reduce(
    "union", lapply(redcap_output_json, names)
  )))

})


test_that("Primary table name is ignored", {
  expect_identical(REDCap_split(records, metadata, "HELLO", "all"),
                   redcap_output_json)
})

test_that("Supports longitudinal data", {
  expect_true(setequal(redcap_long_names, Reduce(
    "union", lapply(redcap_output_long, names)
  )))

})
