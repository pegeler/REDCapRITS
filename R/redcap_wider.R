utils::globalVariables(c("redcap_wider",
"event.glue",
"inst.glue"))

#' @title Redcap Wider
#' @description Converts a list of REDCap data frames from long to wide format.
#' Handles longitudinal projects, but not yet repeated instruments.
#' @param data A list of data frames.
#' @param event.glue A dplyr::glue string for repeated events naming
#' @param inst.glue A dplyr::glue string for repeated instruments naming
#' @return The list of data frames in wide format.
#' @export
#' @importFrom tidyr pivot_wider
#' @importFrom tidyselect all_of
#' @importFrom purrr reduce
#'
#' @examples
#' # Longitudinal
#' list1 <- list(data.frame(record_id = c(1,2,1,2),
#' redcap_event_name = c("baseline", "baseline", "followup", "followup"),
#' age = c(25,26,27,28)),
#' data.frame(record_id = c(1,2),
#' redcap_event_name = c("baseline", "baseline"),
#' gender = c("male", "female")))
#' redcap_wider(list1)
#' # Simpel with two instruments
#' list2 <- list(data.frame(record_id = c(1,2),
#' age = c(25,26)),
#' data.frame(record_id = c(1,2),
#' gender = c("male", "female")))
#' redcap_wider(list2)
#' # Simple with single instrument
#' list3 <- list(data.frame(record_id = c(1,2),
#' age = c(25,26)))
#' redcap_wider(list3)
#' # Longitudinal with repeatable instruments
#' list4 <- list(data.frame(record_id = c(1,2,1,2),
#' redcap_event_name = c("baseline", "baseline", "followup", "followup"),
#' age = c(25,26,27,28)),
#' data.frame(record_id = c(1,1,1,1,2,2,2,2),
#' redcap_event_name = c("baseline", "baseline", "followup", "followup",
#' "baseline", "baseline", "followup", "followup"),
#' redcap_repeat_instrument = "walk",
#' redcap_repeat_instance=c(1,2,1,2,1,2,1,2),
#' dist = c(40, 32, 25, 33, 28, 24, 23, 36)),
#' data.frame(record_id = c(1,2),
#' redcap_event_name = c("baseline", "baseline"),
#' gender = c("male", "female")))
#'redcap_wider(list4)
redcap_wider <-
  function(data,
           event.glue = "{.value}_{redcap_event_name}",
           inst.glue = "{.value}_{redcap_repeat_instance}") {

    if (!is.repeated_longitudinal(data)) {
      if (is.list(data)) {
        if (length(data) == 1) {
          out <- data[[1]]
        } else {
          out <- data |> purrr::reduce(dplyr::left_join)
        }
      } else if (is.data.frame(data)){
        out <- data
      }


    } else {

    id.name <- do.call(c, lapply(data, names))[[1]]

    l <- lapply(data, function(i) {
      rep_inst <- "redcap_repeat_instrument" %in% names(i)

      if (rep_inst) {
        k <- lapply(split(i, f = i[[id.name]]), function(j) {
          cname <- colnames(j)
          vals <-
            cname[!cname %in% c(
              id.name,
              "redcap_event_name",
              "redcap_repeat_instrument",
              "redcap_repeat_instance"
            )]
          s <- tidyr::pivot_wider(
            j,
            names_from = "redcap_repeat_instance",
            values_from = all_of(vals),
            names_glue = inst.glue
          )
          s[!colnames(s) %in% c("redcap_repeat_instrument")]
        })
        i <- Reduce(dplyr::bind_rows, k)
      }

      event <- "redcap_event_name" %in% names(i)

      if (event) {
        event.n <- length(unique(i[["redcap_event_name"]])) > 1

        i[["redcap_event_name"]] <-
          gsub(" ", "_", tolower(i[["redcap_event_name"]]))

        if (event.n) {
          cname <- colnames(i)
          vals <- cname[!cname %in% c(id.name, "redcap_event_name")]

          s <- tidyr::pivot_wider(
            i,
            names_from = "redcap_event_name",
            values_from = all_of(vals),
            names_glue = event.glue
          )
          s[colnames(s) != "redcap_event_name"]
        } else {
          i[colnames(i) != "redcap_event_name"]
          }
      } else {
        i
        }
    })

    out <- data.frame(Reduce(f = dplyr::full_join, x = l))
    }

    out
  }

