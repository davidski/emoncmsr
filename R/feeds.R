#' Functions for interacting with the emonCMS feeds.

#' List available feeds
#'
#' @param authenticated Retrieve authenticated feeds
#' @return An httr response object
#' @importFrom dplyr %>%
#' @export
list_feeds <- function(authenticated = TRUE) {
    send_emon_request("feed/list.json",
                      if (!authenticated) list(userid = 0)) %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON() %>%
    tibble::as_tibble()
}

#' Delete a feed identified by ID.
#'
#' @param feedid ID (integer) of the feed to delete.
#' @return A tibble of data feed values
#' @importFrom dplyr %>%
#' @export
delete_feed <- function(feedid) {
    send_emon_request("feed/delete.json", list(id = 0)) %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON() %>% tibble::as_tibble()
}

#' Retrieve the current consumed size of all feeds
#'
#' @return Integer of bytes consumed
#' @importFrom dplyr %>%
#' @export
get_feed_size <- function() {
    send_emon_request("feed/updatesize.json") %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
        jsonlite::fromJSON()
  }

#' Retrieve the most current value from a given feed.
#'
#' @param feedid ID (integer) of the feed to retrieve.
#' @return A tibble of data feed values
#' @export
#' @importFrom dplyr %>%
get_feed_values <- function(feedid = 1) {
    dat <- if (length(feedid) == 1) {
        send_emon_request("feed/value.json", list(id = feedid))
    } else {
        send_emon_request("feed/fetch.json",
                          list(ids = paste(feedid, collapse = ",")))
    }
    dat %>% httr::content(as = "text", encoding = "UTF-8") %>%
      jsonlite::fromJSON() %>%
      tibble::tibble(feed_id = feedid, value = .)
}

#' Gets metadata information for a data feed.
#'
#' @param feedid Feed ID to retrieve.
#' @return A tibble of metadata information
#' @export
#' @importFrom dplyr %>%
get_feed_metadata <- function(feedid) {
    send_emon_request("feed/getmeta.json", list(id = feedid)) %>%
        httr::content(as = "text", encoding = "UTF-8") %>%
        jsonlite::fromJSON() %>% dplyr::bind_rows() %>%
        dplyr::bind_cols(feed_id = id, .)
}

#' Get a timerange of data from a feed
#'
#' @param feedid ID of feed
#' @param start Start time (must be coercable by lubridate to unixtime)
#' @param end End time (must be coercable by lubridate to unixtime). Defaults
#'     to now.
#' @return Tibble
#' @export
#' @importFrom dplyr %>%
get_feed_data <- function(feedid, start = as.integer(lubridate::now() -
    lubridate::ddays(7)), end = as.integer(lubridate::now()),
    interval = 60 * 30) {
    start <- ceiling(start/interval) * interval * 1000
    end <- ceiling(end/interval) * interval * 1000
    send_emon_request("feed/data.json",
                      params = list(id = feedid, start = start, end = end,
                                    interval = interval)) %>%
      httr::content(as = "text", encoding = "UTF-8") %>%
      jsonlite::fromJSON() %>% tibble::as_tibble() %>%
      dplyr::mutate(V1 = as.POSIXct(V1/1000, origin = "1970-01-01")) %>%
      dplyr::rename(date = V1, value = V2) %>%
      dplyr::mutate(feed_id = id)
}

#' Get the fields associated with a feed
#'
#' This seems to redundent with the get_feeds function
#' @param feedid ID of the feed
#' @return A tibble with all feed information
#' @export
#' @importFrom dplyr %>%
get_feed_fields <- function(feedid) {
    # https://emoncms.org/feed/aget.json?id=1
    send_emon_request("feed/aget.json", list(id = feedid)) %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON() %>%
    purrr::keep(~ length(.) != 0) %>%
    tibble::as_tibble()
}

#' Set field values for a feed
#'
#' Note that attempting to set a field to its current value will generate
#' a failure.
#'
#' @param feed_id ID of the feed to update
#' @param field Name of field to update
#' @param value New value of field to set
#' @return An httr reponse object
#' @export
#' @importFrom dplyr %>%
set_feed_field <- function(feed_id, field, value) {
  param_list <- list(id = feed_id,
                     fields = paste0('{"', field, '":"', value, '"}'))
  send_emon_request("feed/set.json", params = param_list)
}

#' Read a binary PHPFINA file
#'
#' @return XTS object of the data in the feed.
#' @param file Full path to bare (no file extension) feed
#' @export
#' @importFrom dplyr %>%
read_feed_file <- function(feed_id) {
    bytes_per_record <- 4

    metadata_file <- paste0(feed_id, ".meta")
    if (!file.exists(metadata_file))
        stop("Feed metadata file not found")
    data_file <- paste0(feed_id, ".dat")
    if (!file.exists(data_file))
        stop("Feed data file not found")

    # fetch metadata
    con <- file(metadata_file, "rb")
    meta <- readBin(con, "int", size = 4, n = 5)
    interval <- meta[3]
    starttime <- meta[4]
    close(con)

    # calculate number of records based upon file and
    # record size
    rec_count <- file.info(data_file) %>% dplyr::pull(size)/bytes_per_record

    # read in records
    con <- file(data_file, "rb")
    dat <- readBin(con, "double", size = 4, n = rec_count) %>%
        readr::parse_number(na = "NaN")
    close(con)

    # calculate timestamps for data points
    startdate <- as.POSIXlt(starttime, origin = "1970-01-01")
    dates <- seq(startdate, by = lubridate::dseconds(interval),
        along.with = dat)

    # return a time series object
    xts::xts(x = dat, order.by = dates)
}
