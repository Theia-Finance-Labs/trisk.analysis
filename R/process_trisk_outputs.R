
#' Title
#'
#' @param portfolio_data portfolio_data
#' @param multi_crispy_data multi_crispy_data
#' @param portfolio_crispy_merge_cols portfolio_crispy_merge_cols
#'
make_analysis_data <-
  function(portfolio_data,
           npv_results,
           pd_results) {
    # If no portfolio is provided, fill the merging columns
    # with the ones available in crispy, in order to get a full crispy output
    if (nrow(portfolio_data) == 0) {
      merge_cols_values <- multi_crispy_data |>
        dplyr::distinct_at(portfolio_crispy_merge_cols)
      portfolio_data <- dplyr::full_join(portfolio_data, merge_cols_values)
    }

    analysis_data <-
      dplyr::inner_join(
        portfolio_data,
        multi_crispy_data,
        by = portfolio_crispy_merge_cols,
        relationship = "many-to-many"
      )

    facts <- c(
      "net_present_value_baseline",  "net_present_value_shock", "pd_baseline", "pd_shock",
      "exposure_value_usd", "loss_given_default", "pd_portfolio")


    stopifnot(all(facts %in% names(analysis_data))) 

    return(analysis_data)

  }


#' Title
#'
#' TODO FIND CLOSEST COMPANY IF group_cols=NULL
#'
#' @param multi_crispy multi_crispy
#' @param group_cols group_cols
#'
aggregate_crispy_facts <- function(multi_crispy, group_cols) {
  multi_crispy <- multi_crispy |>
    dplyr::group_by_at(group_cols) |>
    dplyr::summarise(
      # trisk columns
      net_present_value_baseline = sum(net_present_value_baseline, na.rm = T),
      net_present_value_shock = sum(net_present_value_shock, na.rm = T),
      pd_baseline = stats::median(pd_baseline, na.rm = T),
      pd_shock = stats::median(pd_shock, na.rm = T),
      # portfolio columns
      exposure_value_usd = sum(.data$exposure_value_usd),
      loss_given_default = stats::median(loss_given_default, na.rm = T),
      pd_portfolio = stats::median(.data$pd_portfolio, na.rm = T),
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

