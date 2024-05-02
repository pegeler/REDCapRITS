utils::globalVariables(c("calculations", "choices"))
#' Doc table to data dictionary - EARLY, DOCS MISSING
#'
#' @description
#' Works well with `project.aid::docx2list()`.
#' Allows defining a database in a text document (see provided template) for
#' an easier to use data base creation. This approach allows easier
#' collaboration when defining the database. The generic case is a data frame
#' with variable names as values in a column. This is a format like the REDCap
#' data dictionary, but gives a few options for formatting.
#'
#' @param data tibble or data.frame with all variable names in one column
#' @param instrument.name character vector length one. Instrument name.
#' @param col.variables variable names column (default = 1), allows dplyr
#' subsetting
#' @param list.datetime.format formatting for date/time detection.
#' See `case_match_regex_list()`
#' @param col.description descriptions column, allows dplyr
#' subsetting. If empty, variable names will be used.
#' @param col.condition conditions for branching column, allows dplyr
#' subsetting. See `char2cond()`.
#' @param col.subheader sub-header column, allows dplyr subsetting.
#' See `format_subheader()`.
#' @param subheader.tag formatting tag. Default is "h2"
#' @param condition.minor.sep condition split minor. See `char2cond()`.
#' Default is ",".
#' @param condition.major.sep condition split major. See `char2cond()`.
#' Default is ";".
#' @param col.calculation calculations column. Has to be written exact.
#' Character vector.
#' @param col.choices choices column. See `char2choice()`.
#' @param choices.char.sep choices split. See `char2choice()`. Default is "/".
#' @param missing.default value for missing fields. Default is NA.
#'
#' @return tibble or data.frame (same as data)
#' @export
#'
#' @examples
#' # data <- dd_inst
#' # data |> doc2dd(instrument.name = "evt",
#' # col.description = 3,
#' # col.condition = 4,
#' # col.subheader = 2,
#' # col.calculation = 5,
#' # col.choices = 6)
doc2dd <- function(data,
                   instrument.name,
                   col.variables = 1,
                   list.datetime.format = list(
                     date_dmy = "_dat[eo]$",
                     time_hh_mm_ss = "_ti[md]e?$"
                   ),
                   col.description = NULL,
                   col.condition = NULL,
                   col.subheader = NULL,
                   subheader.tag = "h2",
                   condition.minor.sep = ",",
                   condition.major.sep = ";",
                   col.calculation = NULL,
                   col.choices = NULL,
                   choices.char.sep = "/",
                   missing.default = NA) {
  data <- data |>
    dplyr::mutate(dplyr::across(dplyr::everything(), ~ dplyr::na_if(.x, c(""))))


  ## Defining the field name
  out <- data |>
    dplyr::mutate(
      field_name = dplyr::pick(col.variables) |> unlist()
    )

  ## Defining the field label. Field name is used if no label is provided.
  if (is_missing(col.description)) {
    out <- out |>
      dplyr::mutate(
        field_label = field_name
      )
  } else {
    out <- out |>
      dplyr::mutate(
        field_label = dplyr::pick(col.description) |> unlist()
      )
  }

  ## Defining the sub-header
  if (!is_missing(col.subheader)) {
    out <- out |>
      dplyr::mutate(
        section_header = dplyr::pick(col.subheader) |>
          unlist() |>
          format_subheader(tag = subheader.tag)
      )
  }

  ## Defining the choices
  if (is_missing(col.choices)) {
    out <- out |>
      dplyr::mutate(
        choices = missing.default
      )
  } else {
    out <- out |>
      dplyr::mutate(
        choices = dplyr::pick(col.choices) |>
          unlist() |>
          char2choice(char.split = choices.char.sep)
      )
  }

  ## Defining the calculations
  if (is_missing(col.calculation)) {
    out <- out |>
      dplyr::mutate(
        calculations = missing.default
      )
  } else {
    out <- out |>
      dplyr::mutate(
        calculations = dplyr::pick(col.calculation) |>
          unlist() |>
          tolower() |>
          (\(.x) gsub("’", "'", .x))()
      )
  }

  ## Merging choices and calculations, defining field type and setting form name
  out <- out |>
    dplyr::mutate(
      select_choices_or_calculations = dplyr::coalesce(calculations, choices),
      field_type = dplyr::case_when(!is.na(choices) ~ "radio",
        !is.na(calculations) ~ "calc",
        .default = "text"
      ),
      form_name = instrument.name
    )

  ## Defining branching logic from conditions
  if (is_missing(col.condition)) {
    out <- out |>
      dplyr::mutate(
        branching_logic = missing.default
      )
  } else {
    out <- out |>
      dplyr::mutate(
        branching_logic = dplyr::pick(col.condition) |>
          unlist() |>
          char2cond(minor.split = condition.minor.sep,
                    major.split = condition.major.sep)
      )
  }

  ## Detecting data/time formatting from systematic field names
  if (is.null(list.datetime.format)) {
    out <- out |>
      dplyr::mutate(
        text_validation_type_or_show_slider_number = missing.default
      )
  } else {
    out <- out |>
      dplyr::mutate(
        text_validation_type_or_show_slider_number = case_match_regex_list(
          field_name,
          list.datetime.format
        )
      )
  }

  ## Selecting relevant columns
  out <- out |>
    dplyr::select(dplyr::any_of(names(REDCapCAST::redcapcast_meta)))

  ## Merging and ordering columns for upload
  out |>
    list(REDCapCAST::redcapcast_meta |> dplyr::slice(0)) |>
    dplyr::bind_rows() |>
    dplyr::select(names(REDCapCAST::redcapcast_meta))
}




