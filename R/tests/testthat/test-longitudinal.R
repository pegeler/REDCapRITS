context("Longitudinal data")

test_that("CSV export matches reference", {
  # Reading in the files
  file_paths <- file.path(
    system.file("tests", "testthat", "data", package = "REDCapRITS"),
    c(
      records = "WARRIORtestForSoftwa_DATA_2018-06-21_1431.csv",
      metadata = "WARRIORtestForSoftwareUpgrades_DataDictionary_2018-06-21.csv"
    )
  )

  redcap <- lapply(file_paths, read.csv, stringsAsFactors = FALSE)
  names(redcap) <- c("records", "metadata")
  redcap[["metadata"]] <- with(redcap, metadata[metadata[,1] > "",])
  redcap_output <- with(redcap, REDCap_split(records, metadata))


  expect_known_hash(redcap_output, "dff3a52955")
})
