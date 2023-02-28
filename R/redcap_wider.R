

#' @title Redcap Wider
#' @description Converts a list of REDCap data frames from long to wide format.
#' Handles longitudinal projects, but not yet repeated instruments.
#' @param list A list of data frames.
#' @param names.glud A string to glue the column names together.
#' @return The list of data frames in wide format.
#' @export
#' @importFrom tidyr pivot_wider
#'
#' @examples
#' list <- list(data.frame(record_id = c(1,2,1,2),
#' redcap_event_name = c("baseline", "baseline", "followup", "followup"),
#' age = c(25,26,27,28)),
#' data.frame(record_id = c(1,2),
#' redcap_event_name = c("baseline", "baseline"),
#' gender = c("male", "female")))
#' redcap_wider(list)
redcap_wider <- function(list,names.glud="{.value}_{redcap_event_name}_long") {
  l <- lapply(list,function(i){
    incl <- any(duplicated(i[["record_id"]]))

    cname <- colnames(i)
    vals <- cname[!cname%in%c("record_id","redcap_event_name")]

    i$redcap_event_name <- tolower(gsub(" ","_",i$redcap_event_name))

    if (incl){
      s <- tidyr::pivot_wider(i,
                              names_from = redcap_event_name,
                              values_from = all_of(vals),
                              names_glue = names.glud)
      s[colnames(s)!="redcap_event_name"]
    } else (i[colnames(i)!="redcap_event_name"])

  })

  ## Additional conditioning is needed to handle repeated instruments.

  data.frame(Reduce(f = dplyr::full_join, x = l))
  }
