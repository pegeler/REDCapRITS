# get_data_location <- function(x) {
#   system.file(
#     "testdata",
#     x,
#     package = "REDCapRITS"
#   )
# }

get_data_location <- function(x) file.path("data", x)
