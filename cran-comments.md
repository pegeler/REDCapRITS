For a CRAN submission we recommend that you fix all NOTEs, WARNINGs and ERRORs.
## Test environments
- R-hub windows-x86_64-devel (r-devel)
- R-hub ubuntu-gcc-release (r-release)
- R-hub fedora-clang-devel (r-devel)

## R CMD check results
❯ On windows-x86_64-devel (r-devel)
  checking CRAN incoming feasibility ... [15s] NOTE
  Maintainer: 'Andreas Gammelgaard Damsbo <agdamsbo@clin.au.dk>'
  
  Found the following (possibly) invalid URLs:
    URL: https://github.com/SpectrumHealthResearch/REDCapRITS (moved to https://github.com/pegeler/REDCapRITS)
      From: README.md
      Status: 200
      Message: OK

❯ On windows-x86_64-devel (r-devel)
  checking for non-standard things in the check directory ... NOTE

❯ On windows-x86_64-devel (r-devel)
  checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'

❯ On ubuntu-gcc-release (r-release)
  checking CRAN incoming feasibility ... [8s/35s] NOTE
  Maintainer: ‘Andreas Gammelgaard Damsbo <agdamsbo@clin.au.dk>’
  
  Found the following (possibly) invalid URLs:
    URL: https://github.com/SpectrumHealthResearch/REDCapRITS (moved to https://github.com/pegeler/REDCapRITS)
      From: README.md
      Status: 200
      Message: OK

❯ On ubuntu-gcc-release (r-release), fedora-clang-devel (r-devel)
  checking HTML version of manual ... NOTE
  Skipping checking HTML validation: no command 'tidy' found

❯ On fedora-clang-devel (r-devel)
  checking CRAN incoming feasibility ... [9s/44s] NOTE
  Maintainer: ‘Andreas Gammelgaard Damsbo <agdamsbo@clin.au.dk>’
  
  Found the following (possibly) invalid URLs:
    URL: https://agdamsbo.github.io/REDCapCAST/
      From: DESCRIPTION
      Status: 200
      Message: OK
      CRAN URL not in canonical form
    URL: https://app.codecov.io/gh/agdamsbo/REDCapCAST?branch=master
      From: README.md
      Status: 200
      Message: OK
      CRAN URL not in canonical form
    URL: https://doi.org/10.5281/zenodo.8013984
      From: README.md
      Status: 200
      Message: OK
      CRAN URL not in canonical form
    URL: https://github.com/OuhscBbmc/REDCapR
      From: README.md
      Status: 200
      Message: OK
      CRAN URL not in canonical form
    URL: https://github.com/SpectrumHealthResearch/REDCapRITS (moved to https://github.com/pegeler/REDCapRITS)
      From: README.md
      Status: 200
      Message: OK
      CRAN URL not in canonical form
    URL: https://github.com/agdamsbo/REDCapCAST
      From: DESCRIPTION
            README.md
      Status: 200
      Message: OK
      CRAN URL not in canonical form
    URL: https://github.com/agdamsbo/REDCapCAST/actions/workflows/R-CMD-check.yaml
      From: README.md
      Status: 200
      Message: OK
      CRAN URL not in canonical form
    URL: https://github.com/agdamsbo/REDCapCAST/actions/workflows/pages/pages-build-deployment
      From: README.md
      Status: 200
      Message: OK
      CRAN URL not in canonical form
    URL: https://github.com/agdamsbo/REDCapCAST/issues
      From: DESCRIPTION
      Status: 200
      Message: OK
      CRAN URL not in canonical form
    URL: https://github.com/pegeler/REDCapRITS
      From: DESCRIPTION
      Status: 200
      Message: OK
      CRAN URL not in canonical form
    URL: https://lifecycle.r-lib.org/articles/stages.html
      From: README.md
      Status: 200
      Message: OK
      CRAN URL not in canonical form
    URL: https://redcap-tools.github.io/
      From: README.md
      Status: 200
      Message: OK
      CRAN URL not in canonical form
    URL: https://tidyr.tidyverse.org/reference/pivot_wider.html
      From: README.md
      Status: 200
      Message: OK
      CRAN URL not in canonical form
    URL: https://www.tidyverse.org/
      From: README.md
      Status: 200
      Message: OK
      CRAN URL not in canonical form
    Canonical CRAN.R-project.org URLs use https.
  
  Found the following (possibly) invalid ORCID iD:
    iD: 0000-0002-7559-1154	(from: DESCRIPTION)

0 errors ✔ | 0 warnings ✔ | 6 notes ✖
