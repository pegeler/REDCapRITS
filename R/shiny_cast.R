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

#' Deploy the Shiny app with rsconnect to shinyapps.io
#'
#' @description
#' This is really just a simple wrapper
#'
#' @param path app folder path
#' @param name.app name of deployed app
#' @param name.token stored name of token
#' @param name.secret stored name of secret
#'
#' @return deploy
#' @export
#'
#' @examples
#' # deploy_shiny()
#'
deploy_shiny <- function(path = here::here("app/"),
                         account.name,
                         name.app = "shiny_cast",
                         name.token,
                         name.secret) {
  # Connecting
  rsconnect::setAccountInfo(
    name = account.name,
    token = keyring::key_get(service = name.token),
    secret = keyring::key_get(service = name.secret)
  )

  # Deploying
  rsconnect::deployApp(appDir = path, lint = TRUE, appName = name.app, )
}
