#' Send a request to emonCMS
#'
#' @return An httr response object
#' @export
send_emon_request <- function(uri, params = NULL, verbose = FALSE) {
  url <- paste0(emoncms_uri(), uri)
  query_params <- list(apikey = emoncms_api_key())
  query_params <- c(query_params, params)
  if (verbose)
    warning("Sending query params", (params))
  response <- httr::GET(url, query = query_params,
                        httr::add_headers(Authorization =
                                             paste("Bearer", emoncms_api_key())))
  response
}

#' Fetch URI to the emoncms server
#'
#' @return Returns the URI to the emonCMS endpoint.
#' @export
emoncms_uri <- function() {
  Sys.getenv("EMONCMS_URI")
}

#' Fetch the emonCMS API key from the environment.
#'
#' @return Returns the API key to use for the emonCMS server.
#' @export
emoncms_api_key <- function() {
  Sys.getenv("EMONCMS_API_KEY")
}