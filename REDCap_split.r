#' Split REDCap repeating instruments table into multiple tables
#'
#' This will take a raw \code{data.frame} from REDCap and split it into a base table
#' and give individual tables for each repeating instrument. Metadata
#' is used to determine which fields should be included in each resultant table.
#'
#' @param records \code{data.frame} containing project records
#' @param metadata \code{data.frame} containing project metadata (the data dictionary)
#' @author Paul W. Egeler, M.S., GStat
#' @examples
#' \dontrun{
#' library(jsonlite)
#' library(RCurl)
#'
#' # Get the metadata
#' result.meta <- postForm(
#'     api_url,
#'     token = api_token,
#'     content = 'metadata',
#'     format = 'json'
#' )
#'
#' # Get the records
#' result.record <- postForm(
#'     uri = api_url,
#'     token = api_token,
#'     content = 'record',
#'     format = 'json',
#'     returnFormat = 'json'
#' )
#'
#' # Convert JSON to data.frames
#' records <- fromJSON(result.record)
#' metadata <- fromJSON(result.meta)
#'
#' # Split the data.frame into a list of data.frames
#' REDCap_split(records, metadata)
#' }
#' @return a list of data.frames
#' @export
REDCap_split <- function(records, metadata) {

  stopifnot(all(sapply(list(records,metadata), inherits, "data.frame")))

  # Check to see if there were any repeating instruments

  if (!any(names(records) == "redcap_repeat_instrument")) {

    message("There are no repeating instruments in this data.")

    return(list(records))

  }

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

  return(out)

}
