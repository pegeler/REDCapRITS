context("Reading in JSON")

# Set up the path ----------------------------------------------------------

data_dir <- system.file("tests", "testthat", "data", package = "REDCapRITS")

# Check the RCurl export ---------------------------------------------------
test_that("JSON character vector from RCurl matches reference", {

  metadata <- jsonlite::fromJSON(
    file.path(
      data_dir,
      "ExampleProject_metadata.json"
    )
  )

  records <- jsonlite::fromJSON(
    file.path(
      data_dir,
      "ExampleProject_records.json"
    )
  )

  redcap_output_json1 <- REDCap_split(records, metadata)

  expect_known_hash(redcap_output_json1, "2c8b6531597182af1248f92124161e0c")

})

# Check the httr export ---------------------------------------------------

# Something will go here.
