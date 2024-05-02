utils::globalVariables(c("server"))
#' Shiny server factory
#'
#' @return shiny server
#' @export
server_factory <- function() {
  source(here::here("app/server.R"))
  server
}

#' UI factory for shiny app
#'
#' @return shiny ui
#' @export
ui_factory <- function() {
  # require(ggplot2)
  source(here::here("app/ui.R"))
}

#' Launch the included Shiny-app for database casting and upload
#'
#' @return shiny app
#' @export
#'
#' @examples
#' # shiny_cast()
#'
shiny_cast <- function() {
  # shiny::runApp(appDir = here::here("app/"), launch.browser = TRUE)

  shiny::shinyApp(
    ui_factory(),
    server_factory()
  )
}


#' Helper to import files correctly
#'
#' @param filenames file names
#'
#' @return character vector
#' @export
#'
#' @examples
#' file_extension(list.files(here::here(""))[[2]])[[1]]
#' file_extension(c("file.cd..ks","file"))
file_extension <- function(filenames) {
  sub(pattern = "^(.*\\.|[^.]+)(?=[^.]*)", replacement = "",
      filenames,
      perl = TRUE)
}

#' Flexible file import based on extension
#'
#' @param file file name
#' @param consider.na character vector of strings to consider as NAs
#'
#' @return tibble
#' @export
#'
#' @examples
#' read_input("https://raw.githubusercontent.com/agdamsbo/cognitive.index.lookup/main/data/sample.csv")
read_input <- function(file, consider.na = c("NA", '""', "")) {
  ext <- file_extension(file)

  tryCatch(
    {
      if (ext == "csv") {
        df <- readr::read_csv(file = file, na = consider.na)
      } else if (ext %in% c("xls", "xlsx")) {
        df <- openxlsx2::read_xlsx(file = file, na.strings = consider.na)
      } else if (ext == "dta") {
        df <- haven::read_dta(file = file)
      } else if (ext == "ods") {
        df <- readODS::read_ods(file = file)
      } else {
        stop("Input file format has to be on of:
             '.csv', '.xls', '.xlsx', '.dta' or '.ods'")
      }
    },
    error = function(e) {
      # return a safeError if a parsing error occurs
      stop(shiny::safeError(e))
    }
  )

  df
}

