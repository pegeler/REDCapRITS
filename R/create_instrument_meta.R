#' Create zips file with necessary content based on data set
#'
#' @description
#' Metadata can be added by editing the data dictionary of a project in the
#' initial design phase. If you want to later add new instruments, this can be
#' used to add instrument(s) to a project in production.
#'
#' @param data metadata for the relevant instrument.
#' Could be from `ds2dd_detailed()`
#' @param dir destination dir for the instrument zip. Default is the current WD.
#' @param record.id flag to omit the first row of the data dictionary assuming
#' this is the record_id field which should not be included in the instrument.
#' Default is TRUE.
#'
#' @return list
#' @export
#'
#' @examples
#' data <- iris |>
#'   ds2dd_detailed(add.auto.id = TRUE,
#'   form.name=sample(c("b","c"),size = 6,replace = TRUE,prob=rep(.5,2))) |>
#'   purrr::pluck("meta")
#' # data |> create_instrument_meta()
#'
#' data <- iris |>
#'   ds2dd_detailed(add.auto.id = FALSE) |>
#'   purrr::pluck("data")
#' names(data) <- glue::glue("{sample(x = c('a','b'),size = length(names(data)),
#' replace=TRUE,prob = rep(x=.5,2))}__{names(data)}")
#' data <- data |> ds2dd_detailed(form.sep="__")
#' # data |>
#' #   purrr::pluck("meta") |>
#' #   create_instrument_meta(record.id = FALSE)
create_instrument_meta <- function(data,
                                   dir = here::here(""),
                                   record.id = TRUE) {
  if (record.id) {
    data <- data[-1,]
  }
  temp_dir <- tempdir()
  split(data,data$form_name) |> purrr::imap(function(.x,.i){
    utils::write.csv(.x, paste0(temp_dir, "/instrument.csv"), row.names = FALSE, na = "")
    writeLines("REDCapCAST", paste0(temp_dir, "/origin.txt"))
    zip::zip(paste0(dir, "/", .i, Sys.Date(), ".zip"),
             files = c("origin.txt", "instrument.csv"),
             root = temp_dir
    )
  })

}
