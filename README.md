  <!-- badges: start -->
  [![R-CMD-check](https://github.com/Theia-Finance-Labs/trisk.analysis/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Theia-Finance-Labs/trisk.analysis/actions/workflows/R-CMD-check.yaml)
  <!-- badges: end -->

# trisk.analysis


The goal of trisk.analysis is to provide a tool that can be used to conduct what-if climate stress test analyses for financial institutions, supervisors, regulators and other stakeholders. The tool aims at highlighting potential financial risk in especially climate relevant sectors, split by production technology where required.
The core Trisk model source code is available in another package, already included in the installation of this one. Specific documentation and source code related links is available on [trisk.model](https://theia-finance-labs.github.io/trisk.model/index.html) .



- [trisk.analysis](#triskanalysis)
  - [Use the package](#use-the-package)
    - [Installation](#installation)
    - [Reading path](#reading-path)
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

### Reading path

The documentation is a five-step path, each article building on the previous one:

1. **[Getting started](https://theia-finance-labs.github.io/trisk.analysis/articles/getting-started.html)** — install the package and run TRISK on the bundled toy portfolio in a few lines.
2. **[Inputs and outputs](https://theia-finance-labs.github.io/trisk.analysis/articles/inputs-and-outputs.html)** — the 4 input datasets (assets, scenarios, financial_features, ngfs_carbon_prices) and 3 output datasets (npv_results, pd_results, company_trajectories), their column structure, the Trisk parameter definitions, and how to access the bundled scenarios.
3. **[Run on a portfolio](https://theia-finance-labs.github.io/trisk.analysis/articles/run-on-a-portfolio.html)** — match a portfolio to TRISK, compute PD / NPV / expected loss, and visualise the results.
4. **[Sensitivity analysis](https://theia-finance-labs.github.io/trisk.analysis/articles/sensitivity-analysis.html)** — sweep shock year, IAM, and ambition policy, each read through a bank-impact lens.
5. **[PD & EL integration](https://theia-finance-labs.github.io/trisk.analysis/articles/pd-el-integration.html)** — recombine TRISK shock PDs with your internal PDs and translate the result into expected-loss basis points.

> **Note** Application of the code requires availability of custom data for assets and financial data. Those inputs need to be pre-processed independantly, following the structure of the mock datasets presented in the vignettes.

## Analyses

An online version of those analyses is available on our apps portal https://apps.1in1000.com

### Portfolio analysis
A wrapper function called `run_trisk_on_portfolio()` can be used to run Trisk on a subset of the input assets dataframe, based on companies that can be matched between the two. It returns the model's PDs and NPVs alongside the matched exposures; the derived metrics such as expected loss are then computed with `compute_analysis_metrics()` (which the plotting pipelines call for you). Plots to visualize the results are included in the package.
Example showcased in the [Run on a portfolio](https://theia-finance-labs.github.io/trisk.analysis/articles/run-on-a-portfolio.html) vignette.

### Sensitivity analysis
A wrapper function called `run_trisk_sa()` is provided if you'd like to generate a set of Trisk runs with different parameters configurations. The results obtained can be plotted using functions included in the package, or integrated in your analysis pipeline.
Example showcased in the [Sensitivity Analysis](https://theia-finance-labs.github.io/trisk.analysis/articles/sensitivity-analysis.html) vignette.


## Funding

EU LIFE Project Grant

Co-funded by the European Union. Views and opinions expressed are however those of the author(s) only and do not necessarily reflect those of the European Union or CINEA. Neither the European Union nor the granting authority can be held responsible for them.

Scientific Transition Risk Exercises for Stress tests & Scenario Analysis has received funding from the European Union’s Life programme under Grant No. LIFE21-GIC-DE-Stress under the LIFE-2021-SAP-CLIMA funding call.

![](inst/LifeLogo2.jpg)

