metadata_names <- c(
  "field_name", "form_name", "section_header", "field_type",
  "field_label", "select_choices_or_calculations", "field_note",
  "text_validation_type_or_show_slider_number", "text_validation_min",
  "text_validation_max", "identifier", "branching_logic", "required_field",
  "custom_alignment", "question_number", "matrix_group_name", "matrix_ranking",
  "field_annotation"
)

usethis::use_data(metadata_names, overwrite = TRUE, internal = TRUE)
