

#' focused_metadata
#' @description Extracts limited metadata for variables in a dataset
#' @param metadata A dataframe containing metadata
#' @param vars_in_data Vector of variable names in the dataset
#' @return A dataframe containing metadata for the variables in the dataset
#' @export
#'
focused_metadata <- function(metadata, vars_in_data) {

  if (any(c("tbl_df", "tbl") %in% class(metadata))) {
    metadata <- data.frame(metadata)
  }

  field_name <- grepl(".*[Ff]ield[._][Nn]ame$", names(metadata))
  field_type <- grepl(".*[Ff]ield[._][Tt]ype$", names(metadata))

  fields <-
    metadata[!metadata[, field_type] %in% c("descriptive", "checkbox") &
               metadata[, field_name] %in% vars_in_data,
             field_name]

  # Process checkbox fields
  if (any(metadata[, field_type] == "checkbox")) {
    # Getting base field names from checkbox fields
    vars_check <-
      sub(pattern = "___.*$", replacement = "", vars_in_data)

    # Processing
    checkbox_basenames <-
      metadata[metadata[, field_type] == "checkbox" &
                 metadata[, field_name] %in% vars_check,
               field_name]

    fields <- c(fields, checkbox_basenames)

  }

  # Process instrument status fields
  form_names <-
    unique(metadata[, grepl(".*[Ff]orm[._][Nn]ame$",
                            names(metadata))][metadata[, field_name]
                                              %in% fields])

  form_complete_fields <- paste0(form_names, "_complete")

  fields <- c(fields, form_complete_fields)

  # Process survey timestamps
  timestamps <-
    intersect(vars_in_data, paste0(form_names, "_timestamp"))
  if (length(timestamps)) {
    timestamp_fields <- timestamps

    fields <- c(fields, timestamp_fields)

  }

  # Process ".*\\.factor" fields supplied by REDCap's export data R script
  if (any(grepl("\\.factor$", vars_in_data))) {
    factor_fields <-
      do.call("rbind",
              apply(fields,
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
                    y = vars_in_data))

    fields <- c(fields, factor_fields[, 1])

  }

  metadata[metadata[, field_name] %in% fields, ]

}

#' clean_redcap_name
#' @description
#' Stepwise removal on non-alphanumeric characters, trailing white space,
#' substitutes spaces for underscores and converts to lower case.
#' Trying to make up for different naming conventions.
#'
#' @param x vector or data frame for cleaning
#'
#' @return vector or data frame, same format as input
#' @export
#'
clean_redcap_name <- function(x){

  gsub(" ", "_",
       gsub("[' ']$","",
           gsub("[^a-z0-9' '_]", "",
                tolower(x)
       )))}


#' Sanitize list of data frames
#'
#' Removing empty rows
#' @param l A list of data frames.
#' @param generic.names A vector of generic names to be excluded.
#'
#' @return A list of data frames with generic names excluded.
#'
#' @export
#'
#'
sanitize_split <- function(l,
                           generic.names = c(
                             "record_id",
                             "redcap_event_name",
                             "redcap_repeat_instrument",
                             "redcap_repeat_instance"
                           )) {
  lapply(l, function(i) {
    if (ncol(i) > 2) {
      s <- data.frame(i[, !colnames(i) %in% generic.names])
      i[!apply(is.na(s), MARGIN = 1, FUN = all),]
    } else {
      i
    }
  })
}


