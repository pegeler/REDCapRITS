utils::globalVariables(c("DTSTART"))

#' Convert data set to ical file
#'
#' @param data data set
#' @param start event start column
#' @param location event location column
#' @param event.length use lubridate functions to generate "Period" class
#' element (default is lubridate::hours(2))
#' @param summary.glue.string character string to pass to glue::glue() for event
#' name (summary). Can take any column from data set.
#' @param description.glue.string character string to pass to glue::glue() for
#' event description. Can take any column from data set.
#'
#' @return tibble of class "ical"
#' @export
#'
#' @examples
#' df <- dplyr::tibble(start = c(Sys.time(), Sys.time() + lubridate::days(2)),
#' id = c("1", 3), assessor = "A", location = "111", note = c(NA, "OBS"))
#' df |> ds2ical(start, location)
#' df |> ds2ical(start, location,
#' summary.glue.string = "ID {id} [{assessor}] {note}")
#' # Export .ics file: (not run)
#' ical <- df |> ds2ical(start, location, description.glue.string = "{note}")
#' # ical |> calendar::ic_write(file=here::here("calendar.ics"))
ds2ical <- function(data,
                   start,
                   location,
                   summary.glue.string = "ID {id} [{assessor}]",
                   description.glue.string = NULL,
                   event.length = lubridate::hours(2)) {
  ds <- data |>
    dplyr::transmute(
      SUMMARY = glue::glue(summary.glue.string, .na = ""),
      DTSTART = lubridate::ymd_hms({{ start }}, tz = "CET"),
      DTEND = DTSTART + event.length,
      LOCATION = {{ location }}
    )

  if (!is.null(description.glue.string)){
    ds <- dplyr::tibble(ds,
                        dplyr::transmute(data,
                                         DESCRIPTION = glue::glue(
                                           description.glue.string,
                                           .na = ""
                                           )
                                         )
                        )
  }

  ds |>
    (\(x){
      x |>
        dplyr::mutate(UID = replicate(nrow(x), calendar::ic_guid()))
    })() |>
    dplyr::filter(!is.na(DTSTART)) |>
    calendar::ical()
}
