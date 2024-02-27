mtcars_redcap <- mtcars |> dplyr::mutate(record_id=seq_len(dplyr::n()),
                        name=rownames(mtcars)
                        ) |>
  dplyr::select(record_id,dplyr::everything())

mtcars_redcap |>
  write.csv(here::here("data/mtcars_redcap.csv"),row.names = FALSE)

usethis::use_data(mtcars_redcap, overwrite = TRUE)
