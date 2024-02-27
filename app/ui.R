ui <- shiny::fluidPage(

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
      value = "https://redcap.your.institution/api/"
    ),
    shiny::textInput(
      inputId = "api",
      label = "API key",
      value = ""
    ),
    shiny::actionButton(
      inputId = "upload.meta",
      label = "Upload dictionary", icon = shiny::icon("book-bookmark")
    ),
    shiny::h6("Please note, that before uploading any real data, put your project
         into production mode."),
    shiny::actionButton(
      inputId = "upload.data",
      label = "Upload data", icon = shiny::icon("upload")
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
        shiny::htmlOutput("data.tbl", container = shiny::span),
        shiny::h3("Dictionary overview"),
        shiny::htmlOutput("meta.tbl", container = shiny::span)
      ),
      ## -----------------------------------------------------------------------------
      ## Upload tab
      ## -----------------------------------------------------------------------------
      shiny::tabPanel(
        "Upload",
        shiny::h3("Meta upload overview"),
        shiny::htmlOutput("upload.meta.print", container = shiny::span),
        shiny::h3("Data upload overview"),
        shiny::htmlOutput("upload.data.print", container = shiny::span)
      )
    )
  )
)
