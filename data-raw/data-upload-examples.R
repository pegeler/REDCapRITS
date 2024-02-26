mtcars |> dplyr::mutate(record_id=seq_len(n()),
                        name=rownames(mtcars)
                        ) |>
  dplyr::select(record_id,dplyr::everything()) |>
  write.csv(here::here("data/mtcars_redcap.csv"),row.names = FALSE)
