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

#' Deploy the Shiny app with rsconnect
#'
#' @param path app folder path
#' @param name.app name of deployed app
#'
#' @return deploy
#' @export
#'
#' @examples
#' # deploy_shiny
#'
deploy_shiny <- function(path = here::here("app/"), name.app = "shiny_cast") {
  # Connecting
  rsconnect::setAccountInfo(
    name = "cognitiveindex",
    token = keyring::key_get(service = "rsconnect_cognitiveindex_token"),
    secret = keyring::key_get(service = "rsconnect_cognitiveindex_secret")
  )

  # Deploying
  rsconnect::deployApp(appDir = path, lint = TRUE, appName = name.app, )
}
