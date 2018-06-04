#' Split REDCap repeating instruments table into multiple tables
#'
#' This will take output from a REDCap export and split it into a base table
#' and child tables for each repeating instrument. Metadata
#' is used to determine which fields should be included in each resultant table.
#'
#' @param records Exported project records. May be a \code{data.frame} or
#'   \code{character} vector containing JSON from an API call.
#' @param metadata Project metadata (the data dictionary). May be a
#'   \code{data.frame} or \code{character} vector containing JSON from an API
#'   call.
#' @author Paul W. Egeler, M.S., GStat
#' @examples
#' \dontrun{
#' library(RCurl)
#'
#' # Get the records
#' records <- postForm(
#'     uri = api_url,     # Supply your site-specific URI
#'     token = api_token, # Supply your own API token
#'     content = 'record',
#'     format = 'json',
#'     returnFormat = 'json'
#' )
#'
#' # Get the metadata
#' metadata <- postForm(
#'     uri = api_url,
#'     token = api_token,
#'     content = 'metadata',
#'     format = 'json'
#' )
#'
#' # Convert exported JSON strings into a list of data.frames
#' REDCap_split(records, metadata)
#' }
#' @return A list of \code{"data.frame"}s: one base table and zero or more
#'   tables for each repeating instrument.
#' @include JSON2data.frame.r
#' @export
REDCap_split <- function(records, metadata) {

  # Process user input
  records  <- JSON2data.frame(records)
  metadata <- JSON2data.frame(metadata)

  # Check to see if there were any repeating instruments
  if (!any(names(records) == "redcap_repeat_instrument")) {

    message("There are no repeating instruments in this data.")

    return(list(records))

  }

  # Standardize variable names for metadata
  names(metadata) <- c(
    "field_name", "form_name", "section_header", "field_type",
    "field_label", "select_choices_or_calculations", "field_note",
    "text_validation_type_or_show_slider_number", "text_validation_min",
    "text_validation_max", "identifier", "branching_logic", "required_field",
    "custom_alignment", "question_number", "matrix_group_name", "matrix_ranking",
    "field_annotation"
  )

  # Make sure that no metadata columns are factors
  metadata <- rapply(metadata, as.character, classes = "factor", how = "replace")

  # Find the fields and associated form
  fields <- metadata[
    !metadata$field_type %in% c("descriptive", "checkbox"),
    c("field_name", "form_name")
  ]

  if (any(metadata$field_type == "checkbox")) {

    checkbox_basenames <- metadata[
      metadata$field_type == "checkbox",
      c("field_name", "form_name")
    ]

    checkbox_fields <-
      do.call(
        "rbind",
        apply(
          checkbox_basenames,
          1,
          function(x)
            data.frame(
              field_name = names(records)[grepl(paste0("^", x[1], "___.+$"), names(records))],
              form_name = x[2],
              stringsAsFactors = FALSE,
              row.names = NULL
            )
        )
      )

    fields <- rbind(fields, checkbox_fields)

  }

  # Identify the subtables in the data
  subtables <- unique(records$redcap_repeat_instrument)
  subtables <- subtables[subtables != ""]

  # Split the table based on instrument
  out <- split.data.frame(records, records$redcap_repeat_instrument)

  # Delete the variables that are not relevant
  for (i in names(out)) {

    if (i == "") {

      out[[which(names(out) == "")]] <-
        out[[which(names(out) == "")]][fields[!fields[,2] %in% subtables, 1]]

    } else {

      out[[i]] <-
        out[[i]][c(names(records[1:3]),fields[fields[,2] == i, 1])]

    }

  }

  out

}
