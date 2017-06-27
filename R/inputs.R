#' Functions for interacting with the emonCMS inputs.

#https://emoncms.org/input/list
#' List available feeds
#'
#' @param authenticated Retrieve authenticated feeds
#' @return An httr response object
#' @export
list_inputs <- function() {
}

#' List available feeds
#'
#' @param authenticated Retrieve authenticated feeds
#' @return An httr response object
#' @export
delete_input <- function() {
}


#' List available feeds
#'
#' @param authenticated Retrieve authenticated feeds
#' @return An httr response object
#' @export
post_data_to_input <- function(id, time, value) {
}

#' List available feeds
#'
#' @param authenticated Retrieve authenticated feeds
#' @return An httr response object
#' @export
list_input_processes <- function(inputid) {}

#' List available feeds
#'
#' @param authenticated Retrieve authenticated feeds
#' @return An httr response object
#' @export
add_input_process <- function(inputid, processid, argv, newfeedname) {}

#' List available feeds
#'
#' @param authenticated Retrieve authenticated feeds
#' @return An httr response object
#' @export
delete_input_process <- function(inputid, processid) {}

#' List available feeds
#'
#' @param authenticated Retrieve authenticated feeds
#' @return An httr response object
#' @export
move_input_process <- function(inputid, processid, moveby) {}

#' List available feeds
#'
#' @param authenticated Retrieve authenticated feeds
#' @return An httr response object
#' @export
reset_input_processes <- function(inputid) {}
