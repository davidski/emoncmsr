#' Functions for interacting with the emonCMS inputs.

#' List all available inputs
#'
#' @return A tibble of available inputs
#' @importFrom dplyr %>%
#' @export
list_inputs <- function() {
  send_emon_request("input/list") %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
}

#' Delete an input by id
#'
#' @param inputid ID of the input to delete
#' @return An httr response object
#' @export
delete_input <- function(inputid) {
  send_emon_request("input/delete", params = list("inputid" = inputid))
}

#' Post data to an input
#'
#' @param value Data value to post
#' @param nodeid Node ID
#' @return An httr response object
#' @export
post_data_to_input <- function(value, nodeid = "emoncmsr") {
  list_params <- vector(mode = "list", length = 1)
  names(list_params) <- nodeid
  list_params[[nodeid]] <- value
  send_emon_request("input/post", params = list(data = jsonlite::toJSON(list_params)))
}

#' Post data to an input
#'
#' @param value Data value to post
#' @param nodeid Node ID
#' @param timestamp UNIX timestamp
#' @return An httr response object
#' @export
post_bulk_data_to_input <- function(value, nodeid = "emoncmsr",
                                    timestamp = as.integer(Sys.time())) {
  list_params <- list(data = jsonlite::toJSON(c(timestamp, "test", value)))
  send_emon_request("input/bulk", params = list_params)
}

#' List input processes
#'
#' List all of the processes associated with a given input.
#'
#' @param inputid Input ID to get process list.
#' @return An httr response object
#' @export
list_input_processes <- function(inputid) {
  send_emon_request("input/process/list", params = list(inputid = inputid))
}

#' Add input process
#'
#' Add a processing step to a given input. The processing step will be
#' placed after an existing process steps.
#'
#' @param inputid Input to add the process step
#' @param processid ID of the processing type to add
#' @param arg Arguments for the processing feed
#' @param newfeedname New feed name
#' @return An httr response object
#' @export
add_input_process <- function(inputid, processid, arg, newfeedname) {
  send_emon_request("input/process/add", params = list(inputid = inputid,
                                                      processid = processid,
                                                      arg = arg,
                                                      newfeedname = newfeedname))
}

#' Delete input process
#'
#' Remove a processing step from an input.
#'
#' @param inputid ID of feed to modify.
#' @param processid ID of the processing step to remove
#' @return An httr response object
#' @export
delete_input_process <- function(inputid, processid) {
  send_emon_request("input/process/reset", params = list(inputid = inputid,
                                                         processid = processid))
}

#' Move input process
#'
#' Moves the rank order of a given feed's process step
#'
#' @param inputid Input ID to modify the process list.
#' @param processid Which process to modify.
#' @param moveby How many slots forward or backward to move the process.
#' @return An httr response object
#' @export
move_input_process <- function(inputid, processid, moveby) {
  send_emon_request("input/process/move", params = list(inputid = inputid,
                                                         processid = processid,
                                                         moveby = moveby))
}

#' Reset input processes
#'
#' Removes all processing steps associated with an input
#'
#' @param inputid Input ID to reset.
#' @return An httr response object
#' @export
reset_input_processes <- function(inputid) {
  send_emon_request("input/process/reset", params = list(inputid = inputid))
}
