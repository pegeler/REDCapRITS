ui <- shiny::shinyUI(
  shiny::fluidPage(
    theme = shinythemes::shinytheme("united"),

    ## -----------------------------------------------------------------------------
    ## Application title
    ## -----------------------------------------------------------------------------


    # customHeaderPanel(title = "REDCapCAST: data base creation and data upload from data set file",
    #                   windowTitle = "REDCap database creator"
    # ),

    shiny::titlePanel(title = shiny::div(shiny::a(shiny::img(src="logo.png"),href="https://agdamsbo.github.io/REDCapCAST"),
                                  "Easy REDCap database creation"),
      windowTitle = "REDCap database creator"
    ),
    shiny::h4("This tool includes to convenient functions:",
              shiny::br(),
              "1) creating a REDCap data dictionary based on a spreadsheet (.csv/.xls(x)/.dta) and",
              shiny::br(),
              "2) creating said database on a given REDCap server and uploading the dataset via API access."),


    ## -----------------------------------------------------------------------------
    ## Side panel
    ## -----------------------------------------------------------------------------

    shiny::sidebarPanel(
      shiny::h4("1) REDCap datadictionary and compatible dataset"),
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
         corresponding data dictionary for a new data base, if you want to upload manually."),
      # Button
      shiny::downloadButton("downloadData", "Download data"),

      # Button
      shiny::downloadButton("downloadMeta", "Download datadictionary"),


      # Horizontal line ----
      shiny::tags$hr(),
      shiny::h4("2) REDCap upload"),
      shiny::h6("This tool is usable for now. Detailed instructions are coming."),
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
      shiny::h6("An API key is an access key to the REDCap database. Please", shiny::a("see here for directions", href="https://www.iths.org/news/redcap-tip/redcap-api-101/"), " to obtain an API key for your project."),
      shiny::actionButton(
        inputId = "upload.meta",
        label = "Upload datadictionary", icon = shiny::icon("book-bookmark")
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
    ),


    # close sidebarLayout

    shiny::br(),
    shiny::br(),
    shiny::br(),
    shiny::br(),
    shiny::hr(),
    shiny::tags$footer(shiny::strong("Disclaimer: "),
                       "This tool is aimed at demonstrating use of REDCapCAST. No responsibility for data loss or any other problems will be taken. Please contact me for support.",
                       shiny::br(),
                       shiny::a("License: GPL-3+",href="https://agdamsbo.github.io/REDCapCAST/LICENSE.html"),
                       "|",
                       shiny::a("agdamsbo/REDCapCAST",href="https://agdamsbo.github.io/REDCapCAST"),
                       "|",
                       shiny::a("Source",href="https://github.com/agdamsbo/REDCapCAST"),
                       "|",
                       shiny::a("Contact",href="https://andreas.gdamsbo.dk"),
                align = "center",
                style = "
                 position:fixed;
                 bottom:40px;
                 width:100%;
                 height:20px;
                 color: black;
                 padding: 0px;
                 background-color: White;
                 z-index: 100;
                ")
  )
)
