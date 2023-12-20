
#' Retrieve project API key if stored, if not, set and retrieve
#'
#' @param key.name character vector of key name
#'
#' @return character vector
#' @importFrom keyring key_list key_get key_set
#' @export
get_api_key <- function(key.name) {
  if (key.name %in% keyring::key_list()$service) {
    keyring::key_get(service = key.name)
  } else {
    keyring::key_set(service = key.name, prompt = "Write REDCap API key:")
    keyring::key_get(service = key.name)
  }
}


#' Secure API key storage and data acquisition in one
#'
#' @param project.name The name of the current project (for key storage with
#' `keyring::key_set()`)
#' @param widen.data argument to widen the exported data
#' @param ... arguments passed on to `REDCapCAST::read_redcap_tables()`
#'
#' @return data.frame or list depending on widen.data
#' @importFrom purrr reduce
#' @importFrom dplyr left_join
#' @export
easy_redcap <- function(project.name, widen.data = TRUE, ...) {
  project.name <- "ENIGMA"

  key <- get_api_key(key.name = paste0(project.name, "_REDCAP_API"))

  out <- read_redcap_tables(
    token = key,
    ...
  )

  all_names <- out |>
    lapply(names) |>
    Reduce(c, x = _) |>
    unique()

  if (widen.data) {
    if (!any(c("redcap_event_name", "redcap_repeat_instrument") %in%
      all_names)) {
      if (length(out) == 1) {
        out <- out[[1]]
      } else {
        out <- out |> purrr::reduce(dplyr::left_join)
      }
    } else {
      out <- out |> redcap_wider()
    }
  }

  out
}
