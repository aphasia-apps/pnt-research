PNT-CAT: \[research version\] A free, open-source web-app for
administering the computer adative Philadelphia Naming Test
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

The app can be installed locally via `remotes::install_github()`

*Note: It’s likely that installing the package will prompt you to update
packages on your local machine. This may be necessary if you have much
older versions of some packages installed (e.g. the {bslib} package).
The number of packages to update is large, as the current app uses quite
a few {tidyverse} apps which have a number of dependencies. Please raise
an issue in github if there are any issues downloading.*

First, download the package:

``` r
install.packages("remotes")
remotes::install_github("aphasia-apps/pnt.research")
```

Then, run the app using the built in function

``` r
library(pnt.research)
pnt.research::run_app()
```

By running the app locally, there are no issues with app-timeout or
server costs or maintenance.
