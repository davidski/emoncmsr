
`emoncmsr` : Tools to work with the emonCMS API.

-   emonCMS: <https://openenergymonitor.org/>

Installation
------------

``` r
devtools::install_github("davidski/emoncmsr")
```

Usage
-----

-   Set environment variables
    -   EMONCMS\_URI - Full URL (w/final slash) to API endpoint
    -   EMONCMS\_API\_KEY - API key value (read or write) to API

``` r
library(emoncmsr)
library(tidyverse)
```

    ## Loading tidyverse: ggplot2
    ## Loading tidyverse: tibble
    ## Loading tidyverse: tidyr
    ## Loading tidyverse: readr
    ## Loading tidyverse: purrr
    ## Loading tidyverse: dplyr

    ## Conflicts with tidy packages ----------------------------------------------

    ## filter(): dplyr, stats
    ## lag():    dplyr, stats

``` r
# Inputs
list_inputs()
```

    ## # A tibble: 15 x 7
    ##       id  nodeid     name                      description
    ##  * <chr>   <chr>    <chr>                            <chr>
    ##  1     1 emontx1   power1                    House Power 1
    ##  2     2 emontx1   power2                    House Power 2
    ##  3     3 emontx1   power3      Office Branch Circuit Power
    ##  4     5 emontx1     vrms                                 
    ##  5     6 emontx1    temp1                    Basement Temp
    ##  6     7 emontx1    temp2                                 
    ##  7     8 emontx1    temp3                                 
    ##  8     9 emontx1    temp4                                 
    ##  9    10 emontx1    temp5                                 
    ## 10    11 emontx1    temp6                                 
    ## 11    12 emontx1    pulse                                 
    ## 12    13 emontx1     rssi                                 
    ## 13    14 emontx1   power4 Living Room Branch Circuit Power
    ## 14    15 weather     temp                                 
    ## 15    16 weather humidity                                 
    ## # ... with 3 more variables: processList <chr>, time <int>, value <dbl>

``` r
# create some beverage data
dat <- list(coffee = 42, tea = 6, water = 42)
post_data_to_input(dat)
```

    ## [1] TRUE

``` r
list_inputs() %>% filter(nodeid == "emoncmsr", name == "coffee")
```

    ## # A tibble: 1 x 7
    ##      id   nodeid   name description processList       time value
    ##   <chr>    <chr>  <chr>       <chr>       <chr>      <int> <dbl>
    ## 1    44 emoncmsr coffee                         1498848166    42

``` r
# store the id of the new input
inputid <- list_inputs() %>% filter(nodeid == "emoncmsr", name == "coffee") %>% pull(id)
inputid
```

    ## [1] "44"

``` r
# set a friendly description for our new input
set_input_field(inputid, "description", "cups of coffee remaining in pot")
```

    ## # A tibble: 1 x 2
    ##   success       message
    ##     <lgl>         <chr>
    ## 1    TRUE Field updated

``` r
list_inputs() %>% filter(id == inputid)
```

    ## # A tibble: 1 x 7
    ##      id   nodeid   name                     description processList
    ##   <chr>    <chr>  <chr>                           <chr>       <chr>
    ## 1    44 emoncmsr coffee cups of coffee remaining in pot            
    ## # ... with 2 more variables: time <int>, value <dbl>

``` r
# Create feeds for one of our new inputs
feed_response <- create_feed("coffeelevel", "emoncmsr")
feed_response
```

    ## # A tibble: 1 x 3
    ##   success feedid result
    ##     <lgl>  <int>  <lgl>
    ## 1    TRUE     43   TRUE

``` r
list_feeds() %>% filter(id == feed_response$feedid)
```

    ## # A tibble: 1 x 11
    ##      id userid        name datatype      tag public  size engine
    ##   <chr>  <chr>       <chr>    <chr>    <chr>  <chr> <chr>  <chr>
    ## 1    43      1 coffeelevel        1 emoncmsr            0      5
    ## # ... with 3 more variables: processList <chr>, time <int>, value <dbl>

``` r
# Hook up the coffee monitor to the feed
set_input_process(inputid, paste(1, feed_response$feedid, sep = ":"))
```

    ## # A tibble: 1 x 2
    ##   success                   message
    ##     <lgl>                     <chr>
    ## 1    TRUE Input processlist updated

``` r
get_input_processes(inputid)
```

    ## [1] "1:43"

``` r
# Post new data to all three new inputs
dat <- list(coffee = 86, tea = 100, water = 4)
post_data_to_input(dat)
```

    ## [1] TRUE

``` r
# We can also use the bulk data input format for sending a dataframe 
# worth of data, all at differnet offsets to an optional timestamp
dat <- tibble::tribble(~offset, ~nodeid, ~value,
               -100, "emoncmsr", list(coffee = 100),
               -50, "emoncmsr", list(tea = 50),
               -10, "emoncmsr", list(water = 10))
post_bulk_data_to_input(dat)
```

    ## [1] TRUE

``` r
# show the values we just posted appeared in the input
list_inputs() %>% filter(nodeid == "emoncmsr")
```

    ## # A tibble: 3 x 7
    ##      id   nodeid   name                     description processList
    ##   <chr>    <chr>  <chr>                           <chr>       <chr>
    ## 1    44 emoncmsr coffee cups of coffee remaining in pot        1:43
    ## 2    45 emoncmsr    tea                                            
    ## 3    46 emoncmsr  water                                            
    ## # ... with 2 more variables: time <int>, value <dbl>

``` r
# we can also post with a specific reference time
reference_time <- lubridate::as_datetime("2017-03-27 01:30:00") %>% as.integer()
post_bulk_data_to_input(dat, reference_time)
```

    ## [1] TRUE

``` r
# show the logged input made it to our new feed
get_feed_values(feed_response$feedid)
```

    ## # A tibble: 1 x 2
    ##   feed_id value
    ##     <int> <int>
    ## 1      43   100

``` r
# Clean up
list_feeds() %>% filter(tag == "emoncmsr") %>% pull(id) %>% 
                          map(~ delete_feed(.x))
```

    ## [[1]]
    ## # A tibble: 1 x 1
    ##   success
    ##     <lgl>
    ## 1    TRUE

``` r
list_inputs() %>% filter(nodeid == "emoncmsr") %>% pull(id) %>% 
                           map(~ delete_input(.x))
```

    ## [[1]]
    ## [1] TRUE
    ## 
    ## [[2]]
    ## [1] TRUE
    ## 
    ## [[3]]
    ## [1] TRUE

Test results
------------

``` r
library(emoncmsr)
library(testthat)
```

    ## 
    ## Attaching package: 'testthat'

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     matches

    ## The following object is masked from 'package:purrr':
    ## 
    ##     is_null

``` r
date()
```

    ## [1] "Fri Jun 30 11:42:47 2017"

``` r
test_dir("tests/")
```

    ## testthat results ===========================================================
    ## OK: 0 SKIPPED: 0 FAILED: 0
    ## 
    ## DONE ======================================================================

Contributing
============

This project is governed by a [Code of Conduct](./CODE_OF_CONDUCT.md). By participating in this project you agree to abide by these terms.

License
=======

The [MIT License](LICENSE) applies.
