context("CSV Exports")

# Set up the path and data -------------------------------------------------
metadata <- read.csv(
  get_data_location(
    "ExampleProject_DataDictionary_2018-06-07.csv"
  )
)

records <- read.csv(
  get_data_location(
    "ExampleProject_DATA_2018-06-07_1129.csv"
  )
)

redcap_output_csv1 <- REDCap_split(records, metadata)

# Test that basic CSV export matches reference ------------------------------
test_that("CSV export matches reference", {
  expect_known_hash(redcap_output_csv1, "f74558d1939c17d9ff0e08a19b956e26")
})

# Test that R code enhanced CSV export matches reference --------------------
if (requireNamespace("Hmisc", quietly = TRUE)) {
  test_that("R code enhanced export matches reference", {
      redcap_output_csv2 <- REDCap_split(REDCap_process_csv(records), metadata)

      expect_known_hash(redcap_output_csv2, "34f82cab35bf8aae47d08cd96f743e6b")
  })
}


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

  redcap_output_readr <- REDCap_split(records, metadata)

  expect_matching_elements <- function(FUN) {
    FUN <- match.fun(FUN)
    expect_identical(
      lapply(redcap_output_readr, FUN),
      lapply(redcap_output_csv1, FUN)
    )
  }

  test_that("Result of data read in with `readr` will match result with `read.csv`", {

    # The list itself
    expect_identical(length(redcap_output_readr), length(redcap_output_csv1))
    expect_identical(names(redcap_output_readr), names(redcap_output_csv1))

    # Each element of the list
    expect_matching_elements(names)
    expect_matching_elements(dim)
  })

}
