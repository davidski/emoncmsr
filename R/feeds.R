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
    jsonlite::fromJSON() %>%
    tibble::as_tibble()
}

#' Create a new feed.
#'
#' @param name Descriptive name for the new feed.
#' @param tag Tag for the new feed.
#' @param datatype Defaults to REALTIME (1). May also be DAILY (2).
#' @param engine Timeseries storage engine. Defaults to PHPFINA (5). May
#'     also be VIRTUAL (7)).
#' @param interval Interval of time series in seconds. Defaults to 10.
#' @importFrom dplyr %>%
#' @return Tibble with id of new feed
#' @export
create_feed <- function(name, tag, datatype = c("realtime", "daily"), engine = c("phpfina", "virtual"),
                        interval = 10) {
  datatypes <- c("realtime" = 1, "daily" = 2)
  datatype <- unname(datatypes[match.arg(datatype)])
  engines <- c("phpfina" = 5, "virtual" = 7)
    engine <- unname(engines[match.arg(engine)])
    list_params <- list(tag = tag, name = name, datatype = datatype,
                        engine = engine,
                        options = paste0('{"interval":', interval, '}'))
    send_emon_request("feed/create.json", params = list_params) %>%
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
    dat <- send_emon_request("feed/delete.json", list(id = feedid)) %>%
      jsonlite::fromJSON()
    if (is.null(dat)) {
      tibble::tibble(success = TRUE)
    } else {
      tibble::as_tibble(dat)
    }
}

#' Retrieve the number of buffer points pending write
#'
#' Checks the number of cached data feed points in the emonCMS cache layer
#' (typically Redis) that have not yet been saved to disk.
#'
#' @return Number (integer) of data points pending flush to disk
#' @importFrom dplyr %>%
#' @export
get_buffer_size <- function() {
    send_emon_request("feed/buffersize.json") %>%
      as.integer()
}


#' Retrieve the current consumed size of all feeds
#'
#' @return Integer of bytes consumed
#' @importFrom dplyr %>%
#' @export
get_feed_size <- function() {
    send_emon_request("feed/updatesize.json") %>%
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
    dat <- jsonlite::fromJSON(dat)

    # attempt to return a more consistent response
    if ("success" %in% names(dat)) {
      tibble::as_tibble(dat) }
    else {
      tibble::tibble(feed_id = feedid, value = dat)
    }
}

#' Gets metadata information for a data feed.
#'
#' @param feedid Feed ID to retrieve.
#' @return A tibble of metadata information
#' @export
#' @importFrom dplyr %>%
get_feed_metadata <- function(feedid) {
    send_emon_request("feed/getmeta.json", list(id = feedid)) %>%
        jsonlite::fromJSON() %>% dplyr::bind_rows() %>%
        dplyr::bind_cols(feed_id = feedid, .)
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
      jsonlite::fromJSON() %>% tibble::as_tibble() %>%
      dplyr::mutate(V1 = as.POSIXct(V1/1000, origin = "1970-01-01")) %>%
      dplyr::rename(date = V1, value = V2) %>%
      dplyr::mutate(feed_id = feedid)
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
