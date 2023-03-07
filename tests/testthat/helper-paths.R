# get_data_location <- function(x) {
#   system.file(
#     "testdata",
#     x,
#     package = "REDCapCAST"
#   )
# }

get_data_location <- function(x)
  file.path("data", x)
