match_fields_to_form <- function(metadata, vars_in_data) {

  fields <- metadata[
    !metadata$field_type %in% c("descriptive", "checkbox"),
    c("field_name", "form_name")
  ]

  # Process instrument status fields
  form_names <- unique(metadata$form_name)
  form_complete_fields <- data.frame(
    field_name = paste0(form_names, "_complete"),
    form_name = form_names,
    stringsAsFactors = FALSE
  )

  fields <- rbind(fields, form_complete_fields)

  # Process checkbox fields
  if (any(metadata$field_type == "checkbox")) {

    checkbox_basenames <- metadata[
      metadata$field_type == "checkbox",
      c("field_name", "form_name")
    ]

    checkbox_fields <-
      do.call(
        "rbind",
        apply(
          checkbox_basenames,
          1,
          function(x, y)
            data.frame(
              field_name = y[grepl(paste0("^", x[1], "___((?!\\.factor).)+$"), y, perl = TRUE)],
              form_name = x[2],
              stringsAsFactors = FALSE,
              row.names = NULL
            ),
          y = vars_in_data
        )
      )

    fields <- rbind(fields, checkbox_fields)

  }

  # Process ".*\\.factor" fields supplied by REDCap's export data R script
  if (any(grepl("\\.factor$", vars_in_data))) {

    factor_fields <-
      do.call(
        "rbind",
        apply(
          fields,
          1,
          function(x, y) {
            field_indices <- grepl(paste0("^", x[1], "\\.factor$"), y)
            if (any(field_indices))
              data.frame(
                field_name = y[field_indices],
                form_name = x[2],
                stringsAsFactors = FALSE,
                row.names = NULL
              )
          },
          y = vars_in_data
        )
      )

    fields <- rbind(fields, factor_fields)

  }

  fields

  }
