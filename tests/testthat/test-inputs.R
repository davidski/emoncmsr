library(emoncmsr)

context("Inputs")
test_that("Feed inputs processed correctly", {
  dat_path <-  rprojroot::is_testthat$find_file("input_list.Rds")
  m <- mockery::mock(readRDS(dat_path))

   with_mock(send_emon_request = m,
    dat <- list_inputs(),
    expect_equal(nrow(dat), 28)
    )
})