#' Match fields to forms
#'
#' @param metadata A data frame containing field names and form names
#' @param vars_in_data A character vector of variable names
#'
#' @return A data frame containing field names and form names
#'
#' @export
#'
#'
match_fields_to_form <- function(metadata, vars_in_data) {

  metadata <- data.frame(metadata)

  field_form_name <- grepl(".*([Ff]ield|[Ff]orm)[._][Nn]ame$",names(metadata))
  field_type <- grepl(".*[Ff]ield[._][Tt]ype$",names(metadata))

  fields <- metadata[!metadata[,field_type] %in% c("descriptive", "checkbox"),
                     field_form_name]

  names(fields) <- c("field_name", "form_name")

  # Process instrument status fields
  form_names <- unique(metadata[,grepl(".*[Ff]orm[._][Nn]ame$",
                                       names(metadata))])
  form_complete_fields <- data.frame(
    field_name = paste0(form_names, "_complete"),
    form_name = form_names,
    stringsAsFactors = FALSE
  )

  fields <- rbind(fields, form_complete_fields)

  # Process survey timestamps
  timestamps <-
    intersect(vars_in_data, paste0(form_names, "_timestamp"))
  if (length(timestamps)) {
    timestamp_fields <- data.frame(
      field_name = timestamps,
      form_name = sub("_timestamp$", "", timestamps),
      stringsAsFactors = FALSE
    )

    fields <- rbind(fields, timestamp_fields)

  }

  # Process checkbox fields
  if (any(metadata[,field_type] == "checkbox")) {
    checkbox_basenames <- metadata[metadata[,field_type] == "checkbox",
                                   field_form_name]

    checkbox_fields <-
      do.call("rbind",
              apply(checkbox_basenames,
                    1,
                    function(x, y)
                      data.frame(
                        field_name =
                          y[grepl(paste0("^", x[1], "___((?!\\.factor).)+$"),
                                  y, perl = TRUE)],
                        form_name = x[2],
                        stringsAsFactors = FALSE,
                        row.names = NULL
                      ),
                    y = vars_in_data))

    fields <- rbind(fields, checkbox_fields)

  }

  # Process ".*\\.factor" fields supplied by REDCap's export data R script
  if (any(grepl("\\.factor$", vars_in_data))) {
    factor_fields <-
      do.call("rbind",
              apply(fields,
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
                    y = vars_in_data))

    fields <- rbind(fields, factor_fields)

  }

  fields

}

#' Split a data frame into separate tables for each form
#'
#' @param table A data frame
#' @param universal_fields A character vector of fields that should be included
#' in every table
#' @param fields A two-column matrix containing the names of fields that should
#' be included in each form
#'
#' @return A list of data frames, one for each non-repeating form
#'
#' @export
#'
#' @examples
#' # Create a table
#' table <- data.frame(
#'   id = c(1, 2, 3, 4, 5),
#'   form_a_name = c("John", "Alice", "Bob", "Eve", "Mallory"),
#'   form_a_age = c(25, 30, 25, 15, 20),
#'   form_b_name = c("John", "Alice", "Bob", "Eve", "Mallory"),
#'   form_b_gender = c("M", "F", "M", "F", "F")
#' )
#'
#' # Create the universal fields
#' universal_fields <- c("id")
#'
#' # Create the fields
#' fields <- matrix(
#'   c("form_a_name", "form_a",
#'     "form_a_age", "form_a",
#'     "form_b_name", "form_b",
#'     "form_b_gender", "form_b"),
#'   ncol = 2, byrow = TRUE
#' )
#'
#' # Split the table
#' split_non_repeating_forms(table, universal_fields, fields)
split_non_repeating_forms <-
  function(table, universal_fields, fields) {
    forms <- unique(fields[[2]])

    x <- lapply(forms,
                function (x) {
                  table[names(table) %in% union(universal_fields,
                                                fields[fields[, 2] == x, 1])]
                })

    structure(x, names = forms)

  }


