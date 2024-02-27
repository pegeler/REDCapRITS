test_that("strsplitx works", {
  expect_equal(2 * 2, 4)
  test <- c("12 months follow-up", "3 steps", "mRS 6 weeks",
            "Counting to 231 now")
  expect_length(strsplitx(test, "[0-9]", type = "around")[[1]], 3)

  expect_equal(strsplitx(test, "[0-9]", type = "classic")[[2]][1], "")
  expect_length(strsplitx(test, "[0-9]", type = "classic")[[4]], 4)

  expect_length(strsplitx(test, "[0-9]", type = "classic")[[4]], 4)
})

test_that("d2w works", {
  expect_length(d2w(c(2:8, 21)), 8)

  expect_equal(d2w(data.frame(2:7, 3:8, 1),
    lang = "da",
    neutrum = TRUE
  )[1, 3], "et")

  expect_equal(d2w(list(2:8, c(2, 6, 4, 23), 2), everything = T)[[2]][4], "two three")
})
