#' Shiny server factory
#'
#' @return shiny server
#' @export
server_factory <- function() {
  function(input, output, session) {
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
    output$upload.data.print <- shiny::renderPrint({
      shiny::eventReactive(input$upload.meta, {
        shiny::req(input$uri)

        shiny::req(input$api)

        REDCapR::redcap_metadata_write(
          ds = purrr::pluck(dd(), "meta"),
          redcap_uri = input$uri,
          token = input$api
        )
      })
    })

    output$upload.data.print <- shiny::renderPrint({
      shiny::eventReactive(input$upload.data, {
        shiny::req(input$uri)

        shiny::req(input$api)

        REDCapR::redcap_write(
          ds = purrr::pluck(dd(), "data"),
          redcap_uri = input$uri,
          token = input$api
        )
      })
    })
  }
}



#' UI factory for shiny app
#'
#' @return shiny ui
#' @export
ui_factory <- function() {
  # require(ggplot2)

  shiny::fluidPage(

    ## -----------------------------------------------------------------------------
    ## Application title
    ## -----------------------------------------------------------------------------
    shiny::titlePanel("Simple REDCap data base creation and data upload from data set file via API",
      windowTitle = "REDCap databse creator"
    ),
    shiny::h5("Please note, that this tool serves as a demonstration of some of the functionality
       of the REDCapCAST package. No responsibility for data loss or any other
       problems will be taken."),

    ## -----------------------------------------------------------------------------
    ## Side panel
    ## -----------------------------------------------------------------------------

    shiny::sidebarPanel(
      shiny::h4("REDCap database and dataset"),
      shiny::fileInput("ds", "Choose data file",
        multiple = FALSE,
        accept = c(
          ".csv",
          ".xls",
          ".xlsx",
          ".dta"
        )
      ),
      shiny::h6("Below you can download the dataset formatted for upload and the
         corresponding data dictionary for a new data base."),
      # Button
      shiny::downloadButton("downloadData", "Download data"),

      # Button
      shiny::downloadButton("downloadMeta", "Download dictionary"),


      # Horizontal line ----
      shiny::tags$hr(),
      shiny::h4("REDCap upload"),
      shiny::textInput(
        inputId = "uri",
        label = "URI",
        value = ""
      ),
      shiny::textInput(
        inputId = "api",
        label = "API key",
        value = ""
      ),
      shiny::actionButton(
        inputId = "upload.meta",
        label = "Upload dictionary", icon = icon("book-bookmark")
      ),
      shiny::h6("Please note, that before uploading any real data, put your project
         into production mode."),
      shiny::actionButton(
        inputId = "upload.datata",
        label = "Upload data", icon = icon("upload")
      ),

      # Horizontal line ----
      shiny::tags$hr()
    ),
    shiny::mainPanel(
      shiny::tabsetPanel(

        ## -----------------------------------------------------------------------------
        ## Summary tab
        ## -----------------------------------------------------------------------------
        shiny::tabPanel(
          "Summary",
          shiny::h3("Data overview (first 20)"),
          shiny::htmlOutput("data.tbl", container = span),
          shiny::h3("Dictionary overview"),
          shiny::htmlOutput("meta.tbl", container = span)
        )
      )
    )
  )
}

#' Launch the included Shiny-app for database casting and upload
#'
#' @return shiny app
#' @export
#'
#' @examples
#' # shiny_cast()
#'
shiny_cast <- function() {
  # shiny::runApp(appDir = here::here("app/"), launch.browser = TRUE)

  shiny::shinyApp(
    ui_factory(),
    server_factory()
  )
}
