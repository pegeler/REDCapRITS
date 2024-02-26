server <- function(input, output, session) {
  require(REDCapCAST)

  dat <- shiny::reactive({
    shiny::req(input$ds)

    read_input(input$ds$datapath)
  })

  dd <- shiny::reactive({
    ds2dd_detailed(data = dat())
  })


  output$data.tbl <- shiny::renderTable({
    dd() |>
      purrr::pluck("data") |>
      head(20) |>
      dplyr::tibble()
  })

  output$meta.tbl <- shiny::renderTable({
    dd() |>
      purrr::pluck("meta") |>
      dplyr::tibble()
  })

  # Downloadable csv of dataset ----
  output$downloadData <- shiny::downloadHandler(
    filename = "data_ready.csv",
    content = function(file) {
      write.csv(purrr::pluck(dd(), "data"), file, row.names = FALSE)
    }
  )

  # Downloadable csv of data dictionary ----
  output$downloadMeta <- shiny::downloadHandler(
    filename = "dictionary_ready.csv",
    content = function(file) {
      write.csv(purrr::pluck(dd(), "meta"), file, row.names = FALSE)
    }
  )

  output_staging <- shiny::reactiveValues()
  output_staging$meta <- output_staging$data <- NA

  shiny::observeEvent(input$upload.meta,{  upload_meta()  })

  shiny::observeEvent(input$upload.data,{  upload_data()  })

  upload_meta <- function(){

    shiny::req(input$uri)

    shiny::req(input$api)

    output_staging$meta <- REDCapR::redcap_metadata_write(
      ds = purrr::pluck(dd(), "meta"),
      redcap_uri = input$uri,
      token = input$api
    )|> purrr::pluck("success")
  }

  upload_data <- function(){

    shiny::req(input$uri)

    shiny::req(input$api)

    output_staging$data <- REDCapR::redcap_write(
      ds = purrr::pluck(dd(), "data"),
      redcap_uri = input$uri,
      token = input$api
    ) |> purrr::pluck("success")
  }

  output$upload.meta.print <- renderText(output_staging$meta)

  output$upload.data.print <- renderText(output_staging$data)

}
