<!-- badges: start -->
[![GitHub R package version](https://img.shields.io/github/r-package/v/agdamsbo/REDCapCAST)](https://github.com/agdamsbo/REDCapCAST)
[![CRAN/METACRAN](https://img.shields.io/cran/v/REDCapCAST)](https://CRAN.R-project.org/package=REDCapCAST)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8013984.svg)](https://doi.org/10.5281/zenodo.8013984)
[![R-CMD-check](https://github.com/agdamsbo/REDCapCAST/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/agdamsbo/REDCapCAST/actions/workflows/R-CMD-check.yaml)
[![Page deployed](https://github.com/agdamsbo/REDCapCAST/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/agdamsbo/REDCapCAST/actions/workflows/pages/pages-build-deployment)
[![Codecov test coverage](https://codecov.io/gh/agdamsbo/REDCapCAST/branch/master/graph/badge.svg)](https://app.codecov.io/gh/agdamsbo/REDCapCAST?branch=master)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/REDCapCAST)](https://cran.r-project.org/package=REDCapCAST)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)
<!-- badges: end -->

# REDCapCAST package <img src="man/figures/logo.png" align="right" />

REDCap database casting and handling of castellated data when using repeated instruments and longitudinal projects.

This package is a fork of [pegeler/REDCapRITS](https://github.com/pegeler/REDCapRITS). The REDCapRITS represents great and extensive work to handle castellated REDCap data in different programming languages. This fork is purely minded on R usage and includes a few implementations of the main `REDCap_split` function.

I started working on this project as the castellated longitudinal data set was a little challenging. Later, I have come to learn of the [`redcapAPI`](https://github.com/vubiostat/redcapAPI) package, which would also cover this functionality. I find the `redcapAPI`package quite advanced and a little difficult to work with. This have led to the continued work on this package, as an easy-to-use approach for data migration, data base creation and data handling. This package is very much to be seen as an attempt at a R-to-REDCap-to-R foundry for handling both the transition from dataset/variable list to database and the other way, from REDCap database to a tidy dataset. The goal was also to allow for a "minimal data" approach by allowing to filter records, instruments and variables in the export to only download data needed. I think this approach is desirable for handling sensitive, clinical data. Please refer to [REDCap-Tools](https://redcap-tools.github.io/) for other great tools for working with REDCap in R.

For any more advanced uses, consider using the `redcapAPI` package.

## Use and immprovements

Here is just a short description of the main functions:

* `REDcap_split()`: Works largely as the original `REDCapRITS::REDCap_split()`. It takes a REDCap dataset and metadata (data dictionary) to split the data set into a list of dataframes of instruments.

* `read_redcap_tables()`: wraps the use of [`REDCapR::redcap_read()`](https://github.com/OuhscBbmc/REDCapR) with `REDCap_split()` to ease the export of REDCap data. Default output is a list of data frames with one data frame for each REDCap instrument.

* `redcap_wider()`: joins and pivots a list of data frames with repeated instruments to a wide format utilizing the [`tidyr::pivot_wider()`](https://tidyr.tidyverse.org/reference/pivot_wider.html) from the [tidyverse](https://www.tidyverse.org/).

* `easy_redcap()`: combines secure API key storage with the `keyring`-package, focused data retrieval and optional widening. This is the recommended approach for easy data access and analysis.

* `ds2dd_detailed()`: Converts a data set to a data dictionary for upload to a new REDCap database. Variables (fields) and instruments in a REDCap data base are defined by this data dictionary.

* `shiny_cast()`: [Shiny](https://www.rstudio.com/products/shiny/) application to ease the process of converting a spreadsheet/data set to a REDCap database. The app runs locally and data is transferred securely. You can just create and upload the data dictionary, but you can also transfer the given data in the same process. The app is [hosted on shinyapps.io](https://agdamsbo.shinyapps.io/redcapcast/) while I work on a [shinylive](https://posit-dev.github.io/r-shinylive/) implementation.

## Future

The plan with this package is to be bundled with a Handbook on working with REDCap from R. This work is in progress but is limited by the time available. Please feel free to contact me or create and issue with ideas for future additions.

## Installation

The package is available on CRAN. Install the latest version:

```
install.packages("REDCapCAST")
```

Install the latest version directly from GitHub:

```
remotes::install_github("agdamsbo/REDCapCAST")
```

## Code of Conduct

Please note that the REDCapCAST project is released with a [Contributor Code of Conduct](https://agdamsbo.github.io/REDCapCAST/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.
