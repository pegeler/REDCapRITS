## code to prepare `redcapcast_data` dataset goes here

redcapcast_data <- REDCapR::redcap_read(
  redcap_uri = keyring::key_get("DB_URI"),
  token = keyring::key_get("cast_api"),
  raw_or_label = "label"
)$data |> dplyr::tibble()

# redcapcast_data <- easy_redcap(project.name = "redcapcast_pacakge",
#                                uri = keyring::key_get("DB_URI"),
#                                widen.data = FALSE)

usethis::use_data(redcapcast_data, overwrite = TRUE)
