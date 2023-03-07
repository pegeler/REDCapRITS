utils::globalVariables(c("redcap_wider",
"event.glue",
"inst.glue"))

#' @title Redcap Wider
#' @description Converts a list of REDCap data frames from long to wide format.
#' Handles longitudinal projects, but not yet repeated instruments.
#' @param list A list of data frames.
#' @param event.glue A dplyr::glue string for repeated events naming
#' @param inst.glue A dplyr::glue string for repeated instruments naming
#' @return The list of data frames in wide format.
#' @export
#' @importFrom tidyr pivot_wider
#' @importFrom tidyselect all_of
#'
#' @examples
#' list <- list(data.frame(record_id = c(1,2,1,2),
#' redcap_event_name = c("baseline", "baseline", "followup", "followup"),
#' age = c(25,26,27,28)),
#' data.frame(record_id = c(1,2),
#' redcap_event_name = c("baseline", "baseline"),
#' gender = c("male", "female")))
#' redcap_wider(list)
redcap_wider <-
  function(list,
           event.glue = "{.value}_{redcap_event_name}",
           inst.glue = "{.value}_{redcap_repeat_instance}") {
    all_names <- unique(do.call(c, lapply(list, names)))

    if (!any(c("redcap_event_name", "redcap_repeat_instrument") %in% all_names)) {
      stop(
        "The dataset does not include a 'redcap_event_name' variable.
         redcap_wider only handles projects with repeating instruments or
         longitudinal projects"
      )
    }

    # if (any(grepl("_timestamp",all_names))){
    #   stop("The dataset includes a '_timestamp' variable, which is not supported
    #        by this function yet. Sorry! Feel free to contribute :)")
    # }

    id.name <- all_names[1]

    l <- lapply(list, function(i) {
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
        } else
          (i[colnames(i) != "redcap_event_name"])
      } else
        (i)
    })

    ## Additional conditioning is needed to handle repeated instruments.

    data.frame(Reduce(f = dplyr::full_join, x = l))
  }
