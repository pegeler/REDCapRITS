if (requireNamespace("readr", quietly = TRUE)) {

  context("Compatibility with readr")

  metadata <- readr::read_csv(
    get_data_location(
      "ExampleProject_DataDictionary_2018-06-07.csv"
    )
  )

  records <- readr::read_csv(
    get_data_location(
      "ExampleProject_DATA_2018-06-07_1129.csv"
    )
  )

  test_that("Data read in with `readr` will return correct result", {
    redcap_output_readr <- REDCap_split(records, metadata)
    expect_known_hash(redcap_output_readr, "bde303d330fba161ca500c10cfabb693")
  })

}
