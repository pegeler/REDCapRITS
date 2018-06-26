#' Split REDCap repeating instruments table into multiple tables
#'
#' This will take output from a REDCap export and split it into a base table
#' and child tables for each repeating instrument. Metadata
#' is used to determine which fields should be included in each resultant table.
#'
#' @param records Exported project records. May be a \code{data.frame},
#'   \code{response}, or \code{character} vector containing JSON from an API
#'   call.
#' @param metadata Project metadata (the data dictionary). May be a
#'   \code{data.frame}, \code{response}, or \code{character} vector containing
#'   JSON from an API call.
#' @author Paul W. Egeler, M.S., GStat
#' @examples
#' \dontrun{
#' # Using an API call -------------------------------------------------------
#'
#' library(RCurl)
#'
#' # Get the records
#' records <- postForm(
#'   uri = api_url,     # Supply your site-specific URI
#'   token = api_token, # Supply your own API token
#'   content = 'record',
#'   format = 'json',
#'   returnFormat = 'json'
#' )
#'
#' # Get the metadata
#' metadata <- postForm(
#'   uri = api_url,     # Supply your site-specific URI
#'   token = api_token, # Supply your own API token
#'   content = 'metadata',
#'   format = 'json'
#' )
#'
#' # Convert exported JSON strings into a list of data.frames
#' REDCapRITS::REDCap_split(records, metadata)
#'
#' # Using a raw data export -------------------------------------------------
#'
#' # Get the records
#' records <- read.csv("/path/to/data/ExampleProject_DATA_2018-06-03_1700.csv")
#'
#' # Get the metadata
#' metadata <- read.csv("/path/to/data/ExampleProject_DataDictionary_2018-06-03.csv")
#'
#' # Split the tables
#' REDCapRITS::REDCap_split(records, metadata)
#'
#' # In conjunction with the R export script ---------------------------------
#'
#' # You must set the working directory first since the REDCap data export script
#' # contains relative file references.
#' setwd("/path/to/data/")
#'
#' # Run the data export script supplied by REDCap.
#' # This will create a data.frame of your records called 'data'
#' source("ExampleProject_R_2018-06-03_1700.r")
#'
#' # Get the metadata
#' metadata <- read.csv("ExampleProject_DataDictionary_2018-06-03.csv")
#'
#' # Split the tables
#' REDCapRITS::REDCap_split(data, metadata)
#' }
#' @return A list of \code{"data.frame"}s: one base table and zero or more
#'   tables for each repeating instrument.
#' @include process_user_input.r
#' @export
REDCap_split <- function(records, metadata) {

  # Process user input
  records  <- process_user_input(records)
  metadata <- process_user_input(metadata)

  # Get the variable names in the dataset
  vars_in_data <- names(records)

  # Check to see if there were any repeating instruments
  if (!any(vars_in_data == "redcap_repeat_instrument")) {

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

  # Process instrument status fields
  form_names <- unique(metadata$form_name)
  form_complete_fields <- data.frame(
    field_name = paste0(form_names, "_complete"),
    form_name = form_names,
    stringsAsFactors = FALSE
  )

  fields <- rbind(fields, form_complete_fields)

  # Process checkbox fields
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
          function(x, y)
            data.frame(
              field_name = y[grepl(paste0("^", x[1], "___((?!\\.factor).)+$"), y, perl = TRUE)],
              form_name = x[2],
              stringsAsFactors = FALSE,
              row.names = NULL
            ),
          y = vars_in_data
        )
      )

    fields <- rbind(fields, checkbox_fields)

  }

  # Process ".*\\.factor" fields supplied by REDCap's export data R script
  if (any(grepl("\\.factor$", vars_in_data))) {

    factor_fields <-
      do.call(
        "rbind",
        apply(
          fields,
          1,
          function(x, y) {
            field_indices <- grepl(paste0("^", x[1], "\\.factor$"), y)
            if (any(field_indices))
              data.frame(
                field_name = y[field_indices],
                form_name = x[2],
                stringsAsFactors = FALSE,
                row.names = NULL
              )
          },
          y = vars_in_data
        )
      )

    fields <- rbind(fields, factor_fields)

  }

  # Identify the subtables in the data
  subtables <- unique(records$redcap_repeat_instrument)
  subtables <- subtables[subtables != ""]

  # Variables to be present in each output table
  universal_fields <- c(
    vars_in_data[1],
    grep(
      "^redcap_(?!(repeat)).*",
      vars_in_data,
      value = TRUE,
      perl = TRUE
    )
  )

  # Variables to be at the beginning of each repeating instrument
  repeat_instrument_fields <- grep(
    "^redcap_repeat.*",
    vars_in_data,
    value = TRUE
  )


  # Split the table based on instrument
  out <- split.data.frame(records, records$redcap_repeat_instrument)

  # Delete the variables that are not relevant
  for (i in names(out)) {

    if (i == "") {

      out_fields <- which(
        vars_in_data %in% c(
          universal_fields,
          fields[!fields[,2] %in% subtables, 1]
        )
      )
      out[[which(names(out) == "")]] <- out[[which(names(out) == "")]][out_fields]

    } else {

      out_fields <- which(
        vars_in_data %in% c(
          universal_fields,
          repeat_instrument_fields,
          fields[fields[,2] == i, 1]
        )
      )
      out[[i]] <- out[[i]][out_fields]

    }

  }

  out

}
