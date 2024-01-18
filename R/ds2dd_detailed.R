utils::globalVariables(c(  "stats::setNames",  "field_name",  "field_type",  "select_choices_or_calculations"))
#' Try at determining which are true time only variables
#'
#' @description
#' This is just a try at guessing data type based on data class and column names
#' hoping for a tiny bit of naming consistency. R does not include a time-only
#' data format natively, so the "hms" class from `readr` is used. This
#' has to be converted to character class before REDCap upload.
#'
#' @param data data set
#' @param validate flag to output validation data. Will output list.
#' @param sel.pos Positive selection regex string
#' @param sel.neg Negative selection regex string
#'
#' @return character vector or list depending on `validate` flag.
#' @export
#'
#' @examples
#' data <- redcapcast_data
#' data |> guess_time_only_filter()
#' data |> guess_time_only_filter(validate = TRUE) |> lapply(head)
guess_time_only_filter <- function(data, validate = FALSE, sel.pos = "[Tt]i[d(me)]", sel.neg = "[Dd]at[eo]") {
  datetime_nms <- data |>
    lapply(\(x)any(c("POSIXct","hms") %in% class(x))) |>
    (\(x) names(data)[do.call(c, x)])()

  time_only_log <- datetime_nms |> (\(x) {
    ## Detects which are determined true Time only variables
    ## Inspection is necessary
    grepl(pattern = sel.pos, x = x) &
      !grepl(pattern = sel.neg, x = x)
  })()

  if (validate) {
    list(
      "is.POSIX" = data[datetime_nms],
      "is.datetime" = data[datetime_nms[!time_only_log]],
      "is.time_only" = data[datetime_nms[time_only_log]]
    )
  } else {
    datetime_nms[time_only_log]
  }
}

#' Correction based on time_only_filter function. Introduces new class for easier
#' validation labelling.
#'
#' @description
#' Dependens on the data class "hms" introduced with
#' `guess_time_only_filter()` and converts these
#'
#' @param data data set
#' @param ... arguments passed on to `guess_time_only_filter()`
#'
#' @return tibble
#' @importFrom readr parse_time
#'
#' @examples
#' data <- redcapcast_data
#' ## data |> time_only_correction()
time_only_correction <- function(data, ...) {
  nms <- guess_time_only_filter(data, ...)
  z <- nms |>
    lapply(\(y) {
      readr::parse_time(format(data[[y]], format = "%H:%M:%S"))
    }) |>
    suppressMessages(dplyr::bind_cols()) |>
    stats::setNames(nm = nms)
  data[nms] <- z
  data
}

#' Change "hms" to "character" for REDCap upload.
#'
#' @param data data set
#'
#' @return data.frame or tibble
#'
#' @examples
#' data <- redcapcast_data
#' ## data |> time_only_correction() |> hms2character()
hms2character <- function(data) {
  data |>
    lapply(function(x) {
      if ("hms" %in% class(x)) {
        as.character(x)
      } else {
        x
      }
    }) |>
    dplyr::bind_cols()
}

