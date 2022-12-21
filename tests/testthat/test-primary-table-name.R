context("Primary table name processing")


# Global  variables -------------------------------------------------------
metadata <- jsonlite::fromJSON(
  get_data_location(
    "ExampleProject_metadata.json"
  )
)

records <- jsonlite::fromJSON(
  get_data_location(
    "ExampleProject_records.json"
  )
)

ref_hash <- "2c8b6531597182af1248f92124161e0c"

# Tests -------------------------------------------------------------------
test_that("Will not use a repeating instrument name for primary table", {

  redcap_output_json1 <- expect_warning(
    REDCap_split(records, metadata, "sale"),
    "primary table"
  )

  expect_known_hash(redcap_output_json1, ref_hash)

})

test_that("Names are set correctly and output is identical", {
  redcap_output_json2 <- REDCap_split(records, metadata, "main")


  expect_identical(names(redcap_output_json2), c("main", "sale"))
  expect_known_hash(setNames(redcap_output_json2, c("", "sale")), ref_hash)

})
