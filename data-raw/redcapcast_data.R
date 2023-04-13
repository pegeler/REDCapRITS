## code to prepare `redcapcast_data` dataset goes here

redcapcast_data <- REDCapR::redcap_read(redcap_uri = uri,
                                        token = keyring::key_get("cast_api"),
                                        raw_or_label = "label"
                                        )$data

usethis::use_data(redcapcast_data, overwrite = TRUE)