#' Extended string splitting
#'
#' Can be used as a substitute of the base function. Main claim to fame is
#' easing the split around the defined delimiter, see example.
#' @param x data
#' @param split delimiter
#' @param type Split type. Can be c("classic", "before", "after", "around")
#' @param perl perl param from strsplit()
#' @param ... additional parameters are passed to base strsplit handling splits
#'
#' @return list
#' @export
#'
#' @examples
#' test <- c("12 months follow-up", "3 steps", "mRS 6 weeks", "Counting to 231 now")
#' strsplitx(test,"[0-9]",type="around")
strsplitx <- function(x,
                      split,
                      type = "classic",
                      perl = FALSE,
                      ...) {
  if (type == "classic") {
    # use base::strsplit
    out <- base::strsplit(x = x, split = split, perl = perl, ...)
  } else if (type == "before") {
    # split before the delimiter and keep it
    out <- base::strsplit(x = x,
                          split = paste0("(?<=.)(?=", split, ")"),
                          perl = TRUE,
                          ...)
  } else if (type == "after") {
    # split after the delimiter and keep it
    out <- base::strsplit(x = x,
                          split = paste0("(?<=", split, ")"),
                          perl = TRUE,
                          ...)
  } else if (type == "around") {
    # split around the defined delimiter

    out <- base::strsplit(gsub("~~", "~", # Removes double ~
                               gsub("^~", "", # Removes leading ~
                                    gsub(
                                      # Splits and inserts ~ at all delimiters
                                      paste0("(", split, ")"), "~\\1~", x
                                    ))), "~")

  } else {
    # wrong type input
    stop("type must be 'classic', 'after', 'before' or 'around'!")
  }

  out
}

#' Convert single digits to words
#'
#' @param x data. Handle vectors, data.frames and lists
#' @param lang language. Danish (da) and English (en), Default is "en"
#' @param neutrum for numbers depending on counted word
#' @param everything flag to also split numbers >9 to single digits
#'
#' @return returns characters in same format as input
#' @export
#'
#' @examples
#' d2w(c(2:8,21))
#' d2w(data.frame(2:7,3:8,1),lang="da",neutrum=TRUE)
#'
#' ## If everything=T, also larger numbers are reduced.
#' ## Elements in the list are same length as input
#' d2w(list(2:8,c(2,6,4,23),2), everything=TRUE)
#'
d2w <- function(x, lang = "en", neutrum=FALSE, everything=FALSE) {

  # In Danish the written 1 depends on the counted word
  if (neutrum) nt <- "t" else nt <- "n"

  # A sapply() call with nested lapply() to handle vectors, data.frames and lists
  convert <- function(x, lang, neutrum) {
    zero_nine = data.frame(
      num = 0:9,
      en = c(
        'zero',
        'one',
        'two',
        'three',
        'four',
        'five',
        'six',
        'seven',
        'eight',
        'nine'
      ),
      da = c(
        "nul",
        paste0("e",nt),
        "to",
        "tre",
        "fire",
        "fem",
        "seks",
        "syv",
        "otte",
        "ni"
      )
    )

    wrd <- lapply(x, function(i) {
      zero_nine[, tolower(lang)][zero_nine[, 1] == i]
    })

    sub <- lengths(wrd) == 1

    x[sub] <- wrd[sub]

    unlist(x)
  }

  # Also converts numbers >9 to single digits and writes out
  # Uses strsplitx()
  if (everything) {
    out <- sapply(x,function(y){
      do.call(c,lapply(y,function(z){
        v <- strsplitx(z,"[0-9]",type="around")
        Reduce(paste,sapply(v,convert,lang = lang, neutrum = neutrum))
      }))

    })
  } else {
  out <- sapply(x,convert,lang = lang, neutrum = neutrum)
  }

  if (is.data.frame(x)) out <- data.frame(out)

  out
}

#' Test if repeatable or longitudinal
#'
#' @param data data set
#' @param generics default is "redcap_event_name", "redcap_repeat_instrument"
#' and "redcap_repeat_instance"
#'
#' @return logical
#' @examples
#' is.repeated_longitudinal(c("record_id", "age", "record_id", "gender"))
#'
is.repeated_longitudinal <- function(data, generics = c(
  "redcap_event_name",
  "redcap_repeat_instrument",
  "redcap_repeat_instance"
)) {
  if (is.list(data)) {
    names <- data |>
      lapply(names) |>
      purrr::list_c()
  } else if (is.data.frame(data)) {
    names <- names(data)
  } else if (is.vector(data)) {
    names <- data
  }
  any(generics %in% names)
}
