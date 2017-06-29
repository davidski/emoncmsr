#' Send a request to emonCMS
#'
#' @return An httr response object
#' @param verbose if set (boolean), will warn on the query parameters to be sent
#' @export
send_emon_request <- function(uri, params = NULL, verbose = FALSE) {
  url <- paste0(emoncms_uri(), uri)
  # currently add the API key to the query string as header support is
  # broken on emoncms.org and only available on emoncms master as of 6/27/17
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
#' @return The URI to the emonCMS endpoint.
#' @export
emoncms_uri <- function() {
  Sys.getenv("EMONCMS_URI")
}

#' Fetch the emonCMS API key from the environment.
#'
#' @return The API key to use for the emonCMS server.
#' @export
emoncms_api_key <- function() {
  Sys.getenv("EMONCMS_API_KEY")
}