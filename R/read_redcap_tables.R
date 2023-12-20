#' Download REDCap data
#'
#' Implementation of REDCap_split with a focused data acquisition approach using
#' REDCapR::redcap_read nad only downloading specified fields, forms and/or
#' events using the built-in focused_metadata including some clean-up.
#' Works with longitudinal projects with repeating instruments.
#' @param uri REDCap database uri
#' @param token API token
#' @param records records to download
#' @param fields fields to download
#' @param events events to download
#' @param forms forms to download
#' @param raw_or_label raw or label tags
#' @param split_forms Whether to split "repeating" or "all" forms, default is
#' all.
#' @param generics vector of auto-generated generic variable names to
#' ignore when discarding empty rows
#'
#' @return list of instruments
#' @importFrom REDCapR redcap_metadata_read redcap_read redcap_event_instruments
#' @include utils.r
#' @export
#'
#' @examples
#' # Examples will be provided later
read_redcap_tables <- function(uri,
                               token,
                               records = NULL,
                               fields = NULL,
                               events = NULL,
                               forms = NULL,
                               raw_or_label = "label",
                               split_forms = "all",
                               generics = c(
                                 "record_id",
                                 "redcap_event_name",
                                 "redcap_repeat_instrument",
                                 "redcap_repeat_instance"
                               )) {


  if (!is.null(forms) | !is.null(events)){
    arm_event_inst <- REDCapR::redcap_event_instruments(redcap_uri = uri,
                                              token = token)

    if (!is.null(forms)){

    forms_test <- forms %in% unique(arm_event_inst$data$form)

    if (any(!forms_test)){
      stop("Not all supplied forms are valid")
    }
    }

    if (!is.null(events)){
    event_test <- events %in% unique(arm_event_inst$data$unique_event_name)

    if (any(!event_test)){
      stop("Not all supplied event names are valid")
    }
    }
  }

  # Getting dataset
  d <- REDCapR::redcap_read(
    redcap_uri = uri,
    token = token,
    fields = fields,
    events = events,
    forms = forms,
    records = records,
    raw_or_label = raw_or_label
  )[["data"]]

  # Process repeat instrument naming
  # Removes any extra characters other than a-z, 0-9 and "_", to mimic raw
  # instrument names.
  if ("redcap_repeat_instrument" %in% names(d)) {
    d$redcap_repeat_instrument <- clean_redcap_name(d$redcap_repeat_instrument)
  }

  # Getting metadata
  m <-
    REDCapR::redcap_metadata_read (redcap_uri = uri, token = token)[["data"]]

  # Processing metadata to reflect dataset
  if (!is.null(c(fields,forms,events))){
    m <- focused_metadata(m,names(d))
  }

  # Splitting
  l <- REDCap_split(d,
                    m,
                    forms = split_forms,
                    primary_table_name = "")

  # Sanitizing split list by removing completely empty rows apart from colnames
  # in "generics"
  sanitize_split(l,generics)

}


