utils::globalVariables(c("server"))
#' Shiny server factory
#'
#' @return shiny server
#' @export
server_factory <- function() {
  source(here::here("app/server.R"))
  server
}

#' UI factory for shiny app
#'
#' @return shiny ui
#' @export
ui_factory <- function() {
  # require(ggplot2)
  source(here::here("app/ui.R"))
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