#' Simple function to generate REDCap choices from character vector
#'
#' @param data vector
#' @param char.split splitting character(s)
#' @param raw specific values. Can be used for options of same length.
#' @param .default default value for missing. Default is NA.
#'
#' @return vector
#' @export
#'
#' @examples
#' char2choice(c("yes/no","  yep. / nope  ","",NA,"what"),.default=NA)
char2choice <- function(data, char.split = "/", raw = NULL,.default=NA) {
  ls <- strsplit(x = data, split = char.split)

  ls |>
    purrr::map(function(.x) {
      if (is.null(raw)) {
        raw <- seq_len(length(.x))
      }
      if (length(.x) == 0 | all(is.na(.x))) {
        .default
      } else {
        paste(paste0(raw, ", ",trimws(.x)), collapse = " | ")
      }
    }) |>
    purrr::list_c()
}

#' Simple function to generate REDCap branching logic from character vector
#'
#' @param data vector
#' @param .default default value for missing. Default is NA.
#' @param minor.split minor split
#' @param major.split major split
#' @param major.sep argument separation. Default is " or ".
#'
#' @return vector
#' @export
#'
#' @examples
#' #data <- dd_inst$betingelse
#' #c("Extubation_novent, 2; Pacu_delay, 1") |> char2cond()
char2cond <- function(data, minor.split = ",", major.split = ";", major.sep = " or ", .default = NA) {
  strsplit(x = data, split = major.split) |>
    purrr::map(function(.y) {
      strsplit(x = .y, split = minor.split) |>
        purrr::map(function(.x) {
          if (length(.x) == 0 | all(is.na(.x))) {
            .default
          } else {
            glue::glue("[{trimws(tolower(.x[1]))}]='{trimws(.x[2])}'")
          }
        }) |>
        purrr::list_c() |>
        glue::glue_collapse(sep = major.sep)
    }) |>
    purrr::list_c()
}

#' List-base regex case_when
#'
#' @description
#' Mimics case_when for list of regex patterns and values. Used for date/time
#' validation generation from name vector. Like case_when, the matches are in
#' order of priority.
#' Primarily used in REDCapCAST to do data type coding from systematic variable
#' naming.
#'
#' @param data vector
#' @param match.list list of case matches
#' @param .default Default value for non-matches. Default is NA.
#'
#' @return vector
#' @export
#'
#' @examples
#' case_match_regex_list(
#'   c("test_date", "test_time", "test_tida", "test_tid"),
#'   list(date_dmy = "_dat[eo]$", time_hh_mm_ss = "_ti[md]e?$")
#' )
case_match_regex_list <- function(data, match.list, .default = NA) {
  match.list |>
    purrr::imap(function(.z, .i) {
      dplyr::if_else(grepl(.z, data), .i, NA)
    }) |>
    (\(.x){
      dplyr::coalesce(!!!.x)
    })() |>
    (\(.x){
      dplyr::if_else(is.na(.x), .default, .x)
    })()
}

#' Multi missing check
#'
#' @param data character vector
#' @param nas character vector of strings considered as NA
#'
#' @return logical vector
is_missing <- function(data,nas=c("", "NA")) {
  if (is.null(data)) {
    TRUE
  } else {
    is.na(data) | data %in% nas
  }
}
