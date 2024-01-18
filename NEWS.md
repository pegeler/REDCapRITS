# REDCapCAST 24.1.2

### Functions

* Fix: `ds2dd()`: uses correct default dd column names. Will be deprecated.

* NEW: `ds2dd_detailed()`: extension of the `ds2dd()`, which serves to preserve as much metadata as possible automatically. Depends on a group of helper functions also introduced. Of special note is the `guess_time_only_filter()`, which will try to guess which columns/variables should be formatted as time only formats. Supports hms time format. DETAILED INSTRUCTION AND VIGNETTE IS PENDING.

### Other

I believe `renv` has now been added and runs correctly. After clone, do `renv::restore()` to install all necessary package to modify the package.

# REDCapCAST 24.1.1

### Functions

* Fix: `read_redcap_tables()`: checking form names based on data dictionary to allow handling of non-longitudinal projects. Prints invalid form names and invalid event names. If invalid form names are supplied to `REDCapR::redcap_read()` (which is the backbone), all forms are exported, which is not what we want with a focused approach. Invalid event names will give an output with a rather peculiar formatting. Checking of field names validity is also added.

# REDCapCAST 23.12.1

One new function to ease secure dataset retrieval and a few bug fixes.

### Functions

* New: `easy_redcap()` function to ease the retrieval of a dataset with `read_redcap_tables()` with `keyring`-package based key storage, which handles secure API set, storage and retrieval. Relies on a small helper function, `get_api_key()`, which wraps relevant `keyring`-functions. Includes option to cast the data in a wide format with flag `widen.data`.
* Fix: `REDCap_split()`: when using this function on its own, supplying a data set with check boxes would fail if metadata is supplied as a tibble. Metadata is now converted to data.frame. Fixed.
* Fix: `read_redcap_tables()`: fixed bug when supplying events.

# REDCapCAST 23.6.2

This version marks the introduction of a few helper functions to handle database creation.

### Functions

* New: `ds2dd()` function migrating from the `stRoke`-package. Assists in building a data dictionary for REDCap from a dataset.

* New: `strsplitx()` function to ease the string splitting as an extension of `base::strsplit()`. Inspiration from https://stackoverflow.com/a/11014253/21019325 and https://www.r-bloggers.com/2018/04/strsplit-but-keeping-the-delimiter/. 

* New: `d2n()` function converts single digits to written numbers. Used to sanitize variable and form names in REDCap database creation. For more universal number to word I would suggest `english::word()` or `xfun::numbers_to_words()`, though I have not been testing these.


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
