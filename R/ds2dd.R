utils::globalVariables(c("metadata_names"))
#' (DEPRECATED) Data set to data dictionary function
#'
#' @description
#' Creates a very basic data dictionary skeleton. Please see `ds2dd_detailed()`
#' for a more advanced function.
#'
#' @details
#' Migrated from stRoke ds2dd(). Fits better with the functionality of
#' 'REDCapCAST'.
#' @param ds data set
#' @param record.id name or column number of id variable, moved to first row of
#' data dictionary, character of integer. Default is "record_id".
#' @param form.name vector of form names, character string, length 1 or length
#' equal to number of variables. Default is "basis".
#' @param field.type vector of field types, character string, length 1 or length
#' equal to number of variables. Default is "text.
#' @param field.label vector of form names, character string, length 1 or length
#' equal to number of variables. Default is NULL and is then identical to field
#' names.
#' @param include.column.names Flag to give detailed output including new
#' column names for original data set for upload.
#' @param metadata Metadata column names. Default is the included
#' REDCapCAST::metadata_names.
#'
#' @return data.frame or list of data.frame and vector
#' @export
#'
#' @examples
#' redcapcast_data$record_id <- seq_len(nrow(redcapcast_data))
#' ds2dd(redcapcast_data, include.column.names=TRUE)

ds2dd <-
  function(ds,
           record.id = "record_id",
           form.name = "basis",
           field.type = "text",
           field.label = NULL,
           include.column.names = FALSE,
           metadata = metadata_names) {
    dd <- data.frame(matrix(ncol = length(metadata), nrow = ncol(ds)))
    colnames(dd) <- metadata

    if (is.character(record.id) && !record.id %in% colnames(ds)) {
      stop("Provided record.id is not a variable name in provided data set.")
    }

    # renaming to lower case and substitute spaces with underscore
    field.name <- gsub(" ", "_", tolower(colnames(ds)))

    # handles both character and integer
    colsel <-
      colnames(ds) == colnames(ds[record.id])

    if (summary(colsel)[3] != 1) {
      stop("Provided record.id has to be or refer to a uniquely named column.")
    }

    dd[, "field_name"] <-
      c(field.name[colsel], field.name[!colsel])

    if (length(form.name) > 1 && length(form.name) != ncol(ds)) {
      stop(
        "Provided form.name should be of length 1 (value is reused) or equal
        length as number of variables in data set."
      )
    }
    dd[, "form_name"] <- form.name

    if (length(field.type) > 1 && length(field.type) != ncol(ds)) {
      stop(
        "Provided field.type should be of length 1 (value is reused) or equal
        length as number of variables in data set."
      )
    }

    dd[, "field_type"] <- field.type

    if (is.null(field.label)) {
      dd[, "field_label"] <- dd[, "field_name"]
    } else
      dd[, "field_label"] <- field.label

    if (include.column.names){
      list("DataDictionary"=dd,"Column names"=field.name)
    } else dd
  }


