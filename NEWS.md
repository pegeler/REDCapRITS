# REDCapCAST 23.6.1

### Documentation:

* Updated description.
* Look! A hex icon!
* Heading for CRAN.

# REDCapCAST 23.4.1

### Documentation:

* Aiming for CRAN

# REDCapCAST 23.3.2

### Documentation:

* Page added. Vignettes to follow.

* GithubActions tests added and code coverage assessed. Badge galore..

# REDCapCAST 23.3.1

### New name: REDCapCAST

To reflect new functions and the limitation to only working in R, I have changed the naming of the fork, while still, of course, maintaining the status as a fork.

The versioning has moved to a monthly naming convention.

The main goal this package is to keep the option to only export a defined subset of the whole dataset from the REDCap server as is made possible through the `REDCapR::redcap_read()` function, and combine it with the work put into the REDCapRITS package and the handling of longitudinal projects and/or projects with repeated instruments.

### Functions:

* `read_redcap_tables()` **NEW**: this function is mainly an implementation of the combined use of `REDCapR::readcap_read()` and `REDCap_split()` to maintain the focused nature of `REDCapR::readcap_read()`, to only download the specified data. Also implements tests of valid form names and event names. The usual fall-back solution was to get all data.

* `redcap_wider()` **NEW**: this function pivots the long data frames from `read_redcap_tables()` using `tidyr::pivot_wider()`.

* `focused_metadata()` **NEW**: a hidden helper function to enable a focused data acquisition approach to handle only a subset of metadata corresponding to the focused dataset.

### Notes:

* metadata handling **IMPROVED**: improved handling of different column names in matadata (DataDictionary) from REDCap dependent on whether it is acquired thorugh the api og downloaded from the server. 
