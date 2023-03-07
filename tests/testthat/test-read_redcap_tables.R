
# Test that the function throws an error when uri and token are not provided
test_that("read_redcap_tables throws error when uri and token are not provided",
          {
            testthat::expect_error(read_redcap_tables(uri, token))
          })
