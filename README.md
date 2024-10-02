  <!-- badges: start -->
  [![R-CMD-check](https://github.com/Theia-Finance-Labs/trisk.utils/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Theia-Finance-Labs/trisk.utils/actions/workflows/R-CMD-check.yaml)
  <!-- badges: end -->

# trisk.analysis


This repository provides analytical tools to explore and interpret Trisk model outputs. 
The TRISK model requires specific input datasets whose requirements are explained in more details in the documentation of the [trisk.model](https://theia-finance-labs.github.io/trisk.model/index.html) package.



- [trisk.analysis](#triskanalysis)
  - [Installation](#installation)
  - [Data Input](#data-input)
  - [Usecases](#usecases)
    - [Sensitivity analysis](#sensitivity-analysis)
    - [Potfolio analysis](#potfolio-analysis)



## Installation

You can install this package directly from GitHub using the `remotes` package in R.

1. Install the `remotes` package if you don't have it:

    ```r
    install.packages("remotes")
    ```

2. Install the package from GitHub:

    ```r
    remotes::install_github("Theia-Finance-Labs/trisk.analysis")
    ```

## Data Input

We provide consolidated scenarios data from publicly available sources. The [Download and run vignette](https://theia-finance-labs.github.io/trisk.analysis/articles/download-data-and-run-trisk.html) showcases how to access this data.

> **Note** Real-world assets and financial data is not provided due to its closed-source nature. It needs to be pre-processed independantly, following the structure of the mock datasets which are part of the download. 

## Usecases

### Potfolio analysis
Example showcased in the [Portfolio analysis vignette]([https://theia-finance-labs.github.io/trisk.analysis/articles/apply-trisk-on-portfolio.html](https://theia-finance-labs.github.io/trisk.analysis/articles/apply-stress-test-on-portfolio.html)

### Sensitivity analysis

Example showcased in the [Sensitivity analysis vignette](https://theia-finance-labs.github.io/trisk.analysis/articles/sensitivity-analysis.html)

