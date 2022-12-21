context("Longitudinal data")

test_that("CSV export matches reference", {
  file_paths <- sapply(
    c(
      records = "WARRIORtestForSoftwa_DATA_2018-06-21_1431.csv",
      metadata = "WARRIORtestForSoftwareUpgrades_DataDictionary_2018-06-21.csv"
    ), get_data_location
  )

  redcap <- lapply(file_paths, read.csv, stringsAsFactors = FALSE)
  redcap[["metadata"]] <- with(redcap, metadata[metadata[,1] > "",])
  redcap_output <- with(redcap, REDCap_split(records, metadata))


  expect_known_hash(redcap_output, "0934bcb292")
})
