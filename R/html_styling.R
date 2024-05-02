#' Create two-column HTML table for data piping in REDCap instruments
#'
#' @param text descriptive text
#' @param variable variable to pipe
#'
#' @return character vector
#' @export
#'
#' @examples
#' create_html_table(text = "Patient ID", variable = c("[cpr]"))
#' create_html_table(text = paste("assessor", 1:2, sep = "_"), variable = c("[cpr]"))
#' # create_html_table(text = c("CPR nummer","Word"), variable = c("[cpr][1]", "[cpr][2]", "[test]"))
create_html_table <- function(text, variable) {
  assertthat::assert_that(length(text)>1 & length(variable)==1 |
                            length(text)==1 & length(variable)>1 |
                            length(text)==length(variable),
                          msg = "text and variable has to have same length, or one has to have length 1")

  start <- '<table style="border-collapse: collapse; width: 100%;" border="0"> <tbody>'
  end <- "</tbody> </table>"

  # Extension would allow defining number of columns and specify styling
  items <- purrr::map2(text, variable, function(.x, .y) {
    glue::glue('<tr> <td style="width: 58%;"> <h5><span style="font-weight: normal;">{.x}<br /></span></h5> </td> <td style="width: 42%; text-align: left;"> <h5><span style="font-weight: bold;">{.y}</span></h5> </td> </tr>')
  })

  glue::glue(start, glue::glue_collapse(purrr::list_c(items)), end)
}

#' Simple html tag wrapping for REDCap text formatting
#'
#' @param data character vector
#' @param tag character vector length 1
#' @param extra character vector
#'
#' @return character vector
#' @export
#'
#' @examples
#' html_tag_wrap("Titel", tag = "div", extra = 'class="rich-text-field-label"')
#' html_tag_wrap("Titel", tag = "h2")
html_tag_wrap <- function(data, tag = "h2", extra = NULL) {
  et <- ifelse(is.null(extra), "", paste0(" ", extra))
  glue::glue("<{tag}{et}>{data}</{tag}>")
}


#' Sub-header formatting wrapper
#'
#' @param data character vector
#' @param tag character vector length 1
#'
#' @return character vector
#' @export
#'
#' @examples
#' "Instrument header" |> format_subheader()
format_subheader <- function(data, tag = "h2") {
  dplyr::if_else(is.na(data) | data == "",
                 NA,
                 data |>
                   html_tag_wrap(tag = tag) |>
                   html_tag_wrap(
                     tag = "div",
                     extra = 'class="rich-text-field-label"'
                   )
  )
}
