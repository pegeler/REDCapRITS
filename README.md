<!-- badges: start -->
[![GitHub R package version](https://img.shields.io/github/r-package/v/agdamsbo/REDCapCAST)](https://github.com/agdamsbo/REDCapCAST)
[![CRAN/METACRAN](https://img.shields.io/cran/v/REDCapCAST)](https://CRAN.R-project.org/package=REDCapCAST)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8013985.svg)](https://doi.org/10.5281/zenodo.8013985)
[![R-CMD-check](https://github.com/agdamsbo/REDCapCAST/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/agdamsbo/REDCapCAST/actions/workflows/R-CMD-check.yaml)
[![Page deployed](https://github.com/agdamsbo/REDCapCAST/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/agdamsbo/REDCapCAST/actions/workflows/pages/pages-build-deployment)
[![Codecov test coverage](https://codecov.io/gh/agdamsbo/REDCapCAST/branch/master/graph/badge.svg)](https://app.codecov.io/gh/agdamsbo/REDCapCAST?branch=master)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)
<!-- badges: end -->

# REDCapCAST package <img src="man/figures/logo.png" align="right" />

REDCap Castellated data handling when using repeated instruments.

This package is a fork of [SpectrumHealthResearch/REDCapRITS](https://github.com/SpectrumHealthResearch/REDCapRITS). The REDCapRITS represents great and extensive work to handle castellated REDCap data in different programming languages. This fork is purely minded on R usage and includes a few implementations of the main `REDCap_split` function.

The main goal for this project was to allow for a "minimal data" approach by allowing to filter records, instruments and variables in the export to only download data needed. I think this approach is desireable for handling sensitive, clinical data. No similar functionality is available from similar tools (like `REDCapR` or `REDCapTidieR`). Please refer to [REDCap-Tools](https://redcap-tools.github.io/) for other great tools.

## Use and immprovements

This package is primarily relevant for working with longitudinal projects and/or projects using repeated instruments. Here is just a short descirption of the main functions:

* `REDcap_split()`: Works largely as the original `REDCapRITS::REDCap_split()`. It takes a REDCap dataset and metadata (data dictionary) to split the data set into a list of dataframes of instruments.

* `read_redcap_tables()`: wraps the use of [`REDCapR::redcap_read()`](https://github.com/OuhscBbmc/REDCapR) with `REDCap_split()` to ease the export of REDCap data.

* `redcap_wider()`: pivots each data frame with repeated instruments to a wide format utilizing the [`tidyr::pivot_wider()`](https://tidyr.tidyverse.org/reference/pivot_wider.html) from the [tidyverse](https://www.tidyverse.org/).

Compared to the original `REDCapRITS`, all matching functions are improved to accept column naming of REDCap data from manual download or API export.

## Future

The plan with this package is to be bundled with a Handbook on working with REDCap from R. I plan to also include functionality to assist in casting (yes, pun intended) the initial REDCap database.

## Installation

Install the latest version directly from GitHub:

```
remotes::install_github("agdamsbo/REDCapCAST")
```

