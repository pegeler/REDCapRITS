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
    keyring::key_set(service = key.name, prompt = "Provide REDCap API key:")
    keyring::key_get(service = key.name)
  }
}


#' Secure API key storage and data acquisition in one
#'
#' @param project.name The name of the current project (for key storage with
#' `keyring::key_set()`, using the default keyring)
#' @param widen.data argument to widen the exported data
#' @param uri REDCap database API uri
#' @param ... arguments passed on to `REDCapCAST::read_redcap_tables()`
#'
#' @return data.frame or list depending on widen.data
#' @export
easy_redcap <- function(project.name, widen.data = TRUE, uri, ...) {
  key <- get_api_key(key.name = paste0(project.name, "_REDCAP_API"))

  out <- read_redcap_tables(
    uri = uri,
    token = key,
    ...
  )

  if (widen.data) {
    out <- out |> redcap_wider()
  }

  out
}
