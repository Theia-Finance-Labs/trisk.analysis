# Package index

## Run TRISK

Entry points that execute the TRISK model — on raw inputs, on a
portfolio, or across a grid of parameter sets for sensitivity analysis.

- [`run_trisk_model`](run_trisk_model.md) : run_trisk_model
- [`run_trisk_on_portfolio()`](run_trisk_on_portfolio.md) : Run TRISK
  Model on Portfolio (technology-resolved)
- [`run_trisk_on_simple_portfolio()`](run_trisk_on_simple_portfolio.md)
  : Run TRISK Model on Simple Portfolio
- [`run_trisk_sa()`](run_trisk_sa.md) : Run TRISK sensitivity analysis
  on multiple scenarios
- [`run_trisk_agg()`](run_trisk_agg.md) : Run TRISK Model with
  Aggregated Results
- [`run_trisk_from_db()`](run_trisk_from_db.md) : Fetch Data from
  PostgreSQL and Run Transition Risk Aggregation

## Inputs and parameters

Scaffold a local input folder, download bundled inputs, list available
scenario parameters, and match companies.

- [`setup_trisk_inputs()`](setup_trisk_inputs.md) : Scaffold a local
  TRISK input-data folder
- [`download_trisk_inputs()`](download_trisk_inputs.md) : Download TRISK
  input data files from a specified endpoint
- [`get_available_parameters()`](get_available_parameters.md) : Get the
  possible parameters values for Trisk from the scenario data
- [`fuzzy_match_company_ids()`](fuzzy_match_company_ids.md) : Fuzzy
  Match Company IDs

## Portfolio metrics and checks

Validate a portfolio, join it to TRISK outputs, and compute exposure
metrics.

- [`check_portfolio()`](check_portfolio.md) : Check Portfolio and Match
  Company IDs
- [`check_portfolio_simple()`](check_portfolio_simple.md) : Check Simple
  Portfolio
- [`compute_analysis_metrics()`](compute_analysis_metrics.md) : Compute
  Analysis Metrics
- [`compute_simple_portfolio_metrics()`](compute_simple_portfolio_metrics.md)
  : Compute value-change and expected-loss metrics on exposure shares
- [`add_exposure_share_from_npv()`](add_exposure_share_from_npv.md) :
  Compute exposure shares from baseline NPV
- [`join_trisk_outputs_to_portfolio()`](join_trisk_outputs_to_portfolio.md)
  : Join TRISK Outputs to Portfolio
- [`join_simple_portfolio_to_trisk()`](join_simple_portfolio_to_trisk.md)
  : Join simple portfolio to aggregated TRISK outputs

## Aggregation

Roll up firm-level facts to portfolio and sector aggregates.

- [`aggregate_el_integration()`](aggregate_el_integration.md) :
  Aggregate EL integration results to portfolio level
- [`aggregate_pd_integration()`](aggregate_pd_integration.md) :
  Aggregate PD integration results to EAD-weighted portfolio level
- [`aggregate_simple_portfolio()`](aggregate_simple_portfolio.md) :
  Aggregate simple portfolio input rows
- [`aggregate_simple_portfolio_results()`](aggregate_simple_portfolio_results.md)
  : Aggregate simple portfolio tech details back to input-row shape
- [`aggregate_trajectories_facts()`](aggregate_trajectories_facts.md) :
  Aggregate numerical trajectories columns
- [`aggregate_trisk_outputs_simple()`](aggregate_trisk_outputs_simple.md)
  : Aggregate TRISK outputs for simple portfolio analysis

## PD and EL integration

Recombine TRISK shock PDs with the bank’s internal PDs and translate to
expected loss, and convert PDs between cumulative-lifetime and 12-month
horizons for IFRS-9 staging.

- [`integrate_pd()`](integrate_pd.md) : Integrate TRISK PD shift into an
  internal PD estimate
- [`integrate_el()`](integrate_el.md) : Integrate TRISK EL shift into an
  internal EL estimate
- [`pd_lifetime_to_annual()`](pd_lifetime_to_annual.md) : Convert a
  cumulative lifetime PD to an equivalent annual PD
- [`pd_annual_to_lifetime()`](pd_annual_to_lifetime.md) : Convert an
  annual PD to a cumulative lifetime PD over a horizon

## Plots and KPI tables

Visualisations and summary tables for PD, EL, NPV, and exposure results.

- [`pipeline_trisk_pd_integration_bars()`](pipeline_trisk_pd_integration_bars.md)
  : PD integration bar plot (4-bar grouped)
- [`pipeline_trisk_pd_method_comparison()`](pipeline_trisk_pd_method_comparison.md)
  : PD Integration Method Comparison Plot
- [`pipeline_trisk_pd_waterfall()`](pipeline_trisk_pd_waterfall.md) : PD
  waterfall plot
- [`pipeline_trisk_pd_term_plot()`](pipeline_trisk_pd_term_plot.md) :
  Visualize PD Values by Term and Business Unit
- [`pipeline_trisk_pd_kpi_table()`](pipeline_trisk_pd_kpi_table.md) : PD
  Integration KPI Table
- [`pipeline_trisk_el_adjustment_bars()`](pipeline_trisk_el_adjustment_bars.md)
  : EL Adjustment Bar Plot (horizontal, sign-filled)
- [`pipeline_trisk_el_kpi_table()`](pipeline_trisk_el_kpi_table.md) : EL
  Integration KPI Table
- [`pipeline_trisk_el_sector_breakdown_table()`](pipeline_trisk_el_sector_breakdown_table.md)
  : EL Sector Breakdown Table
- [`pipeline_trisk_expected_loss_plot()`](pipeline_trisk_expected_loss_plot.md)
  : Financial Risk Visualization via Expected Loss and Exposure Plot
- [`pipeline_trisk_exposure_change_plot()`](pipeline_trisk_exposure_change_plot.md)
  : Visualize Exposure and Value Loss Changes
- [`pipeline_trisk_npv_change_plot()`](pipeline_trisk_npv_change_plot.md)
  : Visualize Sector-wise NPV Percentage Changes
- [`plot_multi_trajectories()`](plot_multi_trajectories.md) : Visualize
  Trajectory Risks Over Time by Business Unit and Sector

## Plot styling

Shared theme and palette used across the package plots.

- [`TRISK_PLOT_THEME_FUNC()`](TRISK_PLOT_THEME_FUNC.md) : TRISK plot
  theme
- [`TRISK_HEX_RED`](trisk_palette.md)
  [`TRISK_HEX_GREEN`](trisk_palette.md)
  [`TRISK_HEX_GREY`](trisk_palette.md)
  [`TRISK_HEX_ADJUSTED`](trisk_palette.md)
  [`STATUS_GREEN`](trisk_palette.md) : TRISK plot palette constants
