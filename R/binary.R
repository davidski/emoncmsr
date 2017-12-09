#' Read a binary PHPFINA file
#'
#' @return XTS object of the data in the feed.
#' @param feedfile Full path to bare (no file extension) feed
#' @export
#' @importFrom dplyr %>% pull
#' @importFrom xts xts
#' @importFrom readr parse_number
#' @importFrom lubridate dseconds
read_feed_file <- function(feedfile) {
    bytes_per_record <- 4

    metadata_file <- paste0(feedfile, ".meta")
    if (!file.exists(metadata_file))
        stop("Feed metadata file not found")
    data_file <- paste0(feedfile, ".dat")
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
