#' Convenience function to download complete instrument, using token storage in keyring.
#'
#' @param key key name in standard keyring for token retrieval.
#' @param uri REDCap database API uri
#' @param instrument instrument name
#' @param raw_or_label raw or label passed to `REDCapR::redcap_read()`
#' @param id_name id variable name. Default is "record_id".
#' @param records specify the records to download. Index numbers. Numeric vector.
#'
#' @return data.frame
#' @export
read_redcap_instrument <- function(key,
                            uri,
                            instrument,
                            raw_or_label = "raw",
                            id_name = "record_id",
                            records = NULL) {
  REDCapCAST::read_redcap_tables(
    records = records,
    uri = uri, token = keyring::key_get(key),
    fields = id_name,
    forms = instrument,
    raw_or_label = raw_or_label
  )[[{{ instrument }}]]
}
