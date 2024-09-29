
#' Compute Analysis Metrics
#'
#' @description Function computing financial metrics to use for analysis
#' @param analysis_data analysis_data
#'
compute_analysis_metrics <- function(analysis_data) {
  analysis_data <- analysis_data |>
    dplyr::mutate(
      net_present_value_difference = .data$net_present_value_shock - .data$net_present_value_baseline,
      crispy_perc_value_change = .data$net_present_value_difference / .data$net_present_value_baseline,
      crispy_value_loss = .data$crispy_perc_value_change * .data$exposure_value_usd,
      exposure_at_default = .data$exposure_value_usd * .data$loss_given_default,
      # exposure_at_default_baseline = .data$net_present_value_baseline * .data$loss_given_default,
      # exposure_at_default_shock = .data$net_present_value_shock * .data$loss_given_default,

      pd_difference = .data$pd_shock - .data$pd_baseline,

      expected_loss_baseline = - .data$exposure_at_default * .data$pd_baseline,
      expected_loss_shock = - .data$exposure_at_default * .data$pd_shock,
      expected_loss_difference = - .data$exposure_at_default * .data$pd_difference
    )



  return(analysis_data)
}

#' Title
#'
#' TODO FIND CLOSEST COMPANY IF group_cols=NULL
#'
#' @param multi_crispy multi_crispy
#' @param group_cols group_cols
#'
aggregate_facts <- function(multi_crispy, group_cols) {
  multi_crispy <- multi_crispy |>
    dplyr::group_by_at(group_cols) |>
    dplyr::summarise(
      net_present_value_baseline = sum(net_present_value_baseline, na.rm = T),
      net_present_value_shock = sum(net_present_value_shock, na.rm = T),
      pd_baseline = stats::median(pd_baseline, na.rm = T),
      pd_shock = stats::median(pd_shock, na.rm = T),
      exposure_value_usd = sum(.data$exposure_value_usd),
      loss_given_default = stats::median(loss_given_default, na.rm = T),
            .groups = "drop"
    )
  return(multi_crispy)
}




#' Aggregate numerical trajectories columns
#'
#' @param multi_trajectories dataframe of trajectories from 1 or multiple trisk truns
#' @param group_cols group_cols
#'
#' @export
#'
aggregate_trajectories_facts <- function(multi_trajectories, group_cols) {
    multi_trajectories <- multi_trajectories |>
      dplyr::group_by_at(group_cols) |>
      dplyr::summarise(
        production_baseline_scenario = sum(.data$production_baseline_scenario, na.rm = TRUE),
        production_target_scenario = sum(.data$production_target_scenario, na.rm = TRUE),
        production_shock_scenario = sum(.data$production_shock_scenario, na.rm = TRUE),
        price_baseline_scenario= mean(.data$price_baseline_scenario, na.rm = TRUE),
        price_shock_scenario = mean(.data$price_shock_scenario, na.rm = TRUE),
        net_profits_baseline_scenario = sum(.data$net_profits_baseline_scenario, na.rm = TRUE),
        net_profits_shock_scenario = sum(.data$net_profits_shock_scenario, na.rm = TRUE),
        discounted_net_profits_baseline_scenario = sum(.data$discounted_net_profits_baseline_scenario, na.rm = TRUE),
        discounted_net_profits_shock_scenario = sum(.data$discounted_net_profits_shock_scenario, na.rm = TRUE),
        .groups = "drop"
      )
    return(multi_trajectories)
  }
