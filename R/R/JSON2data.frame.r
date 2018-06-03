JSON2data.frame <- function (x) {

  if (inherits(x, "data.frame")) {

    return(x)

  } else if (inherits(x, "character")) {

    if (requireNamespace("jsonlite", quietly = TRUE)) {

      return(jsonlite::fromJSON(x))

    } else {

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

  } else {

    stop(
      deparse(substitute(x)),
      " must be a 'data.frame' or JSON string of class 'character'.",
      call. = FALSE
    )

  }

}
