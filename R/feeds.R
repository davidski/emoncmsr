emoncms_uri <- Sys.getenv("EMONCMS_URI")
api_key <- Sys.getenv("EMONCMS_APIKEY")

#' Determine fonts we can/should use.
#'
#' @return An httr response object
#' @export
send_emon_request <- function(uri, params = NULL, verbose = FALSE) {
  url <- paste0(emoncms_uri, uri)
  if (verbose) warning("Sending query params", (params))
  response <- httr::POST(url, query = params,
             httr::add_headers("Authorization" = paste("Bearer", api_key)))
  response
}

#' Determine fonts we can/should use.
#'
#' @return An httr response object
#' @export
list_feeds <- function(authenticated = TRUE) {
  send_emon_request("feed/list.json", if (!authenticated) {list(userid = 0)}) %>%
    httr::content(as = "text", encoding = "UTF-8") %>% jsonlite::fromJSON() %>%
    tibble::as_tibble()
}

#' Determine fonts we can/should use.
#'
#' @return An httr response object
#' @export
get_feed_values <- function(id = 1) {
  dat <- if (length(id) == 1) {
    send_emon_request("feed/value.json", list(id=id))
  } else {
    send_emon_request("feed/fetch.json", list(ids=paste(id, collapse = ",")))
  } %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
  tibble::tibble(feed_id = id, values = dat)
}

#' Determine fonts we can/should use.
#'
#' @return An httr response object
#' @export
get_feed_metadata <- function(id) {
  send_emon_request("feed/getmeta.json", list(id = id)) %>%
    httr::content(as = "text", encoding = "UTF-8") %>% jsonlite::fromJSON() %>%
    dplyr::bind_rows() %>% dplyr::bind_cols(feed_id = id, .)
}

#' Determine fonts we can/should use.
#'
#' @return An httr response object
#' @export
get_feed_data <- function(id,
                          start = as.integer(lubridate::now() - lubridate::ddays(7)),
                          end = as.integer(lubridate::now()),
                          interval = 60*30) {
  start <- ceiling(start / interval) * interval * 1000
  end <- ceiling(end / interval) * interval * 1000
  send_emon_request("feed/data.json", list(id = id, start = start, end = end,
                                           interval = interval)) %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON() %>%
    tibble::as_tibble() %>%
    mutate(V1 = as.POSIXct(V1/1000, origin = "1970-01-01")) %>%
    rename(date= V1, value = V2) %>%
    mutate(feed_id = id)
}

#' Determine fonts we can/should use.
#'
#' seems to be redundent with the get_feeds function
#' @return An httr response object
#' @export
get_feed_fields <- function(id) {
  #https://emoncms.org/feed/aget.json?id=1
  send_emon_request("feed/aget.json", list(id = id)) %>%
    httr::content(as = "text", encoding = "UTF-8")
}

#' Determine fonts we can/should use.
#'
#' seems to be redundent with the get_feeds function
#' @return An httr response object
#' @export
read_feed_file <- function(feed_id) {
  bytes_per_record <- 4

  metadata_file <- paste0(feed_id, ".meta")
  if (!file.exists(metadata_file)) stop("Feed metadata file not found")
  data_file <- paste0(feed_id, ".dat")
  if (!file.exists(data_file)) stop("Feed data file not found")

  # fetch metadata
  con <- file(metadata_file, "rb")
  meta <- readBin(con, "int", size = 4, n = 5)
  interval <- meta[3]
  starttime <- meta[4]
  close(con)

  # calculate number of records based upon file and record size
  rec_count <- file.info(data_file) %>% dplyr::pull(size) /
    bytes_per_record

  # read in records
  con <- file(data_file, "rb")
  dat <- readBin(con, "double", size = 4, n = rec_count) %>%
    readr::parse_number(na = "NaN")
  close(con)

  # calculate timestamps for data points
  startdate <- as.POSIXlt(starttime, origin="1970-01-01")
  dates <- seq(startdate, by = lubridate::dseconds(interval), along.with = dat)

  # return a time series object
  xts::xts(x = dat, order.by = dates)
}
