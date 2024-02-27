# Set up the path and data -------------------------------------------------
metadata <- read.csv(
  get_data_location("ExampleProject_DataDictionary_2018-06-07.csv"),
  stringsAsFactors = TRUE
)

records <-
  read.csv(get_data_location("ExampleProject_DATA_2018-06-07_1129.csv"),
    stringsAsFactors = TRUE
  )

redcap_output_csv1 <- REDCap_split(records, metadata)

# Test that basic CSV export matches reference ------------------------------
test_that("CSV export matches reference", {
  expect_known_hash(redcap_output_csv1, "cb5074a06e1abcf659d60be1016965d2")
})

# Test that REDCap_split can handle a focused dataset

records_red <- records[
  !records$redcap_repeat_instrument == "sale",
  !names(records) %in%
    metadata$field_name[metadata$form_name == "sale"] &
    !names(records) == "sale_complete"
]
records_red$redcap_repeat_instrument <-
  as.character(records_red$redcap_repeat_instrument)

redcap_output_red <- REDCap_split(records_red, metadata)


test_that("REDCap_split handles subset dataset", {
  testthat::expect_length(redcap_output_red, 1)
})


# Test that R code enhanced CSV export matches reference --------------------
if (requireNamespace("Hmisc", quietly = TRUE)) {
  test_that("R code enhanced export matches reference", {
    redcap_output_csv2 <-
      REDCap_split(REDCap_process_csv(records), metadata)

    expect_known_hash(redcap_output_csv2, "578dc054e59ec92a21e950042e08ee37")
  })
}


if (requireNamespace("readr", quietly = TRUE)) {
  metadata <-
    readr::read_csv(get_data_location(
      "ExampleProject_DataDictionary_2018-06-07.csv"
    ))

  records <-
    readr::read_csv(get_data_location(
      "ExampleProject_DATA_2018-06-07_1129.csv"
    ))

  redcap_output_readr <- REDCap_split(records, metadata)

  expect_matching_elements <- function(FUN) {
    FUN <- match.fun(FUN)
    expect_identical(
      lapply(redcap_output_readr, FUN),
      lapply(redcap_output_csv1, FUN)
    )
  }

  test_that("Result of data read in with `readr` will
            match result with `read.csv`", {
    # The list itself
    expect_identical(
      length(redcap_output_readr),
      length(redcap_output_csv1)
    )
    expect_identical(
      names(redcap_output_readr),
      names(redcap_output_csv1)
    )

    # Each element of the list
    expect_matching_elements(names)
    expect_matching_elements(dim)
  })
}
