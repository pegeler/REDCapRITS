
# Check the RCurl export ---------------------------------------------------
test_that("JSON character vector from RCurl matches reference", {
  metadata <- jsonlite::fromJSON(get_data_location("ExampleProject_metadata.json"))

  records <- jsonlite::fromJSON(get_data_location("ExampleProject_records.json"))

  redcap_output_json1 <- REDCap_split(records, metadata)

  expect_known_hash(redcap_output_json1, "2c8b6531597182af1248f92124161e0c")

})
