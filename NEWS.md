# REDCapCAST 23.3.1

### New name: REDCapCAST

To reflect new functions and the limitation to only working in R, I have changed the naming of the fork, while still, of course, maintaining the status as a fork.

The versioning has moved to a monthly naming convention.

### Functions:

* `read_redcap_tables()` **NEW**: this function is mainly an implementation of the combined use of `REDCapR::readcap_read()` and `REDCap_split()` to maintain the focused nature of `REDCapR::readcap_read()`, to only download the specified data. Also implements tests of valid form names and event names. The usual fall-back solution was to get all data.

* `redcap_wider()` **NEW**: this function pivots the long data frames from `read_redcap_tables()` using `tidyr::pivot_wider()`.

* `focused_metadata()` **NEW**: a hidden helper function to enable a focused data acquisition approach to handle only a subset of metadata corresponding to the focused dataset.
