#' Functions for interacting with the emonCMS inputs.

#' List all available inputs and their most recent values.
#'
#' @return A tibble of feeds and their current values
#' @importFrom dplyr %>%
#' @export
list_inputs <- function() {
  send_emon_request("input/list.json") %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
}

#' Delete an input by id
#'
#' @param inputid ID of the input to delete
#' @return An httr response object
#' @export
delete_input <- function(inputid) {
  send_emon_request("input/delete.json", params = list("inputid" = inputid))
}

#' Post data to an input
#'
#' @param values List of name/value data pairs to post
#' @param node Node name to post
#' @return An httr response object
#' @export
post_data_to_input <- function(values, nodeid = "emoncmsr") {

  # emonCMS.ORG implementation
  # list_params <- vector(mode = "list", length = 1)
  # names(list_params) <- nodeid
  # list_params[[nodeid]] <- value

  list_params <- list(node = nodeid)
  list_params <- c(list_params, list(fulljson = jsonlite::toJSON(values, auto_unbox = TRUE)))

  send_emon_request("input/post.json", params = list_params) %>%
    httr::content(as = "text", encoding = "UTF-8")
}

#' Post bulk data to an input
#'
#' @param value Data value to post
#' @param nodeid Node ID
#' @param timestamp UNIX timestamp
#' @return An httr response object
#' @export
post_bulk_data_to_input <- function(value, nodeid = "emoncmsr",
                                    timestamp = as.integer(Sys.time())) {
  send_emon_request("input/bulk.json", params = list(time = timestamp),
                    post_body = list(data=jsonlite::toJSON(c(timestamp, "test", value))),
                    method = "POST")
}

#' Get input processes
#'
#' Get all of the processes associated with a given input.
#'
#' @param inputid Input ID to get process list.
#' @return An httr response object
#' @export
get_input_processes <- function(inputid) {
  # emoncms.org only
  #send_emon_request("input/process/list.json", params = list(inputid = inputid))

  send_emon_request("input/process/get.json", params = list(inputid = inputid)) %>%
    httr::content()
}

#' Set input process
#'
#' Set the entire processing chain for an input. This appears to be the counter-
#' part to the `process/add` call from EmonCMS.ORG
#'
#' @param inputid Input ID to modify
#' @param processlist Full process list
#' @return A tibble with success/failure and any additional messages
#' @export
set_input_process <- function(inputid, processlist) {
  send_emon_request("input/process/set.json",
                    params = list(inputid = inputid),
                    post_body = list(processlist = processlist),
                    method = "POST") %>%
    httr::content() %>% tibble::as_tibble()
}


#' Add input process
#'
#' Add a processing step to a given input. The processing step will be
#' placed after any existing process steps.
#'
#' @param inputid Input to add the process step
#' @param processid ID of the processing type to add
#' @param arg Arguments for the processing feed
#' @param newfeedname New feed name
#' @return An httr response object
#' @export
add_input_process <- function(inputid, processid, arg, newfeedname) {
  send_emon_request("input/process/add",
                    params = list(inputid = inputid, processid = processid,
                                  arg = arg, newfeedname = newfeedname))
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
  send_emon_request("input/process/delete",
                    params = list(inputid = inputid, processid = processid))
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
  send_emon_request("input/process/move",
                    params = list(inputid = inputid, processid = processid,
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
  send_emon_request("input/process/reset.json",
                    params = list(inputid = inputid))
}
