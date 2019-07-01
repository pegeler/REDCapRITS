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
#' @param primary_table_label Name of the label given to the list element for
#'   the primary output table (as described in *README.md*).
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
#' @include process_user_input.r utils.r
#' @export
REDCap_split <- function(records,
                         metadata,
                         primary_table_label = ""
) {

  # Process user input
  records  <- process_user_input(records)
  metadata <- process_user_input(metadata)

  # Get the variable names in the dataset
  vars_in_data <- names(records)

  # Check to see if there were any repeating instruments
  if (!"redcap_repeat_instrument" %in% vars_in_data) {
    stop("There are no repeating instruments in this dataset.")
  }

  # Standardize variable names for metadata
  names(metadata) <- metadata_names

  # Make sure that no metadata columns are factors
  metadata <- rapply(metadata, as.character, classes = "factor", how = "replace")

  # Find the fields and associated form
  fields <- match_fields_to_form(metadata, vars_in_data)

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


  # Identify the subtables in the data
  subtables <- unique(records$redcap_repeat_instrument)
  subtables <- subtables[subtables != ""]

  # Split the table based on instrument
  out <- split.data.frame(records, records$redcap_repeat_instrument)

  if (primary_table_label %in% subtables) {
    warning(
      "The label given to the primary table is already used by a repeating instrument.\n",
      "The primary table label will be left blank."
    )
  } else if (primary_table_label > "") {
    names(out)[[which(names(out) == "")]] <- primary_table_label
  }

  # Delete the variables that are not relevant
  for (i in names(out)) {

    if (i == primary_table_label) {

      out_fields <- which(
        vars_in_data %in% c(
          universal_fields,
          fields[!fields[,2] %in% subtables, 1]
        )
      )
      out[[which(names(out) == primary_table_label)]] <- out[[which(names(out) == primary_table_label)]][out_fields]

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
