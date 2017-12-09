#' Functions for interacting with the emonCMS inputs.

#' List all available inputs and their most recent values.
#'
#' @return A tibble of feeds and their current values
#' @importFrom dplyr %>%
#' @importFrom jsonlite fromJSON
#' @importFrom tibble as_tibble
#' @export
list_inputs <- function() {
  send_emon_request("input/list.json") %>%
    jsonlite::fromJSON() %>% tibble::as_tibble()
}

#' Set a field on an input
#'
#' @param inputid ID of the input to delete
#' @param field Name of field to modify
#' @param value New value of the field
#' @importFrom dplyr %>%
#' @importFrom jsonlite fromJSON
#' @importFrom tibble as_tibble
#' @return Tibble with succes, message columns
#' @export
set_input_field <- function(inputid, field, value) {
  params_list <- list("inputid" = inputid,
                      fields = jsonlite::toJSON(purrr::set_names(list(value),
                                                                 field),
                                                auto_unbox = TRUE))
  send_emon_request("input/set.json", params = params_list) %>%
    jsonlite::fromJSON() %>% tibble::as_tibble()
}

#' Delete an input by id
#'
#' @param inputid ID of the input to delete
#' @importFrom dplyr %>%
#' @importFrom jsonlite fromJSON
#' @return Boolean success/failure
#' @export
delete_input <- function(inputid) {
  resp <- send_emon_request("input/delete.json", params = list("inputid" = inputid)) %>%
    jsonlite::fromJSON()
  if (is.null(resp)) {
    TRUE
  } else {
    resp
  }
}

#' Post data to an input
#'
#' @param values List of name/value data pairs to post
#' @param nodeid Node name to post
#' @return Success/failure as a boolean
#' @export
post_data_to_input <- function(values, nodeid = "emoncmsr") {

  # emonCMS.ORG implementation
  # list_params <- vector(mode = "list", length = 1)
  # names(list_params) <- nodeid
  # list_params[[nodeid]] <- value

  list_params <- list(node = nodeid)
  list_params <- c(list_params, list(fulljson = jsonlite::toJSON(values, auto_unbox = TRUE)))

  send_emon_request("input/post.json", params = list_params)
}

#' Post bulk data to an input
#'
#' @param data Dataframe of offset, nodeid, values to post to the input.
#' @param reference_time A reference UNIX timestamp to which all offsets are
#'     added/subtracted for each data point. Defaults to the current time.
#' @return Success/failure as a boolean
#' @importFrom dplyr %>%
#' @importFrom jsonlite toJSON
#' @export
post_bulk_data_to_input <- function(data,
                                    reference_time = as.integer(Sys.time())) {
  bulk_data <- dplyr::select(data, c(offset, nodeid, value)) %>%
    jsonlite::toJSON(dataframe = "values", auto_unbox = TRUE)
  send_emon_request("input/bulk.json", params = list(time = reference_time),
                    post_body = list(data = bulk_data),
                    method = "POST")
}
#' Get input processes
#'
#' Get all of the processes associated with a given input.
#'
#' @param inputid Input ID to get process list.
#' @return A tibble with success/failure and any additional messages
#' @importFrom dplyr %>%
#' @importFrom jsonlite fromJSON
#' @export
get_input_processes <- function(inputid) {
  # emoncms.org only
  #send_emon_request("input/process/list.json", params = list(inputid = inputid))

  send_emon_request("input/process/get.json", params = list(inputid = inputid)) %>%
    jsonlite::fromJSON()
}

#' Set input process
#'
#' Set the entire processing chain for an input. This appears to be the counter-
#' part to the `process/add` call from EmonCMS.ORG
#'
#' @param inputid Input ID to modify
#' @param processlist Full process list
#' @return A tibble with success/message columns
#' @importFrom dplyr %>%
#' @importFrom jsonlite fromJSON
#' @importFrom tibble as_tibble
#' @export
set_input_process <- function(inputid, processlist) {
  send_emon_request("input/process/set.json",
                    params = list(inputid = inputid),
                    post_body = list(processlist = processlist),
                    method = "POST") %>%
    jsonlite::fromJSON() %>% tibble::as_tibble()

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
#' @return A tibble with success/message columns
#' @importFrom dplyr %>%
#' @importFrom tibble as_tibble
#' @importFrom jsonlite fromJSON
#' @export
reset_input_processes <- function(inputid) {
  send_emon_request("input/process/reset.json",
                    params = list(inputid = inputid)) %>%
    jsonlite::fromJSON() %>% tibble::as_tibble()
}
