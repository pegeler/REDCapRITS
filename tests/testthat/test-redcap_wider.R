test_that("redcap_wider() returns expected output", {
  list <-
    list(
      data.frame(
        record_id = c(1, 2, 1, 2),
        redcap_event_name = c("baseline", "baseline", "followup", "followup"),
        age = c(25, 26, 27, 28)
      ),
      data.frame(
        record_id = c(1, 2),
        redcap_event_name = c("baseline", "baseline"),
        gender = c("male", "female")
      )
    )

  expect_equal(
    redcap_wider(list),
    data.frame(
      record_id = c(1, 2),
      age_baseline = c(25, 26),
      age_followup = c(27, 28),
      gender = c("male", "female")
    )
  )
})


# Using test data

# Set up the path and data -------------------------------------------------
file_paths <- lapply(
  c(records = "WARRIORtestForSoftwa_DATA_2018-06-21_1431.csv",
    metadata = "WARRIORtestForSoftwareUpgrades_DataDictionary_2018-06-21.csv"),
  get_data_location
)

redcap <- lapply(file_paths, read.csv, stringsAsFactors = FALSE)
redcap[["metadata"]] <- with(redcap, metadata[metadata[, 1] > "", ])
list <-
  with(redcap, REDCap_split(records, metadata, forms = "all"))

wide_ds <- redcap_wider(list)

test_that("redcap_wider() returns wide output from CSV", {
  expect_equal(ncol(wide_ds), 171)
})
