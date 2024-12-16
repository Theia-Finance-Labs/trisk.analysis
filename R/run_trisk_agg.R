#' Run TRISK Model with Aggregated Results
#'
#' This function performs the transition risk model calculations but returns aggregated results,
#' removing the `country_iso2` column.
#'
#' @param assets_data Data frame containing asset information.
#' @param scenarios_data Data frame containing scenario information.
#' @param financial_data Data frame containing financial information.
#' @param carbon_data Data frame containing carbon price information.
#' @param baseline_scenario String specifying the name of the baseline scenario.
#' @param target_scenario String specifying the name of the shock scenario.
#' @param ... Additional arguments passed to \code{\link[trisk.model]{run_trisk_model}}.
#'
#' @return A list containing aggregated results with `country_iso2` removed:
#'         - `npv_results`: Aggregated NPV results by `company_id`, `sector`, and `technology`.
#'         - `pd_results`: Aggregated PD results by `company_id`, `sector`, and `term`.
#'         - `company_trajectories`: Aggregated company trajectories by `company_id`, `sector`, and `technology`.
#' @export
#'
run_trisk_agg <- function(assets_data,
                          scenarios_data,
                          financial_data,
                          carbon_data,
                          baseline_scenario,
                          target_scenario,
                          ...) {
  # Run the TRISK model
  results <- run_trisk_model(
    assets_data = assets_data,
    scenarios_data = scenarios_data,
    financial_data = financial_data,
    carbon_data = carbon_data,
    baseline_scenario = baseline_scenario,
    target_scenario = target_scenario,
    ...
  )

  # Aggregate NPV results by removing `country_iso2` and summing relevant values, then recreate `net_present_value_difference` and `net_present_value_change`
  npv_agg <- results$npv %>%
    dplyr::select(-.data$country_iso2) %>%
    dplyr::group_by(
      .data$run_id, .data$company_id, .data$asset_id, .data$company_name,
      .data$asset_name, .data$sector, .data$technology
    ) %>%
    dplyr::summarise(
      net_present_value_baseline = sum(.data$net_present_value_baseline, na.rm = TRUE),
      net_present_value_shock = sum(.data$net_present_value_shock, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::mutate(
      net_present_value_difference = .data$net_present_value_shock - .data$net_present_value_baseline,
      net_present_value_change = .data$net_present_value_difference / .data$net_present_value_baseline
    )

  # Aggregate PD results by removing `country_iso2` and averaging where appropriate
  pd_agg <- results$pd

  # Aggregate company trajectories by removing `country_iso2`
  company_trajectories_agg <- results$company_trajectories %>%
    dplyr::select(-.data$country_iso2) %>%
    dplyr::group_by(
      .data$run_id, .data$asset_id, .data$asset_name, .data$company_id, .data$company_name,
      .data$year, .data$sector, .data$technology
    ) %>%
    dplyr::summarise(
      scenario_price_baseline = mean(.data$scenario_price_baseline, na.rm = TRUE),
      price_shock_scenario = mean(.data$price_shock_scenario, na.rm = TRUE),
      production_baseline_scenario = sum(.data$production_baseline_scenario, na.rm = TRUE),
      production_target_scenario = sum(.data$production_target_scenario, na.rm = TRUE),
      production_shock_scenario = sum(.data$production_shock_scenario, na.rm = TRUE),
      production_plan_company_technology = sum(.data$production_plan_company_technology, na.rm = TRUE),
      net_profits_baseline_scenario = sum(.data$net_profits_baseline_scenario, na.rm = TRUE),
      net_profits_shock_scenario = sum(.data$net_profits_shock_scenario, na.rm = TRUE),
      discounted_net_profits_baseline_scenario = sum(.data$discounted_net_profits_baseline_scenario, na.rm = TRUE),
      discounted_net_profits_shock_scenario = sum(.data$discounted_net_profits_shock_scenario, na.rm = TRUE),
      .groups = "drop"
    )

  # Return the aggregated results
  return(
    list(
      npv_results = npv_agg,
      pd_results = pd_agg,
      company_trajectories = company_trajectories_agg
    )
  )
}
