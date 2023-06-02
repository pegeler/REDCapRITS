## Test environments
- R-hub windows-x86_64-devel (r-devel)
- R-hub ubuntu-gcc-release (r-release)
- R-hub fedora-clang-devel (r-devel)

## R CMD check results
❯ On windows-x86_64-devel (r-devel)
  checking CRAN incoming feasibility ... [17s] NOTE
  Maintainer: 'Andreas Gammelgaard Damsbo <agdamsbo@clin.au.dk>'
  
  New submission
  
  Possibly misspelled words in DESCRIPTION:
    Egeler (8:45)
    REDCap (2:8, 10:39, 11:30, 14:5)
    REDCapRITS (8:26)
    interoperability (19:44)

❯ On windows-x86_64-devel (r-devel)
  checking for non-standard things in the check directory ... NOTE
  Found the following files/directories:

❯ On windows-x86_64-devel (r-devel)
  checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'

❯ On ubuntu-gcc-release (r-release)
  checking CRAN incoming feasibility ... [6s/24s] NOTE
  Maintainer: ‘Andreas Gammelgaard Damsbo <agdamsbo@clin.au.dk>’
  
  New submission
  
  Possibly misspelled words in DESCRIPTION:
    Egeler (8:45)
    REDCap (2:8, 10:39, 11:30, 14:5)
    REDCapRITS (8:26)

❯ On ubuntu-gcc-release (r-release), fedora-clang-devel (r-devel)
  checking HTML version of manual ... NOTE
  Skipping checking HTML validation: no command 'tidy' found

❯ On fedora-clang-devel (r-devel)
  checking CRAN incoming feasibility ... [7s/21s] NOTE
  Maintainer: ‘Andreas Gammelgaard Damsbo <agdamsbo@clin.au.dk>’
  
  New submission
  
  Possibly misspelled words in DESCRIPTION:
    Egeler (8:45)
    REDCap (2:8, 10:39, 11:30, 14:5)
    REDCapRITS (8:26)

0 errors ✔ | 0 warnings ✔ | 6 notes ✖
