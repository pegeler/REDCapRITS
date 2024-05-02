#' User input processing
#'
#' @param x input
#'
#' @return processed input
#' @export
process_user_input <- function(x) {
  UseMethod("process_user_input", x)
}

#' User input processing default
#'
#' @param x input
#' @param ... ignored
#'
#' @return processed input
#' @export
process_user_input.default <- function(x, ...) {
  stop(
    deparse(substitute(x)),
    " must be a 'data.frame',",
    " a 'response',",
    " or a 'character' vector containing JSON.",
    call. = FALSE
  )
}


#' User input processing data.frame
#'
#' @param x input
#' @param ... ignored
#'
#' @return processed input
#' @export
process_user_input.data.frame <- function(x, ...) {
  x
}

#' User input processing character
#'
#' @param x input
#' @param ... ignored
#'
#' @return processed input
#' @export
process_user_input.character <- function(x, ...) {
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop(
      "The package 'jsonlite' is needed to convert ",
      deparse(substitute(x)),
      " into a data frame.",
      "\n       Either install 'jsonlite' or pass ",
      deparse(substitute(x)),
      " as a 'data.frame'.",
      call. = FALSE
    )
  }

  jsonlite::fromJSON(x)
}


#' User input processing response
#'
#' @param x input
#' @param ... ignored
#'
#' @return processed input
#' @export
process_user_input.response <- function(x, ...) {
  process_user_input(rawToChar(x$content))
}
