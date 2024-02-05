utils::globalVariables(c("DTSTART"))

#' Convert data set to ical file
#'
#' @param data data set
#' @param start dplyr style event start datetime column name
#' @param end dplyr style event end datetime column name
#' @param location dplyr style event location column name
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
#' id = c("1", 3), assessor = "A", location = "111", note = c(NA, "OBS")) |>
#' dplyr::mutate(end= start+lubridate::hours(2))
#' df |> ds2ical()
#' df |> ds2ical(summary.glue.string = "ID {id} [{assessor}] {note}")
#' # Export .ics file: (not run)
#' ical <- df |> ds2ical(start, end, location, description.glue.string = "{note}")
#' # ical |> calendar::ic_write(file=here::here("calendar.ics"))
ds2ical <- function(data,
                   start=start,
                   end=end,
                   location=location,
                   summary.glue.string = "ID {id} [{assessor}]",
                   description.glue.string = NULL) {
  ds <- data |>
    dplyr::transmute(
      SUMMARY = glue::glue(summary.glue.string, .na = ""),
      DTSTART = lubridate::ymd_hms({{ start }}),
      DTEND = lubridate::ymd_hms({{ end }}),
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
