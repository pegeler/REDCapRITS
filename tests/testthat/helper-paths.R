# get_data_location <- function(x) {
#   system.file(
#     "testdata",
#     x,
#     package = "REDCapCAST"
#   )
# }

# setwd("tests/testthat")

get_data_location <- function(x)
  file.path("data", x)
