
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
-   Inputs
-   Post to inputs
-   List inputs
-   Delete inputs
-   Feeds
-   List feeds
-   Get range of data from a feed
-   Get storage info for all feeds

Test results
------------

``` r
library(emoncmsr)
library(testthat)

date()
```

    ## [1] "Wed Jun 28 21:07:05 2017"

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
