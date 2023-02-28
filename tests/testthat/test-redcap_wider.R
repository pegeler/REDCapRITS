test_that("redcap_wider() returns expected output", {
  list <- list(data.frame(record_id = c(1,2,1,2), redcap_event_name = c("baseline", "baseline", "followup", "followup"), age = c(25,26,27,28)),
               data.frame(record_id = c(1,2), redcap_event_name = c("baseline", "baseline"), gender = c("male", "female")))

  expect_equal(redcap_wider(list),
               data.frame(record_id = c(1,2),
                          age_baseline_long = c(25,26),
                          age_followup_long = c(27,28),
                          gender = c("male","female")))
})
