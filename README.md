
`emoncmsr` : Tools to work with the emonCMS API.

-   emonCMS: <https://openenergymonitor.org/>

Installation
------------

``` r
devtools::install_github("davidski/emoncmsr")
```

Usage
-----

Test results
------------

``` r
library(emoncmsr)
library(testthat)

date()
```

    ## [1] "Mon Jun 26 20:27:22 2017"

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