#' Extract data from stata file for data dictionary
#'
#' @details
#' This function is a natural development of the ds2dd() function. It assumes
#' that the first column is the ID-column. No checks.
#' Please, do always inspect the data dictionary before upload.
#'
#' Ensure, that the data set is formatted with as much information as possible.
#'
#' `field.type` can be supplied
#'
#' @param data data frame
#' @param date.format date format, character string. ymd/dmy/mdy. dafault is
#' dmy.
#' @param add.auto.id flag to add id column
#' @param form.name manually specify form name(s). Vector of length 1 or
#' ncol(data). Default is NULL and "data" is used.
#' @param field.type manually specify field type(s). Vector of length 1 or
#' ncol(data). Default is NULL and "text" is used for everything but factors,
#' which wil get "radio".
#' @param field.label manually specify field label(s). Vector of length 1 or
#' ncol(data). Default is NULL and colnames(data) is used or attribute
#' `field.label.attr` for haven_labelled data set (imported .dta file with
#' `haven::read_dta()`).
#' @param field.label.attr attribute name for named labels for haven_labelled
#' data set (imported .dta file with `haven::read_dta()`. Default is "label"
#' @param field.validation manually specify field validation(s). Vector of
#' length 1 or ncol(data). Default is NULL and `levels()` are used for factors
#' or attribute `factor.labels.attr` for haven_labelled data set (imported .dta file with
#' `haven::read_dta()`).
#' @param metadata redcap metadata headings. Default is
#' REDCapCAST:::metadata_names.
#' @param validate.time Flag to validate guessed time columns
#' @param time.var.sel.pos Positive selection regex string passed to
#' `gues_time_only_filter()` as sel.pos.
#' @param time.var.sel.neg Negative selection regex string passed to
#' `gues_time_only_filter()` as sel.neg.
#'
#' @return list of length 2
#' @export
#'
#' @examples
#' data <- redcapcast_data
#' data |> ds2dd_detailed(validate.time = TRUE)
#' data |> ds2dd_detailed()
#' iris |> ds2dd_detailed(add.auto.id = TRUE)
#' mtcars |> ds2dd_detailed(add.auto.id = TRUE)
ds2dd_detailed <- function(data,
                           add.auto.id = FALSE,
                           date.format = "dmy",
                           form.name = NULL,
                           field.type = NULL,
                           field.label = NULL,
                           field.label.attr ="label",
                           field.validation = NULL,
                           metadata = metadata_names,
                           validate.time = FALSE,
                           time.var.sel.pos = "[Tt]i[d(me)]",
                           time.var.sel.neg = "[Dd]at[eo]") {
  ## Handles the odd case of no id column present
  if (add.auto.id) {
    data <- dplyr::tibble(
      default_trial_id = seq_len(nrow(data)),
      data
    )
    message("A default id column has been added")
  }

  if (validate.time) {
    return(data |> guess_time_only_filter(validate = TRUE))
  }

  if (lapply(data, haven::is.labelled) |> (\(x)do.call(c, x))() |> any()) {
    message("Data seems to be imported with haven from a Stata (.dta) file and will be treated as such.")
    data.source <- "dta"
  } else {
    data.source <- ""
  }

  ## data classes

  ### Only keeps the first class, as time fields (POSIXct/POSIXt) has two classes
  if (data.source == "dta") {
    data_classes <-
      data |>
      haven::as_factor() |>
      time_only_correction(sel.pos = time.var.sel.pos, sel.neg = time.var.sel.neg) |>
      lapply(\(x)class(x)[1]) |>
      (\(x)do.call(c, x))()
  } else {
    data_classes <-
      data |>
      time_only_correction(sel.pos = time.var.sel.pos, sel.neg = time.var.sel.neg) |>
      lapply(\(x)class(x)[1]) |>
      (\(x)do.call(c, x))()
  }

  ## ---------------------------------------
  ## Building the data dictionary
  ## ---------------------------------------

  ## skeleton

  dd <- data.frame(matrix(ncol = length(metadata), nrow = ncol(data))) |>
    stats::setNames(metadata) |>
    dplyr::tibble()

  dd$field_name <- gsub(" ", "_", tolower(colnames(data)))

  ## form_name
  if (is.null(form.name)) {
    dd$form_name <- "data"
  } else {
    if (length(form.name) == 1 | length(form.name) == nrow(dd)) {
      dd$form_name <- form.name
    } else {
      stop("Length of supplied 'form.name' has to be one (1) or ncol(data).")
    }
  }

  ## field_label

  if (is.null(field.label)) {
    if (data.source == "dta") {
      label <- data |>
        lapply(function(x) {
          if (haven::is.labelled(x)) {
            attributes(x)[[field.label.attr]]
          } else {
            NA
          }
        }) |>
        (\(x)do.call(c, x))()
    } else {
      label <- data |> colnames()
    }

    dd <-
      dd |> dplyr::mutate(field_label = dplyr::if_else(is.na(label), field_name, label))
  } else {
    if (length(field.label) == 1 | length(field.label) == nrow(dd)) {
      dd$field_label <- field.label
    } else {
      stop("Length of supplied 'field.label' has to be one (1) or ncol(data).")
    }
  }


  ## field_type

  if (is.null(field.type)) {
    dd$field_type <- "text"

    dd <-
      dd |> dplyr::mutate(field_type = dplyr::if_else(data_classes == "factor", "radio", field_type))
  } else {
    if (length(field.type) == 1 | length(field.type) == nrow(dd)) {
      dd$field_type <- field.type
    } else {
      stop("Length of supplied 'field.type' has to be one (1) or ncol(data).")
    }
  }

  ## validation

  if (is.null(field.validation)) {
    dd <-
      dd |> dplyr::mutate(
        text_validation_type_or_show_slider_number = dplyr::case_when(
          data_classes == "Date" ~ paste0("date_", date.format),
          data_classes ==
            "hms" ~ "time_hh_mm_ss",
          ## Self invented format after filtering
          data_classes ==
            "POSIXct" ~ paste0("datetime_", date.format),
          data_classes ==
            "numeric" ~ "number"
        )
      )
  } else {
    if (length(field.validation) == 1 | length(field.validation) == nrow(dd)) {
      dd$text_validation_type_or_show_slider_number <- field.validation
    } else {
      stop("Length of supplied 'field.validation' has to be one (1) or ncol(data).")
    }
  }



  ## choices

  if (data.source == "dta") {
    factor_levels <- data |>
      lapply(function(x) {
        if (haven::is.labelled(x)) {
          att <- attributes(x)$labels
          paste(paste(att, names(att), sep = ", "), collapse = " | ")
        } else {
          NA
        }
      }) |>
      (\(x)do.call(c, x))()
  } else {
    factor_levels <- data |>
      lapply(function(x) {
        if (is.factor(x)) {
          ## Re-factors to avoid confusion with missing levels
          ## Assumes alle relevant levels are represented in the data
          re_fac <- factor(x)
          paste(paste(unique(as.numeric(re_fac)), levels(re_fac), sep = ", "), collapse = " | ")
        } else {
          NA
        }
      }) |>
      (\(x)do.call(c, x))()
  }

  dd <-
    dd |> dplyr::mutate(
      select_choices_or_calculations = dplyr::if_else(
        is.na(factor_levels),
        select_choices_or_calculations,
        factor_levels
      )
    )

  list(
    data = data |>
      time_only_correction(sel.pos = time.var.sel.pos, sel.neg = time.var.sel.neg) |>
      hms2character() |>
      (\(x)stats::setNames(x, tolower(names(x))))(),
    meta = dd
  )
}

### Completion
#' Completion marking based on completed upload
#'
#' @param upload output list from `REDCapR::redcap_write()`
#' @param ls output list from `ds2dd_detailed()`
#'
#' @return list with `REDCapR::redcap_write()` results
mark_complete <- function(upload, ls){
  data <- ls$data
  meta <- ls$meta
  forms <- unique(meta$form_name)
  cbind(data[[1]][data[[1]] %in% upload$affected_ids],
        data.frame(matrix(2,ncol=length(forms),nrow=upload$records_affected_count))) |>
    stats::setNames(c(names(data)[1],paste0(forms,"_complete")))
}
