  <!-- badges: start -->
  [![R-CMD-check](https://github.com/Theia-Finance-Labs/trisk.utils/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Theia-Finance-Labs/trisk.utils/actions/workflows/R-CMD-check.yaml)
  <!-- badges: end -->

# trisk.analysis


The goal of trisk.analysis is to provide a tool that can be used to conduct what-if climate stress test analyses for financial institutions, supervisors, regulators and other stakeholders. The tool aims at highlighting potential financial risk in especially climate relevant sectors, split by production technology where required.
The core Trisk model source code is available in another package, already included in the installation of this one. Specific documentation and source code related links is available on [trisk.model](https://theia-finance-labs.github.io/trisk.model/index.html) .



- [trisk.analysis](#triskanalysis)
  - [Use the package](#use-the-package)
    - [Installation](#installation)
    - [Data Input](#data-input)
    - [Read Trisk outputs](#read-trisk-outputs)
  - [Analyses](#analyses)
    - [Portfolio analysis](#portfolio-analysis)
    - [Sensitivity analysis](#sensitivity-analysis)
  - [Funding](#funding)


## Use the package

### Installation

You can install this package directly from GitHub using the `pak` package in R.

1. Install the `pak` package if you don't have it:

    ```r
    install.packages("pak")
    ```

2. Install the package from GitHub:

    ```r
    pak::pak("Theia-Finance-Labs/trisk.analysis")
    ```

### Data Input

We provide consolidated scenarios data from publicly available sources. The [Download Input Data](https://theia-finance-labs.github.io/trisk.analysis/articles/download-input-data.html) vignette showcases how to access this data.

> **Note** Application of the code requires availability of custom data for assets and financial data. Those inputs need to be pre-processed independantly, following the structure of the mock datasets which are part of the download. 


### Read Trisk outputs

The [Read Trisk Outputs](https://theia-finance-labs.github.io/trisk.analysis/articles/download-input-data.html) vignette showcases how to run Trisk on the downloaded data, and .

## Analyses

### Portfolio analysis
A wrapper function called `run_trisk_on_portfolio()` can be used to run Trisk on a subset of the input assets dataframe, based on companies that can be matched between the two. Along with PDs and NPVs computed in the model the function also returns the expected loss, computed using the loss given default provided in the input portfolio. Plots to visualize the results are included in the package.
Example showcased in the [Portfolio Analysis](https://theia-finance-labs.github.io/trisk.analysis/articles/portfolio-analysis.html) vignette.

### Sensitivity analysis
A wrapper function called `run_trisk_sa()` is provided if you'd like to generate a set of Trisk runs with different parameters configurations. The results obtained can be plotted using functions included in the package, or used differently in your analysis pipeline.
Example showcased in the [Sensitivity Analysis](https://theia-finance-labs.github.io/trisk.analysis/articles/sensitivity-analysis.html) vignette.


## Funding

EU LIFE Project Grant

Co-funded by the European Union. Views and opinions expressed are however those of the author(s) only and do not necessarily reflect those of the European Union or CINEA. Neither the European Union nor the granting authority can be held responsible for them.

Scientific Transition Risk Exercises for Stress tests & Scenario Analysis has received funding from the European Union’s Life programme under Grant No. LIFE21-GIC-DE-Stress under the LIFE-2021-SAP-CLIMA funding call.

![](data-raw/LifeLogo2.jpg)

